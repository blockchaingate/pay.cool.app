import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DappWebView extends StatefulWidget {
  final String? url;
  final String? title;
  const DappWebView(this.url, this.title, {super.key});

  @override
  State<DappWebView> createState() => _DappWebViewState();
}

class _DappWebViewState extends State<DappWebView> {
  WebViewController controller = WebViewController();

  @override
  void initState() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint(progress.toString());
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url!));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBarWithIcon(
          title: widget.title,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 20,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                showBottomSheet(context);
              },
              icon: Icon(
                Icons.more_horiz,
                color: Colors.black,
                size: 20,
              ),
            ),
          ]),
      body: WebViewWidget(controller: controller),
    );
  }

  showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height / 4,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                FlutterI18n.translate(context, "quickMenu"),
                style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[400]),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  getWidget("Favorite", "assets/images/new-design/fav_web.png"),
                  getWidget("Share", "assets/images/new-design/share_web.png"),
                  getWidget(
                      "Copy link", "assets/images/new-design/copy_web.png"),
                  getWidget("Refresh", "assets/images/new-design/ref_web.png")
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget getWidget(title, iconUrl) {
    Size size = MediaQuery.of(context).size;
    return InkWell(
      onTap: () {
        if (title == "Favorite") {
        } else if (title == "Share") {
        } else if (title == "Copy link") {
          Clipboard.setData(ClipboardData(text: widget.url!));
        } else if (title == "Refresh") {
          Navigator.pop(context);
          controller.reload();
        }
      },
      child: SizedBox(
          width: size.width / 6,
          height: size.width / 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: size.width / 8,
                width: size.width / 8,
                child: Image.asset(
                  iconUrl,
                ),
              ),
              SizedBox(height: 10),
              Text(
                FlutterI18n.translate(context, title),
                style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
            ],
          )),
    );
  }
}
