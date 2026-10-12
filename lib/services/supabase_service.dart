// lib/services/supabase_service.dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeleft_clone/services/api_service.dart';
import 'package:timeleft_clone/services/deep_link_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://vdsymjzmfrqzvetomswx.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZkc3ltanptZnJxenZldG9tc3d4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg0NDc3MTMsImV4cCI6MjA3NDAyMzcxM30.C9duIFc5ug_HGDkEAz0SCxtOU9nHxJrsb-9sA3SJYD0';

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  static Future<bool> signInWithGoogle() async {
    try {
      print('Starting Google OAuth flow...');

      final result = await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'timeleftclone://login-callback/',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      print('OAuth result: $result');
      return result;
    } catch (e) {
      print('Google sign in error: $e');
      return false;
    }
  }

  // Method to wait for auth state change after OAuth
  static Future<User?> waitForAuthCompletion(
      {Duration timeout = const Duration(seconds: 30)}) async {
    print('Waiting for auth completion...');

    // If user is already signed in, return immediately
    if (currentUser != null) {
      print('User already signed in: ${currentUser!.id}');
      return currentUser;
    }

    // Wait for auth state change
    try {
      await for (final AuthState authState in client.auth.onAuthStateChange) {
        print('Auth state changed: ${authState.event}');

        if (authState.event == AuthChangeEvent.signedIn &&
            authState.session?.user != null) {
          print('User signed in successfully: ${authState.session!.user.id}');
          return authState.session!.user;
        }

        if (authState.event == AuthChangeEvent.signedOut) {
          print('User signed out');
          return null;
        }
      }
    } catch (e) {
      print('Error waiting for auth completion: $e');
      return null;
    }

    return null;
  }

  // Check current user
  static User? get currentUser => client.auth.currentUser;

  // Check if user is signed in
  static bool get isSignedIn => currentUser != null;

  // Sign out
  static Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}
