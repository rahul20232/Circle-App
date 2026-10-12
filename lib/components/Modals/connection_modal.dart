import 'package:flutter/material.dart';
import 'package:circle_app/theme/app_colors.dart';
import 'package:circle_app/services/api_service.dart';
import 'package:circle_app/services/connection_service.dart';
import 'package:circle_app/services/notification_service.dart';

class ConnectionModal extends StatefulWidget {
  final List<dynamic> attendees;
  final String dinnerTitle;
  final VoidCallback? onConnectionsUpdated;
  final VoidCallback? onNotificationUpdate;

  const ConnectionModal({
    Key? key,
    required this.attendees,
    required this.dinnerTitle,
    this.onConnectionsUpdated,
    this.onNotificationUpdate,
  }) : super(key: key);

  @override
  State<ConnectionModal> createState() => _ConnectionModalState();
}

class _ConnectionModalState extends State<ConnectionModal> {
  bool _isProcessingRequest = false;
  late List<dynamic> _attendees; // Local copy of attendees

  @override
  void initState() {
    super.initState();
    // Create a local copy of attendees that we can modify
    _attendees = List<Map<String, dynamic>>.from(widget.attendees
        .map((attendee) => Map<String, dynamic>.from(attendee)));
  }

  Future<void> _sendConnectionRequest(int userId, String displayName) async {
    if (_isProcessingRequest) return;

    setState(() {
      _isProcessingRequest = true;
    });

    try {
      await ConnectionService.sendConnectionRequest(userId);

      if (!mounted) return;

      // Update local state to show pending status immediately
      setState(() {
        final userIndex = _attendees.indexWhere((user) => user['id'] == userId);
        if (userIndex != -1) {
          _attendees[userIndex]['connection_request_sent'] = true;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection request sent to $displayName'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      if (widget.onConnectionsUpdated != null) {
        widget.onConnectionsUpdated!();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send connection request: $e'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingRequest = false;
        });
      }
    }
  }

