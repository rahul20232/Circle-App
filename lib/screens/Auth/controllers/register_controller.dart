// lib/screens/Auth/register_controller.dart
import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';

class RegisterController {
  final VoidCallback onStateChanged;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  RegisterController({required this.onStateChanged});

  // Getters
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get nameController => _nameController;
  bool get isLoading => _isLoading;

  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
  }

  bool _validateInputs() {
    return _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _nameController.text.isNotEmpty;
  }

  void _setLoadingState(bool loading) {
    _isLoading = loading;
    onStateChanged();
  }

  void _showSnackBar(BuildContext context, String message,
      {int durationSeconds = 3}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: durationSeconds),
      ),
    );
  }

  Future<void> registerWithEmail(BuildContext context) async {
    if (!_validateInputs()) {
      _showSnackBar(context, 'Please fill all fields');
      return;
    }

    _setLoadingState(true);

    try {
      final message = await AuthService.registerWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );

      _setLoadingState(false);

      if (message != null) {
        _showSnackBar(context, message, durationSeconds: 5);
        Navigator.pop(context); // Go back to login screen
      } else {
        _showSnackBar(context, 'Registration failed');
      }
    } catch (e) {
      _setLoadingState(false);
      _showSnackBar(
          context, 'An error occurred during registration. Please try again.');
      print('Registration error: $e');
    }
  }

  // Future<void> signInWithGoogle(BuildContext context) async {
  //   _setLoadingState(true);

  //   try {
  //     final user = await AuthService.signInWithGoogle(context);
  //     _setLoadingState(false);

  //     if (user != null) {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => MainScreen()),
  //       );
  //     } else {
  //       _showSnackBar(context, 'Google sign in failed');
  //     }
  //   } catch (e) {
  //     _setLoadingState(false);
  //     _showSnackBar(context, 'Google sign in failed. Please try again.');
  //     print('Google sign in error: $e');
  //   }
  // }

  void navigateToLogin(BuildContext context) {
    Navigator.pop(context);
  }

  void clearFields() {
    _emailController.clear();
    _passwordController.clear();
    _nameController.clear();
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool isValidPassword(String password) {
    return password.length >= 6; // Basic password validation
  }

  bool isValidName(String name) {
    return name.trim().length >= 2;
  }
}
