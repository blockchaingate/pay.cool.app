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

import 'package:bip32/bip32.dart' as bip_32;
import 'package:bitbox/bitbox.dart' as bitbox;
import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:paycool/constants/constants.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/db/token_list_database_service.dart';
import 'package:paycool/utils/fab_util.dart';
import 'package:paycool/utils/ltc_util.dart';
import 'package:paycool/utils/number_util.dart';
import 'package:paycool/utils/wallet_coin_address_utils/doge_util.dart';
import './eth_util.dart';

//import '../packages/bip32/bip32_base.dart' as bip32;

//import '../packages/bip32/utils/ecurve.dart' as ecc;
import 'package:hex/hex.dart';
import '../utils/string_util.dart';
import '../environments/environment.dart';
import './btc_util.dart';
import "package:pointycastle/pointycastle.dart";
import 'dart:typed_data';
import 'dart:convert';
import "package:pointycastle/ecc/curves/secp256k1.dart";
import "package:pointycastle/digests/sha256.dart";
import "package:pointycastle/signers/ecdsa_signer.dart";
import 'package:pointycastle/macs/hmac.dart';
import 'varuint.dart';
import '../environments/coins.dart' as coin_list;
import 'package:paycool/utils/tron_util/trx_generate_address_util.dart'
    as tron_address_util;
import 'package:web3dart/crypto.dart' as web3_dart;

final ECDomainParameters _params = ECCurve_secp256k1();
final BigInt _halfCurveOrder = _params.n >> 1;
final log = getLogger('coin_util');
var fabUtils = FabUtils();

hashKanbanMessage(String message) {
  List<int> messagePrefix = utf8.encode(Constants.KanbanMessagePrefix);
  log.w('hashKanbanMessage prefix=== $messagePrefix');

  var messageHexToBytes = web3_dart.hexToBytes(message);
  debugPrint('messageHexToBytes $messageHexToBytes');
  var messageLengthToAscii = ascii.encode(messageHexToBytes.length.toString());
  var messageBuffer = Uint8List(messageHexToBytes.length);

  int preamble = messagePrefix.length +
      messageHexToBytes.length +
      messageLengthToAscii.length;
  Uint8List preambleBuffer = Uint8List(preamble);

  preambleBuffer.setRange(0, messagePrefix.length + messageLengthToAscii.length,
      messagePrefix + messageLengthToAscii);

  int bufferStart = messagePrefix.length;
  int bufferEnd = preamble;

  preambleBuffer.setRange(
      bufferStart + messageLengthToAscii.length, bufferEnd, messageHexToBytes);

  log.w('hashKanbanMessage buffer $preambleBuffer');
  return web3_dart.keccak256(preambleBuffer);
}

Future signHashKanbanMessage(Uint8List seed, Uint8List hash,
    {isMsgSignatureType = false}) async {
  var network = environment["chains"]["BTC"]["network"];

  final root2 = bip_32.BIP32.fromSeed(
      seed,
      bip_32.NetworkType(
          wif: network.wif,
          bip32: bip_32.Bip32Type(
              public: network.bip32.public, private: network.bip32.private)));
// 1150 = fab coin type
  var bitCoinChild = root2.derivePath("m/44'/${1150}'/0'/0/0");
  var privateKey = bitCoinChild.privateKey;

  var signature = signMessageWithPrivateKey(hash, privateKey!);

  debugPrint('signature.v=======${signature.v}');

  final chainIdV = signature.v + 27;
  debugPrint('chainIdV=$chainIdV');
  signature = web3_dart.MsgSignature(signature.r, signature.s, chainIdV);

  final r = _padTo32(NumberUtil.encodeBigIntV1(signature.r));
  final s = _padTo32(NumberUtil.encodeBigIntV1(signature.s));
  final v = NumberUtil.encodeBigIntV1(BigInt.from(signature.v));
  final hexr = web3_dart.bytesToHex(r.toList(), include0x: true);
  final hexs = web3_dart.bytesToHex(s.toList(), include0x: true);
  final hexv = web3_dart.bytesToHex(v, include0x: true);
  var rsv = {"r": hexr, "s": hexs, "v": hexv};

  return rsv;
}

/*----------------------------------------------------------------------
                    Magic hash kanban
----------------------------------------------------------------------*/

