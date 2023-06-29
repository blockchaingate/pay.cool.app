import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:kyc/kyc.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/local_dialog_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/utils/coin_util.dart';
import 'package:paycool/utils/custom_http_util.dart';
import 'package:paycool/utils/string_util.dart';

class LocalKycUtil {
  // https://testapi.fundark.com/kyc/wallet_address/moxGusyPrnFqsotinFQVHrzfZtYXra5nSH
// {"success":true,"data":{"user":null}}
//      or
// {"success":true,"data":{"user":{"email":"cojomog655@larland.com",
// "wallet_address":"mvLuZXGYMxpRM65kgzbfoKqs3FPcisM6ri"},
// "kyc":{"step":2,"status":0}}}

  // Api response
  // user register and email confirmed: no kyc data
  // phone code sent: kyc.status == 0
  // phone code confirmed: status: 1
  // citizenship selected: status: 2
  // verifyIdentity:  status: 3
  // verifyInfo: status: 4
  // selectIdType: status: 5
  // uploadDocument: status: 6
  // uploadVideo: status: 7
  static checkKycStatus() async {
    final client = CustomHttpUtil.createLetsEncryptUpdatedCertClient();
    SharedService sharedService = locator<SharedService>();
    final log = getLogger('KycUtil');
    var fabAddress = await sharedService.getFabAddressFromCoreWalletDatabase();
    var url = '${KycConstants.baseUrl}/kyc/wallet_address/$fabAddress';
    log.w('checkKycStatus url $url');
    var response = await client.get(Uri.parse(url));
    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        log.w('checkKycStatus response: ${response.body}');
        var data = jsonDecode(response.body);
        if (data['data']['user'] != null) {
          log.i('checkKycStatus user data $data');
          return {"success": true, "data": data};
        } else {
          return {"success": false, "data": null};
        }
      } else {
        return {"success": true, "error": jsonEncode(response.body)};
      }
    } catch (err) {
      log.e('checkKycStatus CATCH $err');
      return {"success": true, "error": err.toString()};
    }
  }

  // getSeedUsing pasword
  static Future<Uint8List?> getSeedUsingPassword(BuildContext context) async {
    Uint8List? seed;
    WalletService walletService = locator<WalletService>();
    final dialogService = locator<LocalDialogService>();
    await dialogService
        .showDialog(
            title: FlutterI18n.translate(context, "enterPassword"),
            description: FlutterI18n.translate(
                context, "dialogManagerTypeSamePasswordNote"),
            buttonTitle: FlutterI18n.translate(context, "confirm"))
        .then((res) async {
      if (res.confirmed) {
        return seed = walletService.generateSeed(res.returnedText);
      } else if (res.returnedText == 'Closed' && !res.confirmed) {
        debugPrint('Dialog Closed By User');
        seed = Uint8List(0);
      } else {
        debugPrint('Wrong pass');
        seed = Uint8List(0);
      }
    });
    return seed;
  }

// sign kanban data
  static Future<String> signKycData(String data, BuildContext context) async {
    String finalSignature = '';
    var hexData = StringUtils.stringToHex(data);
    debugPrint('hexData $hexData');

    var stringToHash = hashKanbanMessage(hexData);
    debugPrint('stringToHash $stringToHash');

    var seed = await getSeedUsingPassword(context);
    if (seed!.isNotEmpty) {
      var signature = await signHashKanbanMessage(seed, stringToHash);
      debugPrint('signature $signature');
      var s = trimHexPrefix(signature['s']!);
      var v = trimHexPrefix(signature['v']!);
      finalSignature = '${signature['r']}$s$v}';
    }
    return finalSignature;
  }
}