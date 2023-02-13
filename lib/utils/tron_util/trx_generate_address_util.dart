import 'dart:typed_data';
import 'package:bs58check/bs58check.dart' as bs58check;

// import 'package:bip32/src/utils/ecurve.dart' as ecc;
// import 'package:pointycastle/src/utils.dart';
import 'package:bip32/bip32.dart' as bip32;
import '../../../os_packages/bitcoin_flutter/lib/bitcoin_flutter.dart' as BitcoinFlutter;
import 'package:web3dart/crypto.dart' as CryptoWeb3;

import '../../service_locator.dart';
import '../../services/wallet_service.dart';

generateTrxPrivKey(String mnemonic) {
  final walletService = locator<WalletService>();
  var seed = walletService.generateSeed(mnemonic);
  var root = walletService.generateBip32Root(seed);

  String ct = '195';
  bip32.BIP32 node = root.derivePath("m/44'/" + ct + "'/0'/0/" + 0.toString());

  var privKey = node.privateKey;
  return privKey;
}

generateTrxPrivKeyBySeed(seed) {
  final walletService = locator<WalletService>();
  var root = walletService.generateBip32Root(seed);

  String ct = '195';
  bip32.BIP32 node = root.derivePath("m/44'/" + ct + "'/0'/0/" + 0.toString());

  var privKey = node.privateKey;
  return privKey;
}

generateTrxAddress(String mnemonic) {
  final walletService = locator<WalletService>();
  var privKey = generateTrxPrivKey(mnemonic);
  //debugPrint('priv key $privKey -- length ${privKey.length}');
  // debugPrint('priv Key ${StringUtil.uint8ListToHex(privKey)}');
  //  var pubKey = node.publicKey;
  //  log.w('pub key $pubKey -- length ${pubKey.length}');
  var uncompressedPubKey =
      BitcoinFlutter.ECPair.fromPrivateKey(privKey, compressed: false)
          .publicKey;
  // debugPrint('uncompressedPubKey  length ${uncompressedPubKey.length}');
  // debugPrint('uncompressedPubKey ${StringUtil.uint8ListToHex(uncompressedPubKey)}');

  if (uncompressedPubKey!.length == 65) {
    uncompressedPubKey = uncompressedPubKey.sublist(1);
    //  debugPrint(
    //     'uncompressedPubKey > 65 ${StringUtil.uint8ListToHex(uncompressedPubKey)} -- length ${uncompressedPubKey.length}');
  }

  var hash = CryptoWeb3.keccak256(uncompressedPubKey);
  // debugPrint('hash $hash');

  // debugPrint('hex ${StringUtil.uint8ListToHex(hash)}');
// take 20 bytes at the end from hash
  var last20Bytes = hash.sublist(12);
  // debugPrint('last20Bytes $last20Bytes');
  List<int> updatedHash = [];
  //  var addressHex = Uint8List.fromList(hash);
  int i = 1;
  for (var f in last20Bytes) {
    if (i == 1) {
      updatedHash.add(65);
      i++;
    }
    updatedHash.add(f);
    i++;
  }
  //debugPrint('updatedHash $updatedHash');
  // take 0x41 or 65 + (hash[12:32] means take last 20 bytes from addressHex and discard first 12)
  // to do sha256 twice and get 4 bytes checksum
  var sha256Hash = walletService.sha256Twice(updatedHash);

  // first 4 bytes checksum
  var checksum = sha256Hash.bytes.sublist(0, 4);
  //debugPrint('checksum  -- $checksum');
  //debugPrint('checksum hex ${StringUtil.uint8ListToHex(checksum)}');
  updatedHash.addAll(checksum);
  //debugPrint('updatedHash with checksum $updatedHash');

  // use base58 on (0x41 + hash[12:32] + checksum)
  // or base 58 on updateHash which first need to convert to Iint8List to get address
  Uint8List uIntUpdatedHash = Uint8List.fromList(updatedHash);
  var address = bs58check.base58.encode(uIntUpdatedHash);
  // debugPrint('address $address');
  return address;
}

computeAddress(String pubBytes) {
  // debugPrint('in compute');
  if (pubBytes.length == 65) pubBytes = pubBytes.substring(1);
  // var signature = sign(keccak256(concat), privateKey);
  // debugPrint('1 $pubBytes');
  var hash = CryptoWeb3.keccakUtf8(pubBytes);
  // debugPrint('hash $hash');
  //   var addressHex = "41" + hash.substring(24);
  //   debugPrint('address hex $addressHex');
  // var output = hex.encode(outputHashData);
  //  return hexStr2byteArray(addressHex);
}
