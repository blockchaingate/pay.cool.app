import 'dart:convert';
import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:observable_ish/observable_ish.dart';
import 'package:paycool/constants/api_routes.dart';
import 'package:paycool/environments/environment.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/db/core_wallet_database_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/utils/abi_util.dart';
import 'package:paycool/utils/custom_http_util.dart';
import 'package:paycool/utils/kanban.util.dart';
import 'package:paycool/utils/keypair_util.dart';
import 'package:paycool/views/paycool/models/pay_order_model.dart';
import 'package:paycool/views/paycool/models/merchant_model.dart';
import 'package:paycool/views/paycool/rewards/payment_rewards_model.dart';
import 'package:paycool/views/paycool/transaction_history/paycool_transaction_history_model.dart';
import 'package:stacked/stacked.dart';
import 'package:hex/hex.dart';
import 'models/payment_rewards_model.dart';

//@LazySingleton()
class PayCoolService with ListenableServiceMixin {
  final log = getLogger('PayCoolService');

  final client = CustomHttpUtil.createLetsEncryptUpdatedCertClient();
  final coreWalletDatabaseService = locator<CoreWalletDatabaseService>();
  SharedService sharedService = locator<SharedService>();

  final RxValue<int> _pageNumber = RxValue<int>(1);
  int get pageNumber => _pageNumber.value;
  final int _pageSize = 2;
  int get pageSize => _pageSize;

  final RxValue<bool> _hasUpdatedPageNumber = RxValue<bool>(false);
  bool get hasUpdatedPageNumber => _hasUpdatedPageNumber.value;

  PayCoolService() {
    listenToReactiveValues([_pageNumber, _hasUpdatedPageNumber]);
  }
  updatePage({bool? isNext}) {
    _pageNumber.value = isNext! ? _pageNumber.value + 1 : _pageNumber.value - 1;
    log.w('updatePage ${_pageNumber.value}');
    notifyListeners();
    hasUpdatedPageNumberFunc(true);
  }

  hasUpdatedPageNumberFunc(bool value) {
    _hasUpdatedPageNumber.value = value;
    log.w(
        'hasUpdatedPageNumberFunc : _hasUpdatedPageNumber ${_hasUpdatedPageNumber.value}');
  }

