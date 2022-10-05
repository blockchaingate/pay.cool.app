import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewWidget extends StatefulWidget {
  final String url;
  final String title;
  final int Function(int) onCallBack;
  const WebViewWidget(this.url, this.title, this.onCallBack);

  @override
  State<WebViewWidget> createState() => _WebViewWidgetState(this.url);
}

class _WebViewWidgetState extends State<WebViewWidget> {
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  final String _url;
  final _key = UniqueKey();
  _WebViewWidgetState(this._url);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   centerTitle: true,
        //   title: Text(
        //     widget.title,
        //     style: headText4,
        //   ),
        // ),
        body: WebView(
      onProgress: ((progress) => widget.onCallBack(progress)),
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<VerticalDragGestureRecognizer>(
          () => VerticalDragGestureRecognizer(),
        ),
      },
      key: _key,
      javascriptMode: JavascriptMode.unrestricted,
      initialUrl: _url,
      //initialUrl: Uri.dataFromString(
      //   '<p>Web view sample</p>' * 1000,
      //    ).toString(),
    ));
  }
}
