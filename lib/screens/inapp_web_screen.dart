import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebPageScreen extends StatefulWidget {
  final String url;
  final String title;

  const WebPageScreen({super.key, required this.url, required this.title});

  @override
  State<WebPageScreen> createState() => _WebPageScreenState();
}

class _WebPageScreenState extends State<WebPageScreen> {
  late InAppWebViewController webViewController;
  late PullToRefreshController pullToRefreshController;

  double progress = 0;

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController.reload();
        } else if (Platform.isIOS) {
          webViewController.loadUrl(
              urlRequest: URLRequest(url: await webViewController.getUrl()));
        }
      },
    );
  }

  void _handleUrlNavigation(String url) {
    if (url.contains('/api/success')) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (url.contains('/api/failed')) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest:
                URLRequest(url: WebUri(Uri.parse(widget.url).toString())),
            pullToRefreshController: pullToRefreshController,
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            onLoadStop: (controller, url) {
              pullToRefreshController.endRefreshing();
              if (url != null) {
                _handleUrlNavigation(url.toString());
              }
            },
            onLoadError: (controller, url, code, message) {
              pullToRefreshController.endRefreshing();
            },
            onProgressChanged: (controller, p) {
              setState(() {
                progress = p / 100;
              });
            },
          ),
          if (progress < 1.0)
            LinearProgressIndicator(
              value: progress,
              color: Colors.orange,
              backgroundColor: Colors.grey[300],
            ),
        ],
      ),
    );
  }
}
