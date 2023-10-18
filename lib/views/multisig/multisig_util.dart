import 'package:flutter/foundation.dart';
import 'package:paycool/environments/environment.dart';
import 'package:bip32/bip32.dart' as bip32;
import 'package:paycool/utils/exaddr.dart';
import '../../constants/constants.dart';
import '../../utils/coin_util.dart';
import '../../utils/string_util.dart';
import 'package:hex/hex.dart';

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

  static signature(String hash, bip32.BIP32 root) async {
    var coinType = environment["CoinType"]["FAB"];
    final fabCoinChild = root.derivePath("m/44'/$coinType'/0'/0/0");
    var privateKey = fabCoinChild.privateKey;

    var ethChainId = environment["chains"]["ETH"]["chainId"];
    debugPrint('chainId==$ethChainId');

    var signedMess = await signPersonalMessageWith(
        Constants.EthMessagePrefix, privateKey!, stringToUint8List(hash),
        chainId: ethChainId);
    String ss = HEX.encode(signedMess);
    log.w('hexSignature $ss');

    return ss;
  }

  static transferABI(
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
