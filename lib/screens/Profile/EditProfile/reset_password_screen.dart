// lib/screens/Auth/reset_password_screen.dart
import 'package:flutter/material.dart';
import 'package:circle_app/theme/app_colors.dart';
import 'package:circle_app/screens/Profile/EditProfile/controllers/reset_password_controller.dart';
import 'package:circle_app/screens/Profile/EditProfile/components/reset_password_components.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? token;

  const ResetPasswordScreen({Key? key, this.token}) : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  late ResetPasswordController _controller;
  late ResetPasswordComponents _components;

  @override
  void initState() {
    super.initState();
    _controller = ResetPasswordController(
      initialToken: widget.token,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    _components = ResetPasswordComponents(controller: _controller);
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
        title: const Text(
          "Reset Password",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.ink),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _components.buildInstructionText(),
            const SizedBox(height: 30),
            _components.buildTokenField(),
            const SizedBox(height: 20),
            _components.buildNewPasswordField(),
            const SizedBox(height: 20),
            _components.buildConfirmPasswordField(),
            const SizedBox(height: 40),
            _components.buildResetButton(context),
            const SizedBox(height: 20),
            _components.buildInstructions(),
          ],
        ),
      ),
    );
  }
}
