import 'dart:convert';
import 'package:exchangily_core/exchangily_core.dart';

import 'package:paycool/views/paycool_club/paycool_club_model/paycool_club_model.dart';

import 'package:paycool/views/paycool_club/paycool_club_model/paycool_create_order_model.dart';
import 'package:paycool/views/paycool_club/paycool_dashboard_model.dart';
import 'package:referral/referral.dart';

import '../../constants/paycool_api_routes.dart';

class PayCoolClubService {
  final log = getLogger('PayCoolClubService');

  final client = CustomHttpUtils.createLetsEncryptUpdatedCertClient();
  final String campaignId = '1';

  final environmentService = locator<EnvironmentService>();
/*----------------------------------------------------------------------
                      Tx Receipt
----------------------------------------------------------------------*/

// status 1 means success, 0 means failure
  Future<bool> txReceipt(String txId) async {
    String url = environmentService.kanbanBaseUrl() +
        'kanban/getTransactionReceipt/' +
        txId;
    log.i('txReceipt url $url');
    bool res = false;
    try {
      var response = await client.get(url);
      var json = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (json != null) {
          String holder = json['transactionReceipt']['status'];
          log.e('txReceipt status $holder');
          res = true;
          // if (holder == '0x0') res = true;
          // if (holder == '0x1') res = false;
          return res;
        } else {
          return res;
        }
      } else {
        log.e("txReceipt error: " + json);
        return false;
      }
    } catch (e) {
      log.e('txReceipt failed to load the data from the API $e');
      return false;
    }
  }

/*----------------------------------------------------------------------
                            Check if referral is valid
----------------------------------------------------------------------*/
  Future<bool> isValidReferralCode(String fabAddress,
      {bool isValidStarPayMemeberCheck = false}) async {
    String url = (isValidStarPayMemeberCheck
            ? PaycoolApiRoutes.isValidReferralStarPayMemberUrl
            : PaycoolApiRoutes.isValidPaidReferralCodeUrl) +
        fabAddress;
    log.i('isValidReferralCode url $url');
    bool res = false;
    try {
      var response = await client.get(url);
      var json = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        log.w('isValidReferralCode json $json');

        var isValid = json['isValid'];
        if (isValid != null) {
          log.e('isvalid $isValid');
          res = isValid;
        }
        return res;
      } else {
        log.e("isValidReferralCode error: " + json);
        return false;
      }
    } catch (e) {
      log.e('isValidReferralCode failed to load the data from the API $e');
      throw Exception(e);
    }
  }

/*----------------------------------------------------------------------
                            Check if paycool club member
----------------------------------------------------------------------*/
//memberType: 0-should be unknown; 1-keyNode, 2-Consumer, 3-Merchant
  Future<bool> isMember(String fabAddress) async {
    String url = PaycoolApiRoutes.payCoolClubrRefUrl + fabAddress;
    log.i('isMember url $url');
    bool res = false;
    try {
      var response = await client.get(url);
      var json = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        log.w('isMember json $json');

        var mt = json['id'];
        if (mt != null) {
          log.e('jsonmember $mt');
          if (json['memberType'] == 0) {
            res = false;
          } else {
            res = true;
          }
        }
        return res;
      } else {
        log.e("isMember error: " + json);
        return false;
      }
    } catch (e) {
      log.e('isMember func: failed to load the data from the API $e');
      return false;
    }
  }

/*----------------------------------------------------------------------
                            Paycool Club Details
----------------------------------------------------------------------*/

  Future<List<PayCoolClubModel>> getPayCoolClubDetails() async {
    String url = PaycoolApiRoutes.campaignListUrl;
    log.w('getPayCoolClubDetails url $url');

    try {
      var response = await client.get(url);
      var json = jsonDecode(response.body) as List;
      log.w('getPayCoolClubDetails json $json');
      if (response.statusCode == 200 || response.statusCode == 201) {
        PayCoolClubModelList payCoolClubModel =
            PayCoolClubModelList.fromJson(json);
        return payCoolClubModel.payCoolClubModeList;
      } else {
        log.e("getPayCoolClubDetails error: " + response.body);
        return [];
      }
    } catch (e) {
      log.e('getPayCoolClubDetails failed to load the data from the API $e');
      return [];
    }
  }