  Future<String?> createTemplateById(String id) async {
    String orderIdResult = '';
    String url = '${paycoolBaseUrl}userpay/createOrderFromTemplate';
    var body = {"id": id};
    log.i('createTemplateById url $url -- body ${jsonEncode(body)}');

    try {
      var response = await client.post(Uri.parse(url),
          body: jsonEncode(body),
          headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json'
          });
      if (response.statusCode == 200 || response.statusCode == 201) {
        var json = jsonDecode(response.body);
        log.w('createTemplateById json $json');

        orderIdResult = json['_id'];
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
  //https://test.fabcoin.org/api/userpay/createOrderFromAddress

  Future<String> createOrderFromAddress(String address, Decimal amount) async {
    String url = '${paycoolBaseUrl}userpay/createOrderFromAddress';

    final body = {"address": address, "amount": amount};
    log.i('createOrderFromAddress url $url -- body ${jsonEncode(body)}');

    try {
      var response = await client.post(Uri.parse(url),
          body: jsonEncode(body),
          headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json'
          });

      var json = jsonDecode(response.body);

      log.w('createOrderFromAddress json $json');
      // return order id
      return json['_id'];
    } catch (err) {
      log.e('In createOrderFromAddress catch $err');
      return '';
    }
  }

  Future<String> createStoreMerchantOrder(Map<String, dynamic> body) async {
    String url =
        '$baseBlockchainGateV2Url$ordersTextApiRoute$paycoolTextApiRoute/create';

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
      var response = await client.post(Uri.parse(url),
          body: jsonEncode(body),
          headers: {
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

  Future<MerchantModel?> getMerchantInfo(String id) async {
    String url = '${paycoolBaseUrl}merchantreferral/v2/$id';
    log.i('getMerchantInfo url $url');
    try {
      var response = await client.get(Uri.parse(url));

      var json = jsonDecode(response.body)['_body'];
      MerchantModel merchantModel = MerchantModel();
      if (json.isNotEmpty) {
        log.w('getMerchantInfo json $json');
        merchantModel = MerchantModel.fromJson(json);
        log.w('getMerchantInfo json ${merchantModel.toJson()}');
      }
      return merchantModel;
    } catch (err) {
      log.e('In getMerchantInfo catch $err');
      return null;
    }
  }

  Future<PaymentRewardsModel?> getPayOrderInfoWithRewards(String id) async {
    String fabAddress =
        await coreWalletDatabaseService.getWalletAddressByTickerName('FAB');
    //https:fabtest.info/api/userpay/v2/order/635ab250f8ba77d673a32474
    String url = '${paycoolBaseUrl}userpay/v2/order/$id/$fabAddress/rewardInfo';

    log.i('getPayOrderInfoWithRewards url $url');
    PaymentRewardsModel? rewardInfoModel;
    try {
      var response = await client.get(Uri.parse(url));
      if (response.statusCode == 200 || response.statusCode == 201) {
        var json = jsonDecode(response.body)['_body'];
        var isDataCorrect = jsonDecode(response.body)['success'];
        if (json.isNotEmpty) {
          log.w('getPayOrderInfoWithRewards json $json');

          if (!isDataCorrect) {
            log.e('In getPayOrderInfoWithRewards catch $json');
            throw Exception(json);
          } else if (isDataCorrect) {
            rewardInfoModel = PaymentRewardsModel.fromJson(json);
          }
        }
      } else {
        log.e(
            'getPayOrderInfoWithRewards Response failed : reson ${response.toString()} -- body ${response.body}');
      }
      return rewardInfoModel;
    } catch (err) {
      log.e('In getPayOrderInfoWithRewards catch $err');
      throw Exception(err);
    }
  }

  Future<PayOrder?> getPayOrderInfo(String id) async {
    //  https: //fabtest.info/api/userpay/v2/order/635ab250f8ba77d673a32474
    String url = '${paycoolBaseUrl}userpay/v2/order/$id';

    log.i('getPayOrderInfo url $url');
    PayOrder? payOrder;
    try {
      var response = await client.get(Uri.parse(url));
      if (response.statusCode == 200 || response.statusCode == 201) {
        var isDataCorrect = jsonDecode(response.body)['success'];

        if (!isDataCorrect) {
          throw Exception(jsonDecode(response.body)['error']);
        } else if (isDataCorrect) {
          var jsonData = jsonDecode(response.body)['_body']['items'];
          log.w('getPayOrderInfo json $jsonData');
          payOrder = PayOrder.fromJson(jsonData.first);
        }
      }

      return payOrder;
    } catch (err) {
      log.e('In getPayOrderInfo catch $err');
      throw Exception(err);
    }
  }

  Future<List<String>> getRegionalAgent(String smartContractAddress) async {
    String url = regionalAgentStarPayUrl + smartContractAddress;
    log.i('getRegionalAgent url $url');
    try {
      var response = await client.get(Uri.parse(url));
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
        log.e("getParentAddress error: ${response.body}");
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
      var response = await client.get(Uri.parse(url));
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
        log.e("getParentAddress error: ${response.body}");
        return [];
      }
    } catch (err) {
      log.e('In getParentAddress catch $err');
      return [];
    }
  }

  Future<PayCoolTransactionHistory?> applyRefund(
      String orderId, String randomId, signature) async {
    String url = '${paycoolBaseUrl}charge/requestrefund/$orderId';
    var txHistory = PayCoolTransactionHistory();
    var body = {
      "refundAll": true,
      "items": [],
      "requestRefundId": '0x$randomId',
      "r": signature['r'],
      "s": signature['s'],
      "v": signature['v'],
    };
    log.i('getRefund url ${Uri.parse(url)} -- body ${jsonEncode(body)}');
    try {
      var response = await client.post(Uri.parse(url),
          body: jsonEncode(body),
          headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json'
          });
      if (response.statusCode == 200 || response.statusCode == 201) {
        var json = jsonDecode(response.body);
        log.w(' json  object $json');
        txHistory = PayCoolTransactionHistory.fromJson(json);
      } else {
        log.e("Not good response ${response.body}");
      }
    } catch (err) {
      log.e('In getRefund catch $err');
    }
    return txHistory;
  }

  // Get Transaction History

  Future<int> getTransactionHistoryCount(String fabAddress) async {
    String url = '$paymentTransactionHistoryUrl$fabAddress/totalCount';
    int totalCount = 0;
    log.i('getTransactionHistoryCount url $url');
    try {
      var response = await client.get(Uri.parse(url));
      if (response.statusCode == 200 || response.statusCode == 201) {
        var json = jsonDecode(response.body);
        if (json["success"]) {
          totalCount = json['_body']['totalCount'];
          log.i('getTransactionHistoryCount count $totalCount');
          return totalCount;
        } else {
          return 0;
        }
      } else {
        log.e("getTransactionHistoryCount error: ${response.body}");
        return 0;
      }
    } catch (err) {
      log.e('In getTransactionHistoryCount catch $err');
      return 0;
    }
  }

  Future<List<PayCoolTransactionHistory>?> getTransactionHistory(String address,
      {int pageSize = 10, int pageNumber = 0}) async {
    String url = paymentTransactionHistoryUrl + address;

    // page number - 1 because page number start from 0 in the api but in front end its from 1
    if (pageNumber != 0) {
      pageNumber = pageNumber - 1;
    }
    url = '$url/$pageSize/$pageNumber';
    log.i('getTransactionHistory url $url');

    try {
      var response = await client.get(Uri.parse(url));
      if (response.statusCode == 200 || response.statusCode == 201) {
        var json = jsonDecode(response.body)['_body'] as List;

        log.w(
            'getTransactionHistory - LENGTH ${json.length} -- json first object ${json[0]}');
        if (json.isNotEmpty) {
          PayCoolTransactionHistoryModelList transactionList =
              PayCoolTransactionHistoryModelList.fromJson(json);
          log.w(
              'getTransactionHistory func:  transactions length -- ${transactionList.transactions!.length}');
          return transactionList.transactions;
        } else {
          return [];
        }
      } else {
        log.e("getTransactionHistory error: ${response.body}");
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
      final res = await client.post(Uri.parse(url),
          body: jsonEncode(body),
          headers: {
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
        log.e("error: ${res.body}");
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
    String url = '$paymentRewardUrl$fabAddress/totalCount';
    int referralCount = 0;
    log.i('getPaymentRewardTotalCount url $url');
    try {
      var response = await client.get(Uri.parse(url));
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
        log.e("getPaymentRewardTotalCount error: ${response.body}");
        return 0;
      }
    } catch (err) {
      log.e('In getPaymentRewardTotalCount catch $err');
      return 0;
    }
  }

  Future<List<PaymentReward>?> getPaymentRewards(String address,
      {int pageSize = 10, int pageNumber = 0}) async {
    String url = paymentRewardUrl + address;
    // page number - 1 because page number start from 0 in the api but in front end its from 1
    if (pageNumber != 0) {
      pageNumber = pageNumber - 1;
    }
    url = '$url/$pageSize/$pageNumber';
    log.i('getPaymentRewards url $url');
    try {
      var response = await client.get(Uri.parse(url));
      if (response.statusCode == 200 || response.statusCode == 201) {
        var json = jsonDecode(response.body)['_body'] as List;

        // log.w('getPayRewards json ${json[0]}');
        if (json.isNotEmpty) {
          PaymentRewards paymentRewardList = PaymentRewards.fromJson(json);

          log.e(
              'getPaymentRewards length ${paymentRewardList.paymentRewards!.length}');
          return paymentRewardList.paymentRewards;
        } else {
          return [];
        }
      } else {
        log.e("getPaymentRewards error: ${response.body}");
        return [];
      }
    } catch (err) {
      log.e('In getPaymentRewards catch $err');
      return [];
    }
  }

  Future<String> signSendTx(
      Uint8List seed, String abiHex, String toAddress) async {
    String result = '';
    String exgAddress =
        await sharedService.getExgAddressFromCoreWalletDatabase();

    var keyPairKanban = getExgKeyPair(Uint8List.fromList(seed));
    log.w('keyPairKanban $keyPairKanban');
    int kanbanGasPrice = environment["chains"]["KANBAN"]["gasPrice"];
    int kanbanGasLimit = environment["chains"]["KANBAN"]["gasLimit"];

    var txKanbanHex;
    var res;

    var nonce = await getNonce(exgAddress);
    try {
      txKanbanHex = await signAbiHexWithPrivateKey(
          abiHex,
          HEX.encode(keyPairKanban["privateKey"]),
          toAddress,
          nonce,
          kanbanGasPrice,
          kanbanGasLimit);

      log.i('txKanbanHex $txKanbanHex');
    } catch (err) {
      log.e('err $err');
    }
    if (txKanbanHex != '') {
      var resBody =
          await sendKanbanRawTransactionV2(paycoolBaseUrl, txKanbanHex);
      res = resBody['_body'];
      var txHash = res['transactionHash'];
      //{"ok":true,"_body":{"transactionHash":"0x855f2d8ec57418670dd4cb27ecb71c6794ada5686e771fe06c48e30ceafe0548","status":"0x1"}}

      log.w('res $res');
      if (res['status'] != null) {
        result = res['status'];
      } else {
        result = res['transactionHash'];
      }
    }
    return result;
  }
}
