/*
* Copyright (c) 2020 Exchangily LLC
*
* Licensed under Apache License v2.0
* You may obtain a copy of the License at
*
*      https://www.apache.org/licenses/LICENSE-2.0
*
*----------------------------------------------------------------------
* Author: barry-ruprai@exchangily.com
*----------------------------------------------------------------------
*/

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import '../constants/api_routes.dart';
import '../logger.dart';
import '../models/shared/pair_decimal_config_model.dart';
import '../models/wallet/exchange_balance_model.dart';
import '../models/wallet/token_model.dart';
import '../models/wallet/transaction_history.dart';
import '../models/wallet/wallet_balance.dart';
import '../service_locator.dart';
import '../utils/custom_http_util.dart';
import '../utils/string_util.dart' as string_utils;
import '../environments/environment.dart';
import '../views/paycool/paycool__history.dart';
import 'config_service.dart';
import 'db/core_wallet_database_service.dart';
import 'local_storage_service.dart';
import 'shared_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// The service responsible for networking requests
class ApiService {
  final log = getLogger('ApiService');

  final client = CustomHttpUtil.createLetsEncryptUpdatedCertClient();
  ConfigService configService = locator<ConfigService>();
  SharedService sharedService = locator<SharedService>();
  LocalStorageService storageService = locator<LocalStorageService>();
  CoreWalletDatabaseService coreWalletDatabaseService =
      locator<CoreWalletDatabaseService>();

  // Get unstoppable supported tlds
  Future<List<String>> getDomainSupportedTlds() async {
    var url = "https://resolve.unstoppabledomains.com/supported_tlds";
    log.i('getDomainSupportedTlds url $url');
    try {
      var response = await client.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });
      var json = jsonDecode(response.body)['tlds'];
      json = json.cast<String>();
      log.w('getDomainSupportedTlds func: json data $json');

