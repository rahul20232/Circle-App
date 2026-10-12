// lib/screens/auth/google_auth_webview.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoogleAuthWebView extends StatefulWidget {
  @override
  _GoogleAuthWebViewState createState() => _GoogleAuthWebViewState();
}

class _GoogleAuthWebViewState extends State<GoogleAuthWebView> {
  late WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('timeleftclone://')) {
              Navigator.pop(context, true); // Auth completed
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(
          'https://vdsymjzmfrqzvetomswx.supabase.co/auth/v1/authorize?provider=google&redirect_to=timeleftclone%3A%2F%2Flogin-callback%2F'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign in with Google'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
