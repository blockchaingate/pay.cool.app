import 'dart:convert';

import 'package:observable_ish/observable_ish.dart';
import 'package:paycool/constants/api_routes.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/db/core_wallet_database_service.dart';
import 'package:paycool/utils/custom_http_util.dart';
import 'package:paycool/views/paycool/models/paycool_store_model.dart';
import 'package:paycool/views/paycool/models/store_and_merchant_model.dart';
import 'package:paycool/views/paycool/rewards/paycool_rewards_model.dart';
import 'package:paycool/views/paycool/models/paycool_model.dart';
import 'package:paycool/views/paycool/transaction_history/paycool_transaction_history_model.dart';
import 'package:stacked/stacked.dart';

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

  Future<ScanToPayModelV2> scanToPayV2Info(String id) async {
    String fabAddress =
        await coreWalletDatabaseService.getWalletAddressByTickerName('FAB');
    // url example https://test.blockchaingate.com/v2/orders/62a0eb10d447e63ed49f7c0e/Paycool
    String url = baseBlockchainGateV2Url +
        ordersTextApiRoute +
        id +
        '/' +
        paycoolTextApiRoute;
    var body = {"address": fabAddress};
    log.i('scanToPayV2Info url $url -- body ${jsonEncode(body)}');
    ScanToPayModelV2 scanToPayModelV2;
    try {
      var response = await client.post(url, body: jsonEncode(body), headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        var json = jsonDecode(response.body)['_body'];
        var isDataCorrect = jsonDecode(response.body)['ok'];
        if (json.isNotEmpty) {
          log.w('scanToPayV2Info json $json');

          if (!isDataCorrect) {
            log.e('In scanToPayV2Info catch $json');
            throw Exception(json);
          } else if (isDataCorrect) {
            scanToPayModelV2 = ScanToPayModelV2.fromJson(json);
          }
        }
      } else {
        log.e(
            'Response failed : reson ${response.toString()} -- body ${response.body}');
      }
      return scanToPayModelV2;
    } catch (err) {
      log.e('In scanToPayV2Info catch $err');
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

  Future<List<PayCoolTransactionHistoryModel>> getPayTransactionDetails(
      String address) async {
    String url = payCoolTransactionHistoryUrl + address;
    log.i('getPayTransactionDetails url $url');
    try {
      var response = await client.get(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        var json = jsonDecode(response.body)['_body'] as List;

        log.w('getPayTransactionDetails json first object ${json[0]}');
        if (json.isNotEmpty) {
          PayCoolTransactionHistoryModelList transactionList =
              PayCoolTransactionHistoryModelList.fromJson(json);
          log.w(
              'getpaytransaction func:  transactions length -- ${transactionList.transactions.length}');
          return transactionList.transactions;
        } else {
          return [];
        }
      } else {
        log.e("getPayTransactionDetails error: " + response.body);
        return [];
      }
    } catch (err) {
      log.e('In getPayTransactionDetails catch $err');
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
  Future<int> getRewardListCount(String fabAddress) async {
    String url = payCoolRewardUrl + fabAddress + '/count';
    int referralCount = 0;
    log.i('getRewardListCount url $url');
    try {
      var response = await client.get(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        var json = jsonDecode(response.body);

        // log.w('getChildrenByAddress json $json');
        if (json.isNotEmpty) {
          referralCount = json['_body'];
          log.i('getRewardListCount count $referralCount');
          return referralCount;
        } else {
          return 0;
        }
      } else {
        log.e("getRewardListCount error: " + response.body);
        return 0;
      }
    } catch (err) {
      log.e('In getRewardListCount catch $err');
      return 0;
    }
  }

  Future<List<PayCoolRewardsModel>> getPayCoolRewards(String address,
      {int pageSize = 10, int pageNumber = 0}) async {
    String url = payCoolRewardUrl + address;
    // page number - 1 because page number start from 0 in the api but in front end its from 1
    if (pageNumber != 0) {
      pageNumber = pageNumber - 1;
    }
    url = url + '/$pageSize/$pageNumber';
    log.i('getPayRewards url $url');
    try {
      var response = await client.get(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        var json = jsonDecode(response.body)['_body'] as List;

        // log.w('getPayRewards json ${json[0]}');
        if (json.isNotEmpty) {
          PayCoolRewardsModelList paycoolReferralList =
              PayCoolRewardsModelList.fromJson(json);

          log.e('rewards length ${paycoolReferralList.rewards.length}');
          return paycoolReferralList.rewards;
        } else {
          return [];
        }
      } else {
        log.e("getPayRewards error: " + response.body);
        return [];
      }
    } catch (err) {
      log.e('In getPayRewards catch $err');
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
