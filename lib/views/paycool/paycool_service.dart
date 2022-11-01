import 'dart:convert';

import 'package:observable_ish/observable_ish.dart';
import 'package:paycool/constants/api_routes.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/db/core_wallet_database_service.dart';
import 'package:paycool/utils/custom_http_util.dart';
import 'package:paycool/views/paycool/models/paycool_store_model.dart';
import 'package:paycool/views/paycool/models/store_and_merchant_model.dart';
import 'package:paycool/views/paycool/rewards/payment_rewards_model.dart';
import 'package:paycool/views/paycool/transaction_history/paycool_transaction_history_model.dart';
import 'package:stacked/stacked.dart';

import 'models/payment_model.dart';

//@LazySingleton()
class PayCoolService with ReactiveServiceMixin {
  final log = getLogger('PayCoolService');

  final client = CustomHttpUtil.createLetsEncryptUpdatedCertClient();
  final coreWalletDatabaseService = locator<CoreWalletDatabaseService>();

  final RxValue<int> _pageNumber = RxValue<int>(1);
  int get pageNumber => _pageNumber.value;
  final int _pageSize = 2;
  int get pageSize => _pageSize;

  final RxValue<bool> _hasUpdatedPageNumber = RxValue<bool>(false);
  bool get hasUpdatedPageNumber => _hasUpdatedPageNumber.value;

  PayCoolService() {
    listenToReactiveValues([_pageNumber, _hasUpdatedPageNumber]);
  }
  updatePage({bool isNext}) {
    _pageNumber.value = isNext ? _pageNumber.value + 1 : _pageNumber.value - 1;
    log.w('updatePage ${_pageNumber.value}');
    notifyListeners();
    hasUpdatedPageNumberFunc(true);
  }

  hasUpdatedPageNumberFunc(bool value) {
    _hasUpdatedPageNumber.value = value;
    log.w(
        'hasUpdatedPageNumberFunc : _hasUpdatedPageNumber ${_hasUpdatedPageNumber.value}');
  }

  Future<String> createTemplateById(String id) async {
    String orderIdResult = '';
    String url = baseBlockchainGateV2Url +
        ordersTextApiRoute +
        paycoolTextApiRoute +
        '/createFromTemplate';
    var body = {"id": id};
    log.i('createTemplateById url $url -- body ${jsonEncode(body)}');

    try {
      var response = await client.post(url, body: jsonEncode(body), headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        var json = jsonDecode(response.body)['_body'];
        log.w('createTemplateById json $json');
        if (json.isNotEmpty) {
          orderIdResult = json['_id'];
        }
      } else {
        log.e(
            'createTemplateById Response failed : reson ${response.toString()} -- body ${response.body}');
      }
      return orderIdResult;
    } catch (err) {
      log.e('In createTemplateById catch $err');
      return null;
    }
  }

