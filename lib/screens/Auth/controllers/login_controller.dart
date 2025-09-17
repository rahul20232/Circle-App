// lib/screens/Auth/login_controller.dart
import 'package:flutter/material.dart';
import 'package:timeleft_clone/screens/main_screen.dart';
import '../../../services/auth_service.dart';

class LoginController {
  final VoidCallback onStateChanged;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  LoginController({required this.onStateChanged});

  // Getters
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  bool get isLoading => _isLoading;

  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
  }

  bool _validateInputs() {
    return _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty;
  }

  void _setLoadingState(bool loading) {
    _isLoading = loading;
    onStateChanged();
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> loginWithEmail(BuildContext context) async {
    if (!_validateInputs()) {
      _showSnackBar(context, 'Please fill all fields');
      return;
    }

    _setLoadingState(true);

    try {
      final user = await AuthService.loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );

      _setLoadingState(false);

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      } else {
        _showSnackBar(context, 'Login failed. Please check your credentials.');
      }
    } catch (e) {
      _setLoadingState(false);
      _showSnackBar(
          context, 'An error occurred during login. Please try again.');
      print('Login error: $e');
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

  void clearFields() {
    _emailController.clear();
    _passwordController.clear();
  }
}
