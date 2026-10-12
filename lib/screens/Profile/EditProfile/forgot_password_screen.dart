// lib/screens/Auth/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:circle_app/screens/Profile/EditProfile/controllers/forgot_password_controller.dart';
import 'package:circle_app/screens/Profile/EditProfile/components/forgot_password_components.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String email;

  const ForgotPasswordScreen({Key? key, required this.email}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late ForgotPasswordController _controller;
  late ForgotPasswordComponents _components;

  @override
  void initState() {
    super.initState();
    _controller = ForgotPasswordController(
      email: widget.email,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    _components = ForgotPasswordComponents(controller: _controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF1DE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEF1DE),
        elevation: 0,
        title: const Text(
          "Forgot Password",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              // Use a flexible layout instead of hardcoded spacing
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _components.buildInstructionText(),
                  const SizedBox(height: 20),
                  _components.buildEmailField(),

                  // Use Spacer to push button to bottom
                  const Spacer(),

                  // Button at the bottom with safe area consideration
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom > 0
                          ? MediaQuery.of(context).viewInsets.bottom + 20
                          : 20,
                    ),
                    child: _components.buildSendResetButton(context),
                  ),
                ],
              ),

              // Success overlay - positioned responsively
              if (_controller.isLinkSent)
                Positioned(
                  top: 140,
                  left: 0,
                  right: 0,
                  child: _components.buildSuccessOverlay(context),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
