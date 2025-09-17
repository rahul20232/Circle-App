import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/google_oauth_service.dart';

class GoogleOAuthWebView extends StatefulWidget {
  final String authUrl;
  
  const GoogleOAuthWebView({Key? key, required this.authUrl}) : super(key: key);
  
  @override
  _GoogleOAuthWebViewState createState() => _GoogleOAuthWebViewState();
}

class _GoogleOAuthWebViewState extends State<GoogleOAuthWebView> {
  late final WebViewController controller;
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              isLoading = progress < 100;
            });
          },
          onPageStarted: (String url) {
            _handleNavigation(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            _handleNavigation(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authUrl));
  }
  
  void _handleNavigation(String url) {
  print('Navigation URL: $url'); // Debug print
  
  // Check if we've reached a page with the authorization code
  if (url.contains('code=')) {
    final uri = Uri.parse(url);
    final code = uri.queryParameters['code'];
    
    if (code != null) {
      _handleAuthorizationCode(code);
      return;
    }
  }
  
  // Check for error
  if (url.contains('error=')) {
    final uri = Uri.parse(url);
    final error = uri.queryParameters['error'];
    Navigator.pop(context, {'error': error ?? 'OAuth error'});
    return;
  }
  
  // Alternative: Check page content for authorization code
  _checkPageForCode();
}

Future<void> _checkPageForCode() async {
  // This will check if the page contains an authorization code display
  final html = await controller.runJavaScriptReturningResult(
    'document.documentElement.outerHTML'
  );
  
  if (html.toString().contains('authorization code')) {
    // Look for the code pattern in the HTML
    final codeMatch = RegExp(r'code=([^&\s]+)').firstMatch(html.toString());
    if (codeMatch != null) {
      final code = codeMatch.group(1);
      if (code != null) {
        _handleAuthorizationCode(code);
      }
    }
  }
}
  
  Future<void> _handleAuthorizationCode(String code) async {
    setState(() => isLoading = true);
    
    try {
      // Exchange code for tokens
      final tokenData = await GoogleOAuthService.exchangeCodeForTokens(code);
      
      if (tokenData == null || tokenData['access_token'] == null) {
        Navigator.pop(context, {'error': 'Failed to get access token'});
        return;
      }
      
      // Get user information
      final userInfo = await GoogleOAuthService.getUserInfo(tokenData['access_token']);
      
      if (userInfo == null) {
        Navigator.pop(context, {'error': 'Failed to get user information'});
        return;
      }
      
      // Return user data
      Navigator.pop(context, {
        'success': true,
        'user': userInfo,
        'tokens': tokenData,
      });
      
    } catch (e) {
      Navigator.pop(context, {'error': e.toString()});
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign in with Google'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context, {'cancelled': true}),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}