      return json;
    } catch (err) {
      log.e('getDomainSupportedTlds CATCH $err');
      throw Exception(err);
    }
  }

  // Get unstoppable domain info
  Future getDomainRecord(String domain) async {
    var token = dotenv.env['UD_BEARER_TOKEN'];
    var url = "https://resolve.unstoppabledomains.com/domains/$domain";
    log.i('getDomainRecord url $url');
    try {
      var response = await client.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      var json = jsonDecode(response.body);

      log.w('getDomainRecord func: json data $json');

      return json;
    } catch (err) {
      log.e('getDomainRecord CATCH $err');
      throw Exception(err);
    }
  }

  Future getTronTsWalletBalance(String address) async {
    var body = {"address": address, "visible": true};

    log.i('getTronTsWalletBalance url $TronGetAccountUrl - body $body');
    try {
      var response =
          await client.post(TronGetAccountUrl, body: jsonEncode(body));
      var json = jsonDecode(response.body);
      if (json != null) {
        log.e('getTronTsWalletBalance $json}');
        return json;
      }
    } catch (err) {
      log.e('getTronTsWalletBalance CATCH $err');
      throw Exception(err);
    }
  }

  Future getTronUsdtTsWalletBalance(
      String officialTrxAddress, String smartContractAddress) async {
    String officialTrxAddressToHex =
        string_utils.convertFabAddressToHex(officialTrxAddress);
    var abiHex =
        string_utils.fixLength(officialTrxAddressToHex.substring(2), 64);
    debugPrint('addressToHex $officialTrxAddress');
    debugPrint('abi hex $abiHex');
    var body = {
      "contract_address": smartContractAddress,
      "function_selector": 'balanceOf(address)',
      "owner_address": '410000000000000000000000000000000000000000',
      "parameter": abiHex
    };

    debugPrint(
        'getTronTsWalletBalance url $TronUsdtAccountBalanceUrl - body $body');
    try {
      var response =
          await client.post(TronUsdtAccountBalanceUrl, body: jsonEncode(body));
      var json = jsonDecode(response.body);
      if (json != null) {
        log.e('getTronUsdtTsWalletBalance $json}');
        var balanceInHex = json["constant_result"][0];
        debugPrint('balanceInHex $balanceInHex');
        // var hexToBytesBalance =
        //     stringUtils.hexToUint8List(balanceInHex[0]);
        //       debugPrint('hexToBytesBalance $hexToBytesBalance');
        var res = int.parse(balanceInHex, radix: 16);
        //stringUtils.uint8ListToHex(hexToBytesBalance);
        debugPrint('res $res');
        return res;
      }
    } catch (err) {
      log.e('getTronUsdtTsWalletBalance CATCH $err');
      throw Exception(err);
    }
  }

  Future getTronLatestBlock() async {
    log.i('getBanner url $GetTronLatestBlockUrl');

    try {
      var response = await client.get(GetTronLatestBlockUrl);
      var json = jsonDecode(response.body);
      if (json != null) {
        log.e('getTronLatestBlock $json}');
        return json;
      }
    } catch (err) {
      log.e('getTronLatestBlock CATCH $err');
      throw Exception(err);
    }
  }

  Future<List<TransactionHistory>> getTransactionHistoryEvents() async {
    String fabAddress = '';

    List<TransactionHistory> transactionHistory = [];
    await coreWalletDatabaseService
        .getWalletAddressByTickerName('FAB')
        .then((address) => fabAddress = address);

    String url =
        configService.getKanbanBaseUrl() + WithDrawDepositTxHistoryApiRoute;
    Map<String, dynamic> body = {"fabAddress": fabAddress};

    log.i('getTransactionHistoryEvents url $url -- body $body');

    try {
      var response = await client.post(url, body: body);

      var json = jsonDecode(response.body);
      if (json != null) {
        log.w('getTransactionHistoryEvents json $json}');
        if (json['success']) {
          //  log.e('getTransactionHistoryEvents json ${json['data']}');
          var data = json['data'] as List;

          int index = 1;
          for (var element in data) {
            var tag = element['action'] as String;
            var ticker = element['coin'] as String;
            var timestamp = element['timestamp'];
            var tickerChainTxStatus;
            var kanbanTxStatus;
            var kanbanTxId;
            var tickerTxId;
            String chainName;
            List transactionsInside = element['transactions'] as List;
            // It has only 2 objects inside
            for (var element in transactionsInside) {
              String chain = element['chain'];
              if (chain == 'KANBAN') {
                kanbanTxStatus = element['status'];
                if (element['transactionId'] != null) {
                  kanbanTxId = element['transactionId'];
                }
              }
              // if (chain == 'FAB' ||
              //     chain == 'ETH' ||
              //     ticker == 'BTC' ||
              //     ticker == 'LTC' ||
              //     ticker == 'ETH' ||
              //     ticker == 'DOGE' ||
              //     ticker == 'FAB' ||
              //     ticker == 'BCH')
              else {
                tickerChainTxStatus = element['status'];
                chainName = chain;
                if (element['transactionId'] != null) {
                  tickerTxId = element['transactionId'];
                }
              }
            }

            var date =
                DateTime.fromMillisecondsSinceEpoch(timestamp * 1000).toLocal();
            String filteredDate =
                date.toString().substring(0, date.toString().length - 4);
            var amount = element['quantity'].toString();

            //  debugPrint(
            // 'tag $tag -- ticker $ticker -- date ${date.toLocal()} - amount ${double.parse(amount)}');
            TransactionHistory tx = TransactionHistory(
                id: index,
                tag: tag,
                chainName: chainName,
                tickerChainTxStatus: tickerChainTxStatus,
                kanbanTxStatus: kanbanTxStatus,
                kanbanTxId: kanbanTxId,
                tickerChainTxId: tickerTxId,
                date: filteredDate,
                tickerName: ticker,
                quantity: double.parse(amount));

            transactionHistory.add(tx);
            index++;
          }
        }
      }
      return transactionHistory;
    } catch (err) {
      log.e('getTransactionHistoryEvents CATCH $err');

      throw Exception(err);
    }
  }

