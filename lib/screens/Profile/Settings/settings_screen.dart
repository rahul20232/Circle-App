// lib/screens/Profile/Settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:circle_app/theme/app_colors.dart';
import 'package:circle_app/screens/Profile/Settings/controllers/settings_controller.dart';
import 'package:circle_app/screens/Profile/Settings/components/settings_components.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsController _controller;
  late SettingsComponents _components;

  @override
  void initState() {
    super.initState();
    _controller = SettingsController(
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    _components = SettingsComponents(controller: _controller);
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          _components.buildNotificationsSection(context),
          SizedBox(height: 20),
          _components.buildSubscriptionSection(context),
          SizedBox(height: 20),
          _components.buildLegalSection(context),
          SizedBox(height: 40),
          _components.buildLogoutButton(context),
          SizedBox(height: 16),
          _components.buildDeleteAccountButton(context),
          SizedBox(height: 30),
          _components.buildAppVersion(),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
