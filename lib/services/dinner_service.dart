// lib/services/dinner_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dinner_model.dart';
import '../models/rating_model.dart';
import 'core/token_manager.dart';
import 'api_service.dart';

/// Service for dinner-related operations
class DinnerService {
  static const String baseUrl = 'https://149a582761bc.ngrok-free.app/api';

  // ================== Dinner Queries ==================

  static Future<List<Dinner>> getAvailableDinners() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dinners/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Dinner.fromJson(json)).toList();
      } else {
        throw DinnerException(
            'Failed to fetch dinners', response.statusCode, response.body);
      }
    } catch (e) {
      throw DinnerException('Error fetching dinners: $e');
    }
  }

  static Future<List<Dinner>> getAllDinners() async {
    try {
      final headers = await TokenManager.instance.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/dinners/all'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Dinner.fromJson(json)).toList();
      } else {
        throw DinnerException(
            'Failed to fetch all dinners', response.statusCode, response.body);
      }
    } catch (e) {
      throw DinnerException('Error fetching all dinners: $e');
    }
  }

  static Future<Map<String, dynamic>> getUsersFromDinner(int dinnerId) async {
    try {
      final headers = await TokenManager.instance.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/dinners/$dinnerId/users'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw DinnerException(
            'Failed to fetch dinner users', response.statusCode, response.body);
      }
    } catch (e) {
      throw DinnerException('Error fetching dinner users: $e');
    }
  }

  static Future<List<dynamic>> getRecentDinnerAttendees() async {
    try {
      final headers = await TokenManager.instance.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/dinners/user/recent-dinner-attendees'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['attendees'] as List<dynamic>;
      } else {
        throw DinnerException('Failed to load recent dinner attendees',
            response.statusCode, response.body);
      }
    } catch (e) {
      throw DinnerException('Error in getRecentDinnerAttendees: $e');
    }
  }

  static Future<List<dynamic>> getDinnerIdAttendees(int dinnerId) async {
    try {
      final headers = await TokenManager.instance.getAuthHeaders();
      final response = await http.get(
        Uri.parse(
            '$baseUrl/dinners/user/dinner-id-attendees?dinner_id=$dinnerId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['attendees'] as List<dynamic>;
      } else if (response.statusCode == 403) {
        final errorData = jsonDecode(response.body);
        throw DinnerException(
            errorData['detail'] ?? 'Access forbidden', response.statusCode);
      } else if (response.statusCode == 404) {
        throw DinnerException('Dinner not found', response.statusCode);
      } else {
        throw DinnerException('Failed to load dinner attendees',
            response.statusCode, response.body);
      }
    } catch (e) {
      throw DinnerException('Error in getDinnerIdAttendees: $e');
    }
  }

  // ================== Booking Management ==================

  static Future<void> bookDinner(int dinnerId, {String? notes}) async {
    try {
      final headers = await TokenManager.instance.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/dinners/$dinnerId/book'),
        headers: headers,
        body: jsonEncode({'notes': notes}),
      );

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw DinnerException(
            data['detail'] ?? 'Booking failed', response.statusCode);
      }
    } catch (e) {
      throw DinnerException('Booking error: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getUserBookings() async {
    try {
      final headers = await TokenManager.instance.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/dinners/user/bookings'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw DinnerException('Failed to fetch user bookings',
            response.statusCode, response.body);
      }
    } catch (e) {
      throw DinnerException('Error fetching user bookings: $e');
    }
  }

  static Future<bool> cancelBooking(int bookingId) async {
    try {
      final headers = await TokenManager.instance.getAuthHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/dinners/bookings/$bookingId/cancel'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return true; // Success
      } else {
        final data = jsonDecode(response.body);
        throw DinnerException(data['detail'] ?? 'Booking cancellation failed',
            response.statusCode);
      }
    } catch (e) {
      print('Cancel booking error: $e');
      return false; // Failure
    }
  }

  static Future<bool> removeBookingFromHistory(int bookingId) async {
    try {
      final headers = await TokenManager.instance.getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/dinners/bookings/$bookingId/remove'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ================== Rating System ==================

  static Future<List<Booking>> getRatableBookings() async {
    try {
      final headers = await TokenManager.instance.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/ratings/ratable-bookings'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Booking.fromJson(json)).toList();
      } else {
        throw DinnerException('Failed to fetch ratable bookings',
            response.statusCode, response.body);
      }
    } catch (e) {
      throw DinnerException('Error fetching ratable bookings: $e');
    }
  }

  static Future<RatingResponse> rateDinner({
    required int bookingId,
    required int rating,
  }) async {
    try {
      final headers = await TokenManager.instance.getAuthHeaders();
      final ratingRequest = RatingRequest(
        bookingId: bookingId,
        rating: rating,
      );

      final response = await http.post(
        Uri.parse('$baseUrl/ratings/'),
        headers: headers,
        body: jsonEncode(ratingRequest.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return RatingResponse.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        throw DinnerException(errorData['detail'] ?? 'Rating submission failed',
            response.statusCode);
      }
    } catch (e) {
      throw DinnerException('Error submitting rating: $e');
    }
  }
}

// ================== Exception Class ==================

class DinnerException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  DinnerException(this.message, [this.statusCode, this.responseBody]);

  @override
  String toString() =>
      'DinnerException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}
