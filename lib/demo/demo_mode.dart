import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Demo mode: the whole app runs on bundled JSON instead of the live backend.
///
///   flutter build ios --simulator --dart-define=DEMO=true
///
/// Used for the portfolio's embedded simulator. Every HTTP call made through
/// `package:http` is answered by [DemoClient]; the chat WebSocket is faked by
/// [DemoSocket]. Writes (bookings, ratings, messages…) live in memory for the
/// session. Fixtures: assets/demo/demo_data.json.
const bool kDemoMode = bool.fromEnvironment('DEMO');

class DemoStore {
  DemoStore._(this._raw);
  static DemoStore? _instance;
  static DemoStore get instance => _instance!;

  final Map<String, dynamic> _raw;
  late final Map<String, dynamic> user;
  late final Map<int, Map<String, dynamic>> people;
  late final List<Map<String, dynamic>> dinners;
  late final List<Map<String, dynamic>> pastDinners;
  late final List<Map<String, dynamic>> bookings;
  late final Map<int, List<int>> attendees;
  late final Set<int> connected;
  late final Set<int> requestSent;
  late final List<Map<String, dynamic>> pendingReceived;
  late final List<Map<String, dynamic>> chats;
  late final List<String> chatReplies;
  late final List<Map<String, dynamic>> notifications;
  int _nextId = 10000;
  int get nextId => _nextId++;

  int get userId => user['id'] as int;

  /// Load fixtures and sign the demo user in (writes the same keys the real
  /// auth flow stores, so the app opens straight to the home screen).
  static Future<void> init() async {
    final raw = jsonDecode(await rootBundle.loadString('assets/demo/demo_data.json')) as Map<String, dynamic>;
    final store = DemoStore._(_resolveDates(raw) as Map<String, dynamic>);
    store._hydrate();
    _instance = store;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', 'demo-token');
    await prefs.setString('user_id', store.userId.toString());
    await prefs.setString('user_data', jsonEncode(store.user));
  }

