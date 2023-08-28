/*
* Copyright (c) 2020 Exchangily LLC
*
* Licensed under Apache License v2.0
* You may obtain a copy of the License at
*
*      https://www.apache.org/licenses/LICENSE-2.0
*
*----------------------------------------------------------------------
* Author: ken.qiu@exchangily.com
*----------------------------------------------------------------------
*/

import 'package:flutter/widgets.dart';
import 'package:paycool/constants/api_routes.dart';
import 'package:paycool/constants/constants.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/config_service.dart';
import 'dart:convert';
import 'package:bitcoin_flutter/bitcoin_flutter.dart' as bitcoin_flutter;
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/utils/custom_http_util.dart';

final client = CustomHttpUtil.createLetsEncryptUpdatedCertClient();
bitcoin_flutter.NetworkType kanbanMainnetNetwork = bitcoin_flutter.NetworkType(
    messagePrefix: Constants.KanbanMessagePrefix,
    bip32: bitcoin_flutter.Bip32Type(public: 0x019da462, private: 0x019d9cfe),
    pubKeyHash: 0x30,
    scriptHash: 0x32,
    wif: 0xb0);

Future<String> getScarAddress() async {
  ConfigService configService = locator<ConfigService>();

  var url = configService.getKanbanBaseUrl() +
      kanbanApiRoute +
      getScarAddressApiRoute;
  var response = await client.get(Uri.parse(url));
  return response.body;
}

Future<String> getCoinPoolAddress() async {
  ConfigService configService = locator<ConfigService>();
  var url = '${configService.getKanbanBaseUrl()}exchangily/getCoinPoolAddress';

  var response = await client.get(Uri.parse(url));
  return response.body;
}

Future<String> getExchangilyAddress() async {
  ConfigService configService = locator<ConfigService>();
  var url = '${configService.getKanbanBaseUrl()}exchangily/getExchangeAddress';
  debugPrint('URL getExchangilyAddress $url');

  var response = await client.get(Uri.parse(url));
  return response.body;
}

Future<double> getGas(String address) async {
  ConfigService configService = locator<ConfigService>();
  var url = configService.getKanbanBaseUrl() +
      kanbanApiRoute +
      GetBalanceApiRoute +
      address;

  var response = await client.get(Uri.parse(url));
  var json = jsonDecode(response.body);
  var fab = json["balance"]["FAB"];
  return double.parse(fab);
}

Future<int> getNonce(String address) async {
  ConfigService configService = locator<ConfigService>();
  var url = configService.getKanbanBaseUrl() +
      kanbanApiRoute +
      GetTransactionCountApiRoute +
      address;
  debugPrint('URL getNonce $url');

  var response = await client.get(Uri.parse(url));
  var json = jsonDecode(response.body);
  debugPrint('getNonce json $json');
  return json["transactionCount"];
}

Future<Map<String, dynamic>> submitDeposit(
    String rawTransaction, String rawKanbanTransaction) async {
  ConfigService configService = locator<ConfigService>();
  var url = configService.getKanbanBaseUrl() + SubmitDepositApiRoute;
  debugPrint('submitDeposit url $url');
  final sharedService = locator<SharedService>();
  var versionInfo = await sharedService.getLocalAppVersion();
  debugPrint('getAppVersion $versionInfo');
  String? versionName = versionInfo['name'];
  String? buildNumber = versionInfo['buildNumber'];
  String? fullVersion = '$versionName+$buildNumber';
  debugPrint('fullVersion $fullVersion');
  var body = {
    'app': Constants.appName,
    'version': fullVersion,
    'rawTransaction': rawTransaction,
    'rawKanbanTransaction': rawKanbanTransaction
  };
  debugPrint('body $body');

  try {
    var response = await client.post(Uri.parse(url), body: body);
    debugPrint("Kanban_util submitDeposit response body:");
    debugPrint(response.body.toString());
    Map<String, dynamic> res = jsonDecode(response.body);
    return res;
  } catch (err) {
    debugPrint('Catch submitDeposit in kanban util $err');
    throw Exception(err);
  }
}

