import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Only for Web
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:ui' as ui;

class MiniAppWidget extends StatelessWidget {
  final String url;

  const MiniAppWidget({required this.url, super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Register iframe view
      const String viewType = 'iframeElement';
      ui.platformViewRegistry.registerViewFactory(
        viewType,
        (int viewId) {
          final iframe = IFrameElement()
            ..src = url
            ..style.border = 'none'
            ..width = '100%'
            ..height = '400';
          return iframe;
        },
      );

      return const SizedBox(
        height: 400,
        child: HtmlElementView(viewType: 'iframeElement'),
      );
    } else {
      return SizedBox(
        height: 400,
        child: WebView(
          initialUrl: url,
          javascriptMode: JavascriptMode.unrestricted,
        ),
      );
    }
  }
}
