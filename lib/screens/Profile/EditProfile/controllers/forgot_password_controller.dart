// lib/screens/Auth/forgot_password_controller.dart
import 'package:flutter/material.dart';
import 'package:timeleft_clone/services/auth_service.dart';

class ForgotPasswordController {
  final String email;
  final VoidCallback onStateChanged;

  late TextEditingController _emailController;
  bool _isButtonEnabled = true;
  bool _isLinkSent = false;
  bool _isSending = false;

  ForgotPasswordController({
    required this.email,
    required this.onStateChanged,
  }) {
    _emailController = TextEditingController(text: email);
  }

  // Getters
  TextEditingController get emailController => _emailController;
  bool get isButtonEnabled => _isButtonEnabled;
  bool get isLinkSent => _isLinkSent;
  bool get isSending => _isSending;

  void dispose() {
    _emailController.dispose();
  }

  void _setButtonEnabled(bool enabled) {
    _isButtonEnabled = enabled;
    onStateChanged();
  }

  void _setLinkSent(bool sent) {
    _isLinkSent = sent;
    onStateChanged();
  }

  void _setSending(bool sending) {
    _isSending = sending;
    onStateChanged();
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> sendPasswordResetEmail(BuildContext context) async {
    if (!_isButtonEnabled) return;

    _setSending(true);
    _setButtonEnabled(false);

    try {
      final message = await AuthService.sendPasswordResetEmail(email);
      _setSending(false);
      _setLinkSent(true);

      if (message != null) {
        _showSnackBar(context, message, isError: false);
      } else {
        _showSnackBar(context, 'Reset link sent successfully', isError: false);
      }
    } catch (e) {
      _setSending(false);
      _setButtonEnabled(true);
      _showSnackBar(
        context,
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void retrySendEmail(BuildContext context) {
    _setButtonEnabled(true);
    _setLinkSent(false);
    _setSending(false);
    sendPasswordResetEmail(context);
  }

  // Helper methods
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String getEmailDomain() {
    if (email.contains('@')) {
      return email.split('@').last;
    }
    return '';
  }

  // State checks
  bool get canSendEmail => isValidEmail(email) && _isButtonEnabled;
  bool get showSuccessState => _isLinkSent;
}
