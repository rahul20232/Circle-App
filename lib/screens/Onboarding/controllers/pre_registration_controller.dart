// lib/screens/Onboarding/controllers/pre_registration_controller.dart
import 'package:flutter/material.dart';
import 'package:timeleft_clone/services/supabase_service.dart';
import 'package:timeleft_clone/services/auth_service.dart';
import 'package:timeleft_clone/screens/Auth/login_screen.dart';

class PreRegistrationController {
  final BuildContext context;
  final VoidCallback onStateChanged;
  final Map<String, String>? personalityData;
  final Map<String, String>? identityData;

  bool _isLoading = false;

  PreRegistrationController({
    required this.context,
    required this.onStateChanged,
    this.personalityData,
    this.identityData,
  });

  bool get isLoading => _isLoading;

  void _setLoading(bool loading) {
    _isLoading = loading;
    onStateChanged();
  }

  Future<void> handleGoogleSignUp() async {
    _setLoading(true);

    try {
      print('Starting Google sign up flow...');

      final oauthStarted = await SupabaseService.signInWithGoogle();
      if (!oauthStarted) {
        throw Exception('Failed to start OAuth flow');
      }

      print('Waiting for OAuth completion...');
      final supabaseUser = await SupabaseService.waitForAuthCompletion(
        timeout: Duration(seconds: 30),
      );

      if (supabaseUser == null) {
        throw Exception('OAuth flow completed but no user found');
      }

      print('OAuth completed for user: ${supabaseUser.id}');

      final email = supabaseUser.email;
      if (email == null) {
        throw Exception('No email found in Google account');
      }

      final displayName = supabaseUser.userMetadata?['full_name'] ??
          supabaseUser.userMetadata?['name'] ??
          email.split('@')[0];
      final googleId = supabaseUser.id;
      final photoUrl = supabaseUser.userMetadata?['avatar_url'] ??
          supabaseUser.userMetadata?['picture'];

      print('Creating new user with Google: $email');

      // CHANGE THIS LINE - use new method with onboarding data
      await AuthService.signUpWithGoogleAndOnboardingData(
        email: email,
        displayName: displayName,
        googleId: googleId,
        photoUrl: photoUrl,
        personalityData: personalityData ?? {}, // ADD THIS
        identityData: identityData ?? {}, // ADD THIS
      );

      _setLoading(false);

      print('User created successfully');

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
          (route) => false,
        );

        Future.delayed(Duration(milliseconds: 500), () {
          if (context.mounted) {
            _showVerificationModal(email);
          }
        });
      }
    } catch (e) {
      _setLoading(false);
      print('Google sign up error: $e');

      if (!e.toString().contains('ACCOUNT_EXISTS') &&
          !e.toString().contains('already registered')) {
        try {
          await SupabaseService.signOut();
        } catch (signOutError) {
          print('Error signing out: $signOutError');
        }
      }

      if (context.mounted) {
        _showErrorMessage(e.toString());
      }
    }
  }

  void _showVerificationModal(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Account Created!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Your account has been created successfully with Google.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
            SizedBox(height: 8),
            Text(
              email,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Continue to Login',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorMessage(String error) {
    String userMessage = 'Sign up failed. Please try again.';
    bool shouldNavigateToLogin = false;

    if (error.contains('already registered') ||
        error.contains('ACCOUNT_EXISTS')) {
      userMessage = 'Account already exists. Redirecting to login...';
      shouldNavigateToLogin = true;
    } else if (error.contains('timeout')) {
      userMessage =
          'Sign up timed out. Please check your connection and try again.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(userMessage),
        backgroundColor:
            shouldNavigateToLogin ? Colors.orange : Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: Duration(seconds: shouldNavigateToLogin ? 2 : 4),
      ),
    );

    // Navigate to login after showing message
    if (shouldNavigateToLogin) {
      Future.delayed(Duration(seconds: 2), () {
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(),
            ),
            (route) => false,
          );
        }
      });
    }
  }
}
