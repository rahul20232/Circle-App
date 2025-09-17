import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import '../widgets/google_oauth_webview.dart';

class GoogleOAuthService {
  static const String clientId =
      '625616333977-mogrkp2og1qdl6qjjp7l9cgkmh3r8qft.apps.googleusercontent.com';
  static const String redirectUri =
      'https://5923997ed36c.ngrok-free.app/callback';
  static const String scope = 'openid email profile';

  static String _generateState() {
    final random = Random.secure();
    return base64Url.encode(List.generate(32, (_) => random.nextInt(256)));
  }

  static String _buildAuthUrl() {
    final state = _generateState();
    final params = {
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'response_type': 'code',
      'scope': scope,
      'state': state,
      'access_type': 'offline',
      'prompt': 'select_account',
    };

    final query = params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return 'https://accounts.google.com/oauth/v2/auth?$query';
  }

  static Future<Map<String, dynamic>?> signInWithGoogle(
      BuildContext context) async {
    final authUrl = _buildAuthUrl();

    return await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => GoogleOAuthWebView(authUrl: authUrl),
        fullscreenDialog: true,
      ),
    );
  }

  static Future<Map<String, dynamic>?> exchangeCodeForTokens(
      String code) async {
    try {
      final response = await http.post(
        Uri.parse('https://oauth2.googleapis.com/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': clientId,
          'code': code,
          'grant_type': 'authorization_code',
          'redirect_uri': redirectUri,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Token exchange error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserInfo(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('https://www.googleapis.com/oauth2/v2/userinfo'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('User info error: $e');
      return null;
    }
  }
}
