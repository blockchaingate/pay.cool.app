import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DappViewmodel extends BaseViewModel {
  BuildContext? context;

  final sharedService = locator<SharedService>();
  final searchController = TextEditingController();
  final navigationService = locator<NavigationService>();

  var dapps = [
    {
      "title": "Biswap",
      "url": "https://biswap.com",
      "image":
          "https://play-lh.googleusercontent.com/vivOq9u0gB1y2cyvmAi7T6UhAca3lZAfGGd_xYJS6q3Af5GPUgnm-4v1ZX3zndvMazAj",
      "buttons": [
        {"label": "Accept", "action": "connect"},
        {"label": "Reject", "action": "disconnect"}
      ]
    },
    {
      "title": "Exchangily",
      "url": "https://exchangily.com",
      "image":
          "https://pbs.twimg.com/profile_images/1398063786989326338/PtEVQlwW_400x400.jpg",
      "buttons": [
        {"label": "Accept", "action": "connect"},
        {"label": "Reject", "action": "disconnect"}
      ]
    },
    {
      "title": "Uni",
      "url": "https://uniswap.com",
      "image":
          "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e7/Uniswap_Logo.svg/1026px-Uniswap_Logo.svg.png",
      "buttons": [
        {"label": "Accept", "action": "connect"},
        {"label": "Reject", "action": "disconnect"}
      ]
    },
    {
      "title": "Pancake",
      "url": "https://pancakeswap.com",
      "image":
          "https://logowik.com/content/uploads/images/pancakeswap-cake6091.jpg",
      "buttons": [
        {"label": "Accept", "action": "connect"},
        {"label": "Reject", "action": "disconnect"}
      ]
    },
    {
      "title": "Sushi",
      "url": "https://sushi.com",
      "image":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQnrOcDPaBVj9K7UR7T3fjm0BVAr6DdsLjK8ydE5CblCw&s",
      "buttons": [
        {"label": "Accept", "action": "connect"},
        {"label": "Reject", "action": "disconnect"}
      ]
    },
  ];

  WebViewController controller = WebViewController();

/*----------------------------------------------------------------------
                          INIT
----------------------------------------------------------------------*/

  init() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
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
      ..loadRequest(Uri.parse('https://flutter.dev'))
      ..addJavaScriptChannel('Print',
          onMessageReceived: (JavaScriptMessage message) {
        print(message.message);
      });
  }

  onBackButtonPressed() async {
    await sharedService.onBackButtonPressed('/dashboard');
  }
}