magicHashForKanban(message) {
  log.i('kanban message prefix string ${Constants.KanbanMessagePrefix}');
  List<int> messagePrefix = utf8.encode('\u0017Kanban Signed Message:\n');
  log.w('magicHashForKanban prefix=== $messagePrefix');

  //int messageVISize = encodingLength(message.length);
  //log.i('messageVISize=== $messageVISize');
  var messageLengthToAscii = ascii.encode(message.length.toString());
  debugPrint('messageLengthToAscii $messageLengthToAscii');
  int totalBufferLen =
      (messagePrefix.length + message.length + messageLengthToAscii.length)
          .toInt();
  Uint8List buffer = Uint8List(totalBufferLen);

  buffer.setRange(0, messagePrefix.length + messageLengthToAscii.length,
      messagePrefix + messageLengthToAscii);

  int bufferStart = messagePrefix.length
      // + messageVISize
      +
      messageLengthToAscii.length;
  int bufferEnd = totalBufferLen;

  buffer.setRange(bufferStart, bufferEnd, utf8.encode(message));

  log.w('magicHashForKanban buffer $buffer');
  return web3_dart.keccak256(buffer);
}

/*----------------------------------------------------------------------
                Sign kanban message
----------------------------------------------------------------------*/

Future<Uint8List> signKanbanMessage(
  Uint8List seed,
  String message,
) async {
  var network = environment["chains"]["BTC"]["network"];

  final root2 = bip_32.BIP32.fromSeed(
      seed,
      bip_32.NetworkType(
          wif: network.wif,
          bip32: bip_32.Bip32Type(
              public: network.bip32.public, private: network.bip32.private)));
// 1150 = fab coin type
  var bitCoinChild = root2.derivePath("m/44'/${1150}'/0'/0/0");
  var privateKey = bitCoinChild.privateKey;
  log.w('signKanbanMessage message $message');
  var hash = magicHashForKanban(message);
  log.i('signKanbanMessage hash in hex ${uint8ListToHex(hash)}');
  var signature = signMessageWithPrivateKey(hash, privateKey!);

  debugPrint('signature.v=======${signature.v}');

  final chainIdV = signature.v + 27;
  debugPrint('chainIdV=$chainIdV');
  signature = web3_dart.MsgSignature(signature.r, signature.s, chainIdV);

  final r = _padTo32(NumberUtil.encodeBigIntV1(signature.r));
  final s = _padTo32(NumberUtil.encodeBigIntV1(signature.s));
  final v = NumberUtil.encodeBigIntV1(BigInt.from(signature.v));

  return uint8ListFromList(r + s + v);
  // return credential.sign(concat, chainId: chainId);
}

/*----------------------------------------------------------------------
                Sign deposit TRX tx
--------------r--------------------------------------------------------*/
signTrxMessage(
  String originalMessage,
  Uint8List privateKey,
) {
  // const a = "0x15TRON Signed Message:\n";
  // var aToAscii = ascii.encode(a);
  // debugPrint('aToAscii $aToAscii');
  //debugPrint('part1HexPrefix $part1PrefixBytes');
  //Uint8List prefixBytes = CryptoWeb3.hexToBytes(messagePrefix);
// Uint8List bytePrefixIntToUintList = CryptoWeb3.(
//   bytePrefixToInt);

  // const intBytePrefix = 0x15;
  // Uint8List part1PrefixBytes = utf8.encode(intBytePrefix.toString());
  // debugPrint('intBytePrefixToHex ${uint8ListToHex(part1PrefixBytes)}');

  const messagePrefix = '\u0015TRON Signed Message:\n';
  final prefixBytes = ascii.encode(messagePrefix);
  debugPrint(
      'part2PrefixBytes ascii bytes to hex-- ${web3_dart.bytesToHex(prefixBytes)}');

  //final prefixBytes = part1PrefixBytes + part2PrefixBytes;
  debugPrint(
      'final prefixBytes bytes ascii bytes to hex-- ${web3_dart.bytesToHex(prefixBytes)}');

  debugPrint('hash $originalMessage --  hash length ${originalMessage.length}');

  Uint8List originalMessageWithPrefix = Uint8List.fromList(prefixBytes +
      //CryptoWeb3.hexToBytes(originalMessage));
      ascii.encode(originalMessage));
  debugPrint(
      'originalMessageWithPrefix ${web3_dart.bytesToHex(originalMessageWithPrefix)}');

  var hashedOriginalMessageWithPrefix =
      web3_dart.keccak256(originalMessageWithPrefix);

  debugPrint(
      'hashedOriginalMessageWithPrefix ${web3_dart.bytesToHex(hashedOriginalMessageWithPrefix)}');

  var signature =
      signMessageWithPrivateKey(hashedOriginalMessageWithPrefix, privateKey);

  debugPrint('signature v ${signature.v}');

  final chainIdV = signature.v + 27;

  debugPrint('chainIdV $chainIdV');

  signature = web3_dart.MsgSignature(signature.r, signature.s, chainIdV);

  final r = _padTo32(NumberUtil.encodeBigIntV1(signature.r));
  final s = _padTo32(NumberUtil.encodeBigIntV1(signature.s));
  var v = NumberUtil.encodeBigIntV1(BigInt.from(signature.v));

  var rsv = r + s + v;
  debugPrint('rsv  $rsv');
  return rsv;
}

