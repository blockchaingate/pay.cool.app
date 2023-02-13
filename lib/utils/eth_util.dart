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
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/coin_service.dart';
import 'package:paycool/utils/number_util.dart';
import 'package:paycool/utils/string_util.dart';
import '../../os_packages/keccak/lib/keccak.dart';
import 'package:hex/hex.dart';
import 'dart:typed_data';
import '../environments/environment.dart';
import 'dart:async';
import 'package:web3dart/web3dart.dart' as Web3;

import 'dart:convert';

import 'custom_http_util.dart';

final client = CustomHttpUtil.createLetsEncryptUpdatedCertClient();
getTransactionHash(Uint8List signTransaction) {
  var p = keccak(signTransaction);
  var hash = "0x${HEX.encode(p)}";
  return hash;
}

Future getEthTransactionStatus(String txid) async {
  var url = '${ethBaseUrl}getconfirmationcount/$txid';

  var response = await client.get(Uri.parse(url));
  debugPrint(response.body);
  return response.body;
}

getEthNode(root, {index = 0}) {
  var node =
      root.derivePath("m/44'/${environment["CoinType"]["ETH"]}'/0'/0/$index");
  return node;
}

getEthAddressForNode(node) async {
  var privateKey = node.privateKey;

  Web3.Credentials credentials =
      Web3.EthPrivateKey.fromHex(HEX.encode(privateKey));

  final address = credentials.address;

  var ethAddress = address.hex;
  return ethAddress;
}

Future getEthBalanceByAddress(String address) async {
  var url = '${ethBaseUrl}getbalance/$address';
  var ethBalance = 0.0;
  try {
    var response = await client.get(Uri.parse(url));
    Map<String, dynamic> balance = jsonDecode(response.body);
    ethBalance =
        NumberUtil.rawStringToDecimal(balance['balance'].toString()).toDouble();
  } catch (e) {}
  return {'balance': ethBalance, 'lockbalance': 0.0};
}

Future getEthTokenBalanceByAddress(String address, String coinName,
    [String? smartContractAddress]) async {
  final coinService = locator<CoinService>();

  if (smartContractAddress!.isEmpty) {
    await coinService
        .getSmartContractAddressByTickerName(coinName)
        .then((value) => smartContractAddress = value);
  }
  var url = '${ethBaseUrl}callcontract/$smartContractAddress/$address';
  debugPrint('eth_util - getEthTokenBalanceByAddress - $url ');

  var tokenBalanceIe18 = 0.0;
  var balanceIe8 = 0.0;
  var balance1e6 = 0.0;
  try {
    var response = await client.get(Uri.parse(url));
    var balance = jsonDecode(response.body);
    balanceIe8 = double.parse(balance['balance']) / 1e8;
    balance1e6 = double.parse(balance['balance']) / 1e6;
    tokenBalanceIe18 = double.parse(balance['balance']) / 1e18;
  } catch (e) {}
  return {
    'balance1e6': balance1e6,
    'balanceIe8': balanceIe8,
    'lockbalance': 0.0,
    'tokenBalanceIe18': tokenBalanceIe18
  };
}
