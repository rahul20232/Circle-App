import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../models/chat_model.dart';
import 'api_service.dart';

class ChatService {
  static const String baseUrl = 'https://149a582761bc.ngrok-free.app/api';
  static const String wsUrl = 'wss://149a582761bc.ngrok-free.app/api';

  WebSocketChannel? _channel;
  StreamController<WebSocketMessage>? _messageController;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  bool _isConnected = false;
  bool _shouldReconnect = true;
  int? _currentUserId;
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 5;

  // Singleton pattern
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  // Stream for incoming WebSocket messages
  Stream<WebSocketMessage> get messageStream =>
      _messageController?.stream ?? const Stream.empty();

  bool get isConnected => _isConnected;

  Future<void> connect(int userId) async {
    if (_isConnected && _currentUserId == userId) return;

    _shouldReconnect = true;
    _reconnectAttempts = 0;
    await _connectWithRetry(userId);
  }

  Future<void> _connectWithRetry(int userId) async {
    if (!_shouldReconnect || _reconnectAttempts >= maxReconnectAttempts) {
      print('Max reconnection attempts reached or connection not desired');
      return;
    }

    await disconnect(reconnecting: true);

    try {
      _currentUserId = userId;
      _messageController = StreamController<WebSocketMessage>.broadcast();

      final token = await ApiService.getAuthToken();
      if (token == null) {
        throw Exception('No auth token available');
      }

      final wsUri = Uri.parse('$wsUrl/ws/$userId').replace(
        queryParameters: {'token': token},
      );

      print(
          'Connecting to WebSocket (attempt ${_reconnectAttempts + 1}): $wsUri');
      _channel = WebSocketChannel.connect(wsUri);

      // Wait for connection to be established
      await _channel!.ready;

      _channel!.stream.listen(
        (data) {
          try {
            final jsonData = json.decode(data);
            final message = WebSocketMessage.fromJson(jsonData);
            _messageController?.add(message);
          } catch (e) {
            print('Error parsing WebSocket message: $e');
          }
        },
        onDone: () {
          print('WebSocket connection closed');
          _isConnected = false;
          _stopHeartbeat();
          _scheduleReconnect();
        },
        onError: (error) {
          print('WebSocket error: $error');
          _isConnected = false;
          _stopHeartbeat();
          _scheduleReconnect();
        },
      );

      _isConnected = true;
      _reconnectAttempts = 0;
      _startHeartbeat();
      print('WebSocket connected successfully');
    } catch (e) {
      print('Failed to connect to WebSocket: $e');
      _isConnected = false;
      _reconnectAttempts++;
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (!_shouldReconnect || _reconnectAttempts >= maxReconnectAttempts) return;

    _reconnectTimer?.cancel();
    final delay = Duration(
        seconds: math.min(30, math.pow(2, _reconnectAttempts).toInt()));

    print('Scheduling reconnect in ${delay.inSeconds} seconds...');
    _reconnectTimer = Timer(delay, () {
      if (_currentUserId != null && _shouldReconnect) {
        _connectWithRetry(_currentUserId!);
      }
    });
  }

  // Disconnect from WebSocket
  Future<void> disconnect({bool reconnecting = false}) async {
    if (!reconnecting) {
      _shouldReconnect = false;
    }

    _stopHeartbeat();
    _reconnectTimer?.cancel();

    if (_channel != null) {
      await _channel!.sink.close(status.goingAway);
      _channel = null;
    }

    if (!reconnecting) {
      if (_messageController != null) {
        await _messageController!.close();
        _messageController = null;
      }
      _currentUserId = null;
    }

    _isConnected = false;
  }

  // Start heartbeat to keep connection alive
  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected && _channel != null) {
        _sendWebSocketMessage('ping', {});
      }
    });
  }

  // Stop heartbeat
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  // Send message via WebSocket
  void _sendWebSocketMessage(String type, Map<String, dynamic> data) {
    if (_channel != null && _isConnected) {
      try {
        final message = WebSocketMessage(type: type, data: data);
        _channel!.sink.add(json.encode(message.toJson()));
      } catch (e) {
        print('Error sending WebSocket message: $e');
      }
    } else {
      print('Cannot send message: WebSocket not connected');
    }
  }

  // Send chat message
  void sendMessage(int chatId, String content, {String messageType = 'text'}) {
    if (!_isConnected) {
      throw Exception('WebSocket not connected');
    }

    _sendWebSocketMessage('message', {
      'chat_id': chatId,
      'content': content,
      'message_type': messageType,
    });
  }

  // Send typing indicator
  void sendTypingIndicator(int chatId, bool isTyping) {
    if (!_isConnected) return; // Fail silently for typing indicators

    _sendWebSocketMessage('typing', {
      'chat_id': chatId,
      'is_typing': isTyping,
    });
  }

  // Mark messages as read
  void markMessagesAsRead(int chatId) {
    if (!_isConnected) return; // Fail silently for read receipts

    _sendWebSocketMessage('read', {
      'chat_id': chatId,
    });
  }

  // HTTP API methods

  static Future<bool> deleteChat(int chatId) async {
    try {
      final response = await ApiService.delete('/chat/$chatId');
      if (response['success']) {
        return true;
      } else {
        throw Exception(response['message'] ?? 'Failed to delete chat');
      }
    } catch (e) {
      print('Error deleting chat: $e');
      throw e;
    }
  }

  // Get all chats for current user
  static Future<List<Chat>> getUserChats() async {
    try {
      final response = await ApiService.get('/chat/');
      if (response['success']) {
        final List<dynamic> chatsJson = response['data'];
        return chatsJson.map((json) => Chat.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to get chats');
      }
    } catch (e) {
      print('Error getting user chats: $e');
      throw e;
    }
  }

  // Start a new chat
  static Future<Chat> startChat(int otherUserId, {int? dinnerId}) async {
    try {
      final request = ChatCreateRequest(
        otherUserId: otherUserId,
        dinnerId: dinnerId,
      );

      final response = await ApiService.post('/chat/start', request.toJson());
      if (response['success']) {
        return Chat.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to start chat');
      }
    } catch (e) {
      print('Error starting chat: $e');
      throw e;
    }
  }

  // Get chat details with messages
  static Future<ChatDetail> getChatDetail(int chatId,
      {int limit = 50, int offset = 0}) async {
    try {
      final response =
          await ApiService.get('/chat/$chatId?limit=$limit&offset=$offset');
      if (response['success']) {
        return ChatDetail.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to get chat details');
      }
    } catch (e) {
      print('Error getting chat details: $e');
      throw e;
    }
  }

  // Load more messages for a chat
  static Future<List<Message>> loadMoreMessages(int chatId, int offset,
      {int limit = 50}) async {
    try {
      final response =
          await ApiService.get('/chat/$chatId?limit=$limit&offset=$offset');
      if (response['success']) {
        final chatDetail = ChatDetail.fromJson(response['data']);
        return chatDetail.messages;
      } else {
        throw Exception(response['message'] ?? 'Failed to load more messages');
      }
    } catch (e) {
      print('Error loading more messages: $e');
      throw e;
    }
  }

  // Clean up when app is disposed
  void dispose() {
    disconnect();
  }
}
