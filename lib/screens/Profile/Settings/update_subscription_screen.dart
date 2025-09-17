// lib/screens/Profile/Settings/update_subscription_screen.dart
import 'package:flutter/material.dart';
import 'package:timeleft_clone/screens/Profile/Settings/controllers/update_subscription_controller.dart';
import 'package:timeleft_clone/screens/Profile/Settings/components/update_subscription_components.dart';

class UpdateSubscriptionScreen extends StatefulWidget {
  @override
  _UpdateSubscriptionScreenState createState() =>
      _UpdateSubscriptionScreenState();
}

class _UpdateSubscriptionScreenState extends State<UpdateSubscriptionScreen> {
  late UpdateSubscriptionController _controller;
  late UpdateSubscriptionComponents _components;

  @override
  void initState() {
    super.initState();
    _controller = UpdateSubscriptionController(
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    _components = UpdateSubscriptionComponents(controller: _controller);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFFEF1DE),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Scaffold(
            backgroundColor: Color(0xFFFEF1DE),
            body: Stack(
              children: [
                _components.buildMainContent(context),
                _components.buildDotsIndicator(context),
                _components.buildTextOverlay(context),
                _components.buildCloseButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
