
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/logger.dart';
import 'package:webview_flutter/webview_flutter.dart';
// // Import for Android features.
// import 'package:webview_flutter_android/webview_flutter_android.dart';
// // Import for iOS features.
// import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class LocalWebViewWidget extends StatefulWidget {
  final String url;
  final String title;
  final int Function(int) onCallBack;
  const LocalWebViewWidget(this.url, this.title, this.onCallBack);

  @override
  State<LocalWebViewWidget> createState() => _LocalWebViewWidgetState(url);
}

class _LocalWebViewWidgetState extends State<LocalWebViewWidget>
    with TickerProviderStateMixin {
  bool isLoading = true;
  int loadingProgress = 0;
  late AnimationController animationController;
  late WebViewController controller;
  late final PlatformWebViewControllerCreationParams params;
  final log = getLogger('LocalWebViewWidget');
  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        duration: const Duration(milliseconds: 700), vsync: this);
    animationController.repeat();
    // if (Platform.isAndroid) {
    //   WebView.platform = SurfaceAndroidWebView();
    // }

    // if (WebViewPlatform.instance is WebKitWebViewPlatform) {
    //   params = WebKitWebViewControllerCreationParams(
    //     allowsInlineMediaPlayback: true,
    //     mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
    //   );
    // } else {
    //   params = const PlatformWebViewControllerCreationParams();
    // }

    // controller = WebViewController.fromPlatformCreationParams(params);

    // if (controller.platform is AndroidWebViewController) {
    //   AndroidWebViewController.enableDebugging(true);
    //   (controller.platform as AndroidWebViewController)
    //       .setMediaPlaybackRequiresUserGesture(false);
    // }
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(secondaryColor)
      ..setNavigationDelegate(NavigationDelegate(onProgress: ((progress) {
        widget.onCallBack(progress);
        setState(() {
          loadingProgress = progress;
        });
        log.i('loadingProgress $loadingProgress');
      }), onPageFinished: (finish) {
        setState(() {
          isLoading = false;
        });
      }, onWebResourceError: (err) {
        log.e('web resource failed error $err');
      }))
      ..loadRequest(Uri.parse(_url));
  }

  final String _url;
  final _key = UniqueKey();
  _LocalWebViewWidgetState(this._url);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Stack(
        children: [
          // WebView(
          //   onPageFinished: (finish) {
          //     setState(() {
          //       isLoading = false;
          //     });
          //   },
          //   gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          //     Factory<VerticalDragGestureRecognizer>(
          //       () => VerticalDragGestureRecognizer(),
          //     ),
          //   },
          //   key: _key,
          //   javascriptMode: JavascriptMode.unrestricted,
          //   initialUrl: _url,
          // ),
          WebViewWidget(
            controller: controller,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<VerticalDragGestureRecognizer>(
                () => VerticalDragGestureRecognizer(),
              ),
            },
            key: _key,
          ),
          Visibility(
            visible: isLoading,
            child: Center(
                child: CircularProgressIndicator(
              color: primaryColor,
              valueColor: animationController
                  .drive(ColorTween(begin: secondaryColor, end: primaryColor)),
              value: double.parse(loadingProgress.toString()) / 100,
              semanticsValue: loadingProgress.toString(),
            )),
          )
        ],
      )),
    );
  }
}