Future getKanbanErrDeposit(String address) async {
  ConfigService configService = locator<ConfigService>();
  var url = configService.getKanbanBaseUrl() + DepositerrApiRoute + address;
  debugPrint('kanbanUtil getKanbanErrDeposit $url');
  try {
    var response = await client.get(Uri.parse(url));
    var json = jsonDecode(response.body);
    // debugPrint('Kanban.util-getKanbanErrDeposit $json');
    return json;
  } catch (err) {
    debugPrint(
        'Catch getKanbanErrDeposit in kanban util $err'); // Error thrown here will go to onError in them view model
    throw Exception(err);
  }
}

Future<Map<String, dynamic>> submitReDeposit(
    String rawKanbanTransaction) async {
  ConfigService configService = locator<ConfigService>();
  var url = configService.getKanbanBaseUrl() + ResubmitDepositApiRoute;
  final sharedService = locator<SharedService>();
  var versionInfo = await sharedService.getLocalAppVersion();
  debugPrint('getAppVersion $versionInfo');
  String? versionName = versionInfo['name'];
  String? buildNumber = versionInfo['buildNumber'];
  String? fullVersion = '$versionName+$buildNumber';
  debugPrint('fullVersion $fullVersion');
  var body = {
    'app': Constants.appName,
    'version': fullVersion,
    'rawKanbanTransaction': rawKanbanTransaction
  };

  debugPrint('URL submitReDeposit $url -- body $body');

  try {
    var response = await client.post(Uri.parse(url), body: body);
    //debugPrint('response from sendKanbanRawTransaction=');
    // debugPrint(response.body);
    Map<String, dynamic> res = jsonDecode(response.body);
    return res;
  } catch (e) {
    //return e;
    return {'success': false, 'data': 'error'};
  }
}

Future<Map<String, dynamic>> sendKanbanRawTransaction(
    String baseUrl, String rawKanbanTransaction) async {
  var url = baseUrl + kanbanApiRoute + SendRawTxApiRoute;
  debugPrint('URL sendKanbanRawTransaction $url');
  var data = {'signedTransactionData': rawKanbanTransaction};

  try {
    var response = await client.post(Uri.parse(url), body: data);
    debugPrint('response from sendKanbanRawTransaction=');
    debugPrint(response.body.toString());
    if (response.body.contains('TS crosschain withdraw verification failed')) {
      return {'success': false, 'data': response.body};
    }
    Map<String, dynamic> res = jsonDecode(response.body);
    return res;
  } catch (e) {
    //return e;
    return {'success': false, 'data': 'error $e'};
  }
}

Future<Map<String, dynamic>> sendKanbanRawTransactionV2(
    String baseUrl, String rawKanbanTransaction) async {
  var url = '$baseUrl${kanbanApiRoute}v2/$sendRawTxApiRouteV2';
  debugPrint('URL sendKanbanRawTransactionV2 $url');
  var data = {'signedTransactionData': rawKanbanTransaction};

  try {
    var response = await client.post(Uri.parse(url), body: data);
    debugPrint('response from sendKanbanRawTransactionV2=');
    debugPrint(response.body.toString());
    if (response.body.contains('TS crosschain withdraw verification failed')) {
      return {'success': false, 'data': response.body};
    }
    Map<String, dynamic> res = jsonDecode(response.body);
    return res;
  } catch (e) {
    debugPrint('sendKanbanRawTransactionV2 CATCH  $e');
    //return e;
    return {'success': false, 'data': 'error $e'};
  }
}

// this one is the last one that works just ETH
Future<Map<String, dynamic>> sendRawTransactionV3(
    String rawKanbanTransaction, String chain) async {
  var url = '$BaseBondApiRoute$chain/postrawtransaction';
  var data = {'rawtx': rawKanbanTransaction};

  try {
    var response = await client.post(Uri.parse(url), body: data);
    debugPrint('response from sendKanbanRawTransactionV3=');
    debugPrint(response.body.toString());
    if (response.body.contains('TS crosschain withdraw verification failed')) {
      return {'success': false, 'data': response.body};
    }
    Map<String, dynamic> res = jsonDecode(response.body);
    return res;
  } catch (e) {
    debugPrint('sendKanbanRawTransactionV2 CATCH  $e');
    //return e;
    return {'success': false, 'data': 'error $e'};
  }
}
