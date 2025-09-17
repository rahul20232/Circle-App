import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class GuideWebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const GuideWebViewScreen({
    Key? key,
    required this.url,
    this.title = 'Guide',
  }) : super(key: key);

  @override
  _GuideWebViewScreenState createState() => _GuideWebViewScreenState();
}

class _GuideWebViewScreenState extends State<GuideWebViewScreen> {
  late final WebViewController controller;
  bool isLoading = true;
  String? errorMessage;
  bool _isDisposed = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
          'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1')
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (!_isDisposed && mounted) {
              if (progress == 100) {
                setState(() {
                  isLoading = false;
                });
              }
            }
          },
          onPageStarted: (String url) {
            if (!_isDisposed && mounted) {
              setState(() {
                isLoading = true;
                errorMessage = null;
                _hasError = false;
              });
            }
          },
          onPageFinished: (String url) {
            if (!_isDisposed && mounted) {
              setState(() {
                isLoading = false;
              });

              // Remove automatic content checking - let the user decide
              // if they want to open in browser via the button
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (!_isDisposed && mounted) {
              setState(() {
                isLoading = false;
                _hasError = true;
                errorMessage = _getErrorMessage(error);
              });
            }
            print('WebView error: ${error.errorCode} - ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      );

    _loadUrl();
  }

  String _getErrorMessage(WebResourceError error) {
    if (error.description.contains('X-Frame-Options') ||
        error.description.contains('frame') ||
        error.errorCode == -6) {
      // ERR_CONNECTION_REFUSED
      return 'This website cannot be displayed in the app due to security restrictions. Please open it in your browser instead.';
    }
    return 'Failed to load page: ${error.description}';
  }

  void _checkPageContent() async {
    if (_isDisposed || _hasError) return;

    try {
      // Only check for obvious error conditions, not content-based assumptions
      String? title = await controller.getTitle();

      // Only flag as error if the page is clearly broken or blank
      // Don't assume Vite pages are broken - they might be legitimate development sites
      if (title == null || title.trim().isEmpty) {
        // Wait a bit more for dynamic content to load
        await Future.delayed(Duration(seconds: 2));
        title = await controller.getTitle();

        if (title == null || title.trim().isEmpty) {
          setState(() {
            _hasError = true;
            errorMessage =
                'This page appears to be blank. Please open it in your browser for the best experience.';
          });
        }
      }
    } catch (e) {
      // Only set error if we can't interact with the page at all
      print('Could not check page content: $e');
      // Don't automatically flag as error - the page might still be working
    }
  }

  void _loadUrl() async {
    if (_isDisposed) return;

    try {
      await controller.loadRequest(
        Uri.parse(widget.url),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1',
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.5',
          'Accept-Encoding': 'gzip, deflate',
          'Connection': 'keep-alive',
          'Upgrade-Insecure-Requests': '1',
        },
      );
    } catch (e) {
      if (!_isDisposed && mounted) {
        setState(() {
          isLoading = false;
          _hasError = true;
          errorMessage = 'Error loading URL: $e';
        });
      }
    }
  }

  void _refresh() {
    if (_isDisposed) return;

    setState(() {
      errorMessage = null;
      _hasError = false;
    });
    _loadUrl();
  }

  Future<void> _openInBrowser() async {
    try {
      final Uri uri = Uri.parse(widget.url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open the URL')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening URL: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFEF1DE),
      appBar: AppBar(
        backgroundColor: Color(0xFFFEF1DE),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.grey.shade800,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          if (_hasError || errorMessage != null)
            Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.close,
                      size: 80,
                      color: Colors.grey.shade500,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Cannot display this website',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      errorMessage ??
                          'This website cannot be displayed in the app.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _openInBrowser,
                        icon: Icon(Icons.open_in_browser),
                        label: Text('Open in Browser'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade800,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _refresh,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        side: BorderSide(
                          color: Colors.grey.shade800,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        'Try Again',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            WebViewWidget(
              key: ValueKey('webview_${widget.url}'),
              controller: controller,
            ),
          if (isLoading && !_hasError && errorMessage == null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
