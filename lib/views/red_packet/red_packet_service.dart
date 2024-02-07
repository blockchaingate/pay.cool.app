//@LazySingleton()
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:paycool/constants/api_routes.dart';
import 'package:paycool/environments/environment.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/models/red/red_packet_rm.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/utils/kanban.util.dart';
import 'package:paycool/utils/keypair_util.dart';
import 'package:paycool/views/paycool/paycool_service.dart';
import 'package:stacked/stacked.dart';

class RedPacketService with ListenableServiceMixin {
  final log = getLogger('RedPacketService');

  String contactAddress = signCcontactAddress;

  SharedService sharedService = locator<SharedService>();

  String getContactAddress() {
    return contactAddress;
  }

  //user seed, user wallet address
  // getCredentials(Uint8List seed) async {
  Future<String> getCredentials(
      BuildContext context, int coinType, double limit) async {
    log.i('RedPacketService getCredentials');

    // String? hex = "";

    PayCoolService ps = PayCoolService();
    var res = await ps.encodeKanbanApproveAbiHex(
        context, contactAddress, coinType, limit);

    print('RedPacketService getCredentials res: $res');

    return res ?? "";
  }

  // RedPacketAbiHex api for approve functions
  Future<String?> encodeCreateRedPacketAbiHex(BuildContext context,
      var pocketId, coinType, var totalAmount, var pocketNumber) async {
    // String url = payCoolEncodeAbiUrl;

    String url = "${paycoolBaseUrlV2}redpocket/createRedPocket";
    // String url = payCoolEncodeAbiUrl;

    // print url
    print('RedPacketService encodeCreateRedPacketAbiHex url: $url');

    //exp time: current uix time + 2days
    var expTime = DateTime.now().millisecondsSinceEpoch + 172800000;

    //print expTime
    print('RedPacketService encodeReceiveRedPacketAbiHex expTime: $expTime');

    var body = {
      "pocketId": pocketId,
      "coinType": coinType,
      "totalAmount": totalAmount,
      "pocketNumber": pocketNumber,
      "expTime": expTime
    };

    //print body
    print('RedPacketService encodeReceiveRedPacketAbiHex body: $body');

    try {
      final res = await client.post(Uri.parse(url),
          body: jsonEncode(body),
          headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json'
          });
      log.w('encodeAbiHex json ${res.body}');

      var json = jsonDecode(res.body);

      // log.w('encodeAbiHex json data: ${json['data']}');

      // log.w('encodeAbiHex json data data: ${json['data']['data']}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        // return res.body.data.data
        return json['data']['data'];
        // return json.toString();
      } else {
        log.e("error: ${res.body}");
        return res.body;
      }
    } catch (e) {
      log.e('CATCH encodeAbiHex failed to load the data from the API $e');
      return '';
    }
  }

  // encodeReceiveRedPacketAbiHex api for approve functions
  Future<String?> encodeReceiveRedPacketAbiHex(BuildContext context,
      var pocketId, var amount, var msg, var v, var r, var s) async {
    String url = payCoolEncodeAbiUrl;

    var body = {
      "types": ["bytes32", "uint256", "bytes32", "uint8", "bytes32", "bytes32"],
      "params": [pocketId, amount, msg, v, r, s]
    };
    try {
      final res = await client.post(Uri.parse(url),
          body: jsonEncode(body),
          headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json'
          });
      log.w('encodeAbiHex json ${res.body}');
      var json = jsonDecode(res.body)['encodedParams'];
      if (res.statusCode == 200 || res.statusCode == 201) {
        return json.toString();
      } else {
        log.e("error: ${res.body}");
        return res.body;
      }
    } catch (e) {
      log.e(
          'CATCH encodeReceiveRedPacketAbiHex failed to load the data from the API $e');
      return '';
    }
  }

  //TODO: Create rec packet
  Future<void> createRedPacket() async {}

  //TODO: claim Red Pocket
  Future<void> claimRedPacket() async {}

  //Get Red Pocket ID
  // {
  //   "pocketId": "HappyNewYear",
  //   "coinType": "FAB"
  // }
  Future<String> getRedPacketId(String pocketId, String coinType) async {
    String id = '';
    // Http post /api/redpocket/createRedPocket

    Map<String, dynamic> data = {
      "pocketId": pocketId,
      "coinType": coinType,
    };

    var response = await client.post(
      Uri.parse('${paycoolBaseUrlV2}redpocket/createRedPocket'),
      body: jsonEncode(data),
      headers: {'Content-Type': 'application/json'},
    );

    //check response success = true
    // {
    //   "success": true,
    //   "message": "Successfully created RedPocket",
    //   "data": {
    //     "id": "ghuwahkghkjvbhvjacnw4biu334tnjk4wnfjkv"
    //   }
    // }

    print('RedPacketService getRedPacketId response: ${response.body}');

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      id = json['data']['id'];
    }

    return id;
  }

  //get claim Red Pocket signed Message
  // {
  //   "pocketId": "HappyNewYear",
  //   "userWalletAddress": "1F1y1iYu47zGB65QH3HKihiqfCHhPRQ54o"
  // }
  Future<RedPacketResponseModal?> getClaimRedPacketSignedMessage(
      String pocketId, String userWalletAddress) async {
    String signedMessage = '';

    print("lkdnfkldshfkhsdkflkds");

    // Http post /api/redpocket/getClaimRedPocketSignedMessage

    Map<String, dynamic> data = {
      "pocketId": pocketId,
      "userWalletAddress": userWalletAddress,
    };

    var response = await client.post(
      Uri.parse('${paycoolBaseUrlV2}redpocket/claimRedPocket'),
      body: jsonEncode(data),
      headers: {'Content-Type': 'application/json'},
    );

    print(response);
    print(response.body);

    //check response success = true
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      return RedPacketResponseModal.fromJson(json);
    } else {
      return null;
    }
  }
}
