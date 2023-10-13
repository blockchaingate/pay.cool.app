import 'package:flutter/foundation.dart';
import 'package:paycool/environments/environment.dart';
import 'package:bip32/bip32.dart' as bip32;
import 'package:paycool/utils/exaddr.dart';
import '../../constants/constants.dart';
import '../../utils/coin_util.dart';
import '../../utils/string_util.dart';
import 'package:hex/hex.dart';

class MultisigUtil {
  static String exgToBinpdpayAddress(String exgAddress) {
    return toKbpayAddress(fabUtils.exgToFabAddress(exgAddress));
  }

  static signature(String hash, bip32.BIP32 root) async {
    var coinType = environment["CoinType"]["FAB"];
    final fabCoinChild = root.derivePath("m/44'/$coinType'/0'/0/0");
    var privateKey = fabCoinChild.privateKey;

    var chainId = environment["chains"]["ETH"]["chainId"];
    debugPrint('chainId==$chainId');

    var signedMess = await signPersonalMessageWith(
        Constants.EthMessagePrefix, privateKey!, stringToUint8List(hash),
        chainId: chainId);
    String ss = HEX.encode(signedMess);
    log.e('sig $ss');

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