/*----------------------------------------------------------------------
                Sign TRX transaction for send
--------------r--------------------------------------------------------*/
List<Uint8List> signTrxTx(
  Uint8List hash,
  Uint8List privateKey,
) {
  debugPrint('sign trx');

  var signature = signMessageWithPrivateKey(hash, privateKey);

  // https://github.com/ethereumjs/ethereumjs-util/blob/8ffe697fafb33cefc7b7ec01c11e3a7da787fe0e/src/signature.ts#L26
  // be aware that signature.v already is recovery + 27

  debugPrint('signature v ${signature.v}');

  final chainIdV = signature.v;

  debugPrint('chainIdV $chainIdV');
  //final chainIdV = signature.v;
  signature = web3_dart.MsgSignature(signature.r, signature.s, chainIdV);

  //debugPrint('chainIdVchainIdVchainIdV==' + chainIdV.toString());
  //debugPrint('signature.v====');
  //debugPrint(signature.v);
  final r = _padTo32(NumberUtil.encodeBigIntV1(signature.r));
  final s = _padTo32(NumberUtil.encodeBigIntV1(signature.s));
  var v = NumberUtil.encodeBigIntV1(BigInt.from(signature.v));

  if (signature.v == 0) {
    v = Uint8List.fromList([0].toList());
  }
  List<Uint8List> rsvList = [];
  var res = r + s + v;
  rsvList.add(Uint8List.fromList(res));
  debugPrint('rsv list $rsvList');
  return rsvList;
}

/*----------------------------------------------------------------------
                Convert Decimal to Hex
----------------------------------------------------------------------*/

int convertDecimalToHex(int coinType) {
  var x = coinType.toRadixString(16);
  log.e('basecoin $coinType --  Hex == $x');
  return int.parse(x);
}

/*----------------------------------------------------------------------
                Hash 256
----------------------------------------------------------------------*/

Uint8List hash256(Uint8List buffer) {
  Uint8List _tmp = SHA256Digest().process(buffer);
  return SHA256Digest().process(_tmp);
}

/*--------------------------------------------------------------------------
                  Get Coin name by cointype
------------------------------------------------------------------------- */
Future<String?> getTickerNameByType(int coinType) async {
  TokenListDatabaseService tokenListDatabaseService =
      locator<TokenListDatabaseService>();
  String? tickerName = coin_list.newCoinTypeMap[coinType];
  if (tickerName == null) {
    await tokenListDatabaseService
        .getTickerNameByCoinType(coinType)
        .then((ticker) {
      tickerName = ticker;
      log.w('submit redeposit ticker $ticker');
    });
  }
  return tickerName;
}

encodeSignature(signature, recovery, compressed, segwitType) {
  if (segwitType != null) {
    recovery += 8;
    if (segwitType == 'p2wpkh') recovery += 4;
  } else {
    if (compressed) recovery += 4;
  }
  recovery += 27;
  return recovery.toRadixString(16);
}

