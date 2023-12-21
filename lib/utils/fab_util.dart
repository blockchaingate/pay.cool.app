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

import 'dart:convert';
import 'dart:math';

import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import "package:hex/hex.dart";
import 'package:paycool/environments/environment_type.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/coin_service.dart';
import 'package:paycool/utils/number_util.dart';
import 'package:web3dart/web3dart.dart';

import './string_util.dart';
import '../environments/environment.dart';
import 'custom_http_util.dart';

class FabUtils {
  final String fabBaseUrl = environment["endpoints"]["fab"];
  final log = getLogger('fab_util');

  final client = CustomHttpUtil.createLetsEncryptUpdatedCertClient();

  Future getFabTransactionStatus(String txid) async {
    var url = '${fabBaseUrl}gettransactionjson/$txid';

    var response = await client.get(Uri.parse(url));
    debugPrint(url);
    log.w(response.body);
    return response.body;
  }

  getFabNode(root, {index = 0}) {
    var node =
        root.derivePath("m/44'/${environment["CoinType"]["FAB"]}'/0'/0/$index");
    return node;
  }

  Future getFabLockBalanceByAddress(String address) async {
    Decimal balance = Decimal.zero;
    var fabSmartContractAddress =
        environment['addresses']['smartContract']['FABLOCK'];
    var getLockedInfoABI = '43eb7b44';
    var data = {
      'address': trimHexPrefix(fabSmartContractAddress),
      'data': trimHexPrefix(getLockedInfoABI),
      'sender': address
    };
    var url = '${fabBaseUrl}callcontract';
    try {
      var response = await client.post(Uri.parse(url), body: data);
      var json = jsonDecode(response.body);
      if (json != null &&
          json['executionResult'] != null &&
          json['executionResult']['output'] != null) {
        var balanceHex = json['executionResult']['output'];

        //  debugPrint('balanceHex===' + balanceHex);
        const abiCode = """
      [
      {
        "constant": false,
  "name": "withdraw",
  "payable": false,
  "stateMutability": "nonpayable",
  "type": "function",
  "inputs": [],
  "outputs": []
  },
  {
  "constant": true,
  "name": "lockPeriod",
  "payable": false,
  "stateMutability": "view",
  "type": "function",
  "inputs": [],
  "outputs": [
  {
  "name": "",
  "type": "uint256"
  }
  ]
  },
  {
  "constant": true,
  "name": "getLockerInfo",
  "payable": false,
  "stateMutability": "view",
  "type": "function",
  "inputs": [],
  "outputs": [
  {
  "name": "",
  "type": "uint256[]"
  },
  {
  "name": "",
  "type": "uint256[]"
  }
  ]
  },
  {
  "constant": true,
  "name": "startBlock",
  "payable": false,
  "stateMutability": "view",
  "type": "function",
  "inputs": [],
  "outputs": [
  {
  "name": "",
  "type": "uint256"
  }
  ]
  },
  {
  "constant": false,
  "name": "lockFab",
  "payable": true,
  "stateMutability": "payable",
  "type": "function",
  "inputs": [],
  "outputs": []
  },
  {
  "constant": true,
  "name": "isOwner",
  "payable": false,
  "stateMutability": "view",
  "type": "function",
  "inputs": [],
  "outputs": [
  {
  "name": "",
  "type": "bool"
  }
  ]
  },
  {
  "constant": false,
  "name": "updateLockPeriod",
  "payable": false,
  "stateMutability": "nonpayable",
  "type": "function",
  "inputs": [
  {
  "name": "newLockPeriod",
  "type": "uint256"
  }
  ],
  "outputs": []
  },
  {
  "constant": true,
  "name": "_owner",
  "payable": false,
  "stateMutability": "view",
  "type": "function",
  "inputs": [],
  "outputs": [
  {
  "name": "",
  "type": "address"
  }
  ]
  },
  {
  "constant": false,
  "name": "",
  "payable": false,
  "stateMutability": "nonpayable",
  "type": "constructor",
  "inputs": [],
  "outputs": null
  }
  ]""";

        final EthereumAddress contractAddr =
            EthereumAddress.fromHex(fabSmartContractAddress);
        final contract = DeployedContract(
            ContractAbi.fromJson(abiCode, 'FabLock'), contractAddr);
        final getLockerInfo = contract.function('getLockerInfo');
        var res = getLockerInfo.decodeReturnValues(balanceHex);

        if (res.length == 2) {
          var values = res[1];
          values.forEach((element) =>
              {balance = balance + Decimal.parse(element.toString())});
          balance = NumberUtil.rawStringToDecimal(balance.toString(),
              decimalPrecision: 18);
        }
      }
    } catch (e) {
      log.e('CATCH -getFabLockBalanceByAddress -$e');
    }
    return balance;
  }

  Future<Map<String, Decimal>> getFabBalanceByAddress(String address) async {
    var url = '${fabBaseUrl}getbalance/$address';
    var fabBalance = Decimal.zero;
    try {
      var response = await client.get(Uri.parse(url));
      fabBalance =
          NumberUtil.rawStringToDecimal(response.body, decimalPrecision: 8);
    } catch (e) {
      log.e(e);
    }
    var lockbalance = await getFabLockBalanceByAddress(address);
    return {'balance': fabBalance, 'lockbalance': lockbalance};
  }

