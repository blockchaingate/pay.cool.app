import 'dart:convert';

import 'package:paycool/constants/api_routes.dart';
import 'package:paycool/constants/constants.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/utils/custom_http_util.dart';
import 'package:paycool/views/multisig/multisig_wallet_model.dart';

class MultiSigService {
  final log = getLogger('MultiSigService');
  final client = CustomHttpUtil.createLetsEncryptUpdatedCertClient();

  Future<void> getKanbanBalance(String exgAddress) async {
    var url = paycoolBaseUrlV2 + 'kanban/balanceold';
    log.i('getKanbanBalance url $url');
    try {
      var response = await client.post(Uri.parse(url),
          body: jsonEncode({"native": exgAddress}),
          headers: Constants.headersJson);
      var json = jsonDecode(response.body);
      if (json['success']) {
        log.w('getKanbanBalance $json}');
        return json['data'];
      } else {
        log.e('getKanbanBalance success false $json}');
      }
    } catch (err) {
      log.e('getKanbanBalance CATCH $err');
      throw Exception(err);
    }
  }

  // get txid data
  //multisig/txid/
  Future<MultisigWalletModel> getTxidData(String txid) async {
    var url = paycoolBaseUrlV2 + 'multisig/txid/$txid';
    log.i('getTxidData url $url');
    try {
      var response =
          await client.get(Uri.parse(url), headers: Constants.headersJson);
      var json = jsonDecode(response.body);
      if (json['success']) {
        log.w('getTxidData $json}');
        return MultisigWalletModel.fromJson(json['data']);
      } else {
        log.e('getTxidData success false $json}');
      }
      return MultisigWalletModel(txid: '');
    } catch (err) {
      log.e('getTxidData CATCH $err');
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

  Future getKanbanNonce(String address) async {
    var url = paycoolBaseUrlV2 + 'kanban/nonce';
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
}
