// lib/screens/Profile/Settings/event_alert_screen.dart
import 'package:flutter/material.dart';
import 'package:circle_app/theme/app_colors.dart';
import 'package:circle_app/screens/Profile/Settings/controllers/event_alert_controller.dart';
import 'package:circle_app/screens/Profile/Settings/components/event_alert_components.dart';

class EventAlertScreen extends StatefulWidget {
  @override
  _EventAlertScreenState createState() => _EventAlertScreenState();
}

class _EventAlertScreenState extends State<EventAlertScreen> {
  late EventAlertController _controller;
  late EventAlertComponents _components;

  @override
  void initState() {
    super.initState();
    _controller = EventAlertController(
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    _components = EventAlertComponents(controller: _controller);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Event Alerts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _components.buildDescriptionText(),
                  SizedBox(height: 40),
                  _components.buildNotificationOptions(),
                ],
              ),
            ),
          ),
          _components.buildSaveButton(context),
        ],
      ),
    );
  }
}