/*
Future signedBitcoinMessage(String originalMessage, String wif) async {
  debugPrint('originalMessage=');
  debugPrint(originalMessage);
  var hdWallet = Wallet.fromWIF(wif);
  var compressed = false;
  var sigwitType;
  var signedMess = await hdWallet.sign(originalMessage);
  var recovery = 0;
  var r = encodeSignature(signedMess, recovery, compressed, sigwitType);
  debugPrint('r=');
  debugPrint(r);
  debugPrint('signedMess=');
  debugPrint(signedMess);
  return signedMess;
}
*/

web3_dart.MsgSignature signMessageWithPrivateKey(
    Uint8List messageHash, Uint8List privateKey) {
  final digest = SHA256Digest();
  final signer = ECDSASigner(null, HMac(digest, 64));
  final key = ECPrivateKey(NumberUtil.decodeBigIntV1(privateKey), _params);

  signer.init(true, PrivateKeyParameter(key));
  var sig = signer.generateSignature(messageHash) as ECSignature;

  debugPrint('sig =============');
  debugPrint(sig.r.toString());
  debugPrint(sig.s.toString());
  /*
	This is necessary because if a message can be signed by (r, s), it can also
	be signed by (r, -s (mod N)) which N being the order of the elliptic function
	used. In order to ensure transactions can't be tampered with (even though it
	would be harmless), Ethereum only accepts the signature with the lower value
	of s to make the signature for the message unique.
	More details at
	https://github.com/web3j/web3j/blob/master/crypto/src/main/java/org/web3j/crypto/ECDSASignature.java#L27
	 */
  if (sig.s.compareTo(_halfCurveOrder) > 0) {
    final canonicalisedS = _params.n - sig.s;
    sig = ECSignature(sig.r, canonicalisedS);
  }

  final publicKey =
      NumberUtil.decodeBigIntV1(web3_dart.privateKeyBytesToPublic(privateKey));
  debugPrint("publicKey: $publicKey");

  //Implementation for calculating v naively taken from there, I don't understand
  //any of this.
  //https://github.com/web3j/web3j/blob/master/crypto/src/main/java/org/web3j/crypto/Sign.java
  var recId = -1;
  for (var i = 0; i < 4; i++) {
    final k = _recoverFromSignature(i, sig, messageHash, _params);
    if (k == publicKey) {
      recId = i;
      break;
    }
  }

  debugPrint('recId====$recId');
  if (recId == -1) {
    throw Exception(
        'Could not construct a recoverable key. This should never happen');
  }

  return web3_dart.MsgSignature(sig.r, sig.s, recId);
}

BigInt? _recoverFromSignature(
    int recId, ECSignature sig, Uint8List msg, ECDomainParameters params) {
  final n = params.n;
  final i = BigInt.from(recId ~/ 2);
  final x = sig.r + (i * n);

  //Parameter q of curve
  final prime = BigInt.parse(
      'fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f',
      radix: 16);
  if (x.compareTo(prime) >= 0) return null;

  final R = _decompressKey(x, (recId & 1) == 1, params.curve);
  if (!(R! * n)!.isInfinity) return null;

  final e = NumberUtil.decodeBigIntV1(msg);

  final eInv = (BigInt.zero - e) % n;
  final rInv = sig.r.modInverse(n);
  final srInv = (rInv * sig.s) % n;
  final eInvrInv = (rInv * eInv) % n;

  final q = (params.G * eInvrInv)! + (R * srInv);

  final bytes = q!.getEncoded(false);
  return NumberUtil.decodeBigIntV1(bytes.sublist(1));
}

Uint8List uint8ListFromList(List<int> data) {
  if (data is Uint8List) return data;

  return Uint8List.fromList(data);
}

ECPoint? _decompressKey(BigInt xBN, bool yBit, ECCurve c) {
  List<int> x9IntegerToBytes(BigInt s, int qLength) {
    //https://github.com/bcgit/bc-java/blob/master/core/src/main/java/org/bouncycastle/asn1/x9/X9IntegerConverter.java#L45
    final bytes = NumberUtil.encodeBigIntV1(s);

    if (qLength < bytes.length) {
      return bytes.sublist(0, bytes.length - qLength);
    } else if (qLength > bytes.length) {
      final tmp = List<int>.filled(qLength, 0);

      final offset = qLength - bytes.length;
      for (var i = 0; i < bytes.length; i++) {
        tmp[i + offset] = bytes[i];
      }

      return tmp;
    }

    return bytes;
  }

  final compEnc = x9IntegerToBytes(xBN, 1 + ((c.fieldSize + 7) ~/ 8));
  compEnc[0] = yBit ? 0x03 : 0x02;
  return c.decodePoint(compEnc);
}