/*----------------------------------------------------------------------
                Get Bindpay History
----------------------------------------------------------------------*/
  Future getBindpayHistoryEvents() async {
    String fabAddress = '';

    List<TransactionHistory> transactionHistory = [];
    await coreWalletDatabaseService
        .getWalletAddressByTickerName('FAB')
        .then((address) => fabAddress = address);

    String url = configService.getKanbanBaseUrl() + BindpayTxHHistoryApiRoute;
    Map<String, dynamic> body = {"fabAddress": fabAddress};

    log.i('getBindpayHistoryEvents url $url -- body $body');

    try {
      var response = await client.post(url, body: body);

      var json = jsonDecode(response.body);
      if (json != null) {
        log.w('getBindpayHistoryEvents json $json}');
        if (json['success']) {
          //   log.e('getTransactionHistoryEvents json ${json['data']}');
          var data = json['data'] as List;

          for (var element in data) {
            var holder = PayCoolHistory.fromJson(element);
            debugPrint(holder.toJson().toString());
            var timestamp = holder.time;

            var date =
                DateTime.fromMillisecondsSinceEpoch(timestamp * 1000).toLocal();
            String filteredDate =
                date.toString().substring(0, date.toString().length - 4);

            TransactionHistory tx = TransactionHistory(
                tickerChainTxStatus: holder.status.toString() ?? '',
                tag: holder.type ?? '',
                tickerChainTxId: holder.txid ?? '',
                date: filteredDate ?? '',
                tickerName: holder.coin ?? '',
                quantity: holder.amount ?? 0.0);

            transactionHistory.add(tx);
          }

          for (var element in transactionHistory) {
            log.e('getTransactionHistoryEvents length ${element.toJson()}');
          }
        }
      }
      return transactionHistory;
    } catch (err) {
      log.e('getTransactionHistoryEvents CATCH $err');

      throw Exception(err);
    }
  }

  /*<---------------------------------------    ---------------             
                        WALLET Futures
    ----------------------------------------    --------------*/

  Future withdrawTxStatus() async {
    String exgAddress =
        await sharedService.getExgAddressFromCoreWalletDatabase();
    //  String exgAddress = await getExchangilyAddress();
    String url = configService.getKanbanBaseUrl() +
        WithdrawTxStatusApiRoute +
        exgAddress;
    log.e('withdrawTxStatus url $url');

    try {
      var response = await client.get(url);
      var json = jsonDecode(response.body);
      if (json != null) {
        log.e('withdrawTxStatus $json}');
        return json;
      }
    } catch (err) {
      log.e('withdrawTxStatus CATCH $err');
      throw Exception(err);
    }
  }

/*----------------------------------------------------------------------
                    Get All coin exchange balance
----------------------------------------------------------------------*/
  Future<List<ExchangeBalanceModel>> getAssetsBalance(String exgAddress) async {
    if (exgAddress.isEmpty) {
      exgAddress = await sharedService.getExgAddressFromCoreWalletDatabase();
    }
    ExchangeBalanceModelList exchangeBalanceList;
    String url =
        configService.getKanbanBaseUrl() + AssetsBalanceApiRoute + exgAddress;
    log.i('get assets balance url $url');
    try {
      final res = await client.get(url);
      if (res.statusCode == 200 || res.statusCode == 201) {
        var json = jsonDecode(res.body) as List;
        log.w('getAssetsBalance json $json');
        exchangeBalanceList = ExchangeBalanceModelList.fromJson(json);
      }
      return exchangeBalanceList.balances;
    } catch (e) {
      log.e('getAssetsBalance Failed to load the data from the API, $e');
      return null;
    }
  }

/*----------------------------------------------------------------------
                    Get single coin exchange balance
----------------------------------------------------------------------*/
  Future<ExchangeBalanceModel> getSingleCoinExchangeBalance(
      String tickerName) async {
    String exgAddress =
        await sharedService.getExgAddressFromCoreWalletDatabase();
    //  String exgAddress = await getExchangilyAddress();
    String url = configService.getKanbanBaseUrl() +
        GetSingleCoinExchangeBalApiRoute +
        exgAddress +
        '/' +
        tickerName;
    log.e('getSingleCoinExchangeBalance url $url');
    ExchangeBalanceModel exchangeBalance;
    try {
      var response = await client.get(url);
      var json = jsonDecode(response.body);
      if (json != null) {
        exchangeBalance = ExchangeBalanceModel.fromJson(json);
        log.e('exchangeBalance ${exchangeBalance.toJson()}');
      }
      return exchangeBalance;
    } catch (err) {
      log.e('getSingleCoinExchangeBalance CATCH $err');
      throw Exception(err);
    }
  }

