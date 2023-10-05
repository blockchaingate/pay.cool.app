import 'dart:convert';

import 'package:paycool/constants/api_routes.dart';
import 'package:paycool/constants/constants.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/db/core_wallet_database_service.dart';
import 'package:paycool/utils/custom_http_util.dart';
import 'package:paycool/views/multisig/dashboard/multisig_balance_model.dart';
import 'package:paycool/views/multisig/multisig_wallet_model.dart';
import 'package:paycool/views/multisig/transfer/multisig_transaction_hash_model.dart';
import 'package:hex/hex.dart';

class MultiSigService {
  final log = getLogger('MultiSigService');
  final client = CustomHttpUtil.createLetsEncryptUpdatedCertClient();

  Future submitMultisigTransaction(body) async {
    var url = paycoolBaseUrlV2 + 'multisigproposal/execute';
    log.i('submitMultisigTransaction url $url - body ${jsonEncode(body)}');
    try {
      var response = await client.post(Uri.parse(url),
          body: jsonEncode(body), headers: Constants.headersJson);
      var json = jsonDecode(response.body);
      if (json['success']) {
        log.w('submitMultisigTransaction $json}');
        return json['data'];
      } else {
        log.e('submitMultisigTransaction success false $json}');
      }
    } catch (err) {
      log.e('submitMultisigTransaction CATCH $err');
      throw Exception(err);
    }
  }

  Future approveProposal(body) async {
    var url = paycoolBaseUrlV2 + 'multisigproposal/confirm';
    log.i('approveProposal url $url - body ${jsonEncode(body)}');
    try {
      var response = await client.post(Uri.parse(url),
          body: jsonEncode(body), headers: Constants.headersJson);
      var json = jsonDecode(response.body);
      if (json['success']) {
        log.w('approveProposal $json}');
        return json['data'];
      } else {
        log.e('approveProposal success false $json}');
      }
    } catch (err) {
      log.e('approveProposal CATCH $err');
      throw Exception(err);
    }
  }

  Future<bool> createProposal(body) async {
    bool result = false;
    var url = paycoolBaseUrlV2 + 'multisigproposal';
    log.i('createProposal url $url - body ${jsonEncode(body)}');
    try {
      var response = await client.post(Uri.parse(url),
          body: jsonEncode(body), headers: Constants.headersJson);
      var json = jsonDecode(response.body);
      if (json['success']) {
        log.w('createProposal $json}');
        result = true;
        return result;
      } else {
        log.e('createProposal success false $json}');
      }
      return result;
    } catch (err) {
      log.e('createProposal CATCH $err');
      throw Exception(err);
    }
  }

  Future multisigtransferTxHash(MultisigTransactionHashModel body) async {
    var url = paycoolBaseUrlV2 + 'multisig/getTransactionHash';
    log.i('multisigtransferTxHash url $url - body ${body.toJson()}');
    try {
      var response = await client.post(Uri.parse(url),
          body: jsonEncode(body.toJson()), headers: Constants.headersJson);
      var json = jsonDecode(response.body);
      if (json['success']) {
        log.w('multisigtransferTxHash $json}');
        return json['data'];
      } else {
        log.e('multisigtransferTxHash success false $json}');
      }
    } catch (err) {
      log.e('multisigtransferTxHash CATCH $err');
      throw Exception(err);
    }
  }

  Future getQueuetransaction(String address,
      {int pageSize = 10, int pageNumber = 0}) async {
    var url = paycoolBaseUrlV2 + 'multisigproposal/queue/$address';
    if (pageNumber != 0) {
      pageNumber = pageNumber - 1;
    }
    url = '$url/$pageSize/$pageNumber';
    log.i('getQueuetransaction url $url');
    try {
      var response =
          await client.get(Uri.parse(url), headers: Constants.headersJson);
      var json = jsonDecode(response.body);
      if (json['success']) {
        log.w('getQueuetransaction $json}');
        return json['data'];
      } else {
        log.e('getQueuetransaction success false $json}');
      }
    } catch (err) {
      log.e('getQueuetransaction CATCH $err');
      throw Exception(err);
    }
  }

  Future<void> getmultisigTransactions(String address,
      {int pageSize = 10, int pageNumber = 0}) async {
    var url = paycoolBaseUrlV2 + 'multisigtransaction/address/$address';
    if (pageNumber != 0) {
      pageNumber = pageNumber - 1;
    }
    url = '$url/$pageSize/$pageNumber';
    log.i('getmultisigTransactions url $url');
    try {
      var response =
          await client.get(Uri.parse(url), headers: Constants.headersJson);
      var json = jsonDecode(response.body);
      if (json['success']) {
        log.w('getmultisigTransactions $json}');
        return json['data'];
      } else {
        log.e('getmultisigTransactions success false $json}');
      }
    } catch (err) {
      log.e('getmultisigTransactions CATCH $err');
      throw Exception(err);
    }
  }