  Future<String> createStoreMerchantOrder(Map<String, dynamic> body) async {
    String url = baseBlockchainGateV2Url +
        ordersTextApiRoute +
        paycoolTextApiRoute +
        '/' +
        'create';

    //    const body = {
    //     currency: currency,
    //     items: [
    //         {
    //             title: memo,
    //             giveAwayRate: giveAwayRate,
    //             taxRate: 0,
    //             lockedDays: lockedDays,
    //             price: amount,
    //             quantity: 1
    //         }
    //     ],
    //     store: storeId,
    //     totalSale: amount,
    //     totalTax: 0
    // };
    log.i('createStoreMerchantOrder url $url -- body ${jsonEncode(body)}');

    try {
      var response = await client.post(url, body: jsonEncode(body), headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      });

      var json = jsonDecode(response.body)['_body'];

      log.w('createStoreMerchantOrder json $json');
      // return order id
      return json['_id'];
    } catch (err) {
      log.e('In createStoreMerchantOrder catch $err');
      return '';
    }
  }

  Future<StoreMerchantModel> getStoreMerchantInfo(String id) async {
    String url = baseBlockchainGateV2Url + 'stores/' + id;
    log.i('getStoreMerchantInfo url $url');
    try {
      var response = await client.get(url);

      var json = jsonDecode(response.body)['_body'];
      StoreMerchantModel storeModel = StoreMerchantModel();
      if (json.isNotEmpty) {
        log.w('getStoreMerchantInfo json $json');
        storeModel = StoreMerchantModel.fromJson(json);
        log.w('StoreMerchantModel json ${storeModel.toJson()}');
      }
      return storeModel;
    } catch (err) {
      log.e('In getStoreMerchantInfo catch $err');
      return null;
    }
  }

  Future<PaymentModel> getRewardInfo(String id) async {
    String fabAddress =
        await coreWalletDatabaseService.getWalletAddressByTickerName('FAB');
    //fabtest.info/api/userpay/635045f6f3999b02d1598c2c/mowmfJjDSfCNLvu5jjHD55aeXphf6cH2eT/rewardInfo
    String url = fabInfoBaseUrl +
        'api/userpay/v2/order/' +
        id +
        '/' +
        fabAddress +
        '/rewardInfo';

    log.i('getRewardInfo url $url');
    PaymentModel rewardInfoModel;
    try {
      var response = await client.get(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        var json = jsonDecode(response.body)['_body'];
        var isDataCorrect = jsonDecode(response.body)['success'];
        if (json.isNotEmpty) {
          log.w('getRewardInfo json $json');

          if (!isDataCorrect) {
            log.e('In getRewardInfo catch $json');
            throw Exception(json);
          } else if (isDataCorrect) {
            rewardInfoModel = PaymentModel.fromJson(json);
          }
        }
      } else {
        log.e(
            'Response failed : reson ${response.toString()} -- body ${response.body}');
      }
      return rewardInfoModel;
    } catch (err) {
      log.e('In getRewardInfo catch $err');
      throw Exception(err);
    }
  }

  Future<StoreInfoModel> getStoreInfo(String smartContractAddress) async {
    String url = storeInfoPayCoolUrl + smartContractAddress;
    StoreInfoModel payCoolStoreModel = StoreInfoModel();
    log.i('getStoreInfo url $url');
    try {
      var response = await client.get(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        var json = jsonDecode(response.body)['_body'];

        if (json.isNotEmpty) {
          log.w('getStoreInfo json $json');
          payCoolStoreModel = StoreInfoModel.fromJson(json);
        }
      }
      return payCoolStoreModel;
    } catch (err) {
      log.e('In getStoreInfo catch $err');
      return null;
    }
  }

  Future<List<String>> getRegionalAgent(String smartContractAddress) async {
    String url = regionalAgentStarPayUrl + smartContractAddress;
    log.i('getRegionalAgent url $url');
    try {
      var response = await client.get(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        var json = jsonDecode(response.body)['_body'] as List;
        List<String> agents = [];
        if (json.isNotEmpty) {
          log.w('getRegionalAgent json $json');
          for (var element in json) {
            agents.add(element);
          }
          return agents;
        } else {
          return [];
        }
      } else {
        log.e("getParentAddress error: " + response.body);
        return [];
      }
    } catch (err) {
      log.e('In getParentAddress catch $err');
      return [];
    }
  }

/*----------------------------------------------------------------------
                          Get Ref parents
----------------------------------------------------------------------*/

  Future<List<String>> getParentAddress(String address) async {
    String url = paycoolParentAddressUrl + address;
    log.i('getParentAddress url $url');
    try {
      var response = await client.get(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        var json = jsonDecode(response.body) as List;
        List<String> res = [];
        if (json.isNotEmpty) {
          log.w('getParentAddress json $json');
          for (var element in json) {
            res.add(element);
          }
          return res;
        } else {
          return [];
        }
      } else {
        log.e("getParentAddress error: " + response.body);
        return [];
      }
    } catch (err) {
      log.e('In getParentAddress catch $err');
      return [];
    }
  }

  Future<List<PayCoolTransactionHistory>> getTransactionHistory(String address,
      {int pageSize = 10, int pageNumber = 0}) async {
    String url = paymentTransactionHistoryUrl + address;

    // page number - 1 because page number start from 0 in the api but in front end its from 1
    if (pageNumber != 0) {
      pageNumber = pageNumber - 1;
    }
    url = url + '/$pageSize/$pageNumber';
    log.i('getTransactionHistory url $url');

    try {
      var response = await client.get(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        var json = jsonDecode(response.body) as List;

        log.w('getTransactionHistory json first object ${json[0]}');
        if (json.isNotEmpty) {
          var l = [];
          l.add(json[3]);
          PayCoolTransactionHistoryModelList transactionList =
              PayCoolTransactionHistoryModelList.fromJson(l);
          log.w(
              'getTransactionHistory func:  transactions length -- ${transactionList.transactions.length}');
          return transactionList.transactions;
        } else {
          return [];
        }
      } else {
        log.e("getTransactionHistory error: " + response.body);
        return [];
      }
    } catch (err) {
      log.e('In getTransactionHistory catch $err');
      return [];
    }
  }

