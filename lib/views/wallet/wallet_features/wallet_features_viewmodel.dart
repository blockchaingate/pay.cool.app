/*
* Copyright (c) 2020 Exchangily LLC
*
* Licensed under Apache License v2.0
* You may obtain a copy of the License at
*
*      https://www.apache.org/licenses/LICENSE-2.0
*
*----------------------------------------------------------------------
* Author: barry-ruprai@exchangily.com, ken.qiu@exchangily.com
*----------------------------------------------------------------------
*/

import 'dart:convert';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/environments/coins.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/models/wallet/wallet.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/api_service.dart';
import 'package:paycool/services/coin_service.dart';
import 'package:paycool/services/db/token_list_database_service.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:paycool/utils/wallet/wallet_util.dart';
import 'package:stacked/stacked.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:stacked_services/stacked_services.dart';

class WalletFeaturesViewModel extends ReactiveViewModel {
  final log = getLogger('WalletFeaturesViewModel');

  WalletInfo? get walletInfo => walletService.walletInfoDetails;
  WalletService walletService = locator<WalletService>();
  final storageService = locator<LocalStorageService>();
  ApiService apiService = locator<ApiService>();
  SharedService sharedService = locator<SharedService>();
  NavigationService navigationService = locator<NavigationService>();
  final tokenListDatabaseService = locator<TokenListDatabaseService>();
  final coinService = locator<CoinService>();
  final double elevation = 5;
  double containerWidth = 150;
  double containerHeight = 115;
  late double walletBalance;
  late BuildContext context;
  var errDepositItem;
  String? get specialTicker => walletService.specialTickerName;
  List<WalletFeatureName> features = [];
  bool isFavorite = false;
  List<String> iconImg = [
    "coin_in.png",
    "coin_out.png",
    "stock-market.png",
    "cash-back.png",
    "redeposit.png",
    "contract.png"
  ];
  int decimalLimit = 6;
  double unconfirmedBalance = 0.0;
  String smartContractAddress = '';

  init() async {
    getWalletFeatures();
    getErrDeposit();

    log.i('wi object to check name ${walletInfo!.toJson()}');
    refreshBalance();
    checkIfCoinIsFavorite();

    if (smartContractAddress.isEmpty)
      await coinService.getSingleTokenData(walletInfo!.tickerName!).then((res) {
        decimalLimit = res!.decimal!;
        smartContractAddress = res.contract!;
        log.w('decimal limit $decimalLimit');
        log.w('smart contract address $smartContractAddress');
      });
  }

  checkIfCoinIsFavorite() {
    String favCoinsJson = storageService.favWalletCoins;
    if (favCoinsJson.isNotEmpty) {
      List<String> favWalletCoins =
          (jsonDecode(favCoinsJson) as List<dynamic>).cast<String>();

      if (favWalletCoins.contains(walletInfo!.tickerName)) {
        setBusy(true);
        isFavorite = true;
        setBusy(false);
      }
    }
  }

  updateFavWalletCoinsList(String tickerName) {
    List<String> favWalletCoins = [];
    String favCoinsJson = storageService.favWalletCoins;
    debugPrint(favCoinsJson);
    if (favCoinsJson.isNotEmpty) {
      favWalletCoins =
          (jsonDecode(favCoinsJson) as List<dynamic>).cast<String>();
      for (var favTickerName in favWalletCoins) {
        if (favTickerName == tickerName) {}
      }
      if (favWalletCoins.contains(tickerName)) {
        favWalletCoins
            .removeWhere((favTickerName) => favTickerName == tickerName);
        setBusy(true);
        isFavorite = false;
        setBusy(false);
      } else {
        favWalletCoins.add(tickerName);
        setBusy(true);
        isFavorite = true;
        setBusy(false);
      }
    } else {
      favWalletCoins.add(tickerName);
      setBusy(true);
      isFavorite = true;
      setBusy(false);
    }
    storageService.favWalletCoins = json.encode(favWalletCoins);
  }

  getWalletFeatures() {
    return features = [
      WalletFeatureName(FlutterI18n.translate(context, "receive"),
          Icons.arrow_downward, 'receive', Colors.cyan),
      WalletFeatureName(FlutterI18n.translate(context, "send"),
          Icons.arrow_upward, 'send', Colors.lightBlue),
      // move and trade = move to exchange
      WalletFeatureName(FlutterI18n.translate(context, "moveAndTrade"),
          Icons.equalizer, 'deposit', Colors.deepOrange),
      // withdraw to wallet  = move to wallet
      WalletFeatureName(FlutterI18n.translate(context, "withdrawToWallet"),
          Icons.exit_to_app, 'withdraw', Colors.purple),
      WalletFeatureName(FlutterI18n.translate(context, "confirmDeposit"),
          Icons.vertical_align_bottom, 'redeposit', Colors.redAccent),
      WalletFeatureName(FlutterI18n.translate(context, "smartContract"),
          Icons.layers, 'smartContract', Colors.lightBlue),
      WalletFeatureName(FlutterI18n.translate(context, "transactionHistory"),
          Icons.history, TransactionHistoryViewRoute, Colors.lightBlue),
    ];
  }

