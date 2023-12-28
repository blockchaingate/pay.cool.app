import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:paycool/constants/constants.dart';
import 'package:paycool/enums/request_type.dart';

class RequestManager {
  static Future<String?> requestAsync(
      BuildContext context, RequestType requestType, String url,
      [dynamic body, int timeout = Constants.timeOutInterval]) async {
    debugPrint('request started: $url');

    HttpClient client = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

    late HttpClientResponse response;
    try {
      switch (requestType) {
        case RequestType.post:
          var request = await client.postUrl(Uri.parse(url));

          request.headers.set('content-type', 'application/json');
          request.headers.set('accept', 'application/json');

          var jsonBody = json.encode(body);

          request.add(utf8.encode(jsonBody));

          response = await request.close().timeout(Duration(seconds: timeout));

          break;
        case RequestType.put:
          var request = await client.putUrl(Uri.parse(url));

          request.headers.set('content-type', 'application/json-patch+json');
          request.headers.set('accept', 'application/json');
          var jsonBody = json.encode(body);

          request.add(utf8.encode(jsonBody));

          response = await request.close().timeout(Duration(seconds: timeout));
          break;
        case RequestType.get:
          var request = await client.getUrl(Uri.parse(url));
          request.headers.set('content-type', 'application/json-patch+json');
          request.headers.set('accept', 'application/json');
          response = await request.close().timeout(Duration(seconds: timeout));
          break;
        case RequestType.delete:
          var request = await client.deleteUrl(Uri.parse(url));
          request.headers.set('content-type', 'application/json-patch+json');
          request.headers.set('accept', 'application/json');
          response = await request.close().timeout(Duration(seconds: timeout));
          break;
      }

      String result = await response.transform(utf8.decoder).join();

      debugPrint("result HERE =========>$result");
      switch (response.statusCode) {
        case 200:
          debugPrint("200");
          return result;
        case 201:
        case 202:
        case 204:
          return result;
        case 401:
          debugPrint("401");
          return result;
        case 400:
          debugPrint("400");
          return result;
        case 500:
          debugPrint("500");
          return result;
        case 502:
          debugPrint("502");
          return result;
        case 404:
          debugPrint("404");
          return result;
        default:
          return '';
      }
    } on SocketException catch (e) {
      debugPrint(e.toString());
      return '';
    } on TimeoutException catch (e) {
      debugPrint(e.toString());
      return '';
    } catch (e) {
      debugPrint(e.toString());
      return '';
    }
  }
}