  Future<MultisigBalanceModel> getBalance(String address,
      {required String chain, List<String>? ids}) async {
    String endpoint = '';
    switch (chain.toLowerCase()) {
      case 'kanban':
        endpoint = 'kanban/balanceold';
        break;
      case 'eth':
        endpoint = 'eth/balance';
        break;
      case 'bnb':
        endpoint = 'bnb/balance';
        break;
      default:
        endpoint = 'kanban/balanceold';
    }
    var url = paycoolBaseUrlV2 + endpoint;
    log.i('get $endpoint Balance url $url');
    try {
      var response = await client.post(Uri.parse(url),
          body: jsonEncode({"native": address, "ids": ids}),
          headers: Constants.headersJson);
      var json = jsonDecode(response.body);
      var data = MultisigBalanceModel();
      if (json['success']) {
        log.w('get $endpoint Balance $json}');
        data = MultisigBalanceModel.fromJson(json['data']);
        return data;
      } else {
        log.e('get $endpoint Balance success false $json}');
      }
      return data;
    } catch (err) {
      log.e('get $endpoint Balance CATCH $err');
      throw Exception(err);
    }
  }

  // get txid data
  //multisig/txid/
  Future<MultisigWalletModel> importMultisigWallet(String value,
      {bool isTxid = false}) async {
    String apiRoute = isTxid ? 'multisig/txid' : 'multisig/address';
    var url = paycoolBaseUrlV2 + '$apiRoute/$value';
    log.i('getWalletData url $url');
    try {
      var response =
          await client.get(Uri.parse(url), headers: Constants.headersJson);
      var json = jsonDecode(response.body);
      if (json['success']) {
        log.w('getWalletData $json}');
        return MultisigWalletModel.fromJson(json['data']);
      } else {
        log.e('getWalletData success false $json}');
      }
      return MultisigWalletModel(txid: '');
    } catch (err) {
      log.e('getWalletData CATCH $err');
      throw Exception(err);
    }
  }

  // get multisig data
  Future createMultiSig(MultisigWalletModel multisigModel) async {
    // var body = {
    //   {
    //     "chain": multisigModel.chain,
    //     "name": multisigModel.name,
    //     "owners": multisigModel.owners,
    //     "confirmations": multisigModel.confirmations,
    //     "rawtx": multisigModel.signedRawtx
    //   }
    // };
    var url = paycoolBaseUrlV2 + 'multisig';
    log.i(
        'createMultiSig url $url - body ${jsonEncode(multisigModel.toJson())}');
    try {
      var response = await client.post(Uri.parse(url),
          body: jsonEncode(multisigModel.toJson()),
          headers: Constants.headersJson);
      var json = jsonDecode(response.body);
      if (json['success']) {
        log.w('createMultiSig $json}');
        return json['data']["txid"];
      } else {
        log.e('createMultiSig success false $json}');
      }
    } catch (err) {
      log.e('createMultiSig CATCH $err');
      throw Exception(err);
    }
  }

  // get multisig data
  Future multisigData(
      List<String> addresses, int confirmations, String chain) async {
    var body = {
      "chain": chain,
      "addresses": addresses,
      "confirmations": confirmations
    };
    var url = paycoolBaseUrlV2 + 'common/multisig';
    log.i('getMultisigData url $url - body ${jsonEncode(body)}');
    try {
      var response = await client.post(Uri.parse(url),
          body: jsonEncode(body), headers: Constants.headersJson);
      var json = jsonDecode(response.body);
      if (json['success']) {
        log.w('getMultisigData $json}');
        return json['data'];
      } else {
        log.e('getMultisigData success false $json}');
      }
    } catch (err) {
      log.e('getMultisigData CATCH $err');
      throw Exception(err);
    }
  }

  Future getTransferNonce(String address) async {
    var url = paycoolBaseUrlV2 + 'multisig/nonce/' + address;

    log.i('getTransferNonce url $url');
    try {
      var response =
          await client.get(Uri.parse(url), headers: Constants.headersJson);
      var json = jsonDecode(response.body);
      log.i('getTransferNonce $json');

      return int.parse(json['data']);
    } catch (e) {
      log.e('getTransferNonce CATCH $e');
    }
    return null;
  }

  Future getChainNonce(String chain, String address) async {
    var url = paycoolBaseUrlV2 + '$chain/nonce';
    var body = {"native": address};
    log.i('getKanbanNonce url $url - body ${jsonEncode(body)}');
    try {
      var response = await client.post(
        Uri.parse(url),
        body: jsonEncode(body),
        headers: Constants.headersJson,
      );
      var json = jsonDecode(response.body);
      log.i('getKanbanNonce $json');

      return int.parse(json['data']);
    } catch (e) {
      log.e('getKanbanNonce CATCH $e');
    }
    return null;
  }

  Future<String> adjustVInSignature({
    required String signingMethod,
    required String signature,
    String? safeTxHash,
    String? signerAddress,
  }) async {
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

  bool sameString(String a, String b) {
    return a == b;
  }

  String bufferToHex(List<int> buffer) {
    return '0x' + HEX.encode(buffer);
  }
}
