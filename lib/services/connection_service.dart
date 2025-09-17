// lib/services/connection_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'core/token_manager.dart';

/// Service for managing user connections and friend requests
class ConnectionService {
  static const String baseUrl = 'https://149a582761bc.ngrok-free.app/api';

  // ================== Connection Requests ==================

  static Future<void> sendConnectionRequest(int userId) async {
    try {
      final headers = await TokenManager.instance.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/connections/send-request?receiver_id=$userId'),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorData = jsonDecode(response.body);
        throw ConnectionException(
            errorData['detail'] ?? 'Failed to send connection request',
            response.statusCode);
      }
    } catch (e) {
      throw ConnectionException('Error sending connection request: $e');
    }
  }

  static Future<Map<String, dynamic>> acceptConnectionRequest(
      int connectionId) async {
    try {
      final headers = await TokenManager.instance.getAuthHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/connections/accept/$connectionId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw ConnectionException(
            'Failed to accept connection request', response.statusCode);
      }

      final responseData = jsonDecode(response.body);

      // Start a chat automatically after accepting the connection
      try {
        final chatResponse = await http.post(
          Uri.parse('$baseUrl/chat/start'),
          headers: headers,
          body: jsonEncode({
            'other_user_id': responseData['other_user_id'],
            'dinner_id': null,
          }),
        );

        if (chatResponse.statusCode != 200) {
          print('Failed to create chat after connection acceptance');
        }
      } catch (e) {
        print('Failed to create chat after connection acceptance: $e');
        // Don't fail the whole operation if chat creation fails
      }

      return responseData;
    } catch (e) {
      throw ConnectionException('Error accepting connection request: $e');
    }
  }

  static Future<void> rejectConnectionRequest(int connectionId) async {
    try {
      final headers = await TokenManager.instance.getAuthHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/connections/reject/$connectionId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw ConnectionException(
            'Failed to reject connection request', response.statusCode);
      }
    } catch (e) {
      throw ConnectionException('Error rejecting connection request: $e');
    }
  }

  static Future<void> removeConnection(int userId) async {
    try {
      final headers = await TokenManager.instance.getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/connections/remove/$userId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw ConnectionException(
            data['detail'] ?? 'Failed to remove connection',
            response.statusCode);
      }
    } catch (e) {
      throw ConnectionException('Error removing connection: $e');
    }
  }

  // ================== Connection Status & Information ==================

  static Future<Map<String, dynamic>> getPendingRequests() async {
    try {
      final headers = await TokenManager.instance.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/connections/pending-requests'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw ConnectionException(
            'Failed to get pending requests', response.statusCode);
      }
    } catch (e) {
      throw ConnectionException('Error getting pending requests: $e');
    }
  }

  static Future<Map<String, dynamic>> getConnectionStatusWithUser(
      int userId) async {
    try {
      final headers = await TokenManager.instance.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/connections/status/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw ConnectionException(
            'Failed to get connection status', response.statusCode);
      }
    } catch (e) {
      throw ConnectionException('Error getting connection status: $e');
    }
  }

  // ================== Connection Request Handling ==================

  static Future<Map<String, dynamic>> handleConnectionRequest(
      int notificationId, String action) async {
    try {
      final headers = await TokenManager.instance.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/connections/handle-request/$notificationId'),
        headers: headers,
        body: jsonEncode({'action': action}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw ConnectionException(
            errorData['detail'] ?? 'Failed to handle connection request',
            response.statusCode);
      }
    } catch (e) {
      throw ConnectionException('Failed to handle connection request: $e');
    }
  }
}

// ================== Exception Class ==================

class ConnectionException implements Exception {
  final String message;
  final int? statusCode;

  ConnectionException(this.message, [this.statusCode]);

  @override
  String toString() =>
      'ConnectionException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}
