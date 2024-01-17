import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
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
  // WebViewCookieManager cookieManager = WebViewCookieManager();
  // WebViewCookie cookie = WebViewCookie(
  //   name: 'cookieName',
  //   value:
  //       '_ga=GA1.1.230232657.1705342470; _ga_JW8KWJ48EF=GS1.1.1705415153.2.0.1705415153.0.0.0; _hjIncludedInSessionSample_3553126=0; _hjSessionUser_3553126=eyJpZCI6Ijc0YmY5MDM2LWMyNzYtNTJhMi1hNmJkLTBmNmMzYTc2MDgyYiIsImNyZWF0ZWQiOjE3MDUzNDI0NzAzODcsImV4aXN0aW5nIjp0cnVlfQ==; _hjSession_3553126=eyJpZCI6IjkwODQzZTQyLWFiZmQtNDFmYy05ZWU0LTgxOGM4MDYyMjkxNSIsImMiOjE3MDU0MTUxNTM1NDAsInMiOjAsInIiOjAsInNiIjowLCJzciI6MCwic2UiOjAsImZzIjowLCJzcCI6MX0=',
  //   domain: 'cookieDomain',
  //   path: 'cookiePath',
  // );

  // late StreamSubscription _sub;

  @override
  void initState() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint(progress.toString());
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url!));

    // cookieManager = WebViewCookieManager();

    // // Listen to the WebSocket stream
    // channel.stream.listen((data) {
    //   if (data != null && data.isNotEmpty) {
    //     // Process the data as needed
    //     String message = String.fromCharCodes(data.cast<int>());
    //     print('Received from server: $message');
    //     showBottomSheetDetail(message);
    //   }
    // }, onDone: () {
    //   print('WebSocket connection closed');
    // }, onError: (error) {
    //   print('WebSocket error: $error');
    // });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
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
          color: white,
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