  exgToFabAddress(String address) {
    var prefix = '6f';
    if (isProduction) {
      prefix = '00';
    }
    address = prefix + trimHexPrefix(address);
    /*
  var bytes = hex.decode(address);

  debugPrint('bytes=');
  var digest1 = sha256.convert(bytes).toString();
  debugPrint('digest1==' + digest1);
  var bytes1 = hex.decode(digest1);
  var digest2 = sha256.convert(bytes1).toString();
  debugPrint('digest2=' + digest2);
  var checksum = digest2.substring(0,8);
  debugPrint('checksum=' + checksum);
  // address = address + checksum;
  debugPrint('address before encode=' + address);

   */
    address = bs58check.encode(Uint8List.fromList(HEX.decode(address)));
    log.w('address after encode=$address');

    /*
  var decoded = bs58check.decode('mvLuZXGYMxpRM65kgzbfoKqs3FPcisM6ri');
  debugPrint(decoded);
  debugPrint(HEX.encode(decoded));
  debugPrint(bs58check.encode(decoded));
  */
    return address;
  }

  String fabToExgAddress(String address) {
    var decoded = bs58check.decode(address);
    address = HEX.encode(decoded);
    address = address.substring(2);
    address = '0x$address';
    log.w('in fabToExgAddress $address');
    return address;
  }

/*
  miuFiyLJPcg1i586vhj9JWvHa6bfttDJnd
  var decoded = bs58check.decode('mvLuZXGYMxpRM65kgzbfoKqs3FPcisM6ri');
  debugPrint(decoded);
  debugPrint(HEX.encode(decoded));
  debugPrint(bs58check.encode(decoded));
  */

  btcToBase58Address(address) {
    var bytes = bs58check.decode(address);
    var digest1 = sha256.convert(bytes).toString();
    var bytes1 = hex.decode(digest1);
    var digest2 = sha256.convert(bytes1).toString();
    var checksum = digest2.substring(0, 8);

    address = HEX.encode(bytes);
    address = address + checksum;
    // debugPrint('address for exg=' + address);
    return address;
  }

  Future getFabTokenBalanceForABI(
      String balanceInfoABI, String smartContractAddress, String address,
      [int? decimal]) async {
    var body = {
      'address': trimHexPrefix(smartContractAddress),
      'data': balanceInfoABI + fixLength(trimHexPrefix(address), 64)
    };
    var tokenBalance = 0.0;
    var url = '${fabBaseUrl}callcontract';
    debugPrint(
        'Fab_util -- address $address getFabTokenBalanceForABI balance by address url -- $url -- body $body');
    try {
      var response = await client.post(Uri.parse(url), body: body);
      var json = jsonDecode(response.body);
      var unlockBalance = json['executionResult']['output'];

      if (unlockBalance == null || unlockBalance == '') {
        return 0.0;
      }
      // var unlockInt = int.parse(unlockBalance, radix: 16a);
      var unlockInt = BigInt.parse(unlockBalance, radix: 16);

      if ((decimal != null) && (decimal > 0)) {
        tokenBalance =
            ((unlockInt) / BigInt.parse(pow(10, decimal).toString()));
      } else {
        tokenBalance =
            NumberUtil.rawStringToDecimal(unlockInt.toString()).toDouble();
        // debugPrint('tokenBalance for EXG==');
        // debugPrint(tokenBalance);
      }

      //debugPrint('tokenBalance===' + tokenBalance.toString());
    } catch (e) {}
    return tokenBalance;
  }

  Future getSmartContractABI(String smartContractAddress) async {
    var url = '${fabBaseUrl}getabiforcontract/$smartContractAddress';
    var response = await client.get(Uri.parse(url));
    Map<String, dynamic> resJson = jsonDecode(response.body);
    return resJson;
  }

  Future getFabTokenBalanceByAddress(String address, String coinName) async {
    final coinService = locator<CoinService>();
    var smartContractAddress = '';
    await coinService
        .getSmartContractAddressByTickerName(coinName)
        .then((value) => smartContractAddress = value!);
    var tokenBalance = 0.0;
    var tokenLockedBalance = 0.0;
    if (coinName == 'EXG' || coinName == 'CNB') {
      String balanceInfoABI = '70a08231';
      tokenBalance = await getFabTokenBalanceForABI(
          balanceInfoABI, smartContractAddress, address);
      balanceInfoABI = '6ff95d25';
      tokenLockedBalance = await getFabTokenBalanceForABI(
          balanceInfoABI, smartContractAddress, address);
    } else {
      String balanceInfoABI = '70a08231';
      tokenBalance = await getFabTokenBalanceForABI(
          balanceInfoABI, smartContractAddress, address, 6);
    }

    // debugPrint('address=' + address.toString());
    // debugPrint('tokenLockedBalance=' + tokenLockedBalance.toString());
    return {'balance': tokenBalance, 'lockbalance': tokenLockedBalance};
  }
}
