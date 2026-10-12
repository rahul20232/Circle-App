// lib/components/Cards/ConnectionNotificationCard.dart
import 'package:flutter/material.dart';
import 'package:circle_app/theme/app_colors.dart';
import 'package:circle_app/services/connection_service.dart';
import 'package:circle_app/services/notification_service.dart';
import '../../services/api_service.dart';

class ConnectionNotificationCard extends StatefulWidget {
  final String title;
  final String time;
  final String message;
  final int? notificationId;
  final int? connectionId; // Add this parameter
  final VoidCallback? onUpdate;

  const ConnectionNotificationCard({
    Key? key,
    required this.title,
    required this.time,
    required this.message,
    this.notificationId,
    this.connectionId, // Add this parameter
    this.onUpdate,
  }) : super(key: key);

  @override
  _ConnectionNotificationCardState createState() =>
      _ConnectionNotificationCardState();
}

class _ConnectionNotificationCardState
    extends State<ConnectionNotificationCard> {
  bool _isProcessing = false;

  String get _cleanMessage {
    // Remove the "Sender ID: X" part from connection request messages
    if (widget.message.contains('Sender ID:')) {
      return widget.message.split('Sender ID:')[0].trim();
    }
    return widget.message;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Container(
        width: double.infinity,
        child: Stack(
          children: <Widget>[
            // Outer border container
            // Sizes to its content (no fixed height, so long names/messages
            // can't overflow); the ink shows as a 2px border plus the 3D lip.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(2, 2, 2, 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: AppColors.ink,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Main content area
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      color: AppColors.surface,
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: Column(
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
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),

                          const SizedBox(height: 8),

                          // Message
                          Text(
                            _cleanMessage,
                            style: TextStyle(
                              color: AppColors.grey600,
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 8),

                          // Time
                          Text(
                            widget.time,
                            style: TextStyle(
                              color: AppColors.grey500,
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isProcessing
                                      ? null
                                      : () =>
                                          _handleConnectionRequest('accept'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.success,
                                    foregroundColor: AppColors.surface,
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    minimumSize: const Size(0, 44),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                  child: _isProcessing
                                      ? SizedBox(
                                          height: 16,
                                          width: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    AppColors.surface),
                                          ),
                                        )
                                      : Text(
                                          'Accept',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _isProcessing
                                      ? null
                                      : () =>
                                          _handleConnectionRequest('decline'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.grey700,
                                    side:
                                        BorderSide(color: AppColors.grey300),
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    minimumSize: const Size(0, 44),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                  child: Text(
                                    'Decline',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
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

            // New notification indicator dot
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
    );
  }

  Future<void> _handleConnectionRequest(String action) async {
    if (widget.connectionId == null) return; // Use connection_id instead

    setState(() {
      _isProcessing = true;
    });

    try {
      if (action == 'accept') {
        await ConnectionService.acceptConnectionRequest(widget.connectionId!);
      } else {
        await ConnectionService.rejectConnectionRequest(widget.connectionId!);
      }

      // Mark notification as read
      await NotificationEventService.markNotificationRead(
          widget.notificationId!);

      if (mounted) {
        String message = action == 'accept'
            ? 'Connection request accepted! You can now chat.'
            : 'Connection request declined.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(message),
              backgroundColor:
                  action == 'accept' ? AppColors.success : AppColors.warning),
        );

        if (widget.onUpdate != null) {
          widget.onUpdate!();
        }
      }
    } catch (e) {
      // Error handling
    }
  }
}
