// lib/screens/Profile/Settings/delete_account_controller.dart
import 'package:flutter/material.dart';
import 'package:timeleft_clone/services/auth_service.dart';
import 'package:timeleft_clone/screens/Auth/login_screen.dart';

class DeleteAccountController {
  final VoidCallback onStateChanged;

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmationController = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;

  DeleteAccountController({required this.onStateChanged});

  // Getters
  TextEditingController get passwordController => _passwordController;
  TextEditingController get confirmationController => _confirmationController;
  bool get isLoading => _isLoading;
  bool get showPassword => _showPassword;

  void dispose() {
    _passwordController.dispose();
    _confirmationController.dispose();
  }

  void togglePasswordVisibility() {
    _showPassword = !_showPassword;
    onStateChanged();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    onStateChanged();
  }

  bool _validatePassword() {
    return _passwordController.text.isNotEmpty;
  }

  bool _validateConfirmation() {
    return _confirmationController.text.toLowerCase() == "delete my account";
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> deleteAccount(BuildContext context) async {
    if (!_validatePassword()) {
      _showSnackBar(context, 'Please enter your password');
      return;
    }

    if (!_validateConfirmation()) {
      _showSnackBar(context, 'Please type "delete my account" to confirm');
      return;
    }

    _setLoading(true);

    try {
      final success = await AuthService.deleteAccount(
        _passwordController.text,
        _confirmationController.text,
      );

      if (success) {
        // Navigate to login screen and clear all previous screens
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      _showSnackBar(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      _setLoading(false);
    }
  }

  // Validation helpers
  String? validatePasswordInput(String password) {
    if (password.isEmpty) return 'Password is required';
    return null;
  }

  String? validateConfirmationInput(String confirmation) {
    if (confirmation.isEmpty) return 'Confirmation text is required';
    if (confirmation.toLowerCase() != "delete my account") {
      return 'Please type "delete my account" exactly';
    }
    return null;
  }

  // State checks
  bool get canDelete =>
      _validatePassword() && _validateConfirmation() && !_isLoading;

  bool get hasPasswordInput => _passwordController.text.isNotEmpty;
  bool get hasConfirmationInput => _confirmationController.text.isNotEmpty;

  // Clear methods
  void clearAllFields() {
    _passwordController.clear();
    _confirmationController.clear();
  }

  void clearPassword() {
    _passwordController.clear();
  }

  void clearConfirmation() {
    _confirmationController.clear();
  }

  // Security helpers
  bool get isConfirmationTextCorrect =>
      _confirmationController.text.toLowerCase() == "delete my account";

  String get requiredConfirmationText => "delete my account";
}