/*----------------------------------------------------------------------
                    Get Token List Updates
----------------------------------------------------------------------*/

  Future<List<TokenModel>> getTokenListUpdates() async {
    String url = configService.getKanbanBaseUrl() + GetTokenListUpdatesApiRoute;
    log.i('getTokenListUpdates url $url');
    try {
      var response = await client.get(url);
      var json = jsonDecode(response.body);
      var data = json['data'];
      var parsedTokenList = data as List;
      log.w('getTokenListUpdates  $parsedTokenList');
      TokenList tokenList = TokenList.fromJson(parsedTokenList);
      return tokenList.tokens;
    } catch (err) {
      log.e('getTokenList CATCH $err');
      throw Exception(err);
    }
  }

/*----------------------------------------------------------------------
                    Get Token List
----------------------------------------------------------------------*/

  Future<List<TokenModel>> getTokenList() async {
    String url = configService.getKanbanBaseUrl() + GetTokenListApiRoute;
    log.i('getTokenList url $url');
    try {
      var response = await client.get(url);
      var json = jsonDecode(response.body);
      var data = json['data'];
      var parsedTokenList = data['tokenList'] as List;
      log.w('getTokenList  $parsedTokenList');
      TokenList tokenList = TokenList.fromJson(parsedTokenList);
      return tokenList.tokens;
    } catch (err) {
      log.e('getTokenList CATCH $err');
      throw Exception(err);
    }
  }

/*----------------------------------------------------------------------
                    Get app version
----------------------------------------------------------------------*/

  Future getApiAppVersion() async {
    String url = configService.getKanbanBaseUrl() + GetAppVersionRoute;
    log.i('getApiAppVersion url $url');
    try {
      var response = await client.get(url);

      log.w('getApiAppVersion  ${response.body}');
      return response.body;
    } catch (err) {
      log.e('getApiAppVersion $err');
      throw Exception(err);
    }
  }

/*----------------------------------------------------------------------
                    Post free fab
----------------------------------------------------------------------*/

  Future postFreeFab(data) async {
    try {
      var response = await client.post(postFreeFabUrl, body: data);
      var json = jsonDecode(response.body);
      log.w(json);
      return json;
    } catch (err) {
      log.e('postFreeFab $err');
      throw Exception(err);
    }
  }

/*----------------------------------------------------------------------
                    Get free fab
----------------------------------------------------------------------*/

  Future getFreeFab(String address) async {
    String ipAddress;
    await NetworkInterface.list(type: InternetAddressType.IPv4)
        .then((networkData) => ipAddress = networkData[0].addresses[0].address);

    String url = getFreeFabUrl + address + '/' + ipAddress.toString();

    log.i('getFreeFab url $url');
    try {
      var response = await client.get(url);
      var json = jsonDecode(response.body);
      log.w('getFreeFab json $json');
      return json;
    } catch (err) {
      log.e('getFreeFab $err');
      throw Exception(err);
    }
  }

  Future getEthGasPrice() async {
    var ethBaseUrl = environment['endpoints']['eth'];
    // _configService.getEthBaseUrl();
    var url = ethBaseUrl + 'getgasprice';
    var ethGasPrice = 0;
    try {
      var response = await client.get(url);
      var json = jsonDecode(response.body);
      log.w(' getEthGasPrice $json');
      debugPrint((BigInt.parse(json['gasprice']) / BigInt.parse('1000000000'))
          .toDouble()
          .toString());
      ethGasPrice =
          (BigInt.parse(json['gasprice']) / BigInt.parse('1000000000'))
              .toDouble()
              .round();
    } catch (err) {
      log.e('In getEthGasPrice catch $err');
    }

    if (ethGasPrice < environment['chains']['ETH']['gasPrice']) {
      ethGasPrice = environment['chains']['ETH']['gasPrice'];
    }

    if (ethGasPrice > environment['chains']['ETH']['gasPriceMax']) {
      ethGasPrice = environment['chains']['ETH']['gasPriceMax'];
    }
    debugPrint('ethGasPrice=====');
    debugPrint(ethGasPrice.toString());
    return ethGasPrice;
  }