  void _hydrate() {
    List<Map<String, dynamic>> list(String k) => (_raw[k] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    user = Map<String, dynamic>.from(_raw['user'] as Map);
    people = (_raw['people'] as Map).map((k, v) => MapEntry(int.parse(k as String), {'id': int.parse(k), ...Map<String, dynamic>.from(v as Map)}));
    dinners = list('dinners');
    pastDinners = list('past_dinners');
    bookings = list('bookings');
    attendees = (_raw['attendees'] as Map).map((k, v) => MapEntry(int.parse(k as String), (v as List).cast<int>().toList()));
    final c = _raw['connections'] as Map;
    connected = (c['connected'] as List).cast<int>().toSet();
    requestSent = (c['request_sent'] as List).cast<int>().toSet();
    pendingReceived = (c['pending_received'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    chatReplies = (_raw['chat_replies'] as List).cast<String>();
    notifications = list('notifications')
        .map((n) => {'user_id': userId, 'dinner_id': null, 'booking_id': null, 'connection_id': null, 'read_at': null, ...n})
        .toList();

    // Expand chat fixtures into Chat/Message JSON.
    chats = list('chats').map((c) {
      final chatId = c['id'] as int;
      var msgId = chatId * 100;
      final messages = (c['messages'] as List).map((m) {
        final from = m['from'] as int;
        return _message(chatId, from, m['text'] as String, m['at'] as String, id: msgId++, isRead: true);
      }).toList();
      final unread = c['unread'] as int? ?? 0;
      for (var i = 0; i < unread && i < messages.length; i++) {
        messages[messages.length - 1 - i]['is_read'] = false;
      }
      return {
        'id': chatId,
        'other_user_id': c['other_user'],
        'dinner_id': c['dinner_id'],
        'created_at': c['created_at'],
        'is_active': true,
        'messages': messages,
      };
    }).toList();
  }

  // ───────────── Shapes ─────────────

  Map<String, dynamic> person(int id) {
    if (id == userId) return {'id': id, 'display_name': user['display_name'], 'profile_picture_url': user['profile_picture_url']};
    return Map<String, dynamic>.from(people[id] ?? {'id': id, 'display_name': 'Guest', 'profile_picture_url': null});
  }

  Map<String, dynamic> _message(int chatId, int from, String text, String at, {required int id, bool isRead = false}) => {
        'id': id,
        'chat_id': chatId,
        'sender_id': from,
        'content': text,
        'message_type': 'text',
        'sent_at': at,
        'is_read': isRead || from == userId,
        'sender_name': person(from)['display_name'],
        'sender_profile_picture': person(from)['profile_picture_url'],
      };

  Map<String, dynamic> newMessage(int chatId, int from, String text) =>
      _message(chatId, from, text, DateTime.now().toIso8601String(), id: nextId);

  Map<String, dynamic> chatJson(Map<String, dynamic> c, {bool withMessages = false, int limit = 50, int offset = 0}) {
    final messages = (c['messages'] as List).cast<Map<String, dynamic>>();
    final last = messages.isEmpty ? null : messages.last;
    final unread = messages.where((m) => m['is_read'] == false && m['sender_id'] != userId).length;
    final json = {
      'id': c['id'],
      'created_at': c['created_at'],
      'updated_at': last?['sent_at'] ?? c['created_at'],
      'is_active': c['is_active'],
      'dinner_id': c['dinner_id'],
      'other_user': person(c['other_user_id'] as int),
      'last_message': last,
      'unread_count': unread,
    };
    if (withMessages) {
      // Newest `limit` messages, paged backwards by `offset` (the app sorts by sent_at).
      final end = max(0, messages.length - offset);
      final start = max(0, end - limit);
      json['messages'] = messages.sublist(start, end);
    }
    return json;
  }

  Map<String, dynamic>? dinnerById(int id) {
    for (final d in [...dinners, ...pastDinners]) {
      if (d['id'] == id) return d;
    }
    return null;
  }

  Map<String, dynamic> dinnerJson(Map<String, dynamic> d) {
    final max = d['max_attendees'] as int? ?? 6;
    final current = d['current_attendees'] as int? ?? (attendees[d['id']]?.length ?? 0);
    return {
      'description': null,
      'latitude': null,
      'longitude': null,
      ...d,
      'max_attendees': max,
      'current_attendees': current,
      'available_spots': max - current,
      'is_full': current >= max,
      'is_active': true,
      'created_at': d['date'],
      'updated_at': d['date'],
    };
  }

  Map<String, dynamic> attendeeJson(int id) => {
        ...person(id),
        'email': '${(person(id)['display_name'] as String).toLowerCase()}@example.com',
        'industry': people[id]?['industry'],
        'connection_request_sent': requestSent.contains(id),
        'already_connected': connected.contains(id),
      };

  /// Bookings for dinners that have already happened, most recent first.
  List<Map<String, dynamic>> pastBookings() {
    final now = DateTime.now();
    final past = bookings.where((b) {
      final d = dinnerById(b['dinner_id'] as int);
      return d != null && DateTime.parse(d['date'] as String).isBefore(now) && b['status'] != 'cancelled';
    }).toList()
      ..sort((a, b) => (dinnerById(b['dinner_id'] as int)!['date'] as String).compareTo(dinnerById(a['dinner_id'] as int)!['date'] as String));
    return past;
  }

  void notify(String type, String title, String message, {int? dinnerId, int? bookingId}) {
    notifications.insert(0, {
      'id': nextId,
      'user_id': userId,
      'type': type,
      'title': title,
      'message': message,
      'is_read': false,
      'created_at': DateTime.now().toIso8601String(),
      'read_at': null,
      'dinner_id': dinnerId,
      'booking_id': bookingId,
      'connection_id': null,
    });
  }

  // ───────────── Relative dates ─────────────

  static final _rel = RegExp(r'^@([+-])(\d+)([dhm])(?: (\d{1,2}):(\d{2}))?$');

  /// "@+4d 19:30" → local ISO datetime 4 days from now at 19:30; "@-3h" → 3 hours ago.
  static dynamic _resolveDates(dynamic v) {
    if (v is Map) return <String, dynamic>{for (final e in v.entries) e.key as String: _resolveDates(e.value)};
    if (v is List) return v.map(_resolveDates).toList();
    if (v is String) {
      final m = _rel.firstMatch(v);
      if (m == null) return v;
      final sign = m.group(1) == '-' ? -1 : 1;
      final n = int.parse(m.group(2)!) * sign;
      final now = DateTime.now();
      var t = switch (m.group(3)) {
        'd' => now.add(Duration(days: n)),
        'h' => now.add(Duration(hours: n)),
        _ => now.add(Duration(minutes: n)),
      };
      if (m.group(4) != null) {
        t = DateTime(t.year, t.month, t.day, int.parse(m.group(4)!), int.parse(m.group(5)!));
      }
      return t.toIso8601String();
    }
    return v;
  }
}

/// Answers the app's REST calls from [DemoStore].
class DemoClient extends http.BaseClient {
  DemoStore get s => DemoStore.instance;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // A little latency so loading states still feel natural.
    await Future.delayed(const Duration(milliseconds: 180));
    final body = request is http.Request && request.body.isNotEmpty ? _tryDecode(request.body) : null;
    final path = request.url.path.replaceFirst(RegExp(r'^/api'), '').replaceAll(RegExp(r'/+$'), '');
    final q = request.url.queryParameters;
    final (status, payload) = _route(request.method, path.isEmpty ? '/' : path, q, body);
    // ignore: avoid_print
    print('[demo] ${request.method} ${request.url.path} → $status');
    final bytes = utf8.encode(jsonEncode(payload));
    return http.StreamedResponse(Stream.value(bytes), status,
        contentLength: bytes.length, request: request, headers: {'content-type': 'application/json; charset=utf-8'});
  }

  static dynamic _tryDecode(String s) {
    try {
      return jsonDecode(s);
    } catch (_) {
      return null;
    }
  }

  (int, Object?) _route(String method, String path, Map<String, String> q, dynamic body) {
    final seg = path.split('/').where((p) => p.isNotEmpty).toList();
    int? idAt(int i) => seg.length > i ? int.tryParse(seg[i]) : null;
    final ok = {'message': 'ok', 'success': true};

    switch (seg.isEmpty ? '' : seg[0]) {
      // ── Auth & profile ──
      case 'auth':
        final sub = seg.length > 1 ? seg.sublist(1).join('/') : '';
        switch (sub) {
          case 'profile':
          case 'preferences':
            if (method == 'PUT' && body is Map) s.user.addAll(Map<String, dynamic>.from(body));
            return (200, s.user);
          case 'subscription/status':
            return (200, {
              for (final k in ['is_subscribed', 'is_subscription_active', 'subscription_start', 'subscription_end', 'subscription_type', 'subscription_plan_id', 'days_until_subscription_expires']) k: s.user[k],
            });
          case 'subscription':
          case 'subscription/activate':
            s.user['is_subscribed'] = true;
            s.user['is_subscription_active'] = true;
            return (200, sub == 'subscription' ? s.user : {'message': 'Subscription activated (demo)', 'user': s.user});
          case 'subscription/cancel':
            return (200, {'message': 'Demo mode: your subscription is unchanged.'});
          case 'check-user-exists':
            return (200, {'exists': true});
          case 'upload-profile-photo':
            return (200, {'message': 'Demo mode: photo not uploaded', 'profile_picture_url': s.user['profile_picture_url']});
          case 'delete-account':
            return (200, {'message': 'Demo mode: nothing was deleted'});
          case 'login':
          case 'register':
          case 'google':
          case 'google-signup':
            return (200, {'access_token': 'demo-token', 'token_type': 'bearer', 'user': s.user});
          default:
            return (200, ok);
        }

      // ── Dinners & bookings ──
      case 'dinners':
        if (seg.length == 1) {
          if (method == 'GET') {
            return (200, s.dinners.map(s.dinnerJson).where((d) => d['is_full'] != true).toList());
          }
          return (403, {'detail': 'Not available in demo'});
        }
        if (seg[1] == 'all') return (200, s.dinners.map(s.dinnerJson).toList());
        if (seg[1] == 'user') {
          switch (seg.length > 2 ? seg[2] : '') {
            case 'bookings':
              return (200, s.bookings.map((b) {
                final d = s.dinnerById(b['dinner_id'] as int) ?? {};
                return {
                  ...b,
                  'notes': null,
                  'updated_at': b['booked_at'],
                  'dinner_title': d['title'],
                  'dinner_date': d['date'],
                  'dinner_location': d['location'],
                  'dinner_latitude': d['latitude'],
                  'dinner_longitude': d['longitude'],
                };
              }).toList());
            case 'recent-dinner-attendees':
              final recent = s.pastBookings().firstOrNull;
              if (recent == null) return (200, {'dinner_id': null, 'dinner_title': null, 'attendees': []});
              final dinnerId = recent['dinner_id'] as int;
              return (200, {
                'dinner_id': dinnerId,
                'dinner_title': s.dinnerById(dinnerId)!['title'],
                'attendees': (s.attendees[dinnerId] ?? []).map(s.attendeeJson).toList(),
              });
            case 'dinner-id-attendees':
              final dinnerId = int.tryParse(q['dinner_id'] ?? '') ?? 0;
              final list = (s.attendees[dinnerId] ?? []).map(s.attendeeJson).toList();
              return (200, {
                'dinner_id': dinnerId,
                'dinner_title': s.dinnerById(dinnerId)?['title'],
                'dinner_date': s.dinnerById(dinnerId)?['date'],
                'total_attendees': list.length,
                'attendees': list,
              });
          }
        }
        if (seg[1] == 'bookings' && seg.length > 3) {
          final bookingId = idAt(2);
          final booking = s.bookings.where((b) => b['id'] == bookingId).firstOrNull;
          if (booking == null) return (404, {'detail': 'Booking not found'});
          if (seg[3] == 'cancel') {
            booking['status'] = 'cancelled';
            final d = s.dinnerById(booking['dinner_id'] as int);
            if (d != null && d['current_attendees'] is int) d['current_attendees'] = (d['current_attendees'] as int) - 1;
            return (200, {'message': 'Booking cancelled'});
          }
          if (seg[3] == 'remove') {
            s.bookings.remove(booking);
            return (200, {'message': 'Booking removed'});
          }
        }
        final dinnerId = idAt(1);
        final dinner = dinnerId == null ? null : s.dinnerById(dinnerId);
        if (dinner == null) return (404, {'detail': 'Dinner not found'});
        if (seg.length == 2) return (200, s.dinnerJson(dinner));
        if (seg[2] == 'users') {
          final users = (s.attendees[dinnerId] ?? []).map((id) => s.attendeeJson(id)).toList();
          return (200, {'dinner_id': dinnerId, 'dinner_title': dinner['title'], 'total_users': users.length, 'users': users});
        }
        if (seg[2] == 'book') {
          final existing = s.bookings.where((b) => b['dinner_id'] == dinnerId && b['status'] != 'cancelled').firstOrNull;
          if (existing != null) return (400, {'detail': 'You have already booked this dinner'});
          final now = DateTime.now().toIso8601String();
          final booking = {'id': s.nextId, 'dinner_id': dinnerId, 'status': 'confirmed', 'booked_at': now, 'has_been_rated': false, 'rating': null};
          s.bookings.add(booking);
          dinner['current_attendees'] = (dinner['current_attendees'] as int? ?? 0) + 1;
          s.notify('BOOKING_CONFIRMED', "You're in", 'Your seat at ${dinner['title']} is confirmed. We\'ll reveal the restaurant on the day.',
              dinnerId: dinnerId, bookingId: booking['id'] as int);
          return (200, {...booking, 'user_id': s.userId, 'notes': null, 'updated_at': now});
        }
        return (404, {'detail': 'Not found'});

      // ── Ratings ──
      case 'ratings':
        if (seg.length > 1 && seg[1] == 'ratable-bookings') {
          return (200, s.pastBookings().where((b) => b['has_been_rated'] != true).map((b) {
            final d = s.dinnerById(b['dinner_id'] as int)!;
            return {
              'booking_id': b['id'],
              'dinner_id': d['id'],
              'dinner_title': d['title'],
              'dinner_date': d['date'],
              'dinner_location': d['location'],
              'can_rate': true,
            };
          }).toList());
        }
        if (method == 'POST' && body is Map) {
          final booking = s.bookings.where((b) => b['id'] == body['booking_id']).firstOrNull;
          booking?['has_been_rated'] = true;
          booking?['rating'] = body['rating'];
          return (200, {'booking_id': body['booking_id'], 'rating': body['rating'], 'has_been_rated': true});
        }
        return (200, ok);

      // ── Chat ──
      case 'chat':
        if (seg.length == 1) return (200, (s.chats.map((c) => s.chatJson(c)).toList()..sort((a, b) => (b['updated_at'] as String).compareTo(a['updated_at'] as String))));
        if (seg[1] == 'start') {
          final other = (body is Map ? body['other_user_id'] : null) as int?;
          var chat = s.chats.where((c) => c['other_user_id'] == other).firstOrNull;
          if (chat == null) {
            chat = {
              'id': s.nextId,
              'other_user_id': other,
              'dinner_id': body is Map ? body['dinner_id'] : null,
              'created_at': DateTime.now().toIso8601String(),
              'is_active': true,
              'messages': <Map<String, dynamic>>[],
            };
            s.chats.add(chat);
          }
          return (200, s.chatJson(chat));
        }
        final chatId = idAt(1);
        final chat = s.chats.where((c) => c['id'] == chatId).firstOrNull;
        if (chat == null) return (404, {'detail': 'Chat not found'});
        if (method == 'DELETE') {
          s.chats.remove(chat);
          return (200, {'message': 'Chat deleted'});
        }
        // Opening a chat marks its messages read.
        for (final m in (chat['messages'] as List).cast<Map<String, dynamic>>()) {
          m['is_read'] = true;
        }
        return (200, s.chatJson(chat, withMessages: true, limit: int.tryParse(q['limit'] ?? '') ?? 50, offset: int.tryParse(q['offset'] ?? '') ?? 0));

      // ── Connections ──
      case 'connections':
        final action = seg.length > 1 ? seg[1] : '';
        switch (action) {
          case 'send-request':
            final to = int.tryParse(q['receiver_id'] ?? '');
            if (to != null) s.requestSent.add(to);
            return (200, {'message': 'Connection request sent successfully', 'connection_id': s.nextId});
          case 'accept':
          case 'reject':
          case 'handle-request':
            final id = idAt(2);
            final accept = action == 'accept' || (body is Map && body['action'] == 'accept');
            final req = s.pendingReceived.where((r) => r['connection_id'] == id).firstOrNull ??
                (action == 'handle-request'
                    ? s.pendingReceived.where((r) => s.notifications.any((n) => n['id'] == id && n['connection_id'] == r['connection_id'])).firstOrNull
                    : null);
            if (req != null) {
              s.pendingReceived.remove(req);
              final from = req['user_id'] as int;
              if (accept) s.connected.add(from);
              return (200, {
                'message': accept ? 'Connection request accepted' : 'Connection request rejected',
                'connection_id': req['connection_id'],
                'other_user_id': from,
                'other_user_name': s.person(from)['display_name'],
                'action': accept ? 'accept' : 'reject',
              });
            }
            return (200, {'message': 'ok', 'action': accept ? 'accept' : 'reject'});
          case 'remove':
            final id = idAt(2);
            s.connected.remove(id);
            return (200, {'message': 'Connection removed', 'removed_user_id': id, 'removed_user_name': id == null ? null : s.person(id)['display_name']});
          case 'pending-requests':
            final reqs = s.pendingReceived
                .map((r) => {
                      'connection_id': r['connection_id'],
                      'sender': {...s.person(r['user_id'] as int), 'industry': s.people[r['user_id']]?['industry']},
                      'created_at': r['created_at'],
                    })
                .toList();
            return (200, {'total_requests': reqs.length, 'requests': reqs});
          case 'my-connections':
            final list = s.connected.map(s.attendeeJson).toList();
            return (200, {'total_connections': list.length, 'connections': list});
          case 'status':
            final id = idAt(2);
            final pending = s.pendingReceived.where((r) => r['user_id'] == id).firstOrNull;
            return (200, {
              'already_connected': s.connected.contains(id),
              'connection_request_sent': s.requestSent.contains(id),
              'pending_request_received': pending != null,
              'connection_id': pending?['connection_id'],
            });
        }
        return (200, ok);

      // ── Notifications ──
      case 'notifications':
        if (seg.length == 1) {
          final skip = int.tryParse(q['skip'] ?? '') ?? 0;
          final limit = int.tryParse(q['limit'] ?? '') ?? 50;
          return (200, s.notifications.skip(skip).take(limit).toList());
        }
        if (seg[1] == 'unread-count') return (200, {'unread_count': s.notifications.where((n) => n['is_read'] != true).length});
        if (seg[1] == 'read-all') {
          for (final n in s.notifications) {
            n['is_read'] = true;
          }
          return (200, ok);
        }
        final id = idAt(1);
        final n = s.notifications.where((n) => n['id'] == id).firstOrNull;
        if (method == 'DELETE') {
          s.notifications.remove(n);
          return (200, ok);
        }
        if (seg.length > 2 && seg[2] == 'read' && n != null) {
          n['is_read'] = true;
          n['read_at'] = DateTime.now().toIso8601String();
        }
        return (200, n ?? ok);
    }

    // AI image generation and anything else that needs real infrastructure.
    return (503, {'detail': 'This feature is turned off in the demo.'});
  }
}

/// Stands in for the chat WebSocket: echoes your message back, then has the
/// other person "type" and reply.
class DemoSocket {
  DemoSocket(this._emit);
  final void Function(String type, Map<String, dynamic> data) _emit;
  final _rand = Random();
  int _replyIndex = 0;

  void send(String type, Map<String, dynamic> data) {
    if (type != 'message') return;
    final s = DemoStore.instance;
    final chatId = data['chat_id'] as int;
    final chat = s.chats.where((c) => c['id'] == chatId).firstOrNull;
    if (chat == null) return;

    final mine = s.newMessage(chatId, s.userId, data['content'] as String);
    (chat['messages'] as List).add(mine);
    _emit('message', mine);

    final other = chat['other_user_id'] as int;
    Future.delayed(Duration(milliseconds: 700 + _rand.nextInt(500)), () {
      _emit('typing', {'chat_id': chatId, 'user_id': other, 'is_typing': true});
    });
    Future.delayed(Duration(milliseconds: 2200 + _rand.nextInt(900)), () {
      _emit('typing', {'chat_id': chatId, 'user_id': other, 'is_typing': false});
      final reply = s.newMessage(chatId, other, s.chatReplies[_replyIndex++ % s.chatReplies.length]);
      (chat['messages'] as List).add(reply);
      _emit('message', reply);
    });
  }
}
