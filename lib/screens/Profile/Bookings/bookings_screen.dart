// lib/screens/Profile/Bookings/bookings_screen.dart
import 'package:flutter/material.dart';
import 'package:circle_app/theme/app_colors.dart';
import 'package:circle_app/screens/Profile/Bookings/controllers/bookings_controller.dart';
import 'package:circle_app/screens/Profile/Bookings/components/bookings_components.dart';
import 'package:circle_app/services/push_notification_service.dart';

class BookingsScreen extends StatefulWidget {
  @override
  _BookingsScreenState createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  late BookingsController _controller;
  late BookingsComponents _components;

  NavigatorState? _cachedNavigator;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cache the navigator reference for safe disposal
    _cachedNavigator = Navigator.of(context);
  }

  @override
  void initState() {
    super.initState();
    _controller = BookingsController(
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    _components = BookingsComponents(controller: _controller);

    PushNotificationService.setContext(context);
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.ink),
          onPressed: () => _controller.navigateToMainScreen(context),
        ),
        title: Text(
          'Bookings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: AppColors.ink),
            onPressed: () => _components.showNotificationTestDialog(context),
            tooltip: 'Test Notification',
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.ink),
            onPressed: _controller.loadUserBookings,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (_controller.errorMessage != null) {
      return _components.buildErrorState(_controller.errorMessage!);
    }

    if (_controller.displayableBookings.isEmpty) {
      return _components.buildEmptyState(context);
    }

    return _components.buildBookingsList(context);
  }
}