/*----------------------------------------------------------------------
                      Transaction status
----------------------------------------------------------------------*/

  Future getTransactionStatus(String transactionId) async {
    var url = configService.getKanbanBaseUrl() + 'checkstatus/' + transactionId;
    log.e(url);
    try {
      var response = await client.get(url);
      var json = jsonDecode(response.body);
      log.w(' getDepositTransactionStatus $json');
      return json;
    } catch (err) {
      log.e('In getDepositTransactionStatus catch $err');
    }
  }

/*-------------------------------------------------------------------------------------
                      Get all wallet balance
-------------------------------------------------------------------------------------*/

  Future<List<WalletBalance>> getSingleWalletBalance(String fabAddress,
      String tickerName, String thirdPartyChainAddress) async {
    String url = configService.getKanbanBaseUrl() + SingleWalletBalanceApiRoute;
    log.i('getWalletBalance URL $url');
    var body = {
      "fabAddress": fabAddress,
      "tickerName": tickerName,
      "thirdPartyChainAddress": thirdPartyChainAddress,
      "showEXGAssets": "true"
    };
    log.i('getWalletBalance body $body');

    WalletBalanceList balanceList;
    try {
      var response = await client.post(url, body: body);
      bool success = jsonDecode(response.body)['success'];
      if (success == true) {
        var jsonList = jsonDecode(response.body)['data'] as List;
        log.i('json list getWalletBalance $jsonList');
        // List newList = [];
        // jsonList.forEach((element) {
        //   if (element['balance'] != null) newList.add(element);
        // });
        // log.i('single getWalletBalance $newList');
        balanceList = WalletBalanceList.fromJson(jsonList);
      } else {
        log.e('get single wallet balance returning null');
        return null;
      }
      return balanceList.walletBalances;
    } catch (err) {
      log.e('In getWalletBalance catch $err');
      return null;
    }
  }

/*-------------------------------------------------------------------------------------
                      Get all wallet balance
-------------------------------------------------------------------------------------*/

  Future<List<WalletBalance>> getWalletBalance(body) async {
    String url = configService.getKanbanBaseUrl() + WalletBalancesApiRoute;
    log.i('getWalletBalance URL $url');
    log.i('getWalletBalance body $body');

    WalletBalanceList balanceList;
    try {
      var response = await client.post(url, body: body);
      bool success = jsonDecode(response.body)['success'];
      if (success == true) {
        var jsonList = jsonDecode(response.body)['data'] as List;
        //  log.i('json list getWalletBalance $jsonList');
        List newList = [];
        for (var element in jsonList) {
          if (element['balance'] != null) newList.add(element);
        }
        log.i('newList getWalletBalance $newList');
        balanceList = WalletBalanceList.fromJson(newList);
      } else {
        log.e('get wallet balances returning null');
        return null;
      }
      return balanceList.walletBalances;
    } catch (err) {
      log.e('In getWalletBalance catch $err');
      return null;
    }
  }

/*----------------------------------------------------------------------
                Get Current Market Price For The Coin By Name
----------------------------------------------------------------------*/

  Future<double> getCoinMarketPriceByTickerName(String tickerName) async {
    double currentTickerUsdValue = 0;
    if (tickerName == 'DUSD') {
      return currentTickerUsdValue = 1.0;
    }
    await getCoinCurrencyUsdPrice().then((res) {
      if (res != null) {
        currentTickerUsdValue = res['data'][tickerName]['USD'].toDouble();
      }
    });
    return currentTickerUsdValue;
  }

