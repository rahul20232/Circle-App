// lib/screens/Profile/Settings/controllers/delete_account_controller.dart

import 'package:flutter/material.dart';
import 'package:circle_app/services/auth_service.dart';
import 'package:circle_app/screens/Onboarding/initial_onboarding_screen.dart'; // Changed from LoginScreen

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

  // Check if current user is a Google user
  bool get isGoogleUser => AuthService.currentUser?.isGoogleUser ?? false;

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
    // Skip password validation for Google users
    if (isGoogleUser) return true;
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
      // For Google users, send empty password
      final password = isGoogleUser ? '' : _passwordController.text;

      final success = await AuthService.deleteAccount(
        password,
        _confirmationController.text,
      );

      if (success) {
        // Navigate to InitialOnboardingScreen instead of LoginScreen
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                InitialOnboardingScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              // Fade transition for account deletion
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(milliseconds: 300),
          ),
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
    if (isGoogleUser) return null; // Skip validation for Google users
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
