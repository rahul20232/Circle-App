class AppNotification {
  final int id;
  final int userId;
  final int? dinnerId;
  final int? bookingId;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final int? connectionId;

  AppNotification({
    required this.id,
    required this.userId,
    this.dinnerId,
    this.bookingId,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.readAt,
    this.connectionId,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
        id: json['id'],
        userId: json['user_id'],
        dinnerId: json['dinner_id'],
        bookingId: json['booking_id'],
        type: json['type'],
        title: json['title'],
        message: json['message'],
        isRead: json['is_read'],
        createdAt: DateTime.parse(json['created_at']),
        readAt:
            json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
        connectionId: json['connection_id']);
  }
}