Uint8List _padTo32(Uint8List data) {
  if (data.length == 32) return data;
  assert(data.length <= 32);

  // todo there must be a faster way to do this?
  return Uint8List(32)..setRange(32 - data.length, 32, data);
}

Future<Uint8List> signBtcMessageWith(originalMessage, Uint8List privateKey,
    {int? chainId, var network}) async {
  debugPrint('signBtcMessageWith begin');
  Uint8List messageHash = magicHash(originalMessage, network);

  debugPrint('network=');
  debugPrint(network.toString());
  debugPrint('messageHash=');
  debugPrint(messageHash.toString());
  var signature = signMessageWithPrivateKey(messageHash, privateKey);

  // https://github.com/ethereumjs/ethereumjs-util/blob/8ffe697fafb33cefc7b7ec01c11e3a7da787fe0e/src/signature.ts#L26
  // be aware that signature.v already is recovery + 27

  /*
  final chainIdV =
      chainId != null ? (signature.v - 27 + (chainId * 2 + 35)) : signature.v;
  */

  //debugPrint('signature.vsignature.vsignature.v=' + signature.v.toString());
  final chainIdV = signature.v;
  signature = web3_dart.MsgSignature(signature.r, signature.s, chainIdV);

  //debugPrint('chainIdVchainIdVchainIdV==' + chainIdV.toString());
  //debugPrint('signature.v====');
  //debugPrint(signature.v);
  final r = _padTo32(NumberUtil.encodeBigIntV1(signature.r));
  final s = _padTo32(NumberUtil.encodeBigIntV1(signature.s));
  var v = NumberUtil.encodeBigIntV1(BigInt.from(signature.v));

  if (signature.v == 0) {
    v = Uint8List.fromList([0].toList());
  }
  //debugPrint('vvvv=');
  //debugPrint(v);
  // https://github.com/ethereumjs/ethereumjs-util/blob/8ffe697fafb33cefc7b7ec01c11e3a7da787fe0e/src/signature.ts#L63
  return uint8ListFromList(r + s + v);
}

Future<Uint8List> signDogeMessageWith(originalMessage, Uint8List privateKey,
    {int? chainId, var network}) async {
  debugPrint('signDogeMessageWith');
  Uint8List messageHash = magicHashDoge(originalMessage, network);
  //messageHash.insert(1, 25);
  debugPrint('network=');
  debugPrint(network.toString());
  debugPrint('messageHash=');
  debugPrint(messageHash.toString());
  var signature = signMessageWithPrivateKey(messageHash, privateKey);

  // https://github.com/ethereumjs/ethereumjs-util/blob/8ffe697fafb33cefc7b7ec01c11e3a7da787fe0e/src/signature.ts#L26
  // be aware that signature.v already is recovery + 27

  /*
  final chainIdV =
      chainId != null ? (signature.v - 27 + (chainId * 2 + 35)) : signature.v;
  */

  //debugPrint('signature.vsignature.vsignature.v=' + signature.v.toString());
  final chainIdV = signature.v;
  signature = web3_dart.MsgSignature(signature.r, signature.s, chainIdV);

  //debugPrint('chainIdVchainIdVchainIdV==' + chainIdV.toString());
  //debugPrint('signature.v====');
  //debugPrint(signature.v);
  final r = _padTo32(NumberUtil.encodeBigIntV1(signature.r));
  final s = _padTo32(NumberUtil.encodeBigIntV1(signature.s));
  var v = NumberUtil.encodeBigIntV1(BigInt.from(signature.v));

  if (signature.v == 0) {
    v = Uint8List.fromList([0].toList());
  }
  //debugPrint('vvvv=');
  //debugPrint(v);
  // https://github.com/ethereumjs/ethereumjs-util/blob/8ffe697fafb33cefc7b7ec01c11e3a7da787fe0e/src/signature.ts#L63
  return uint8ListFromList(r + s + v);
}

