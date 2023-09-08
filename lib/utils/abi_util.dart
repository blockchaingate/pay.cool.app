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

import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:hex/hex.dart';
import 'package:paycool/constants/constants.dart';
import 'package:paycool/environments/environment.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/utils/exaddr.dart';
import 'package:paycool/utils/fab_util.dart';
import 'package:paycool/utils/number_util.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/src/utils/rlp.dart' as rlp;
import 'package:web3dart/web3dart.dart';

import './string_util.dart';

var fabUtils = FabUtils();
final log = getLogger('AbiUtils');
/*--------------------------------------------------------
                    Display abihex in readable way
--------------------------------------------------------*/
displayAbiHexinReadableFormat(String abiHex) {
  //0xdca68eb0666177656661776566610000000000000000000000000000000000
  int totalLen = abiHex.length;
  String abiWithoutCode = abiHex.substring(10, totalLen - 10);
  int len = abiWithoutCode.length;
  var divisble = len / 64;
  //var remainder =
  int dividedRes = divisble.truncate();
  int start = 0;
  int bytesLen = 64;
  List<String> keys = [
    "orderId",
    "coinType",
    "totalAmount",
    "rewardBeneficiary",
    "",
    "",
    ""
  ];
  debugPrint('abi code: ${abiHex.substring(0, 10)}');
  for (var i = 0; i < dividedRes; i++) {
    var data = abiWithoutCode.substring(start, start + bytesLen);
    debugPrint('${keys[i]}: $data');
    start += bytesLen;
    if (i == 2) {
      // 000000000000000000000000000000000000000000000000a688906bd8b00000
      //double amount = NumberUtil.hexToDouble(data);
      //   debugPrint('amount $amount');
    }
  }
  var remainder = len - (bytesLen * dividedRes);
  debugPrint(abiWithoutCode.substring(start, start + remainder));

  // Web3.ContractAbi contractAbi =
  //     new Web3.ContractAbi.fromJson(abiWithoutCode, 'chargeFundsWithFee');
  // // contractAbi.
  // debugPrint(contractAbi);

  // Web3.DecodingResult dR = new Web3.DecodingResult().data;
  // var res = dR.data(abiWithoutCode);
  // debugPrint(res);

  // Web3.ContractFunction f = new Web3.ContractFunction({});
  // var dec = f.decodeReturnValues(abiHex);
  // debugPrint('dec $dec');
  // var enc = f.encodeCall(dec);
  // debugPrint('enc $enc');
}

/*--------------------------------------------------------
                    Extract referral address
--------------------------------------------------------*/

extractWalletAddressFromPayCoolClubScannedAbiHex(String abiHex) {
  String abi = abiHex.substring(0, 10);
  debugPrint(abi.toString());
  // String orderIdHex = abiHex.substring(10, 74);
  // debugPrint('orderIdHex $orderIdHex');
  String walletAddressHex = abiHex.substring(11, 74);
  String removeZerosFromHex =
      walletAddressHex.substring(23, walletAddressHex.length);
  debugPrint(
      'removeZerosFromHex $removeZerosFromHex -- length ${removeZerosFromHex.length}');
  String walletAddress = '';
  if (removeZerosFromHex.length == 40) {
    walletAddress = fabUtils.exgToFabAddress('0x$removeZerosFromHex');
  }
  debugPrint('wallet address $walletAddress');

  return {'walletAddress': walletAddress};
}
/*--------------------------------------------------------
Extract Referral Address From Pay Cool Club Scanned Abi Hex
--------------------------------------------------------*/

extractAddressFromAbihex(String abiHex) {
  String abi = abiHex.substring(0, 10);
  debugPrint(abi.toString());
  // String orderIdHex = abiHex.substring(10, 74);
  // debugPrint('orderIdHex $orderIdHex');
  String referralAddressHex = abiHex.substring(75, 138);
  String removeZerosFromHex =
      referralAddressHex.substring(23, referralAddressHex.length);
  debugPrint(
      'removeZerosFromHex $removeZerosFromHex -- length ${removeZerosFromHex.length}');
  String referralAddress = '';
  if (removeZerosFromHex.length == 40) {
    referralAddress = fabUtils.exgToFabAddress('0x$removeZerosFromHex');
  }
  debugPrint('referral address $referralAddress');

  return {'referralAddress': referralAddress};
}

/*--------------------------------------------------------
                    Extract data from abihex
--------------------------------------------------------*/

extractDataFromAbiHex(String abiHex) {
  String abi = abiHex.substring(0, 10);
  debugPrint(abi);
  // String orderIdHex = abiHex.substring(10, 74);
  // debugPrint('orderIdHex $orderIdHex');
  String coinTypeHex = abiHex.substring(74, 138);
  int coinType = NumberUtil.hexToInt(coinTypeHex);
  debugPrint('coin type $coinType');
  var amountHex = abiHex.substring(138, abiHex.length);
  double amount = NumberUtil.hexToDouble(amountHex);
  // StringUtils.hexToAscii(orderIdHex);
  return {'coinType': coinType};
}

