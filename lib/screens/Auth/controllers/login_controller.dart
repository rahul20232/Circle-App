// lib/screens/Auth/controllers/login_controller.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:circle_app/screens/main_screen.dart';
import 'package:circle_app/services/supabase_service.dart';
import '../../../services/auth_service.dart';

class LoginController {
  final VoidCallback onStateChanged;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  LoginController({required this.onStateChanged});

  // Getters
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  bool get isLoading => _isLoading;
  bool get isPasswordVisible => _isPasswordVisible;

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

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    onStateChanged();
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
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

  // lib/screens/Auth/controllers/login_controller.dart
  Future<void> signInWithGoogle(BuildContext context) async {
    _setLoadingState(true);

    try {
      print('Starting Google OAuth flow...');

      // Step 1: Start OAuth flow
      final oauthStarted = await SupabaseService.signInWithGoogle();
      if (!oauthStarted) {
        throw Exception('Failed to start OAuth flow');
      }

      // Step 2: Wait for OAuth completion
      print('Waiting for OAuth completion...');
      final supabaseUser = await SupabaseService.waitForAuthCompletion(
        timeout: Duration(seconds: 30),
      );

      if (supabaseUser == null) {
        throw Exception('OAuth flow completed but no user found');
      }

      print('OAuth completed successfully for user: ${supabaseUser.id}');

      // Step 3: Extract user information
      final email = supabaseUser.email;

      if (email == null) {
        throw Exception('No email found in Google account');
      }

      print('Extracted user info - Email: $email');

      // Step 4: Check if user exists in your backend
      print('Checking if user exists in backend...');
      final userExists = await AuthService.checkUserExists(email);

      if (!userExists) {
        print('User does not exist in backend - sign up required');

        // Sign out from Supabase since we're not allowing new users via Google sign-in
        await SupabaseService.signOut();

        _setLoadingState(false);

        if (context.mounted) {
          _showSnackBar(
            context,
            'No account found with this Google account. Please sign up first using email.',
          );
        }
        return;
      }

      // Step 5: User exists, proceed with authentication
      final displayName = supabaseUser.userMetadata?['full_name'] ??
          supabaseUser.userMetadata?['name'] ??
          email.split('@')[0];
      final googleId = supabaseUser.id;
      final photoUrl = supabaseUser.userMetadata?['avatar_url'] ??
          supabaseUser.userMetadata?['picture'];

      print('User exists, authenticating with custom API...');
      final customUser = await AuthService.authenticateWithGoogle(
        email,
        displayName,
        googleId,
        photoUrl,
      );

      print('Custom API authentication successful');
      _setLoadingState(false);

      // Step 6: Navigate to main screen
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
          (route) => false, // Clear navigation stack
        );
      }
    } catch (e) {
      _setLoadingState(false);
      print('Google sign in error: $e');

      // Sign out from Supabase if auth failed
      try {
        await SupabaseService.signOut();
        print('Signed out from Supabase after error');
      } catch (signOutError) {
        print('Error signing out from Supabase: $signOutError');
      }

      if (context.mounted) {
        String errorMessage = 'Google sign in failed. Please try again.';

        if (e.toString().contains('No user found')) {
          errorMessage =
              'Google sign in was cancelled or failed. Please try again.';
        } else if (e.toString().contains('timeout')) {
          errorMessage =
              'Sign in timed out. Please check your connection and try again.';
        }

        _showSnackBar(context, errorMessage);
      }
    }
  }

  void clearFields() {
    _emailController.clear();
    _passwordController.clear();
  }
}
