// lib/models/rating_model.dart
class Booking {
  final int bookingId;
  final int dinnerId;
  final String dinnerTitle;
  final DateTime dinnerDate;
  final String dinnerLocation;
  final bool canRate;

  Booking({
    required this.bookingId,
    required this.dinnerId,
    required this.dinnerTitle,
    required this.dinnerDate,
    required this.dinnerLocation,
    required this.canRate,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      bookingId: json['booking_id'],
      dinnerId: json['dinner_id'],
      dinnerTitle: json['dinner_title'],
      dinnerDate: DateTime.parse(json['dinner_date']),
      dinnerLocation: json['dinner_location'],
      canRate: json['can_rate'] ?? true,
    );
  }
}

class RatingRequest {
  final int bookingId;
  final int rating;

  RatingRequest({
    required this.bookingId,
    required this.rating,
  });

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'rating': rating,
    };
  }
}

class RatingResponse {
  final int bookingId;
  final int rating;
  final bool hasBeenRated;

  RatingResponse({
    required this.bookingId,
    required this.rating,
    required this.hasBeenRated,
  });

  factory RatingResponse.fromJson(Map<String, dynamic> json) {
    return RatingResponse(
      bookingId: json['booking_id'],
      rating: json['rating'],
      hasBeenRated: json['has_been_rated'],
    );
  }
}
