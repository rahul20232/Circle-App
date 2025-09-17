// lib/screens/Notifications/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:timeleft_clone/screens/Notifications/controllers/notifications_controller.dart';
import 'package:timeleft_clone/screens/Notifications/components/notifications_components.dart';

class NotificationsScreenContent extends StatefulWidget {
  final Function(int)? onUnreadCountChanged;

  const NotificationsScreenContent({
    Key? key,
    this.onUnreadCountChanged,
  }) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreenContent>
    with SingleTickerProviderStateMixin {
  late NotificationsController _controller;
  late NotificationsComponents _components;

  @override
  void initState() {
    super.initState();
    _controller = NotificationsController(
      vsync: this,
      onUnreadCountChanged: widget.onUnreadCountChanged,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    _components = NotificationsComponents(controller: _controller);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFEF1DE),
        elevation: 0,
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: _controller.refreshNotifications,
          ),
        ],
        bottom: _controller.shouldShowTabs
            ? PreferredSize(
                preferredSize: Size.fromHeight(60),
                child: Container(
                  color: Color(0xFFFEF1DE),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: _components.buildTabButton(
                            title: 'Bookings',
                            unreadCount: _controller.bookingUnreadCount,
                            isSelected: _controller.tabController.index == 0,
                            onTap: () {
                              _controller.tabController.animateTo(0);
                              setState(() {});
                            },
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _components.buildTabButton(
                            title: 'Connections',
                            unreadCount: _controller.connectionUnreadCount,
                            isSelected: _controller.tabController.index == 1,
                            onTap: () {
                              _controller.tabController.animateTo(1);
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : null,
      ),
      backgroundColor: Color(0xFFFEF1DE),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: Color(0xFF6B46C1)),
      );
    }

    if (_controller.errorMessage != null) {
      return _components.buildErrorState(_controller.errorMessage!);
    }

    if (_controller.notifications.isEmpty) {
      return _components.buildEmptyState();
    }

    return TabBarView(
      controller: _controller.tabController,
      children: [
        _components.buildNotificationsList(
          _controller.bookingNotifications,
          'bookings',
        ),
        _components.buildNotificationsList(
          _controller.connectionNotifications,
          'connections',
        ),
      ],
    );
  }
}
