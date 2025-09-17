class Dinner {
  final int id;
  final String title;
  final String? description;
  final DateTime date;
  final String location;
  final double? latitude;
  final double? longitude;
  final int maxAttendees;
  final int currentAttendees;
  final int availableSpots;
  final bool isFull;
  final bool isActive;

  Dinner({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    required this.location,
    this.latitude,
    this.longitude,
    required this.maxAttendees,
    required this.currentAttendees,
    required this.availableSpots,
    required this.isFull,
    required this.isActive,
  });

  factory Dinner.fromJson(Map<String, dynamic> json) {
    return Dinner(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      date: DateTime.parse(json['date']),
      location: json['location'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      maxAttendees: json['max_attendees'] ?? 6,
      currentAttendees: json['current_attendees'] ?? 0,
      availableSpots: json['available_spots'] ?? 6,
      isFull: json['is_full'] ?? false,
      isActive: json['is_active'] ?? true,
    );
  }

  // Helper method to format date for UI
  String get formattedDate {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  // Helper method to format time for UI
  String get formattedTime {
    final hour =
        date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'location': location,
      'max_attendees': maxAttendees,
      'current_attendees': currentAttendees,
      'available_spots': availableSpots,
      'is_full': isFull,
      'is_active': isActive,
    };
  }
}
