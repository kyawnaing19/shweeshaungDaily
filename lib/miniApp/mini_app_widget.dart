// main.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart'; // For Android specific settings
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart'; // For iOS specific settings
import 'package:http/http.dart' as http;
import 'dart:convert';





class MiniAppScreen extends StatefulWidget {
  const MiniAppScreen({super.key});

  @override
  State<MiniAppScreen> createState() => _MiniAppScreenState();
}

class _MiniAppScreenState extends State<MiniAppScreen> {
  // Replace with your actual raw GitHub Gist URL or other remote config URL
  // Example: 'https://gist.githubusercontent.com/yourusername/yourgistid/raw/config.json'
  // For demonstration, we'll use a placeholder.
  final String _configUrl = 'https://raw.githubusercontent.com/amk-35/apiUrl/refs/heads/main/apiUrl.json'; // Placeholder, replace with your own!

  bool _isLoading = true;
  bool _showMiniApp = false;
  String _miniAppUrl = '';
  String _version = '';
  String _errorMessage = '';

  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _fetchConfig();
  }

  // Fetches the configuration from the remote URL
  Future<void> _fetchConfig() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse(_configUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> config = json.decode(response.body);
        setState(() {
          _showMiniApp = config['showMiniApp'] ?? false;
          _miniAppUrl = config['miniAppUrl'] ?? '';
          _version = config['version'] ?? '';
        });

        if (_showMiniApp && _miniAppUrl.isNotEmpty) {
          _initializeWebViewController();
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load config: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching config: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Initializes the WebViewController based on the platform
  void _initializeWebViewController() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params = AndroidWebViewControllerCreationParams(
        // You can add Android specific settings here
        // For example, to enable JavaScript:
        // is )
      );
    } else if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params);

    // Apply platform-specific settings after controller creation
    if (_controller.platform is AndroidWebViewController) {
      // Enable media playback without user gesture for Android
      // This can be crucial for YouTube videos to autoplay or play inline
      // without requiring an explicit tap.
      (_controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
      // setDomStorageEnabled is not available in newer versions of webview_flutter_android.
      // DOM storage is generally enabled by default when JavaScript is unrestricted.
    }


    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // Enable JavaScript
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
            debugPrint('WebView is loading (progress: $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
              Page resource error:
                code: ${error.errorCode}
                description: ${error.description}
                errorType: ${error.errorType}
                isForMainFrame: ${error.isForMainFrame}
            ''');
            setState(() {
              _errorMessage = 'Web resource error: ${error.description}';
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // You can control navigation here.
            // For example, to prevent navigation to certain URLs:
            // if (request.url.startsWith('https://www.youtube.com/')) {
            //   debugPrint('blocking navigation to ${request.url}');
            //   return NavigationDecision.prevent;
            // }
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_miniAppUrl));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Mini-App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchConfig, // Allow manual refresh of config
          ),
        ],
      ),
      body: Center(
        child: _isLoading
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading mini-app configuration...'),
                ],
              )
            : _errorMessage.isNotEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Error: $_errorMessage',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchConfig,
                        child: const Text('Retry'),
                      ),
                    ],
                  )
                : _showMiniApp
                    ? Column(
                        children: [
                          // Padding(
                          //   padding: const EdgeInsets.all(1.0),
                          //   child: Text(
                          //     'Mini-App Version: $_version',
                          //     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          //   ),
                          // ),
                          Expanded(
                            child: WebViewWidget(controller: _controller),
                          ),
                        ],
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.web, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Mini-app is currently disabled by remote configuration.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
      ),
    );
  }
}
