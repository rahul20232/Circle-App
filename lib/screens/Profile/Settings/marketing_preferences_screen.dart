// lib/screens/Profile/Settings/marketing_alert_screen.dart
import 'package:flutter/material.dart';
import 'package:timeleft_clone/screens/Profile/Settings/controllers/marketing_alert_controller.dart';
import 'package:timeleft_clone/screens/Profile/Settings/components/marketing_alert_components.dart';

class MarketingAlertScreen extends StatefulWidget {
  @override
  _MarketingAlertScreenState createState() => _MarketingAlertScreenState();
}

class _MarketingAlertScreenState extends State<MarketingAlertScreen> {
  late MarketingAlertController _controller;
  late MarketingAlertComponents _components;

  @override
  void initState() {
    super.initState();
    _controller = MarketingAlertController(
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    _components = MarketingAlertComponents(controller: _controller);
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
        backgroundColor: Color(0xFFFEF1DE),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFFEF1DE),
      appBar: AppBar(
        backgroundColor: Color(0xFFFEF1DE),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Marketing',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
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
