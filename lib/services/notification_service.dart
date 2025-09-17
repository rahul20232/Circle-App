import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';
import 'core/token_manager.dart';

class NotificationEventService {
  static const String baseUrl = 'https://149a582761bc.ngrok-free.app/api';

  static final NotificationEventService _instance =
      NotificationEventService._internal();
  factory NotificationEventService() => _instance;
  NotificationEventService._internal();

  final StreamController<String> _notificationController =
      StreamController<String>.broadcast();

  Stream<String> get notificationStream => _notificationController.stream;

  static Future<List<AppNotification>> getUserNotifications({
    bool unreadOnly = false,
    int skip = 0,
    int limit = 50,
  }) async {
    try {
      final headers = await TokenManager.instance.getAuthHeaders();
      String url = '$baseUrl/notifications/?skip=$skip&limit=$limit';
      if (unreadOnly) {
        url += '&unread_only=true';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> notificationsJson = jsonDecode(response.body);
        return notificationsJson
            .map((json) => AppNotification.fromJson(json))
            .toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw NotificationException(
            errorData['detail'] ?? 'Failed to load notifications',
            response.statusCode);
      }
    } catch (e) {
      throw NotificationException('Error in getUserNotifications: $e');
    }
  }

  static Future<void> markNotificationRead(int notificationId) async {
    try {
      final headers = await TokenManager.instance.getAuthHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw NotificationException(
            'Failed to mark notification as read', response.statusCode);
      }
    } catch (e) {
      throw NotificationException('Error marking notification as read: $e');
    }
  }

  static Future<void> markNotificationAsRead(int notificationId) async {
    try {
      final headers = await TokenManager.instance.getAuthHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/$notificationId'),
        headers: headers,
        body: jsonEncode({'is_read': true}),
      );

      if (response.statusCode != 200) {
        throw NotificationException(
            'Failed to mark notification as read', response.statusCode);
      }
    } catch (e) {
      throw NotificationException('Error marking notification as read: $e');
    }
  }

  static Future<int> getUnreadNotificationsCount() async {
    try {
      final headers = await TokenManager.instance.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/unread-count'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['unread_count'] ?? 0;
      } else {
        throw NotificationException(
            'Failed to get unread count', response.statusCode);
      }
    } catch (e) {
      throw NotificationException('Error fetching unread count: $e');
    }
  }

  static Future<void> markAllNotificationsRead() async {
    try {
      final headers = await TokenManager.instance.getAuthHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/read-all'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw NotificationException(
            'Failed to mark all notifications as read', response.statusCode);
      }
    } catch (e) {
      throw NotificationException(
          'Error marking all notifications as read: $e');
    }
  }

  static Future<void> deleteNotification(int notificationId) async {
    try {
      final headers = await TokenManager.instance.getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/notifications/$notificationId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw NotificationException(
            data['detail'] ?? 'Failed to delete notification',
            response.statusCode);
      }
    } catch (e) {
      throw NotificationException('Delete notification error: $e');
    }
  }

  static Future<bool> createTestNotification({
    required int userId,
    String title = "Test Notification",
    String message = "This is a test notification",
    String notificationType = "booking_confirmed",
  }) async {
    try {
      final headers = await TokenManager.instance.getAuthHeaders();
      final response = await http.post(
        Uri.parse(
            '$baseUrl/notifications/test-notification?user_id=$userId&title=${Uri.encodeComponent(title)}&message=${Uri.encodeComponent(message)}&notification_type=$notificationType'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  void refreshNotifications() {
    print('Notification refresh triggered');
    _notificationController.add('refresh');
  }

  void dispose() {
    _notificationController.close();
  }
}

class NotificationException implements Exception {
  final String message;
  final int? statusCode;

  NotificationException(this.message, [this.statusCode]);

  @override
  String toString() =>
      'NotificationException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}
