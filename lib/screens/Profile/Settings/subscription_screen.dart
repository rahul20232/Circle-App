// lib/screens/Profile/Settings/subscription_screen.dart
import 'package:flutter/material.dart';
import 'package:timeleft_clone/screens/Profile/Settings/controllers/subscription_controller.dart';
import 'package:timeleft_clone/screens/Profile/Settings/components/subscription_components.dart';

class SubscriptionScreen extends StatefulWidget {
  final VoidCallback? onSubscribed;

  const SubscriptionScreen({Key? key, this.onSubscribed}) : super(key: key);

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  late SubscriptionController _controller;
  late SubscriptionComponents _components;

  @override
  void initState() {
    super.initState();
    _controller = SubscriptionController(
      onSubscribed: widget.onSubscribed,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    _components = SubscriptionComponents(controller: _controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;

    return Container(
      color: Color(0xFFFEF1DE),
      child: Scaffold(
        backgroundColor: Color(0xFFFEF1DE),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _components.buildImageCarousel(
                  context, isSmallScreen, screenHeight),
              _components.buildContentSection(context, isSmallScreen),
            ],
          ),
        ),
      ),
    );
  }
}