  Future getErrDeposit() async {
    var address = await sharedService.getExgAddressFromCoreWalletDatabase();
    await walletService.getErrDeposit(address).then((result) async {
      if (result != null) {
        for (var i = 0; i < result.length; i++) {
          var item = result[i];
          var coinType = item['coinType'];
          String tickerNameByCointype = newCoinTypeMap[coinType] ?? '';
          if (tickerNameByCointype.isEmpty) {
            await tokenListDatabaseService.getAll().then((tokenList) {
              if (tokenList.isNotEmpty) {
                tickerNameByCointype = tokenList
                    .firstWhere((element) => element.coinType == coinType)
                    .tickerName!;
              }
            });
          }
          log.w('tickerNameByCointype $tickerNameByCointype');
          if (tickerNameByCointype == walletInfo!.tickerName) {
            setBusy(true);
            errDepositItem = item;
            log.w('err deposit item $errDepositItem');
            setBusy(false);
            break;
          }
        }

        log.i('getErrDeposit $result');
      }
    });
  }

  refreshBalance() async {
    setBusy(true);
    unconfirmedBalance = 0.0;
    String fabAddress =
        await sharedService.getFabAddressFromCoreWalletDatabase();
    //  await getExchangeBal();
    await apiService
        .getSingleWalletBalance(
            fabAddress, walletInfo!.tickerName!, walletInfo!.address!)
        .then((walletBalance) async {
      var availableBalance = walletBalance[0].balance;
      walletInfo!.availableBalance = availableBalance;
      var lockedBalance = walletBalance[0].lockBalance;
      walletInfo!.lockedBalance = lockedBalance;
      unconfirmedBalance = walletBalance[0].unconfirmedBalance!;
      if (!specialTicker!.contains('(')) {
        walletInfo!.inExchange = walletBalance[0].unlockedExchangeBalance;
      } else {
        await getExchangeBalForSpecialTokens();
      }
      double currentUsdValue = walletBalance[0].usdValue!.usd!;
      log.e(
          'market price $currentUsdValue -- available bal $availableBalance -- inExchange ${walletInfo!.inExchange} -- locked bal $lockedBalance');
      walletInfo!.usdValue = walletService.calculateCoinUsdBalance(
          currentUsdValue, availableBalance!, lockedBalance!);
      log.w(walletInfo!.toJson());
      unconfirmedBalance = walletBalance[0].unconfirmedBalance!;
    })
        // await walletService
        //     .coinBalanceByAddress(
        //         walletInfo!.tickerName, walletInfo!.address, walletInfo!.tokenType)
        //     .then((data) async {
        //   if (data != null) {
        //     log.e('data $data');

        //     walletBalance = data['tokenBalanceIe18'];
        //     double walletLockedBal = data['lockbalance'];
        //     walletInfo!.availableBalance = walletBalance;
        //     double currentUsdValue = await walletService
        //         .getCoinMarketPriceByTickerName(walletInfo!.tickerName);
        //     walletService.calculateCoinUsdBalance(
        //         currentUsdValue, walletBalance, walletLockedBal);
        //     walletInfo!.usdValue = walletService.coinUsdBalance;
        //   }
        //   await getExchangeBal();
        // })
        .catchError((err) {
      log.e(err);
      setBusy(false);
      throw Exception(err);
    });
    setBusy(false);
  }

  // get exchange balance for single coin
  getExchangeBalForSpecialTokens() async {
    String tickerName = '';
    if (walletInfo!.tickerName == 'DSCE' || walletInfo!.tickerName == 'DSC') {
      tickerName = 'DSC';
    } else if (walletInfo!.tickerName == 'BSTE' ||
        walletInfo!.tickerName == 'BST') {
      tickerName = 'BST';
    } else if (walletInfo!.tickerName == 'FABE' ||
        walletInfo!.tickerName == 'FAB') {
      tickerName = 'FAB';
    } else if (walletInfo!.tickerName == 'EXGE' ||
        walletInfo!.tickerName == 'EXG') {
      tickerName = 'EXG';
    } else if (WalletUtil.isSpecialUsdt(walletInfo!.tickerName!)) {
      tickerName = 'USDT';
    } else if (WalletUtil.isSpecialUsdc(walletInfo!.tickerName!)) {
      tickerName = 'USDC';
    } else {
      tickerName = walletInfo!.tickerName!;
    }
    await apiService.getSingleCoinExchangeBalance(tickerName).then((res) {
      if (res != null) {
        walletInfo!.inExchange = res.unlockedAmount;
        log.w('exchange bal ${walletInfo!.inExchange}');
      }
    });
  }

  @override
  List<ListenableServiceMixin> get listenableServices => [walletService];
}
