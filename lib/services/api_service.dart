// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeleft_clone/models/dinner_model.dart';
import 'package:timeleft_clone/models/notification_model.dart';
import 'package:timeleft_clone/models/rating_model.dart';
import '../models/user_model.dart';
import 'core/token_manager.dart';

/// Pure API service - handles only HTTP requests and responses
class ApiService {
  static const String baseUrl = 'https://149a582761bc.ngrok-free.app/api';

  // ================== Auth Endpoints ==================

  static Future<String?> registerWithEmail(
      String email, String password, String displayName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'display_name': displayName,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message'];
      } else {
        throw ApiException(
            'Registration failed', response.statusCode, response.body);
      }
    } catch (e) {
      throw ApiException('Registration error: $e');
    }
  }

  static Future<LoginResult> loginWithEmail(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LoginResult(
          user: AppUser.fromJson(data['user']),
          token: data['access_token'],
        );
      } else {
        throw ApiException('Login failed', response.statusCode, response.body);
      }
    } catch (e) {
      throw ApiException('Login error: $e');
    }
  }

  static Future<AppUser> authenticateWithGoogle(String email,
      String displayName, String googleId, String? photoUrl) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'display_name': displayName,
          'google_id': googleId,
          'profile_picture_url': photoUrl,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AppUser.fromJson(data['user']);
      } else {
        throw ApiException(
            'Google auth failed', response.statusCode, response.body);
      }
    } catch (e) {
      throw ApiException('Google auth error: $e');
    }
  }

  static Future<AppUser> updateUserProfile({
    String? displayName,
    String? phoneNumber,
    String? profilePictureUrl,
  }) async {
    final response = await _authenticatedPost('/auth/profile', {
      'display_name': displayName,
      'phone_number': phoneNumber,
    });
    return AppUser.fromJson(response);
  }

  static Future<String> sendPasswordResetEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message'];
      } else if (response.statusCode == 429) {
        final data = jsonDecode(response.body);
        throw ApiException(data['detail'], response.statusCode);
      } else {
        throw ApiException(
            'Password reset failed', response.statusCode, response.body);
      }
    } catch (e) {
      throw ApiException('Password reset error: $e');
    }
  }

  static Future<String> resetPassword(String token, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message'];
      } else {
        final data = jsonDecode(response.body);
        throw ApiException(
            data['detail'] ?? 'Password reset failed', response.statusCode);
      }
    } catch (e) {
      throw ApiException('Password reset error: $e');
    }
  }

  // ================== User Management ==================

  static Future<bool> updateFCMToken(String token) async {
    try {
      final response =
          await _authenticatedPost('/auth/fcm-token', {'token': token});
      return true; // Success if no exception thrown
    } catch (e) {
      return false;
    }
  }

  static Future<String> uploadProfilePhoto(File imageFile) async {
    final headers = await TokenManager.instance.getAuthHeaders();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/auth/upload-profile-photo'),
    );

    request.headers.addAll(headers);
    request.files
        .add(await http.MultipartFile.fromPath('file', imageFile.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var data = jsonDecode(responseData);
      return data['profile_picture_url'];
    } else {
      var errorData = await response.stream.bytesToString();
      throw ApiException("Photo upload failed", response.statusCode, errorData);
    }
  }

  static Future<bool> deleteAccount(
      String password, String confirmationText) async {
    try {
      await _authenticatedPost('/auth/delete-account', {
        'password': password,
        'confirmation_text': confirmationText,
      });
      return true;
    } catch (e) {
      rethrow;
    }
  }

  // ================== Subscription Management ==================

  static Future<AppUser> activateSubscription({
    required String subscriptionType,
    DateTime? subscriptionStart,
    DateTime? subscriptionEnd,
    String? subscriptionPlanId,
  }) async {
    final body = <String, dynamic>{
      'subscription_type': subscriptionType,
    };

    if (subscriptionStart != null)
      body['subscription_start'] = subscriptionStart.toIso8601String();
    if (subscriptionEnd != null)
      body['subscription_end'] = subscriptionEnd.toIso8601String();
    if (subscriptionPlanId != null)
      body['subscription_plan_id'] = subscriptionPlanId;

    final response =
        await _authenticatedPost('/auth/subscription/activate', body);
    return AppUser.fromJson(response['user']);
  }

  static Future<AppUser> updateSubscription({
    bool? isSubscribed,
    DateTime? subscriptionStart,
    DateTime? subscriptionEnd,
    String? subscriptionType,
    String? subscriptionPlanId,
  }) async {
    final body = <String, dynamic>{};
    if (isSubscribed != null) body['is_subscribed'] = isSubscribed;
    if (subscriptionStart != null)
      body['subscription_start'] = subscriptionStart.toIso8601String();
    if (subscriptionEnd != null)
      body['subscription_end'] = subscriptionEnd.toIso8601String();
    if (subscriptionType != null) body['subscription_type'] = subscriptionType;
    if (subscriptionPlanId != null)
      body['subscription_plan_id'] = subscriptionPlanId;

    final response = await _authenticatedPut('/auth/subscription', body);
    return AppUser.fromJson(response);
  }

  static Future<String> cancelSubscription() async {
    final response = await _authenticatedPost('/auth/subscription/cancel', {});
    return response['message'];
  }

  static Future<Map<String, dynamic>> getSubscriptionStatus() async {
    return await _authenticatedGet('/auth/subscription/status');
  }

  // ================== Preferences ==================

  static Future<Map<String, dynamic>> updateUserPreferences({
    String? relationshipStatus,
    String? childrenStatus,
    String? industry,
    String? country,
    List<String>? dinnerLanguages,
    String? dinnerBudget,
    bool? hasDietaryRestrictions,
    List<String>? dietaryOptions,
    bool? eventPushNotifications,
    bool? eventSms,
    bool? eventEmail,
    bool? lastminutePushNotifications,
    bool? lastminuteSms,
    bool? lastminuteEmail,
    bool? marketingEmail,
  }) async {
    final body = <String, dynamic>{};
    if (relationshipStatus != null)
      body['relationship_status'] = relationshipStatus;
    if (childrenStatus != null) body['children_status'] = childrenStatus;
    if (industry != null) body['industry'] = industry;
    if (country != null) body['country'] = country;
    if (dinnerLanguages != null) body['dinner_languages'] = dinnerLanguages;
    if (dinnerBudget != null) body['dinner_budget'] = dinnerBudget;
    if (hasDietaryRestrictions != null)
      body['has_dietary_restrictions'] = hasDietaryRestrictions;
    if (dietaryOptions != null) body['dietary_options'] = dietaryOptions;
    if (eventPushNotifications != null)
      body['event_push_notifications'] = eventPushNotifications;
    if (eventSms != null) body['event_sms'] = eventSms;
    if (eventEmail != null) body['event_email'] = eventEmail;
    if (lastminutePushNotifications != null)
      body['lastminute_push_notifications'] = lastminutePushNotifications;
    if (lastminuteSms != null) body['lastminute_sms'] = lastminuteSms;
    if (lastminuteEmail != null) body['lastminute_email'] = lastminuteEmail;
    if (marketingEmail != null) body['marketing_email'] = marketingEmail;

    return await _authenticatedPut('/auth/preferences', body);
  }

  static Future<Map<String, dynamic>> getUserPreferences() async {
    return await _authenticatedGet('/auth/preferences');
  }

  // ================== Private Helper Methods ==================

  static Future<Map<String, dynamic>> _authenticatedGet(String endpoint) async {
    final headers = await TokenManager.instance.getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ApiException(
          'GET request failed', response.statusCode, response.body);
    }
  }

  static Future<Map<String, dynamic>> _authenticatedPost(
      String endpoint, Map<String, dynamic> body) async {
    final headers = await TokenManager.instance.getAuthHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw ApiException(
          'POST request failed', response.statusCode, response.body);
    }
  }

  static Future<Map<String, dynamic>> _authenticatedPut(
      String endpoint, Map<String, dynamic> body) async {
    final headers = await TokenManager.instance.getAuthHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ApiException(
          'PUT request failed', response.statusCode, response.body);
    }
  }

  static Future<Map<String, dynamic>> _authenticatedDelete(
      String endpoint) async {
    final headers = await TokenManager.instance.getAuthHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ApiException(
          'DELETE request failed', response.statusCode, response.body);
    }
  }

  static Future<String?> getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> get(String endpoint) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception("No token found. User may not be logged in.");
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("GET request failed: ${response.body}");
      }
    } catch (e) {
      print('GET request error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception("No token found. User may not be logged in.");
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception("POST request failed: ${response.body}");
      }
    } catch (e) {
      print('POST request error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> delete(String endpoint) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception("No token found. User may not be logged in.");
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return jsonDecode(response.body);
      } else {
        throw Exception("DELETE request failed: ${response.body}");
      }
    } catch (e) {
      print('DELETE request error: $e');
      rethrow;
    }
  }
}

// ================== Helper Classes ==================

class LoginResult {
  final AppUser user;
  final String token;

  LoginResult({required this.user, required this.token});
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  ApiException(this.message, [this.statusCode, this.responseBody]);

  @override
  String toString() =>
      'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}
