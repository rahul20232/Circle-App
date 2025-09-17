import 'package:flutter/material.dart';
import 'package:timeleft_clone/services/api_service.dart';
import 'package:timeleft_clone/services/notification_service.dart';
import 'Home/home_screen_content.dart';
import 'Notifications/notifications_screen_content.dart';
import 'Connect/connect_screen_content.dart';
import 'Profile/profile_screen_content.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  final int? dinnerIdForAttendees; // Add this parameter

  const MainScreen({
    Key? key,
    this.initialIndex = 0,
    this.dinnerIdForAttendees, // Add this parameter
  }) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  int _previousIndex = 0;
  late PageController _pageController;
  final GlobalKey<ConnectScreenContentState> _connectScreenKey =
      GlobalKey<ConnectScreenContentState>();

  int _notificationUnreadCount = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _loadInitialNotificationCount();
    _screens = [
      KeepAliveWrapper(
          child: HomeScreenContent(onSwitchToConnect: () => _switchToTab(2))),
      KeepAliveWrapper(child: NotificationsScreenContent(
        onUnreadCountChanged: (count) {
          setState(() {
            _notificationUnreadCount = count;
          });
        },
      )),
      KeepAliveWrapper(
        child: ConnectScreenContent(
          key: _connectScreenKey,
          dinnerIdForAttendees:
              widget.dinnerIdForAttendees, // Pass the dinner ID
        ),
      ),
      KeepAliveWrapper(child: ProfileScreenContent()),
    ];
    _currentIndex = widget.initialIndex;
    _previousIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  Future<void> _loadInitialNotificationCount() async {
    try {
      final notifications = await NotificationEventService.getUserNotifications(
        unreadOnly: false,
        skip: 0,
        limit: 100,
      );

      if (notifications != null && mounted) {
        final unreadCount = notifications.where((n) => !n.isRead).length;
        setState(() {
          _notificationUnreadCount = unreadCount;
        });
      }
    } catch (e) {
      print('Error loading initial notification count: $e');
    }
  }

  void _switchToTab(int index) {
    if (index == _currentIndex) return;
    _onTabTapped(index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = index;
    });

    // Notify Connect screen when it becomes visible
    if (index == 2) {
      _connectScreenKey.currentState?.onTabSelected();
    }

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: _screens,
        onPageChanged: (index) {
          setState(() {
            _previousIndex = _currentIndex;
            _currentIndex = index;
          });

          if (index == 2) {
            _connectScreenKey.currentState?.onTabSelected();
          }
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.red.shade400,
          unselectedItemColor: Colors.grey.shade600,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(
              icon: _buildNotificationIcon(),
              label: '',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline), label: ''),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline), label: ''),
          ],
        ),
      ),
    );
  }

  // Add method to build notification icon with badge
  Widget _buildNotificationIcon() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(Icons.notifications_outlined),
        if (_notificationUnreadCount > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Color(0xFF6B46C1),
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                _notificationUnreadCount > 99
                    ? '99+'
                    : _notificationUnreadCount.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

// Wrapper widget to keep screens alive
class KeepAliveWrapper extends StatefulWidget {
  final Widget child;

  const KeepAliveWrapper({Key? key, required this.child}) : super(key: key);

  @override
  _KeepAliveWrapperState createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
