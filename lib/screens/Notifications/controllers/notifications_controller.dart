// lib/screens/Notifications/notifications_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:timeleft_clone/models/notification_model.dart';
import 'package:timeleft_clone/services/notification_service.dart';

class NotificationsController {
  final TickerProvider vsync;
  final Function(int)? onUnreadCountChanged;
  final VoidCallback onStateChanged;

  late TabController _tabController;
  late StreamSubscription<String> _notificationSubscription;

  // State variables
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Separate lists for each category
  List<AppNotification> _bookingNotifications = [];
  List<AppNotification> _connectionNotifications = [];

  // Unread counts
  int _bookingUnreadCount = 0;
  int _connectionUnreadCount = 0;

  NotificationsController({
    required this.vsync,
    this.onUnreadCountChanged,
    required this.onStateChanged,
  });

  // Getters
  TabController get tabController => _tabController;
  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<AppNotification> get bookingNotifications => _bookingNotifications;
  List<AppNotification> get connectionNotifications => _connectionNotifications;
  int get bookingUnreadCount => _bookingUnreadCount;
  int get connectionUnreadCount => _connectionUnreadCount;
  int get totalUnreadCount => _bookingUnreadCount + _connectionUnreadCount;
  bool get shouldShowTabs =>
      !_isLoading && _errorMessage == null && _notifications.isNotEmpty;

  void initialize() {
    _tabController = TabController(length: 2, vsync: vsync);
    _tabController.animation?.addListener(() {
      onStateChanged();
    });

    _loadNotifications();

    _notificationSubscription =
        NotificationEventService().notificationStream.listen((event) {
      if (event == 'refresh') {
        refreshNotifications();
      }
    });
  }

  void dispose() {
    _notificationSubscription.cancel();
    _tabController.dispose();
  }

  // Method to categorize notifications
  void _categorizeNotifications() {
    _bookingNotifications.clear();
    _connectionNotifications.clear();
    _bookingUnreadCount = 0;
    _connectionUnreadCount = 0;

    for (var notification in _notifications) {
      if (_isBookingNotification(notification)) {
        _bookingNotifications.add(notification);
        if (!notification.isRead) _bookingUnreadCount++;
      } else if (_isConnectionNotification(notification)) {
        _connectionNotifications.add(notification);
        if (!notification.isRead) _connectionUnreadCount++;
      }
    }

    // Sort each category by newest first
    _bookingNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _connectionNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (onUnreadCountChanged != null) {
      onUnreadCountChanged!(totalUnreadCount);
    }
  }

  // Helper method to identify booking notifications
  bool _isBookingNotification(AppNotification notification) {
    final bookingTypes = [
      'BOOKING_CONFIRMED',
      'booking_confirmed',
      'BOOKING_CANCELLED',
      'booking_cancelled',
      'BOOKING_REMINDER',
      'booking_reminder',
      'DINNER_UPDATED',
      'dinner_updated',
      'BOOKING_PENDING',
      'booking_pending',
      'DINNER_REMINDER',
      'dinner_reminder',
    ];

    return bookingTypes.contains(notification.type);
  }

  // Helper method to identify connection notifications
  bool _isConnectionNotification(AppNotification notification) {
    final connectionTypes = [
      'CONNECTION_REQUEST',
      'connection_request',
      'CONNECTION_ACCEPTED',
      'connection_accepted',
      'CONNECTION_REJECTED',
      'connection_rejected',
      'NEW_MESSAGE',
      'new_message',
    ];

    return connectionTypes.contains(notification.type);
  }

  Future<void> _loadNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    onStateChanged();

    try {
      print('Loading all notifications for current user...');

      final notifications = await NotificationEventService.getUserNotifications(
        unreadOnly: false,
        skip: 0,
        limit: 100,
      );

      print('Received ${notifications?.length ?? 0} notifications');

      _notifications = notifications ?? [];
      _categorizeNotifications();
      _isLoading = false;
      onStateChanged();
    } catch (e) {
      print('Error loading notifications: $e');

      _isLoading = false;
      _errorMessage = "Failed to load notifications: ${e.toString()}";
      onStateChanged();
    }
  }

  Future<void> refreshNotifications() async {
    await _loadNotifications();
  }

  Future<void> clearNotification(
      AppNotification notification, BuildContext context) async {
    try {
      await NotificationEventService.deleteNotification(notification.id);

      _notifications.removeWhere((n) => n.id == notification.id);
      _categorizeNotifications();
      onStateChanged();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notification cleared'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } catch (e) {
      print('Error clearing notification: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to clear notification'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  void retryLoading() {
    _loadNotifications();
  }

  String formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
