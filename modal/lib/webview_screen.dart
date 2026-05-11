import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebviewScreen extends StatefulWidget {
  // Shared controller accessible by Bulk Sender
  static InAppWebViewController? webViewController;

  const WebviewScreen({super.key});

  @override
  State<WebviewScreen> createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020512),
      appBar: AppBar(
        title: const Text('WhatsApp Web', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => WebviewScreen.webViewController?.reload(),
          ),
        ],
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri("https://web.whatsapp.com"),
        ),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          domStorageEnabled: true,
          useWideViewPort: true,
          loadWithOverviewMode: true,
          // Force Desktop User-Agent to avoid "Unsupported Browser" error
          userAgent:
              "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
          preferredContentMode: UserPreferredContentMode.DESKTOP,
        ),
        onWebViewCreated: (controller) {
          WebviewScreen.webViewController = controller;
        },
        onLoadStart: (controller, url) {
          debugPrint("Started loading: $url");
        },
        onLoadStop: (controller, url) {
          debugPrint("Stopped loading: $url");
        },
        onProgressChanged: (controller, progress) {
          if (progress == 100) {
            debugPrint("Page Loaded");
          }
        },
      ),
    );
  }
}
