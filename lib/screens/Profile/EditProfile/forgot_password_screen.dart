// lib/screens/Auth/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:timeleft_clone/screens/Profile/EditProfile/controllers/forgot_password_controller.dart';
import 'package:timeleft_clone/screens/Profile/EditProfile/components/forgot_password_components.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _components.buildInstructionText(),
                const SizedBox(height: 20),
                _components.buildEmailField(),
                SizedBox(height: 575),
                _components.buildSendResetButton(context),
              ],
            ),
            if (_controller.isLinkSent)
              _components.buildSuccessOverlay(context),
          ],
        ),
      ),
    );
  }
}
