import 'dart:convert';

import 'package:paycool/constants/api_routes.dart';
import 'package:paycool/logger.dart';

import 'package:paycool/service_locator.dart';
import 'package:paycool/services/config_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/utils/custom_http_util.dart';
import 'package:paycool/views/paycool_club/club_dashboard_model.dart';
import 'package:paycool/views/paycool_club/club_projects/club_package_checkout_model.dart';
import 'package:paycool/views/paycool_club/club_projects/club_project_model.dart';
import 'package:paycool/views/paycool_club/purchased_package_history/purchased_package_history_model.dart';
import 'package:paycool/views/paycool_club/referral/referral_model.dart';
import 'package:paycool/views/paycool_club/paycool_dashboard_model_old.dart';

import '../../models/paycool/paycool_order_model.dart';

class PayCoolClubService {
  final log = getLogger('PayCoolClubService');

  final client = CustomHttpUtil.createLetsEncryptUpdatedCertClient();
  final configService = locator<ConfigService>();
  final sharedService = locator<SharedService>();
  final String campaignId = '1';

/*----------------------------------------------------------------------
                      Tx Receipt
----------------------------------------------------------------------*/

// status 1 means success, 0 means failure
  Future<bool> txReceipt(String txId) async {
    String url = configService.getKanbanBaseUrl() +
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
  Future<bool> isValidMember(String fabAddress) async {
    String url = isValidPaycoolMemberUrl + fabAddress;
    log.i('isValidMember url $url');
    bool res = false;
    try {
      var response = await client.get(url);
      var json = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        log.w('isValidMember json $json');

        var isValid = json['isValid'];
        if (isValid != null) {
          log.i('isvalid $isValid');
          res = isValid;
        }
        return res;
      } else {
        log.e("isValidMember error: " + json);
        return false;
      }
    } catch (e) {
      log.e('isValidMember failed to load the data from the API $e');
      throw Exception(e);
    }
  }

/*----------------------------------------------------------------------
                     Check if paycool club member
----------------------------------------------------------------------*/
//memberType: 0-should be unknown; 1-keyNode, 2-Consumer, 3-Merchant
  Future<bool> isMember(String fabAddress) async {
    String url = payCoolClubrRefUrl + fabAddress;
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
                            Pay.cool Club Details
----------------------------------------------------------------------*/

  // https://fabtest.info/api/project/v2/10/0
  Future<List<ClubProject>> getClubProjects(
      {int pageSize = 10, int pageNumber = 0}) async {
    String url = clubProjectsUrl;

    if (pageNumber != 0) {
      pageNumber = pageNumber - 1;
    }
    // page number - 1 because page number start from 0 in the api but in front end its from 1
    url = url + '$pageSize/$pageNumber';
    log.i('getClubProjects url $url');

    try {
      var response = await client.get(url);
      var json = jsonDecode(response.body)['_body'] as List;
      log.w('getClubProjects json $json');
      if (response.statusCode == 200 || response.statusCode == 201) {
        ClubProjectList clubProjectList = ClubProjectList.fromJson(json);
        log.i(
            "getClubProjects clubProjectList: ${clubProjectList.clubProjects[0].toJson()}");
        return clubProjectList.clubProjects;
      } else {
        log.e("getClubProjects error: " + response.body);
        return [];
      }
    } catch (e) {
      log.e('getClubProjects failed to load the data from the API $e');
      return [];
    }
  }

// https://fabtest.info/api/projectpackage/v2/project/635d62c88e64d290833fa321/10/0
  Future<List<ClubProject>> getProjectDetails(String projectId,
      {int pageSize = 10, int pageNumber = 0}) async {
    String url = clubProjectDetailsUrl + projectId;

    if (pageNumber != 0) {
      pageNumber = pageNumber - 1;
    }
    // page number - 1 because page number start from 0 in the api but in front end its from 1
    url = url + '/$pageSize/$pageNumber';
    log.i('getProjectDetails url $url');

    try {
      var response = await client.get(url);
      var json = jsonDecode(response.body)['_body'] as List;
      log.w('getProjectDetails json $json');
      if (response.statusCode == 200 || response.statusCode == 201) {
        ClubProjectList clubProjectList = ClubProjectList.fromJson(json);
        log.i(
            "getProjectDetails clubProjectList: ${clubProjectList.clubProjects[0].toJson()}");
        return clubProjectList.clubProjects;
      } else {
        log.e("getProjectDetails error: " + response.body);
        return [];
      }
    } catch (e) {
      log.e('getProjectDetails failed to load the data from the API $e');
      return [];
    }
  }

// https://fabtest.info/api/projectpackage/v2/635d9597b3e4d42b56b1f327/params/muMdVtayH2se3qK361vEz7mjDJuY7owzVK/DUSD
  Future<ClubPackageCheckout> getPackageCheckoutDetails(
      String id, String ticker) async {
    String address = await sharedService.getFabAddressFromCoreWalletDatabase();
    String url =
        baseProjectPackageUrl + id + '/params/' + address + '/' + ticker;
    log.i('getPackageCheckoutDetails url $url');
    try {
      var response = await client.get(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        var json = jsonDecode(response.body)['_body'];

        log.w('getPackageCheckoutDetails json $json');
        if (json != null) {
          ClubPackageCheckout packageCheckoutDetails =
              ClubPackageCheckout.fromJson(json);
          return packageCheckoutDetails;
        } else {
          return ClubPackageCheckout(clubParams: [], rewardDetails: []);
        }
      } else {
        log.e("getPackageCheckoutDetails error: " + response.body);
        return null;
      }
    } catch (err) {
      log.e('In getPackageCheckoutDetails catch $err');
      return null;
    }
  }

  // Future<List<PayCoolClubModel>> getPayCoolClubDetails() async {
  //   String url = campaignListUrl;
  //   log.w('getPayCoolClubDetails url $url');

  //   try {
  //     var response = await client.get(url);
  //     var json = jsonDecode(response.body) as List;
  //     log.w('getPayCoolClubDetails json $json');
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       PayCoolClubModelList payCoolClubModel =
  //           PayCoolClubModelList.fromJson(json);
  //       return payCoolClubModel.clubProjects;
  //     } else {
  //       log.e("getPayCoolClubDetails error: " + response.body);
  //       return [];
  //     }
  //   } catch (e) {
  //     log.e('getPayCoolClubDetails failed to load the data from the API $e');
  //     return [];
  //   }
  // }

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
    log.i('createOrder club $payCoolClubCreateOrderUrl -- body $body');
    try {
      var response = await client.post(payCoolClubCreateOrderUrl, body: body);
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
    log.i('createOrder club $payCoolClubSaveOrderUrl -- body $body');
    try {
      var response = await client.post(payCoolClubSaveOrderUrl, body: body);
      var json = jsonDecode(response.body);
      log.w('save Order try response $json');
      return json;
    } catch (err) {
      log.e('In save Order catch $err');
    }
  }

  Future<PaycoolReferral> getReferralParentByAddress(String address) async {
    try {
      var response = await client.get(payCoolClubrRefUrl + address);
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

  Future<int> getPurchasedPackageCount(
    String address,
  ) async {
    String url = paycoolBaseUrl + 'buy/v2/user/' + address + '/totalCount';
    int referralCount = 0;
    log.i('getPurchasedPackageCount url $url');
    try {
      var response = await client.get(url);

      var json = jsonDecode(response.body)["_body"];

      // log.w('getChildrenByAddress json $json');
      if (json.isNotEmpty) {
        referralCount = json['totalCount'];
        log.i('getPurchasedPackageCount count $referralCount');
        return referralCount;
      } else {
        log.e("getPurchasedPackageCount error: " + response.body);
        return 0;
      }
    } catch (err) {
      log.e('In getPurchasedPackageCount catch $err');
      return 0;
    }
  }

  Future<List<PurchasedPackageHistory>> getPurchasedPackageHistory(
      String address,
      {int pageSize = 10,
      int pageNumber = 0}) async {
    String url = paycoolBaseUrl + 'buy/v2/user/' + address;
    if (pageNumber != 0) {
      pageNumber = pageNumber - 1;
    }
    // page number - 1 because page number start from 0 in the api but in front end its from 1
    url = url + '/$pageSize/$pageNumber';
    log.i('getPurchasedPackageHistory url $url');
    try {
      var response = await client.get(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        var json = jsonDecode(response.body)["_body"] as List;

        // log.w('getChildrenByAddress json $json');
        if (json.isNotEmpty) {
          PurchasedPackageHistoryList historyList =
              PurchasedPackageHistoryList.fromJson(json);
          log.i(
              'getPurchasedPackageHistory first childeren obj ${historyList.purchasedPackageHistoryList[0].toJson()}');
          return historyList.purchasedPackageHistoryList;
        } else {
          return [];
        }
      } else {
        log.e("getPurchasedPackageHistory error: " + response.body);
        return [];
      }
    } catch (err) {
      log.e('In getPurchasedPackageHistory catch $err');
      return [];
    }
  }

// new
  Future<int> getUserReferralCount(
    String address,
  ) async {
    String url =
        paycoolBaseUrl + 'userreferral/user/' + address + '/totalCount';
    int referralCount = 0;
    log.i('getReferralCount url $url');
    try {
      var response = await client.get(url);

      var json = jsonDecode(response.body);

      // log.w('getChildrenByAddress json $json');
      if (json.isNotEmpty) {
        referralCount = json['totalCount'];
        log.i('referral count $referralCount');
        return referralCount;
      } else {
        log.e("getReferralCount error: " + response.body);
        return 0;
      }
    } catch (err) {
      log.e('In getReferralCount catch $err');
      return 0;
    }
  }

  // new
  Future<List<PaycoolReferral>> getUserDownlineByAddress(String address,
      {int pageSize = 10, int pageNumber = 0}) async {
    String url = paycoolBaseUrl + 'userreferral/user/' + address;
    if (pageNumber != 0) {
      pageNumber = pageNumber - 1;
    }
    // page number - 1 because page number start from 0 in the api but in front end its from 1
    url = url + '/$pageSize/$pageNumber';
    log.i('getUserDownlineByAddress url $url');
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
        log.e("getUserDownlineByAddress error: " + response.body);
        return [];
      }
    } catch (err) {
      log.e('In getUserDownlineByAddress catch $err');
      return [];
    }
  }

/*-------------------------------------------------------------------------------------
                            Get Dashboard details
-------------------------------------------------------------------------------------*/
//https://fabtest.info/api/userreferral/v2/user/myqZGzmy1fArKKx1RcgAxQTd4v1KutZgzY/summary
  Future<ClubDashboard> getDashboardSummary(String address) async {
    String url = clubDashboardUrl + address + '/summary';
    log.i('getDashboardSummary url $url');
    try {
      var response = await client.get(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        var json = jsonDecode(response.body)['_body'];

        log.w('getDashboardSummary json $json');
        ClubDashboard dashboard = ClubDashboard.fromJson(json);
        log.i(
            'getDashboardSummary club dashboard obj -- ${dashboard.toJson()}');

        return dashboard;
      } else {
        log.e("getDashboardSummary error: " + response.body);
        return null;
      }
    } catch (err) {
      log.e('In getDashboardSummary catch $err');
      return null;
    }
  }

  Future<PaycoolDashboard> getDashboardDataByAddress(String address) async {
    String url = payCoolClubrRefUrl + 'dashboard/' + address;
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