/*----------------------------------------------------------------------
                    Seven Star club Join Abi
----------------------------------------------------------------------*/
getPayCoolClubFuncABI(int coinType, String walletAddr, String referralAddr) {
  log.i(
      'coinType $coinType -- walletAddress $walletAddr -- referralAddr $referralAddr');
  var abiHex = Constants.payCoolClubSignatureAbi;
  abiHex += fixLength(trimHexPrefix(fabUtils.fabToExgAddress(walletAddr)), 64);
  abiHex += referralAddr.startsWith('0x')
      ? fixLength(trimHexPrefix(referralAddr), 64)
      : fixLength(trimHexPrefix(fabUtils.fabToExgAddress(referralAddr)), 64);
  abiHex += fixLength(coinType.toRadixString(16), 64);
  debugPrint('getPayCoolClubFuncABI abi $abiHex');
  return abiHex;
}

/*----------------------------------------------------------------------
                    Seven Star Pay Abi
----------------------------------------------------------------------*/
String generateGenericAbiHex(String abiCode, String data) {
  var exgAddress = fabUtils.fabToExgAddress(data);
  String abiHex = abiCode + fixLength(trimHexPrefix(exgAddress), 64);
  // 0x775274a17266776165667761726165617700000000000000000000000000000000000000
  return abiHex;
}

getPayCoolFuncABI(int coinType, amount, String abi) {
  var abiHex = abi;

  abiHex += fixLength(coinType.toRadixString(16), 64);
  var amountHex = amount.toRadixString(16);
  abiHex += fixLength(trimHexPrefix(amountHex), 64);
  return abiHex;
}

String constructPaycoolRefundAbiHex(String orderId) {
  String abiHex =
      Constants.payCoolRefundAbi + fixLength(trimHexPrefix(orderId), 64);
  // 0x775274a17266776165667761726165617700000000000000000000000000000000000000
  return abiHex;
}

String constructPaycoolCancelAbiHex(String orderId) {
  String abiHex =
      Constants.payCoolCancelAbi + fixLength(trimHexPrefix(orderId), 64);
  // 0x775274a17266776165667761726165617700000000000000000000000000000000000000
  return abiHex;
}

/*----------------------------------------------------------------------
                    Withdraw abi
----------------------------------------------------------------------*/
getWithdrawFuncABI(coinType, amountInLink, addressInWallet,
    {String chain = '', bool isSpecialToken = false}) {
  var abiHex = Constants.withdrawSignatureAbi;
  if (isSpecialToken) {
    var hexaDecimalCoinType = fix8LengthCoinType(coinType.toRadixString(16));
    abiHex += specialFixLength(hexaDecimalCoinType, 64, chain);
  } else {
    abiHex += fixLength(coinType.toRadixString(16), 64);
  }

  var amountHex = amountInLink.toRadixString(16);
  abiHex += fixLength(trimHexPrefix(amountHex), 64);

  abiHex += fixLength(trimHexPrefix(addressInWallet), 64);
  return abiHex;
}

/*----------------------------------------------------------------------
                    Send Abi
----------------------------------------------------------------------*/
getSendCoinFuncABI(coinType, kbPaymentAddress, amount) {
  var abiHex = Constants.sendSignatureAbi;
  var fabAddress = toLegacyAddress(kbPaymentAddress);

  var exgAddress = fabUtils.fabToExgAddress(fabAddress);
  abiHex += fixLength(trimHexPrefix(exgAddress), 64);
  abiHex += fixLength(coinType.toRadixString(16), 64);
  var amountHex = amount.toRadixString(16);
  abiHex += fixLength(trimHexPrefix(amountHex), 64);
  return abiHex;
}

/*----------------------------------------------------------------------
                    Deposit Abi
----------------------------------------------------------------------*/
//0x10c43d65000000000000000000000000dcd0f23125f74ef621dfa3310625f8af0dcd971b0000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000a688906bd8b00000

getDepositFuncABI(int coinType, String txHash, BigInt amountInLink,
    String addressInKanban, signedMessage,
    {String chain = '', bool isSpecialDeposit = false}) {
  var abiHex = Constants.depositSignatureAbi;
  abiHex += trimHexPrefix(signedMessage["v"]);
  if (isSpecialDeposit) {
    // coin type of coins converting to hex for instance 458753 becomes 00070001
    var hexaDecimalCoinType = fix8LengthCoinType(coinType.toRadixString(16));
    abiHex += specialFixLength(hexaDecimalCoinType, 62, chain);
  } else {
    abiHex += fixLength(coinType.toRadixString(16), 62);
  }
  abiHex += trimHexPrefix(txHash);
  var amountHex = amountInLink.toRadixString(16);

  abiHex += fixLength(amountHex, 64);
  abiHex += fixLength(trimHexPrefix(addressInKanban), 64);
  abiHex += trimHexPrefix(signedMessage["r"]);
  abiHex += trimHexPrefix(signedMessage["s"]);
  return abiHex;
}

