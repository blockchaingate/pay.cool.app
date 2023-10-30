import 'dart:convert';

import 'package:eth_abi_codec/eth_abi_codec.dart';
import 'package:flutter/foundation.dart';
import 'package:paycool/environments/environment.dart';
import 'package:bip32/bip32.dart' as bip32;
import 'package:paycool/utils/exaddr.dart';
import '../../constants/constants.dart';
import '../../utils/coin_util.dart';
import '../../utils/string_util.dart';
import 'package:hex/hex.dart';

import 'package:convert/convert.dart';

class MultisigUtil {
  static isChainKanban(String chain) {
    return chain.toLowerCase() == 'kanban';
  }

  static String exgToBinpdpayAddress(String exgAddress) {
    return toKbpayAddress(fabUtils.exgToFabAddress(exgAddress));
  }

  static bool sameString(String a, String b) {
    return a == b;
  }

  String bufferToHex(List<int> buffer) {
    return '0x' + HEX.encode(buffer);
  }

  decodeContractCall(String hexData) {
    var abi =
        ContractABI.fromJson(jsonDecode(Constants.multisigTransferAbiCode));
    var data = hex.decode('hex string of contract call result');
    var res = abi.decomposeCall(data as Uint8List);
    log.w('decodeContractCall res $res');
    return res;
  }

  static encodeContractCall(
    transaction,
    String signatures,
  ) {
    var jsonAbi = Constants.exuctionAbiJson;
    // var jsonData = json.decode(jsonAbi);
    ;
    log.e('jsonList $jsonAbi');
    var abi = ContractABI.fromJson(jsonAbi);
    var to = transaction["to"];
    debugPrint('to: $to');
    var value = transaction["value"] == "0x0" ? "0" : transaction["value"];
    value = fixLengthV2(value, 64);
    log.w('value $value');
    var data = trimHexPrefix(transaction["data"]);
    log.i('data $data');
    data = Uint8List.fromList(hex.decode(data));
    log.e('data in bytes $data');
    var operation =
        int.parse(transaction["operation"].toString()).toRadixString(16);
    operation = fixLengthV2(operation, 64);
    log.w('operation $operation');
    var safeTxGas = trimHexPrefix(transaction["safeTxGas"]);
    safeTxGas = fixLengthV2(safeTxGas, 64);
    log.i('safetxgas $safeTxGas');
    var baseGas = trimHexPrefix(transaction["baseGas"]);
    baseGas = fixLengthV2(baseGas, 64);
    log.w('basegas $baseGas');
    var gasPrice = trimHexPrefix(transaction["gasPrice"]);
    gasPrice = fixLengthV2(gasPrice, 64);
    log.i('gasPrice $gasPrice');
    var gasToken = trimHexPrefix(transaction["gasToken"]);
    gasToken = fixLengthV2(gasToken, 64);
    log.w('gastoken $gasToken');
    var refundReceiver = trimHexPrefix(transaction["refundReceiver"]);
    refundReceiver = fixLengthV2(refundReceiver, 64);
    log.i('refund receiver $refundReceiver');
    var sig = trimHexPrefix(signatures);
    log.w('sig $sig');
    sig = Uint8List.fromList(hex.decode(sig));
    log.e('sig in bytes $sig');
    var call = ContractCall('execTransaction')
          ..setCallParam('to',
              to) //0000000000000000000000008d65fc45de848e650490f1ffcd51c6baf52ea595
        // ..setCallParam('value', value) //0000000000000000000000000000000000000000000000000000000000000000
        // //[
        // // 63, 175, 10, 102, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 140, 73, 98, 169, 189, 90, 191, 45, 178,
        // // 40, 47, 135, 13, 219, 38, 217, 155, 238, 139, 253, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        // // 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        // // 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 218, 15, 106, 150, 193, 192, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        // // 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        // // ]
        // ..setCallParam('data', data)
        // ..setCallParam('operation', operation)//0000000000000000000000000000000000000000000000000000000000000000
        // ..setCallParam('safeTxGas', safeTxGas)//0000000000000000000000000000000000000000000000000000000000000000
        // ..setCallParam('baseGas', baseGas)//0000000000000000000000000000000000000000000000000000000000000000
        // ..setCallParam('gasPrice', gasPrice)//0000000000000000000000000000000000000000000000000000000000000000
        // ..setCallParam('gasToken', gasToken)//0000000000000000000000000000000000000000000000000000000000000000
        // ..setCallParam('refundReceiver', refundReceiver)//0000000000000000000000000000000000000000000000000000000000000000
        // //[
        // // 246, 64, 108, 193, 110, 94, 10, 229, 75, 47, 44, 107, 130, 193, 123, 1, 97, 142, 56, 85, 112, 204,
        // // 15, 255, 136, 233, 112, 38, 150, 157, 213, 132, 22, 123, 234, 255, 62, 146, 238, 50, 202, 124, 234,
        // // 102, 180, 178, 238, 33, 216, 4, 113, 245, 19, 14, 62, 138, 157, 61, 153, 72, 28, 26, 135, 101, 31,
        // // 107, 253, 20, 153, 198, 197, 5, 190, 211, 126, 139, 210, 39, 71, 21, 160, 107, 228, 60, 77, 60, 71,
        // // 125, 71, 47, 132, 94, 141, 175, 220, 94, 22, 46, 182, 124, 69, 48, 52, 199, 165, 158, 143, 15, 49,
        // // 54, 70, 4, 182, 191, 146, 228, 214, 219, 31, 65, 166, 65, 249, 129, 32, 113, 30, 253, 109, 32
        // // ]
        // ..setCallParam('signatures', sig)
        ;

    log.e('call $call');
    var finalAbi = hex.encode(call.toBinary(abi));
    log.w('finalAbi $finalAbi');
  }