  Future<void> _acceptConnectionRequest(
      int connectionId, String displayName) async {
    if (_isProcessingRequest) return;

    setState(() {
      _isProcessingRequest = true;
    });

    try {
      await ConnectionService.acceptConnectionRequest(connectionId);

      if (!mounted) return;

      // Update local state to show accepted status
      setState(() {
        final userIndex = _attendees
            .indexWhere((user) => user['connection_id'] == connectionId);
        if (userIndex != -1) {
          _attendees[userIndex]['already_connected'] = true;
          _attendees[userIndex]['connection_request_sent'] = false;
          _attendees[userIndex]['pending_request_received'] = false;
        }
      });

      NotificationEventService().refreshNotifications();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection request from $displayName accepted'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      if (widget.onConnectionsUpdated != null) {
        widget.onConnectionsUpdated!();
      }

      if (widget.onNotificationUpdate != null) {
        widget.onNotificationUpdate!();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to accept connection request: $e'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingRequest = false;
        });
      }
    }
  }

  Future<void> _rejectConnectionRequest(
      int connectionId, String displayName) async {
    if (_isProcessingRequest) return;

    setState(() {
      _isProcessingRequest = true;
    });

    try {
      await ConnectionService.rejectConnectionRequest(connectionId);

      if (!mounted) return;

      // Remove user from local list since request was rejected
      setState(() {
        _attendees.removeWhere((user) => user['connection_id'] == connectionId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection request from $displayName rejected'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      if (widget.onConnectionsUpdated != null) {
        widget.onConnectionsUpdated!();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reject connection request: $e'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingRequest = false;
        });
      }
    }
  }

  Widget _buildActionButton(
      int userId,
      String displayName,
      bool alreadyConnected,
      bool connectionRequestSent,
      bool pendingRequestReceived,
      int? connectionId) {
    if (alreadyConnected) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.successSoft,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 14,
              color: AppColors.success,
            ),
            SizedBox(width: 4),
            Text(
              'Connected',
              style: TextStyle(
                color: AppColors.success,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (connectionRequestSent) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.warningSoft,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.schedule,
              size: 14,
              color: AppColors.warning,
            ),
            SizedBox(width: 4),
            Text(
              'Pending',
              style: TextStyle(
                color: AppColors.warning,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // Show accept/reject buttons for incoming requests
    if (pendingRequestReceived && connectionId != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Reject button
          GestureDetector(
            onTap: _isProcessingRequest
                ? null
                : () => _rejectConnectionRequest(connectionId, displayName),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _isProcessingRequest
                    ? AppColors.grey400
                    : AppColors.danger,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: AppColors.surface,
                size: 18,
              ),
            ),
          ),
          SizedBox(width: 8),
          // Accept button
          GestureDetector(
            onTap: _isProcessingRequest
                ? null
                : () => _acceptConnectionRequest(connectionId, displayName),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _isProcessingRequest
                    ? AppColors.grey400
                    : AppColors.success,
                shape: BoxShape.circle,
              ),
              child: _isProcessingRequest
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        color: AppColors.surface,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      Icons.check,
                      color: AppColors.surface,
                      size: 18,
                    ),
            ),
          ),
        ],
      );
    }

    // Default: Show add button for sending new requests
    return GestureDetector(
      onTap: _isProcessingRequest
          ? null
          : () => _sendConnectionRequest(userId, displayName),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color:
              _isProcessingRequest ? AppColors.grey400 : AppColors.accent,
          shape: BoxShape.circle,
        ),
        child: _isProcessingRequest
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: AppColors.surface,
                  strokeWidth: 2,
                ),
              )
            : Icon(
                Icons.add,
                color: AppColors.surface,
                size: 20,
              ),
      ),
    );
  }

  Widget _buildAttendeeItem(Map<String, dynamic> user) {
    final String displayName = user['display_name'] ?? 'Unknown User';
    final String? profilePictureUrl = user['profile_picture_url'];
    final int userId = user['id'];
    final bool connectionRequestSent = user['connection_request_sent'] ?? false;
    final bool alreadyConnected = user['already_connected'] ?? false;
    final bool pendingRequestReceived =
        user['pending_request_received'] ?? false;
    final int? connectionId = user['connection_id'];
    final String? industry = user['industry'];

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withOpacity(0.04),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile picture
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentSoft,
              image: profilePictureUrl != null && profilePictureUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(profilePictureUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: profilePictureUrl == null || profilePictureUrl.isEmpty
                ? Center(
                    child: Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        color: AppColors.accentDeep,
                        fontFamily: AppFonts.serif,
                        fontSize: 22,
                      ),
                    ),
                  )
                : null,
          ),

          SizedBox(width: 12),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  industry ?? 'Fellow diner',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.grey600,
                  ),
                ),
                // Show status text for incoming requests
                if (pendingRequestReceived) ...[
                  SizedBox(height: 4),
                  Text(
                    'Wants to connect with you',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.info,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(width: 12),

          // Action button
          _buildActionButton(userId, displayName, alreadyConnected,
              connectionRequestSent, pendingRequestReceived, connectionId),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            size: 48,
            color: AppColors.grey400,
          ),
          SizedBox(height: 12),
          Text(
            'No fellow diners to connect with',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.grey600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Check back after attending more dinners!',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmallScreen = screenHeight < 650;
    final isSmallScreen = screenHeight < 700 || screenWidth < 375;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          initialChildSize:
              isVerySmallScreen ? 0.85 : (isSmallScreen ? 0.75 : 0.65),
          minChildSize: 0.5,
          maxChildSize: 0.95,
          snap: true,
          snapSizes: [0.5, 0.75, 0.95],
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grey300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header with close button
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12.0 : 20.0,
                      vertical: isVerySmallScreen ? 8.0 : 12.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Connect with Fellow Diners',
                          style: TextStyle(
                            fontSize: isVerySmallScreen
                                ? 16
                                : (isSmallScreen ? 18 : 20),
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            size: isVerySmallScreen
                                ? 20
                                : (isSmallScreen ? 22 : 24),
                            color: AppColors.grey600,
                          ),
                          onPressed: _isProcessingRequest
                              ? null
                              : () => Navigator.pop(context),
                          padding: EdgeInsets.all(8),
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),
                  ),

                  // Subtitle
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12.0 : 20.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          child: Text(
                            widget.dinnerTitle,
                            style: TextStyle(
                              fontSize: isVerySmallScreen ? 14 : 16,
                              color: AppColors.grey700,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          child: Text(
                            'Send connection requests to people from your recent dinner',
                            style: TextStyle(
                              fontSize: isVerySmallScreen ? 12 : 14,
                              color: AppColors.grey500,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12.0 : 20.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Attendees list or empty state
                          _attendees.isEmpty
                              ? _buildEmptyState()
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: _attendees
                                      .map((user) => _buildAttendeeItem(user))
                                      .toList(),
                                ),

                          SizedBox(height: 20),

                          // Done button
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 8),
                            child: ElevatedButton(
                              onPressed: _isProcessingRequest
                                  ? null
                                  : () {
                                      Navigator.of(context).pop();
                                      if (widget.onConnectionsUpdated != null) {
                                        widget.onConnectionsUpdated!();
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isProcessingRequest
                                    ? AppColors.grey500
                                    : AppColors.accent,
                                foregroundColor: AppColors.surface,
                                padding: EdgeInsets.symmetric(
                                  vertical: isVerySmallScreen
                                      ? 12
                                      : (isSmallScreen ? 14 : 16),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Done',
                                style: TextStyle(
                                  fontSize: isVerySmallScreen
                                      ? 14
                                      : (isSmallScreen ? 15 : 16),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
