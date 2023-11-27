import 'dart:convert';

import 'package:observable_ish/observable_ish.dart';
import 'package:paycool/constants/api_routes.dart';
import 'package:paycool/constants/constants.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/utils/custom_http_util.dart';
import 'package:paycool/views/multisig/dashboard/multisig_balance_model.dart';
import 'package:paycool/views/multisig/multisig_wallet_model.dart';
import 'package:paycool/views/multisig/transfer/multisig_transaction_hash_model.dart';
import 'package:stacked/stacked.dart';

class MultiSigService with ListenableServiceMixin {
  final log = getLogger('MultiSigService');
  final client = CustomHttpUtil.createLetsEncryptUpdatedCertClient();

  final RxValue<bool> _hasUpdatedTokenList = RxValue<bool>(false);
  bool get hasUpdatedTokenList => _hasUpdatedTokenList.value;
  MultiSigService() {
    listenToReactiveValues([_hasUpdatedTokenList]);
  }

  hasUpdatedTokenListFunc(bool value) {
    _hasUpdatedTokenList.value = value;
    log.w(' _hasUpdatedTokenList ${_hasUpdatedTokenList.value}');
    notifyListeners();
  }

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
        return json['message'];
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
      log.w('resopnse ${response.body}');
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
    var jsonBody = jsonEncode(body);
    log.i('createProposal url $url - body $jsonBody');
    try {
      var response = await client.post(Uri.parse(url),
          body: jsonBody, headers: Constants.headersJson);
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
    var jsonBody = jsonEncode(body.toJson());
    log.i('multisigtransferTxHash url $url - jsonBody $jsonBody');
    try {
      var response = await client.post(Uri.parse(url),
          body: jsonBody, headers: Constants.headersJson);
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

  Future<int> getTotalCount(String address, {required bool isQueue}) async {
    String route =
        isQueue ? 'multisigproposal/queue/' : 'multisigtransaction/address/';

    var url = paycoolBaseUrlV2 + route + '$address/totalCount';
    int transactionCount = 0;
    log.i('getTotalCount url $url');
    try {
      var response = await client.get(Uri.parse(url));

      var json = jsonDecode(response.body);

      // log.w('getChildrenByAddress json $json');
      if (json['data'] != null) {
        transactionCount = json['data'];
        log.i('getTotalCount count $transactionCount');
        return transactionCount;
      } else {
        log.e("getTotalCount error: ${response.body}");
        return 0;
      }
    } catch (err) {
      log.e('In getTotalCount catch $err');
      return 0;
    }
  }

  Future getmultisigTransactions(String address,
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
      {required String chain, List<String>? tokenIds}) async {
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
    log.i('get $endpoint Balance url $url -- body ${jsonEncode({
          "native": address,
          "tokens": tokenIds ?? []
        })}}');
    try {
      var response = await client.post(Uri.parse(url),
          body: jsonEncode({"native": address, "tokens": tokenIds}),
          headers: Constants.headersJson);
      var json = jsonDecode(response.body);
      var data = MultisigBalanceModel();
      if (json['success']) {
        log.w('get $endpoint $json}');
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
    log.i('importMultisigWallet url $url');
    try {
      var response =
          await client.get(Uri.parse(url), headers: Constants.headersJson);
      var json = jsonDecode(response.body);
      if (json['success']) {
        log.w('importMultisigWallet $json}');
        var res = MultisigWalletModel.fromJson(json['data']);
        log.w('importMultisigWallet - address ${res.address}');
        return res;
      } else {
        log.e('importMultisigWallet success false $json}');
      }
      return MultisigWalletModel(txid: '');
    } catch (err) {
      log.e('importMultisigWallet CATCH $err');
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
    log.i('get $chain Nonce url $url - body ${jsonEncode(body)}');
    try {
      var response = await client.post(
        Uri.parse(url),
        body: jsonEncode(body),
        headers: Constants.headersJson,
      );
      var json = jsonDecode(response.body);
      log.i('get $chain Nonce $json');

      return int.parse(json['data']);
    } catch (e) {
      log.e('get $chain Nonce CATCH $e');
    }
    return null;
  }
}