/*-------------------------------------------------------------------------------------
                        create order
-------------------------------------------------------------------------------------*/

  Future createOrder(PaycoolCreateOrderModel paycoolCreateOrder) async {
    log.w('createOrder ${paycoolCreateOrder.toJson()}');
    Map<String, dynamic> body = {
      "campaignId": paycoolCreateOrder.campaignId.toString(),
      "walletAdd": paycoolCreateOrder.walletAdd,
      "amount": paycoolCreateOrder.amount.toString(),
      "currency": paycoolCreateOrder.currency,
      "referral": paycoolCreateOrder.referral
    };
    log.i(
        'createOrder club ${PaycoolApiRoutes.payCoolClubCreateOrderUrl} -- body $body');
    try {
      var response = await client
          .post(PaycoolApiRoutes.payCoolClubCreateOrderUrl, body: body);
      var json = jsonDecode(response.body)['_body'];
      log.w('createOrder try response $json');
      return json;
    } catch (err) {
      log.e('In createOrder catch $err');
    }
  }

/*-------------------------------------------------------------------------------------
                        Save order
-------------------------------------------------------------------------------------*/

  Future saveOrder(String walletAddress, String txId) async {
    Map<String, dynamic> body = {"txid": txId, "address": walletAddress};
    log.i(
        'createOrder club ${PaycoolApiRoutes.payCoolClubSaveOrderUrl} -- body $body');
    try {
      var response = await client.post(PaycoolApiRoutes.payCoolClubSaveOrderUrl,
          body: body);
      var json = jsonDecode(response.body);
      log.w('save Order try response $json');
      return json;
    } catch (err) {
      log.e('In save Order catch $err');
    }
  }

/*-------------------------------------------------------------------------------------
                            Get Parent By address
-------------------------------------------------------------------------------------*/

  Future<PaycoolReferral> getReferralParentByAddress(String address) async {
    try {
      var response =
          await client.get(PaycoolApiRoutes.payCoolClubrRefUrl + address);
      if (response.statusCode == 200 || response.statusCode == 201) {
        var json = jsonDecode(response.body);

        log.w('getReferralParentByAddress $json');
        PaycoolReferral paycoolReferralList = PaycoolReferral.fromJson(json);
        return paycoolReferralList;
      } else {
        log.e("getReferralParentByAddress error: " + response.body);
        return null;
      }
    } catch (err) {
      log.e('In getReferralParentByAddress catch $err');
      return null;
    }
  }

  Future<int> getReferralCount(
    String address,
  ) async {
    String url =
        PaycoolApiRoutes.payCoolClubrRefUrl + 'children/' + address + '/count';
    int referralCount = 0;
    log.i('getReferralCount url $url');
    try {
      var response = await client.get(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        var json = jsonDecode(response.body);

        // log.w('getChildrenByAddress json $json');
        if (json.isNotEmpty) {
          referralCount = json['_body'];
          log.i('referral count $referralCount');
          return referralCount;
        } else {
          return 0;
        }
      } else {
        log.e("getReferralCount error: " + response.body);
        return 0;
      }
    } catch (err) {
      log.e('In getReferralCount catch $err');
      return 0;
    }
  }

  Future<List<PaycoolReferral>> getChildrenByAddress(String address,
      {int pageSize = 10, int pageNumber = 0}) async {
    String url = PaycoolApiRoutes.payCoolClubrRefUrl + 'children/' + address;
    if (pageNumber != 0) {
      pageNumber = pageNumber - 1;
    }
    // page number - 1 because page number start from 0 in the api but in front end its from 1
    url = url + '/$pageSize/$pageNumber';
    log.i('getChildrenByAddress url $url');
    try {
      var response = await client.get(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        var json = jsonDecode(response.body) as List;

        // log.w('getChildrenByAddress json $json');
        if (json.isNotEmpty) {
          PaycoolReferralList paycoolReferralList =
              PaycoolReferralList.fromJson(json);
          log.i(
              'first childeren obj ${paycoolReferralList.paycoolReferralList[0].toJson()}');
          return paycoolReferralList.paycoolReferralList;
        } else {
          return [];
        }
      } else {
        log.e("getChildrenByAddress error: " + response.body);
        return [];
      }
    } catch (err) {
      log.e('In getChildrenByAddress catch $err');
      return [];
    }
  }

/*-------------------------------------------------------------------------------------
                            Get Dashboard details
-------------------------------------------------------------------------------------*/

  Future<PaycoolDashboard> getDashboardDataByAddress(String address) async {
    String url = PaycoolApiRoutes.payCoolClubrRefUrl + 'dashboard/' + address;
    log.i('getDashboardDetailsByAddress url $url');
    try {
      var response = await client.get(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        var json = jsonDecode(response.body);

        log.w('getDashboardDetailsByAddress json $json');
        PaycoolDashboard dashboard = PaycoolDashboard.fromJson(json);
        log.e(dashboard.toJson());

        return dashboard;
      } else {
        log.e("getDashboardDetailsByAddress error: " + response.body);
        return null;
      }
    } catch (err) {
      log.e('In getDashboardDetailsByAddress catch $err');
      return null;
    }
  }
}