specialFixLength(String hexaDecimalCoinType, int length, String chain) {
  var retStr = '';
  int hexaDecimalCoinTypeLength = hexaDecimalCoinType.length;
  debugPrint('hexaDecimalCoinType $hexaDecimalCoinTypeLength');
  int len2 = length - hexaDecimalCoinTypeLength;
  int finalLength = len2 - 4; // subtract chain hexa length
  if (finalLength > 0) {
    for (int i = 0; i < finalLength; i++) {
      retStr += '0';
    }
    if (chain == 'ETH') {
      retStr += Constants.EthChainPrefix;
    } else if (chain == 'TRX') {
      retStr += Constants.TronChainPrefix;
    } else if (chain == 'FAB') {
      retStr += Constants.FabChainPrefix;
    } else if (chain == 'MATICM' || chain == 'POLYGON') {
      retStr += Constants.maticmChainPrefix;
    } else if (chain == 'BNB') {
      retStr += Constants.bnbChainPrefix;
    }

    retStr += hexaDecimalCoinType;
    return retStr;
  } else if (finalLength < 0) {
    return hexaDecimalCoinType.substring(0, length - 1);
  } else {
    return hexaDecimalCoinType;
  }
}

String fix8LengthCoinType(String coinType) {
  debugPrint('fix8LengthCoinType $coinType');
  String result = '';
  const int reqLength = 8;
  int coinTypeLength = coinType.length;
  int diff = 0;
  if (coinTypeLength < reqLength) {
    diff = reqLength - coinTypeLength;
    for (int i = 0; i < diff; i++) {
      result += '0';
    }
    result += coinType;
  }
  debugPrint('fix8LengthCoinType result $result');
  return result;
}

/*
 0x12a3da170000000000000000000000000000000000000000000000000000000000000001
 00000000000000000000000000000000000000000000000000000000000000010000000000
 00000000000000000000000000000000000000000000000000000200000000000000000000
 00000000000000000000000000000000000000000003000000000000000000000000000000
 000000000000000000002386f26fc100000000000000000000000000000000000000000000
 00000000002386f26fc1000000000000000000000000000000000000000000000000000000
 00006296a75020000000000000000000000000000000000000000000000000000000000000
 000006e328d04a77db9be48be26004e8eb87ccb4432839a10bdff4112a2bffdb3821
   */
getCreateOrderFuncABI(
    bool payWithEXG,
    bool bidOrAsk,
    // int orderType,
    int baseCoin,
    int targetCoin,
    String qty,
    String price,
    //int timeBeforeExpiration,
    String orderHash) {
  var abiHex = '0x19b54ba9';
  var payWithEXGString = payWithEXG ? '1' : '0';
  abiHex += fixLength(payWithEXGString, 64);
  var bidOrAskString = bidOrAsk ? '1' : '0';
  abiHex += fixLength(bidOrAskString, 64);
  // abiHex += fixLength(orderType.toString(), 64);
  abiHex += fixLength(baseCoin.toString(), 64);
  abiHex += fixLength(targetCoin.toString(), 64);
  var qtyHex = BigInt.parse(qty).toRadixString(16);
  abiHex += fixLength(qtyHex, 64);
  var priceHex = BigInt.parse(price).toRadixString(16);
  abiHex += fixLength(priceHex, 64);
  // abiHex += fixLength(timeBeforeExpiration.toString(), 64);
  abiHex += fixLength(orderHash, 64);

  return abiHex;
}

List<dynamic> _encodeToRlp(Transaction transaction, MsgSignature signature) {
  final list = [
    transaction.nonce,
    transaction.gasPrice!.getInWei,
    transaction.maxGas,
  ];

  if (transaction.to != null) {
    list.add(transaction.to!.addressBytes);
  } else {
    list.add('');
  }

  list.add(transaction.value!.getInWei);
  // list.add('');
  list.add(transaction.data);

  list
    ..add(signature.v)
    ..add(signature.r)
    ..add(signature.s);

  return list;
}

Uint8List uint8ListFromList(List<int> data) {
  if (data is Uint8List) return data;

  return Uint8List.fromList(data);
}

Future signAbiHexWithPrivateKey(String data, String privateKey,
    String toAddress, int nonce, int gasPrice, int gasLimit,
    {String chainIdParam = "KANBAN"}) async {
  int? chainId = environment["chains"][chainIdParam]["chainId"];

  data = trimHexPrefix(data);

  var credentials = EthPrivateKey.fromHex(privateKey);

  var transaction = Transaction(
      to: EthereumAddress.fromHex(toAddress),
      gasPrice: EtherAmount.fromInt(EtherUnit.wei, gasPrice),
      maxGas: gasLimit,
      nonce: nonce,
      value: EtherAmount.fromInt(EtherUnit.wei, 0),
      data: Uint8List.fromList(HEX.decode(data)));

  final innerSignature =
      chainId == null ? null : MsgSignature(BigInt.zero, BigInt.zero, chainId);

  var transactionList = _encodeToRlp(transaction, innerSignature!);
  final encoded = uint8ListFromList(rlp.encode(transactionList));

  final signature = credentials.signToEcSignature(encoded, chainId: chainId);

  var encodeList =
      uint8ListFromList(rlp.encode(_encodeToRlp(transaction, signature)));
  var finalString = '0x${HEX.encode(encodeList)}';
  // debugPrint('finalString===' + finalString);
  return finalString;
}
