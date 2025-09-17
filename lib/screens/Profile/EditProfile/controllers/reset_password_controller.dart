// lib/screens/Auth/reset_password_controller.dart
import 'package:flutter/material.dart';
import '../../../../services/auth_service.dart';

class ResetPasswordController {
  final String? initialToken;
  final VoidCallback onStateChanged;

  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  ResetPasswordController({
    this.initialToken,
    required this.onStateChanged,
  });

  // Getters
  TextEditingController get tokenController => _tokenController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get confirmPasswordController =>
      _confirmPasswordController;
  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;

  void initialize() {
    // Pre-fill token if provided
    if (initialToken != null && initialToken!.isNotEmpty) {
      _tokenController.text = initialToken!;
    }
  }

  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    onStateChanged();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    onStateChanged();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    onStateChanged();
  }

  bool _validateInputs() {
    return _tokenController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty;
  }

  bool _validatePasswords() {
    return _passwordController.text == _confirmPasswordController.text;
  }

  bool _validatePasswordLength() {
    return _passwordController.text.length >= 6;
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: isError ? 3 : 4),
      ),
    );
  }

  Future<void> resetPassword(BuildContext context) async {
    // Validation
    if (!_validateInputs()) {
      _showSnackBar(context, 'Please fill all fields');
      return;
    }

    if (!_validatePasswords()) {
      _showSnackBar(context, 'Passwords do not match');
      return;
    }

    if (!_validatePasswordLength()) {
      _showSnackBar(context, 'Password must be at least 6 characters');
      return;
    }

    _setLoading(true);

    try {
      final success = await AuthService.resetPassword(
        _tokenController.text.trim(),
        _passwordController.text,
      );

      _setLoading(false);

      if (success) {
        _showSnackBar(
          context,
          'Password reset successfully! You can now log in.',
          isError: false,
        );

        // Navigate back to login screen
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      _setLoading(false);
      _showSnackBar(
        context,
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // Helper validation methods
  String? validateToken(String token) {
    if (token.isEmpty) return 'Token is required';
    if (token.length < 6) return 'Token is too short';
    return null;
  }

  String? validatePassword(String password) {
    if (password.isEmpty) return 'Password is required';
    if (password.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? validateConfirmPassword(String confirmPassword, String password) {
    if (confirmPassword.isEmpty) return 'Confirm password is required';
    if (confirmPassword != password) return 'Passwords do not match';
    return null;
  }

  // State checks
  bool get hasValidInputs =>
      _validateInputs() && _validatePasswords() && _validatePasswordLength();
  bool get canSubmit => hasValidInputs && !_isLoading;

  // Clear methods
  void clearAllFields() {
    _tokenController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
  }

  void clearPasswords() {
    _passwordController.clear();
    _confirmPasswordController.clear();
  }
}
