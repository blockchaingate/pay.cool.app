import 'dart:convert';

import 'package:paycool/constants/api_routes.dart';
import 'package:paycool/constants/constants.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/utils/custom_http_util.dart';
import 'package:paycool/views/multisig/multisig_model.dart';

class MultiSigService {
  final log = getLogger('MultiSigService');
  final client = CustomHttpUtil.createLetsEncryptUpdatedCertClient();

  // get multisig data
  Future createMultiSig(MultisigModel multisigModel) async {
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
        return json['data'];
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
