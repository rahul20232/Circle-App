// lib/components/Cards/NotificationCard.dart
import 'package:flutter/material.dart';
import 'package:circle_app/theme/app_colors.dart';
import '../../services/api_service.dart';

class Notifictioncard extends StatefulWidget {
  final String title;
  final String time;
  final String location;
  final String status;
  final String? notificationType;
  final int? notificationId;
  final VoidCallback? onUpdate;

  const Notifictioncard({
    Key? key,
    required this.title,
    required this.time,
    required this.status,
    required this.location,
    this.notificationType,
    this.notificationId,
    this.onUpdate,
  }) : super(key: key);

  @override
  _NotifictioncardState createState() => _NotifictioncardState();
}

class _NotifictioncardState extends State<Notifictioncard> {
  bool _isProcessing = false;

  bool get isConnectionRequest =>
      widget.notificationType == 'connection_request';

  bool get isUnread => widget.status.toLowerCase() == 'unread';

  Color get _statusColor {
    switch (widget.status.toLowerCase()) {
      case 'confirmed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.danger;
      case 'read':
        return AppColors.info;
      case 'unread':
        return AppColors.info;
      default:
        return AppColors.grey600;
    }
  }

  String get _statusText {
    switch (widget.status.toLowerCase()) {
      case 'confirmed':
        return 'Confirmed';
      case 'pending':
        return 'Pending';
      case 'cancelled':
        return 'Cancelled';
      case 'read':
        return 'Read';
      case 'unread':
        return 'New';
      default:
        return widget.status;
    }
  }

  String get _cleanMessage {
    // Remove the "Sender ID: X" part from connection request messages
    if (widget.location.contains('Sender ID:')) {
      return widget.location.split('Sender ID:')[0].trim();
    }
    return widget.location;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: IntrinsicHeight(
        // This allows the container to size based on content
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight: 120, // Minimum height to maintain visual consistency
          ),
          child: Stack(
            children: <Widget>[
              // Outer border container
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: AppColors.ink,
                ),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min, // Allow column to size to content
                  children: [
                    // Main content area
                    Container(
                      margin: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        color: AppColors.surface,
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 20, 16,
                            isConnectionRequest && isUnread ? 10 : 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min, // Size to content
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Title
                            Text(
                              widget.title,
                              style: TextStyle(
                                color: AppColors.ink,
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                height:
                                    1.3, // Add line height for better spacing
                              ),
                              textAlign: TextAlign.center,
                              // Remove overflow restrictions to allow expansion
                            ),

                            const SizedBox(height: 8),

                            // Message/Location
                            Text(
                              _cleanMessage,
                              style: TextStyle(
                                color: AppColors.grey600,
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                height: 1.4, // Add line height for readability
                              ),
                              textAlign: TextAlign.center,
                              // Remove maxLines and overflow to allow full text display
                            ),

                            const SizedBox(
                                height:
                                    12), // Slightly more space before footer

                            // Status
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  // Allow time text to wrap if needed
                                  child: Text(
                                    widget.time,
                                    style: TextStyle(
                                      color: AppColors.grey500,
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _statusText,
                                    style: TextStyle(
                                      color: _statusColor,
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Unread indicator dot
              if (isUnread)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.info,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