Future<Uint8List> signPersonalMessageWith(
    String _messagePrefix, Uint8List privateKey, Uint8List payload,
    {int? chainId}) async {
  final prefix = _messagePrefix + payload.length.toString();
  final prefixBytes = ascii.encode(prefix);

  // will be a Uint8List, see the documentation of Uint8List.+
  final concat = uint8ListFromList(prefixBytes + payload);

  //final signature = await credential.signToSignature(concat, chainId: chainId);

  var signature =
      signMessageWithPrivateKey(web3_dart.keccak256(concat), privateKey);

  // https://github.com/ethereumjs/ethereumjs-util/blob/8ffe697fafb33cefc7b7ec01c11e3a7da787fe0e/src/signature.ts#L26
  // be aware that signature.v already is recovery + 27
  debugPrint('signature.v=======${signature.v}');
  debugPrint('chainId=$chainId');

  /*
  final chainIdV =
      chainId != null ? (signature.v + (chainId * 2 + 35)) : signature.v;

   */
  final chainIdV = signature.v + 27;
  debugPrint('chainIdV=$chainIdV');
  signature = web3_dart.MsgSignature(signature.r, signature.s, chainIdV);

  final r = _padTo32(NumberUtil.encodeBigIntV1(signature.r));
  final s = _padTo32(NumberUtil.encodeBigIntV1(signature.s));
  final v = NumberUtil.encodeBigIntV1(BigInt.from(signature.v));

  // https://github.com/ethereumjs/ethereumjs-util/blob/8ffe697fafb33cefc7b7ec01c11e3a7da787fe0e/src/signature.ts#L63
  return uint8ListFromList(r + s + v);
  //return credential.sign(concat, chainId: chainId);
}

Uint8List magicHash(String message, [NetworkType? network]) {
  network = network ?? bitcoin;
  List<int> messagePrefix = utf8.encode(network.messagePrefix);
  debugPrint('messagePrefix===');
  debugPrint(messagePrefix.toString());
  int messageVISize = encodingLength(message.length);
  debugPrint('messageVISize===');
  debugPrint(messageVISize.toString());
  int length = messagePrefix.length + messageVISize + message.length;
  Uint8List buffer = Uint8List(length);
  buffer.setRange(0, messagePrefix.length, messagePrefix);
  encode(message.length, buffer, messagePrefix.length);
  buffer.setRange(
      messagePrefix.length + messageVISize, length, utf8.encode(message));

  return hash256(buffer);
}

Uint8List magicHashDoge(String message, [NetworkType? network]) {
  network = network ?? bitcoin;
  List<int> messagePrefix = utf8.encode(network.messagePrefix);

  int messageVISize = encodingLength(message.length);

  int length = messagePrefix.length + messageVISize + message.length + 1;
  Uint8List buffer = Uint8List(length);
  buffer.setRange(0, 1, [25]);

  buffer.setRange(1, messagePrefix.length + 1, messagePrefix);

  encode(message.length, buffer, messagePrefix.length + 1);
  buffer.setRange(
      messagePrefix.length + messageVISize + 1, length, utf8.encode(message));

  return hash256(buffer);
}

