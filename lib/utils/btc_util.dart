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

import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/src/response.dart';
import '../environments/environment.dart';
import 'custom_http_util.dart';

final String btcBaseUrl = environment["endpoints"]["btc"];

final client = CustomHttpUtil.createLetsEncryptUpdatedCertClient();
Future getBtcTransactionStatus(String txid) async {
  Response? response;
  var url = '${btcBaseUrl}gettransactionjson/$txid';

  try {
    response = await client.get(Uri.parse(url));
  } catch (e) {
    debugPrint(e.toString());
  }

  return response;
}

Future getBtcBalanceByAddress(String address) async {
  var url = '${btcBaseUrl}getbalance/$address';
  var btcBalance = 0.0;
  try {
    var response = await client.get(Uri.parse(url));
    btcBalance = double.parse(response.body) / 1e8;
  } catch (e) {
    debugPrint(e.toString());
  }
  return {'balance': btcBalance, 'lockbalance': 0.0};
}

getBtcNode(root, {String? tickerName, index = 0}) {
  var coinType = environment["CoinType"][tickerName].toString();
  var node = root.derivePath("m/44'/$coinType'/0'/0/$index");
  return node;
}

String? getBtcAddressForNode(node, {String? tickerName}) {
  return P2PKH(
          data: PaymentData(pubkey: node.publicKey),
          //  new P2PKHData(pubkey: node.publicKey),
          network: environment["chains"]["BTC"]["network"])
      .data
      .address;
}
