import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../Utility/utils/constants.dart';

class WebViewPage extends StatelessWidget {
  final String url;

  WebViewPage({
    required this.url,
  });

  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: kReSustainabilityRed,
          title: const Text(
            'Web View',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'ARIAL',
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: WebViewPage(
          url: url,
        ));
  }
}