signedMessage(
  String originalMessage,
  seed,
  coinName,
  tokenType,
) async {
  var r = '';
  var s = '';
  var v = '';

  var signedMess;
  if (coinName == 'TRX' || tokenType == 'TRX') {
    var privateKey = tron_address_util.generateTrxPrivKeyBySeed(seed);
    //var bytes = CryptoWeb3.hexToBytes(originalMessage);

    signedMess = signTrxMessage(originalMessage, privateKey);
    //signTrxMessage(bytes, privateKey);

    String ss = HEX.encode(signedMess);

    r = ss.substring(0, 64);
    s = ss.substring(64, 128);
    v = ss.substring(128);
    debugPrint('r: $r --  s: $s -- v: $v');

    return {'r': r, 's': s, 'v': v};
  }

  // other coins signed message
  else if (coinName == 'ETH' || tokenType == 'ETH') {
    final root = bip_32.BIP32.fromSeed(seed);
    var coinType = environment["CoinType"]["ETH"];
    final ethCoinChild = root.derivePath("m/44'/$coinType'/0'/0/0");
    var privateKey = ethCoinChild.privateKey;
    //var credentials = EthPrivateKey.fromHex(privateKey);
    //var credentials = EthPrivateKey(privateKey);

    var chainId = environment["chains"]["ETH"]["chainId"];
    // chainId = 0;
    debugPrint('chainId==$chainId');

    // var signedMessOrig = await credentials
    //    .signPersonalMessage(stringToUint8List(originalMessage), chainId: chainId);

    signedMess = await signPersonalMessageWith(Constants.EthMessagePrefix,
        privateKey!, stringToUint8List(originalMessage),
        chainId: chainId);
    String ss = HEX.encode(signedMess);
    //String ss2 = HEX.encode(signedMessOrig);

    //debugPrint('ss='+ss);
    //debugPrint('ss2='+ss2);
    r = ss.substring(0, 64);
    s = ss.substring(64, 128);
    v = ss.substring(128);
    debugPrint('v=$v');
  } else if (coinName == 'BNB' ||
      tokenType == 'BNB' ||
      coinName == 'MATICM' ||
      tokenType == 'MATICM' ||
      tokenType == 'POLYGON') {
    final root = bip_32.BIP32.fromSeed(seed);
    var coinType = environment["CoinType"]["ETH"];
    final ethCoinChild = root.derivePath("m/44'/$coinType'/0'/0/0");
    var privateKey = ethCoinChild.privateKey;
    //var credentials = EthPrivateKey.fromHex(privateKey);
    //var credentials = EthPrivateKey(privateKey);
    var chainId;
    if (coinName == 'BNB' || tokenType == 'BNB') {
      chainId = environment["chains"]["BNB"]["chainId"];
    } else if (coinName == 'MATICM' || tokenType == 'MATICM') {
      chainId = environment["chains"]["MATICM"]["chainId"];
    }

    // chainId = 0;
    debugPrint('chainId==$chainId');

    // var signedMessOrig = await credentials
    //    .signPersonalMessage(stringToUint8List(originalMessage), chainId: chainId);

    signedMess = await signPersonalMessageWith(Constants.EthMessagePrefix,
        privateKey!, stringToUint8List(originalMessage),
        chainId: chainId);
    String ss = HEX.encode(signedMess);
    //String ss2 = HEX.encode(signedMessOrig);

    //debugPrint('ss='+ss);
    //debugPrint('ss2='+ss2);
    r = ss.substring(0, 64);
    s = ss.substring(64, 128);
    v = ss.substring(128);
    debugPrint('v=$v');
  } else if (coinName == 'FAB' ||
      coinName == 'BTC' ||
      coinName == 'LTC' ||
      coinName == 'BCH' ||
      coinName == 'DOGE' ||
      tokenType == 'FAB') {
    //var hdWallet = new HDWallet.fromSeed(seed, network: testnet);

    var network = environment["chains"]['BTC']["network"];
    if (coinName == 'LTC') {
      network = environment["chains"]['LTC']["network"];
    } else if (coinName == 'DOGE') {
      network = environment["chains"]['DOGE']["network"];
    }
    final root2 = bip_32.BIP32.fromSeed(
        seed,
        bip_32.NetworkType(
            wif: network.wif,
            bip32: bip_32.Bip32Type(
                public: network.bip32.public, private: network.bip32.private)));

    var coinType = environment["CoinType"]["FAB"];
    if (coinName == 'BTC') {
      coinType = environment["CoinType"]["BTC"];
    }
    if (coinName == 'LTC') {
      coinType = environment["CoinType"]["LTC"];
    }
    if (coinName == 'DOGE') {
      coinType = environment["CoinType"]["DOGE"];
    }
    if (coinName == 'BCH') {
      coinType = environment["CoinType"]["BCH"];
    }
    var bitCoinChild = root2.derivePath("m/44'/$coinType'/0'/0/0");
    //var btcWallet =
    //    hdWallet.derivePath("m/44'/" + coinType.toString() + "'/0'/0/0");
    var privateKey = bitCoinChild.privateKey;
    // var credentials = EthPrivateKey(privateKey);

    if (coinName == 'DOGE') {
      signedMess = await signDogeMessageWith(originalMessage, privateKey!,
          network: network);
    } else {
      signedMess = await signBtcMessageWith(originalMessage, privateKey!,
          network: network);
    }

    String ss = HEX.encode(signedMess);

    r = ss.substring(0, 64);
    s = ss.substring(64, 128);
    v = ss.substring(128);

    /*
    Uint8List messageHash =
        magicHash(originalMessage, environment["chains"]["BTC"]["network"]);

    signedMess = await ecc.sign(messageHash, privateKey);
    */
    var recovery = int.parse(v);
    var compressed = true;
    var sigwitType;
    v = encodeSignature(signedMess, recovery, compressed, sigwitType);

    /*
    String sss = HEX.encode(signedMess);
    var r1 = sss.substring(0, 64);
    var s1 = sss.substring(64, 128);

    if (r == r1) {
      debugPrint('signiture is right');
    } else {
      debugPrint('signiture is wrong');
    }
    */
    //amount=0.01
    //r1=d2c3555da5b1deb7147e63cbc6d431f4ac15433b16bdd95ab6da214a442c8f12
    //s1=0d6564a5e6ae55ed429330189affc31a3f50a1bcf30c2dbd8d814886d2c7d71e
  }

  if (signedMess != null) {}

  return {'r': r, 's': s, 'v': v};
}