  bool isTxHashSignedWithPrefix(
    String txHash,
    String signature,
    String ownerAddress,
  ) {
    bool hasPrefix;
    try {
      final rsvSig = {
        'r': HEX.decode(signature.substring(2, 66)),
        's': HEX.decode(signature.substring(66, 130)),
        'v': int.parse(signature.substring(130, 132), radix: 16),
      };

      // final recoveredData = ecrecover(
      //   HEX.decode(txHash.substring(2)),
      //   rsvSig['v'],
      //   rsvSig['r'],
      //   rsvSig['s'],
      // );

      final recoveredAddress = '';
      //bufferToHex(pubToAddress(recoveredData));
      hasPrefix = !sameString(recoveredAddress, ownerAddress);
    } catch (e) {
      hasPrefix = true;
    }
    return hasPrefix;
  }

  static String adjustVInSignature({
    required String signingMethod,
    required String signature,
    String? safeTxHash,
    String? signerAddress,
  }) {
    final List<int> ethereumVValues = [0, 1, 27, 28];
    const int minValidVValueForSafeEcdsa = 27;
    int signatureV =
        int.parse(signature.substring(signature.length - 2), radix: 16);

    if (!ethereumVValues.contains(signatureV)) {
      throw Exception('Invalid signature');
    }

    if (signingMethod == 'eth_sign') {
      if (signatureV < minValidVValueForSafeEcdsa) {
        signatureV += minValidVValueForSafeEcdsa;
      }

      // String adjustedSignature = signature.substring(0, signature.length - 2) +
      //     signatureV.toRadixString(16);

      bool signatureHasPrefix = sameString(signerAddress!, signerAddress);

      if (signatureHasPrefix) {
        signatureV += 4;
      }
    }

    if (signingMethod == 'eth_signTypedData') {
      if (signatureV < minValidVValueForSafeEcdsa) {
        signatureV += minValidVValueForSafeEcdsa;
      }
    }

    signature = signature.substring(0, signature.length - 2) +
        signatureV.toRadixString(16);
    return signature;
  }

  static signature(Uint8List hash, bip32.BIP32 root, {String tHash = ''}) {
    var coinType = environment["CoinType"]["FAB"];
    final fabCoinChild = root.derivePath("m/44'/$coinType'/0'/0/0");
    var privateKey = fabCoinChild.privateKey;

    var ethChainId = environment["chains"]["ETH"]["chainId"];
    debugPrint('chainId==$ethChainId');

    var signedMess = signMessageWithPrivateKey(
      hash,
      privateKey!,
    );
    var hexSig = fixSignature(signedMess);
    // String ss = HEX.encode(signedMess);
    // log.w('hexSignature $ss');

    debugPrint('finalSig   =$hexSig');

    var finalSig = hexSig['r'] + hexSig['s'] + hexSig['v'];
    debugPrint('finalSig before adjusting   =$finalSig');
    return finalSig;
  }

  static transferABIHex(
    transaction,
    String signatures,
  ) {
    var abiHex = Constants.multisigTransferAbiCode;

    var to = trimHexPrefix(transaction["to"]);
    debugPrint('to: $to');
    abiHex += fixLengthV2(to, 64);

    var value = transaction["value"] == "0x0" ? "0" : transaction["value"];
    abiHex += fixLengthV2(value, 64);

    var data = trimHexPrefix(transaction["data"]);
    abiHex += data;

    var operation =
        int.parse(transaction["operation"].toString()).toRadixString(16);
    abiHex += fixLengthV2(operation, 64);

    var safeTxGas = trimHexPrefix(transaction["safeTxGas"]);
    abiHex += fixLengthV2(safeTxGas, 64);

    var baseGas = trimHexPrefix(transaction["baseGas"]);
    abiHex += fixLengthV2(baseGas, 64);

    var gasPrice = trimHexPrefix(transaction["gasPrice"]);
    abiHex += fixLengthV2(gasPrice, 64);

    var gasToken = trimHexPrefix(transaction["gasToken"]);
    abiHex += fixLengthV2(gasToken, 64);

    var refundReceiver = trimHexPrefix(transaction["refundReceiver"]);
    abiHex += fixLengthV2(refundReceiver, 64);

    abiHex += trimHexPrefix(signatures);

    debugPrint('rawTx abiHex $abiHex');

    return abiHex;
  }
}
