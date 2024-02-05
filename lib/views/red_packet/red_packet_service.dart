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

  //Testnet contract address: 0x8a1ff51bbfb7993e26536b303afe2401b8ad98dc
  String contactAddress = '0x8a1ff51bbfb7993e26536b303afe2401b8ad98dc';

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

    String url = "https://testapi.fundark.com/api/redpocket/createRedPocket";
    // String url = payCoolEncodeAbiUrl;

    // print url
    print('RedPacketService encodeCreateRedPacketAbiHex url: $url');

    //exp time: current uix time + 2days
    var expTime = DateTime.now().millisecondsSinceEpoch + 172800000;

    //print expTime
    print('RedPacketService encodeReceiveRedPacketAbiHex expTime: $expTime');

    // var body = {
    //   "types": ["bytes32", "address", "uint256", "uint256", "uint256"],
    //   "params": [pocketId, coinType, totalAmount, pocketNumber, expTime]
    //   // "params": [pocketId, coinType, totalAmount, pocketNumber, 1705962965]
    // };

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
  Future<String?> encodeReceiveRedPacketAbiHex(
      BuildContext context, var pocketId, var msg, var v, var r, var s) async {
    String url = payCoolEncodeAbiUrl;

    var body = {
      "types": ["bytes32", "bytes32", "uint8", "bytes32", "bytes32"],
      "params": [pocketId, msg, v, r, s]
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
      Uri.parse('https://testapi.fundark.com/api/redpocket/createRedPocket'),
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
      Uri.parse('https://testapi.fundark.com/api/redpocket/claimRedPocket'),
      body: jsonEncode(data),
      headers: {'Content-Type': 'application/json'},
    );

    print(response);
    print(response.body);
    //check response success = true
    // {
    //   "success": true,
    //   "message": "Successfully return the signed message",
    //   "data": {
    //     "signedMessage": {
    //       "_id": "ghuwahkghkjvbhvjacnw4biu334tnjk4wnfjkv",
    //       "messageHash": "0xfd88b67924c01444b40b859e288b6c958b127bb6651424a2688f0d8d5b4cacf8",
    //       "v": "0x1c",
    //       "r": "0xbc5709d9e10b809fab0ebbeebb6b9eedcfb4a9bfb1823f70e8d6e39467d58489",
    //       "s": "0x5f47a7a6acd75e654891a2844622e8d6806c5d518be76c6cfe976eb62d943874",
    //       "signature": "0xbc5709d9e10b809fab0ebbeebb6b9eedcfb4a9bfb1823f70e8d6e39467d584895f47a7a6acd75e654891a2844622e8d6806c5d518be76c6cfe976eb62d9438741c"
    //     }
    //   }
    // }

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      return RedPacketResponseModal.fromJson(json);
    } else {
      return null;
    }
  }
}