/*----------------------------------------------------------------------
                            Encode abi
----------------------------------------------------------------------*/

  Future<String> encodeAbiHex(
      String orderId,
      int coinType,
      var amount,
      var tax,
      List<String> agentAddresses,
      List<String> parentAddresses,
      String rewardInfo) async {
    String url = payCoolEncodeAbiUrl;
    var body = {
      "types": [
        "bytes32",
        "uint32",
        "uint256",
        "uint256",
        "address[]",
        "address[]",
        "bytes32"
      ],
      "params": [
        orderId,
        coinType,
        amount,
        tax,
        agentAddresses,
        parentAddresses,
        rewardInfo
      ]
    };
    log.w('encodeAbiHex url $url --  body $body');
    try {
      final res = await client.post(url, body: jsonEncode(body), headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      });
      log.w('encodeAbiHex json ${res.body}');
      var json = jsonDecode(res.body)['encodedParams'];
      if (res.statusCode == 200 || res.statusCode == 201) {
        return json.toString();
      } else {
        log.e("error: " + res.body);
        return res.body;
      }
    } catch (e) {
      log.e('CATCH encodeAbiHex failed to load the data from the API $e');
      return '';
    }
  }

/*----------------------------------------------------------------------
                            Decode scanned data
----------------------------------------------------------------------*/

  Future<List<String>> decodeScannedAbiHex(String abiHex) async {
    String url = payCoolDecodeAbiUrl;
    var body = {
      "types": [
        "bytes32",
        "uint32",
        "uint256",
        "uint256",
        "address[]",
        "address[]"
      ],
      'bytes': abiHex
    };
    log.w('decodeScannedAbiHex url $url --  body $body');
    try {
      final res = await client.post(url, body: jsonEncode(body), headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      });
      List<String> finalRes = [];
      var json = jsonDecode(res.body)['decodedParams'] as List;
      log.w('decodeScannedAbiHex json $json');
      if (res.statusCode == 200 || res.statusCode == 201) {
        if (json.isNotEmpty) {
          for (var element in json) {
            finalRes.add(element.toString());
          }
        }
        return finalRes;
      } else {
        List<String> err = [];
        log.e("error: " + res.body);
        err.add(res.body.toString());
        return err;
      }
    } catch (e) {
      log.e(
          'CATCH decodeScannedAbiHex failed to load the data from the API $e');
      return [];
    }
  }

/*----------------------------------------------------------------------
                            Get Rewards
----------------------------------------------------------------------*/
  Future<int> getPaymentRewardCount(String fabAddress) async {
    String url = paymentRewardUrl + fabAddress + '/totalCount';
    int referralCount = 0;
    log.i('getPaymentRewardTotalCount url $url');
    try {
      var response = await client.get(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        var json = jsonDecode(response.body);

        // log.w('getChildrenByAddress json $json');
        if (json["success"]) {
          referralCount = json['_body']['totalCount'];
          log.i('getPaymentRewardTotalCount count $referralCount');
          return referralCount;
        } else {
          return 0;
        }
      } else {
        log.e("getPaymentRewardTotalCount error: " + response.body);
        return 0;
      }
    } catch (err) {
      log.e('In getPaymentRewardTotalCount catch $err');
      return 0;
    }
  }

  Future<List<PaymentReward>> getPaymentRewards(String address,
      {int pageSize = 10, int pageNumber = 0}) async {
    String url = paymentRewardUrl + address;
    // page number - 1 because page number start from 0 in the api but in front end its from 1
    if (pageNumber != 0) {
      pageNumber = pageNumber - 1;
    }
    url = url + '/$pageSize/$pageNumber';
    log.i('getPaymentRewards url $url');
    try {
      var response = await client.get(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        var json = jsonDecode(response.body)['_body'] as List;

        // log.w('getPayRewards json ${json[0]}');
        if (json.isNotEmpty) {
          PaymentRewards paymentRewardList = PaymentRewards.fromJson(json);

          log.e(
              'getPaymentRewards length ${paymentRewardList.paymentRewards.length}');
          return paymentRewardList.paymentRewards;
        } else {
          return [];
        }
      } else {
        log.e("getPaymentRewards error: " + response.body);
        return [];
      }
    } catch (err) {
      log.e('In getPaymentRewards catch $err');
      return [];
    }
  }

/*----------------------------------------------------------------------
                            Create Referral
----------------------------------------------------------------------*/

  Future<dynamic> createStarPayReferral(
      String signature, String referralAddress) async {
    String url = payCoolCreateReferralUrl;
    var body = {'parentId': referralAddress, 'sig': '0x' + signature};
    log.w('createStarPayReferral url $url --  body $body');
    try {
      final res = await client.post(url, body: body);
      log.w('createStarPayReferral json ${jsonDecode(res.body)}');
      var json = jsonDecode(res.body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        return json;
      } else {
        log.e("error: " + res.body);
        return res.body;
      }
    } catch (e) {
      String res;
      log.e('createStarPayReferral failed to load the data from the API $e');
      if (e.toString().contains('Error')) {
        res = e
            .toString()
            .split(')')[1]
            .substring(1, (e.toString().split(')')[1].length - 2));
      }
      return res;
    }
  }
}
