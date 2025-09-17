// lib/screens/Notifications/notifications_components.dart
import 'package:flutter/material.dart';
import 'package:timeleft_clone/components/Cards/SwipableNotificationCard.dart';
import 'package:timeleft_clone/models/notification_model.dart';
import '../controllers/notifications_controller.dart';
import '../../../components/Cards/NotifictionCard.dart';
import '../../../components/Cards/ConnectionNotificationCard.dart';

class NotificationsComponents {
  final NotificationsController controller;

  NotificationsComponents({required this.controller});

  Widget buildTabButton({
    required String title,
    required int unreadCount,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (unreadCount > 0) ...[
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Color(0xFF6B46C1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  unreadCount.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            'Failed to load notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            errorMessage,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: controller.retryLoading,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6B46C1),
              foregroundColor: Colors.white,
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyState() {
    return Container(
      color: Color(0xFFFEF1DE),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: 0,
                            left: 20,
                            child: Icon(
                              Icons.auto_awesome,
                              size: 16,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 15,
                            child: Icon(
                              Icons.auto_awesome,
                              size: 12,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(20),
                            child: Icon(
                              Icons.notifications_outlined,
                              size: 80,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      Text(
                        'No notifications yet',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Notifications about your dinners and connections will appear here.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNotificationsList(
      List<AppNotification> notifications, String category) {
    if (notifications.isEmpty) {
      return _buildEmptyCategoryState(category);
    }

    return RefreshIndicator(
      onRefresh: controller.refreshNotifications,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationCard(notification, index, context);
        },
      ),
    );
  }

  Widget _buildEmptyCategoryState(String category) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              category == 'bookings'
                  ? Icons.calendar_today_outlined
                  : Icons.people_outline,
              size: 60,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16),
            Text(
              'No ${category} notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              category == 'bookings'
                  ? 'Booking confirmations and dinner updates will appear here.'
                  : 'Connection requests and messages will appear here.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
      AppNotification notification, int index, BuildContext context) {
    // Check if this is a connection request notification
    final isConnectionRequest = notification.type == 'CONNECTION_REQUEST' ||
        notification.type == 'connection_request';

    // Only show connection request actions if the notification is unread
    final showConnectionActions = isConnectionRequest && !notification.isRead;

    Widget notificationCard;

    if (showConnectionActions) {
      // Use ConnectionNotificationCard for unread connection requests
      notificationCard = ConnectionNotificationCard(
        title: notification.title,
        time: controller.formatTime(notification.createdAt),
        message: notification.message,
        notificationId: notification.id,
        connectionId: notification.connectionId,
        onUpdate: () {
          // Refresh the notifications list when a connection request is handled
          controller.refreshNotifications();
        },
      );
    } else {
      // Use regular NotificationCard for all other notifications
      String status = notification.isRead ? "read" : "unread";

      notificationCard = Notifictioncard(
        title: notification.title,
        time: controller.formatTime(notification.createdAt),
        location: notification.message,
        status: status,
        notificationType: notification.type,
        notificationId: notification.id,
        onUpdate: () {
          // Refresh the notifications list
          controller.refreshNotifications();
        },
      );
    }

    // Wrap in SwipeableNotificationCard
    return SwipeableNotificationCard(
      key: ValueKey(notification.id), // Important for ListView item tracking
      onClear: () => controller.clearNotification(notification, context),
      child: notificationCard,
    );
  }
}