/*
usage:
getAddressForCoin(root, 'BTC');
getAddressForCoin(root, 'ETH');
getAddressForCoin(root, 'FAB');
getAddressForCoin(root, 'USDT', tokenType: 'ETH');
getAddressForCoin(root, 'EXG', tokenType: 'FAB');
 */
Future getAddressForCoin(root, String tickerName,
    {tokenType = '', index = 0}) async {
  if (tickerName == 'BTC') {
    var node = getBtcNode(root, tickerName: tickerName, index: index);
    return getBtcAddressForNode(node, tickerName: tickerName);
  } else if (tickerName == 'LTC') {
    return generateLtcAddress(root);
  } else if (tickerName == 'DOGE') {
    return generateDogeAddress(root);
  } else if ((tickerName == 'ETH') || (tokenType == 'ETH')) {
    var node = getEthNode(root, index: index);
    return await getEthAddressForNode(node);
  } else if (tickerName == 'FAB') {
    var node = fabUtils.getFabNode(root, index: index);
    return getBtcAddressForNode(node, tickerName: tickerName);
  } else if (tokenType == 'FAB') {
    var node = fabUtils.getFabNode(root, index: index);
    var fabPublicKey = node.publicKey;
    Digest sha256 = Digest("SHA-256");
    var pass1 = sha256.process(fabPublicKey);
    Digest ripemd160 = Digest("RIPEMD-160");
    var pass2 = ripemd160.process(pass1);
    var fabTokenAddr = '0x${HEX.encode(pass2)}';
    return fabTokenAddr;
  }
  return '';
}

// Future Coin Balances With Addresses
Future getCoinBalanceByAddress(String coinName, String address,
    {tokenType = ''}) async {
  try {
    if (coinName == 'BTC') {
      return await getBtcBalanceByAddress(address);
    } else if (coinName == 'LTC') {
      return await getLtcBalanceByAddress(address);
    } else if (coinName == 'ETH') {
      return await getEthBalanceByAddress(address);
    } else if (coinName == 'FAB') {
      return await fabUtils.getFabBalanceByAddress(address);
    } else if (tokenType == 'ETH') {
      return await getEthTokenBalanceByAddress(address, coinName);
    } else if (tokenType == 'FAB') {
      return await fabUtils.getFabTokenBalanceByAddress(address, coinName);
    }
  } catch (e) {
    log.e('getCoinBalanceByAddress $e');
  }

  return {'balance': -1.0, 'lockbalance': -1.0};
}

Future getBalanceForCoin(root, coinName, {tokenType = '', index = 0}) async {
  var address = await getAddressForCoin(root, coinName,
      tokenType: tokenType, index: index);
  try {
    if (coinName == 'BTC') {
      return await getBtcBalanceByAddress(address);
    } else if (coinName == 'ETH') {
      return await getEthBalanceByAddress(address);
    } else if (coinName == 'FAB') {
      return await fabUtils.getFabBalanceByAddress(address);
    } else if (tokenType == 'ETH') {
      return await getEthTokenBalanceByAddress(address, coinName);
    } else if (tokenType == 'FAB') {
      return await fabUtils.getFabTokenBalanceByAddress(address, coinName);
    }
  } catch (e) {}

  return {'balance': -1.0, 'lockbalance': -1.0};
}
