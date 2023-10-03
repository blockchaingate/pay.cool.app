import 'package:flutter/foundation.dart';
import 'package:paycool/environments/environment.dart';
import 'package:bip32/bip32.dart' as bip32;
import '../../constants/constants.dart';
import '../../utils/coin_util.dart';
import '../../utils/string_util.dart';
import 'package:hex/hex.dart';
import 'package:web3dart/web3dart.dart' as web3;

class MultisigUtil {
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
    abiHex += fixLength(trimHexPrefix(transaction["to"]), 64);
    abiHex += fixLength(transaction["value"], 64);
    abiHex += transaction["data"];
    abiHex += fixLength(transaction["operation"].toString(), 64);
    abiHex += fixLength(transaction["safeTxGas"], 64);
    abiHex += fixLength(transaction["baseGas"], 64);
    abiHex += fixLength(transaction["gasPrice"], 64);
    abiHex += fixLength(transaction["gasToken"], 64);
    abiHex += fixLength(transaction["refundReceiver"], 64);
    abiHex += signatures;
    debugPrint('rawTx abiHex $abiHex');
    // abiHex += fixLength(amountHex, 64);
    // abiHex += fixLength(trimHexPrefix(addressInKanban), 64);
    // abiHex += trimHexPrefix(signedMessage["r"]);
    // abiHex += trimHexPrefix(signedMessage["s"]);
    return abiHex;
  }
}
