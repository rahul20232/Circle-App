// lib/services/deep_link_handler.dart
import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeleft_clone/screens/Profile/EditProfile/reset_password_screen.dart';

class DeepLinkHandler {
  static final _appLinks = AppLinks();
  static StreamSubscription<Uri>? _linkSubscription;
  static bool _isProcessing = false;
  static GlobalKey<NavigatorState>? _navigatorKey;

  static Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    _navigatorKey = navigatorKey;
    // Handle incoming links when app is already running
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      print('Received deep link: $uri');
      _handleDeepLink(uri);
    });

    // Handle initial link when app is launched via deep link
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      print('Initial deep link: $initialUri');
      _handleDeepLink(initialUri);
    }
  }

  static void _handleDeepLink(Uri uri) {
    if (_isProcessing) {
      print('Already processing a deep link, skipping...');
      return;
    }

    if (uri.scheme == 'timeleftclone' && uri.host == 'reset-password') {
      final token = uri.queryParameters['token'];
      if (token != null) {
        print('Received password reset token: $token');
        // Navigate to reset password screen
        // You'll need to pass NavigatorKey or use a navigation service
        _navigateToResetPassword(token);
      }
      return;
    }

    if (uri.scheme == 'timeleftclone' && uri.host == 'login-callback') {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser != null) {
        print('User already authenticated, skipping callback processing');
        return;
      }

      _isProcessing = true;

      print('Handling auth callback');
      try {
        final fullUrl = uri.toString();
        print('Processing auth URL: $fullUrl');

        Supabase.instance.client.auth.getSessionFromUrl(uri);

        print('Auth callback processed successfully');
      } catch (e) {
        // Ignore these specific OAuth errors - they're expected after signup
        final errorStr = e.toString();
        if (errorStr.contains('Code verifier could not be found') ||
            errorStr.contains('invalid flow state') ||
            errorStr.contains('flow_state_not_found')) {
          print('OAuth callback already processed (expected): $e');
        } else {
          print('Unexpected error handling auth callback: $e');
        }
      } finally {
        Future.delayed(Duration(seconds: 2), () {
          _isProcessing = false;
        });
      }
    }
  }

  static void _navigateToResetPassword(String token) {
    if (_navigatorKey?.currentContext != null) {
      Navigator.of(_navigatorKey!.currentContext!).push(
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(token: token),
        ),
      );
    } else {
      print('ERROR: Navigator key not available');
    }
  }

  static void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }
}
