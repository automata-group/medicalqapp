import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebviewScreen extends StatefulWidget {
  final String checkoutUrl;

  const PaymentWebviewScreen({
    super.key,
    required this.checkoutUrl,
  });

  @override
  State<PaymentWebviewScreen> createState() => _PaymentWebviewScreenState();
}

class _PaymentWebviewScreenState extends State<PaymentWebviewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _checkSuccessRedirect(url);
            
            // Extract HTML for debugging
            _controller.runJavaScript("HtmlViewer.postMessage(document.documentElement.outerHTML);");
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView Resource Error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            if (_checkSuccessRedirect(url)) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel('HtmlViewer', onMessageReceived: (message) {
        debugPrint('--- WEBVIEW HTML CONTENT ---');
        debugPrint(message.message.length > 500 ? '${message.message.substring(0, 500)}...' : message.message);
      })
      ..setOnConsoleMessage((JavaScriptConsoleMessage message) {
        debugPrint('WebView Console: ${message.message}');
      });

    // Clear cache to ensure we get the latest page from the server
    _controller.clearCache().then((_) {
      // Append a timestamp to the URL to bust the cache completely
      final uri = Uri.parse(widget.checkoutUrl);
      final cacheBustedUri = uri.replace(
        queryParameters: {
          ...uri.queryParameters,
          'cb': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );
      
      _controller.loadRequest(cacheBustedUri);
    });
  }

  bool _checkSuccessRedirect(String url) {
    if (url.contains('/payment-callback')) {
      final uri = Uri.parse(url);
      final status = uri.queryParameters['status'];

      if (status == 'paid') {
        Navigator.of(context).pop(true); // Return success
        return true;
      } else if (status == 'failed') {
        Navigator.of(context).pop(false); // Return failure
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: CloseButton(onPressed: () => Navigator.of(context).pop(null)),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