/*-------------------------------------------------------------------------------------
                      Get coin currency Usd Prices
-------------------------------------------------------------------------------------*/

  Future getCoinCurrencyUsdPrice() async {
    try {
      String url =
          configService.getKanbanBaseUrl() + CoinCurrencyUsdValueApiRoute;
      log.e('getCoinCurrencyUsdPrice $url');
      var response = await client.get(url);
      var json = jsonDecode(response.body);
      log.w('getCoinCurrencyUsdPrice $json');
      return json;
    } catch (err) {
      log.e('In getCoinCurrencyUsdPrice catch $err');
    }
  }

  // Get Coin Usd Price ( OLD way to get the market price)

  // Future getCoinsUsdValue() async {
  //   final res = await http.get(usdCoinPriceUrl);
  //   if (res.statusCode == 200 || res.statusCode == 201) {
  //     return jsonDecode(res.body);
  //   }
  //   return log.e('getCoinsUsdValue Failed to load the data from the API');
  // }

  // Get Gas Balance
  Future getGasBalance(String exgAddress) async {
    try {
      String url = configService.getKanbanBaseUrl() +
          kanbanApiRoute +
          GetBalanceApiRoute +
          exgAddress;
      log.i('getGasBalance: url $url');
      final res = await client.get(url);
      log.w(jsonDecode(res.body));
      if (res.statusCode == 200 || res.statusCode == 201) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      log.e('getGasBalance Failed to load the data from the API $e');
    }
    return {};
  }

  // Get Orders by address
  Future getOrdersTest(String exgAddress) async {
    String url =
        configService.getKanbanBaseUrl() + OrdersByAddrApiRoute + exgAddress;
    log.w('get my orders url $url');
    try {
      throw Exception('Catch Exception');
    } catch (err) {
      log.e('getOrders Failed to load the data from the API， $err');
      throw Exception('Catch Exception $err');
    }
  }

  // Get Orders by tickername
  Future getMyOrdersPagedByFabHexAddressAndTickerName(
      String exgAddress, String tickerName) async {
    String url = configService.getKanbanBaseUrl() +
        GetOrdersByTickerApiRoute +
        exgAddress +
        '/' +
        tickerName;
    // String url = environment['endpoints']['kanban'] +
    //     'getordersbytickername/' +
    //     exgAddress +
    //     '/' +
    //     tickerName;
    log.i('getMyOrdersByTickerName url $url');
    try {
      final res = await client.get(url);
      debugPrint('after res ${res.body}');
      if (res.statusCode == 200 || res.statusCode == 201) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      log.e('getMyOrdersByTickerName Failed to load the data from the API， $e');
      throw Exception;
    }
  }

  // Get FabUtxos
  Future getFabUtxos(String address) async {
    var url = fabBaseUrl + GetUtxosApiRoute + address;
    log.w(url);
    var json;
    try {
      var response = await client.get(url);
      json = jsonDecode(response.body);
    } catch (e) {
      log.e(e);
    }
    return json;
  }

  // Get BtcUtxos
  Future getBtcUtxos(String address) async {
    var url = btcBaseUrl + GetUtxosApiRoute + address;
    log.w(url);
    var json;
    try {
      var response = await client.get(url);
      json = jsonDecode(response.body);
    } catch (e) {}
    return json;
  }

  // Get LtcUtxos
  Future getLtcUtxos(String address) async {
    var url = ltcBaseUrl + GetUtxosApiRoute + address;
    log.w(url);

    try {
      var response = await client.get(url);
      var json = jsonDecode(response.body);
      return json;
    } catch (e) {
      log.e('getLtcUtxos $e');
      throw Exception('e');
    }
  }

  Future getBchUtxos(String address) async {
    var url = bchBaseUrl + GetUtxosApiRoute + address;
    log.w(url);

    try {
      var response = await client.get(url);
      var json = jsonDecode(response.body);
      return json;
    } catch (e) {
      log.e('getBchUtxos $e');
      throw Exception('e');
    }
  }

  // Get DogeUtxos
  Future getDogeUtxos(String address) async {
    var url = dogeBaseUrl + GetUtxosApiRoute + address;
    log.w(url);

    try {
      var response = await client.get(url);
      var json = jsonDecode(response.body);
      return json;
    } catch (e) {
      log.e('getDogeUtxos $e');
      throw Exception('e');
    }
  }

  // Post Btc Transaction
  Future postBtcTx(String txHex) async {
    var url = btcBaseUrl + PostRawTxApiRoute;
    var json;
    var txHash = '';
    var errMsg = '';
    try {
      var data = {'rawtx': txHex};
      var response = await client.post(url, body: data);

      json = jsonDecode(response.body);
    } catch (e) {}

    log.w('json= $json');
    if (json != null) {
      if (json['txid'] != null) {
        txHash = '0x' + json['txid'];
      } else if (json['Error'] != null) {
        errMsg = json['Error'];
      }
    } else {
      errMsg = 'invalid json format.';
    }
    return {'txHash': txHash, 'errMsg': errMsg};
  }

  // Post Ltc Transaction
  Future postLtcTx(String txHex) async {
    var url = ltcBaseUrl + PostRawTxApiRoute;
    var json;
    var txHash = '';
    var errMsg = '';
    try {
      var data = {'rawtx': txHex};
      var response = await client.post(url, body: data);

      json = jsonDecode(response.body);
      log.w('json= $json');
      if (json != null) {
        if (json['txid'] != null) {
          txHash = '0x' + json['txid'];
        } else if (json['Error'] != null) {
          errMsg = json['Error'];
        }
      } else {
        errMsg = 'invalid json format.';
      }
      return {'txHash': txHash, 'errMsg': errMsg};
    } catch (e) {
      log.e('postLtcTx $e');
    }
  }

  // Post Bch Transaction
  Future postBchTx(String txHex) async {
    var url = bchBaseUrl + PostRawTxApiRoute;
    var json;
    var txHash = '';
    var errMsg = '';
    try {
      var data = {'rawtx': txHex};
      var response = await client.post(url, body: data);

      json = jsonDecode(response.body);
      log.w('json= $json');
      if (json != null) {
        if (json['txid'] != null) {
          txHash = '0x' + json['txid'];
        } else if (json['Error'] != null) {
          errMsg = json['Error'];
        }
      } else {
        errMsg = 'invalid json format.';
      }
      return {'txHash': txHash, 'errMsg': errMsg};
    } catch (e) {
      log.e('postBchTx $e');
    }
  }

  // Post Ltc Transaction
  Future postDogeTx(String txHex) async {
    var url = dogeBaseUrl + PostRawTxApiRoute;
    var json;
    var txHash = '';
    var errMsg = '';
    try {
      var data = {'rawtx': txHex};
      var response = await client.post(url, body: data);

      json = jsonDecode(response.body);
      log.w('json= $json');
      if (json != null) {
        if (json['txid'] != null) {
          txHash = '0x' + json['txid'];
        } else if (json['Error'] != null) {
          errMsg = json['Error'];
        }
      } else {
        errMsg = 'invalid json format.';
      }
      return {'txHash': txHash, 'errMsg': errMsg};
    } catch (e) {
      log.e('postDogeTx $e');
    }
  }

  // Get Fab Transaction
  Future getFabTransactionJson(String txid) async {
    txid = string_utils.trimHexPrefix(txid);
    var url = fabBaseUrl + 'gettransactionjson/' + txid;
    var json;
    try {
      var response = await client.get(url);
      json = jsonDecode(response.body);
    } catch (e) {}
    return json;
  }

  // Eth Post
  Future postEthTx(String txHex) async {
    var url = ethBaseUrl + 'sendsignedtransaction';
    var data = {'signedtx': txHex};
    var errMsg = '';
    String txHash;
    try {
      var response =
          await client.post(url, headers: {"responseType": "text"}, body: data);
      txHash = response.body;

      if (txHash.contains('txerError')) {
        errMsg = txHash;
        txHash = '';
      }
    } catch (e) {
      errMsg = 'connection error';
    }
    return {'txHash': txHash, 'errMsg': errMsg};
  }

  // Fab Post Tx
  Future postFabTx(String txHex) async {
    var url = fabBaseUrl + PostRawTxApiRoute;
    var txHash = '';
    var errMsg = '';
    if (txHex != '') {
      var data = {'rawtx': txHex};
      try {
        var response = await client.post(url, body: data);

        var json = jsonDecode(response.body);
        if (json != null) {
          if ((json['txid'] != null) && (json['txid'] != '')) {
            txHash = json['txid'];
          } else if (json['Error'] != '') {
            errMsg = json['Error'];
          }
        }
      } catch (e) {
        errMsg = 'connection error';
      }
    }

    return {'txHash': txHash, 'errMsg': errMsg};
  }

  // Eth Nonce
  Future getEthNonce(String address) async {
    var url = ethBaseUrl + GetNonceApiRoute + address + '/latest';
    var nonce = 0;
    try {
      var response = await client.get(url);
      nonce = int.parse(response.body);
    } catch (e) {}
    return nonce;
  }

/*----------------------------------------------------------------------
                  Get Decimal configuration for the coins
----------------------------------------------------------------------*/
  Future<List<PairDecimalConfig>> getPairDecimalConfig() async {
    List<PairDecimalConfig> result = [];
    var url = configService.getKanbanBaseUrl() + GetDecimalPairConfigApiRoute;
    log.e('getPairDecimalConfig $url');
    try {
      var response = await client.get(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonList = jsonDecode(response.body) as List;
        log.w(' getPairDecimalConfig $jsonList');
        PairDecimalConfigList pairList =
            PairDecimalConfigList.fromJson(jsonList);
        result = pairList.pairList;
      }
      return result;
    } catch (err) {
      log.e('In getPairDecimalConfig catch $err');
      return null;
    }
  }

/*----------------------------------------------------------------------
                            Campaign
----------------------------------------------------------------------*/

  Future getSliderImages() async {
    try {
      final res = await client.get(
          // kanbanBaseUrl + "/kanban/getadvconfig"
          configService.getKanbanBaseUrl() + "kanban/getadvconfig");
      log.w(' get slider images ${jsonDecode(res.body)}');
      if (res.statusCode == 200 || res.statusCode == 201) {
        var json = jsonDecode(res.body) as List;
        return json;
      }
    } catch (e) {
      log.e('getSliderImages Failed to load the data from the API $e');
      return "error";
    }
    return "error";
  }

  Future getAnnouncement(lang) async {
    final langcode = lang == "en" ? "en" : "sc";
    final url = baseBlockchainGateV2Url + "announcements/language/" + langcode;

    log.w("Calling api: getAnnouncement " + lang);
    log.i("url: " + url);
    try {
      final res = await client.get(url);
      log.w('getAnnouncement ${jsonDecode(res.body)}');
      if (res.statusCode == 200 || res.statusCode == 201) {
        var body = jsonDecode(res.body)['body'];
        return body;
      }
    } catch (e) {
      log.e('getAnnouncement Failed to load the data from the API $e');
      return "error";
    }
    return "error";
  }

  Future getEvents() async {
    log.i("getEvents Url: " +
        configService.getKanbanBaseUrl() +
        "kanban/getCampaigns");
    try {
      final res = await client.get(
          // "http://192.168.0.12:4000/kanban/getCampaigns"
          configService.getKanbanBaseUrl() + "kanban/getCampaigns");
      log.w('getEvents ${jsonDecode(res.body)}');
      if (res.statusCode == 200 || res.statusCode == 201) {
        debugPrint("success");
        return jsonDecode(res.body);
      } else {
        log.e("error: " + res.body);
        return "error";
      }
    } catch (e) {
      log.e('getEvents failed to load the data from the API $e');
      return "error";
    }
  }

  //get a single event detailed information
  Future postEventSingle(id) async {
    debugPrint("Calling api: getEventSingle");
    try {
      final res = await client.post(
        // "http://192.168.0.12:4000/kanban/getCampaignSingle",
        configService.getKanbanBaseUrl() + "kanban/getCampaignSingle",
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'id': id,
        }),
      );
      log.w(jsonDecode(res.body));
      if (res.statusCode == 200 || res.statusCode == 201) {
        debugPrint("success");
        return jsonDecode(res.body);
      } else {
        debugPrint("error");
        return ["error"];
      }
    } catch (e) {
      log.e('getEventSingle failed to load the data from the API $e');
    }
    return {};
  }
}