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

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/constants/ui_var.dart';
import 'package:paycool/environments/coins.dart';
import 'package:paycool/models/wallet/core_wallet_model.dart';
import 'package:paycool/models/wallet/token_model.dart';
import 'package:paycool/models/wallet/wallet.dart';
import 'package:paycool/models/wallet/wallet_balance.dart';
import 'package:paycool/services/api_service.dart';
import 'package:paycool/services/db/core_wallet_database_service.dart';
import 'package:paycool/services/db/decimal_config_database_service.dart';
import 'package:paycool/services/db/token_list_database_service.dart';
import 'package:paycool/services/db/user_settings_database_service.dart';
import 'package:paycool/services/db/wallet_database_service.dart';
//import 'package:paycool/services/dialog_service.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/services/navigation_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/services/version_service.dart';
import 'package:paycool/shared/ui_helpers.dart';

import 'package:paycool/utils/fab_util.dart';
import 'package:paycool/utils/number_util.dart';
import 'package:paycool/utils/tron_util/trx_generate_address_util.dart'
    as TronAddressUtil;
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/wallet_service.dart';

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:overlay_support/overlay_support.dart';

import 'package:paycool/utils/wallet/wallet_util.dart';
// import 'package:showcaseview/showcaseview.dart';
import 'package:stacked/stacked.dart';

import '../../services/local_dialog_service.dart';

//import 'package:json_diff/json_diff.dart';

class WalletDashboardViewModel extends BaseViewModel {
  final log = getLogger('WalletDashboardViewModel');

  WalletService walletService = locator<WalletService>();
  SharedService sharedService = locator<SharedService>();

  final NavigationService navigationService = locator<NavigationService>();
  final DecimalConfigDatabaseService decimalConfigDatabaseService =
      locator<DecimalConfigDatabaseService>();
  ApiService apiService = locator<ApiService>();
  WalletDatabaseService walletDatabaseService =
      locator<WalletDatabaseService>();
  TokenListDatabaseService tokenListDatabaseService =
      locator<TokenListDatabaseService>();
  var storageService = locator<LocalStorageService>();
  final dialogService = locator<LocalDialogService>();
  final userDatabaseService = locator<UserSettingsDatabaseService>();
  var versionService = locator<VersionService>();
  var coreWalletDatabaseService = locator<CoreWalletDatabaseService>();

  BuildContext context;

  WalletInfo rightWalletInfo;

  final double elevation = 5;
  String totalUsdBalance = '';

  double gasAmount = 0;
  String exgAddress = '';

  bool isHideSmallAssetsButton = false;
  var refreshController;
  bool isConfirmDeposit = false;
  WalletInfo confirmDepositCoinWallet;

  var lang;

  var top = 0.0;
  final freeFabAnswerTextController = TextEditingController();
  String postFreeFabResult = '';
  bool isFreeFabNotUsed = false;
  double fabBalance = 0.0;
  // List<String> formattedUsdValueList = [];
  // List<String> formattedUsdValueListCopy = [];

  final searchCoinTextController = TextEditingController();
  // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  //     FlutterLocalNotificationsPlugin();

  //vars for announcement
  bool hasApiError = false;
  List announceList;
  GlobalKey globalKeyOne;
  GlobalKey globalKeyTwo;
  double totalBalanceContainerWidth = 100.0;

  bool _isShowCaseView = false;
  get isShowCaseView => _isShowCaseView;

  int unreadMsgNum = 0;
  bool isUpdateWallet = false;
  List<WalletBalance> wallets = [];
  List<WalletBalance> walletsCopy = [];
  List<WalletBalance> favWallets = [];
  bool isShowFavCoins = false;
  int currentTabSelection = 0;
  ScrollController walletsScrollController = ScrollController();
  int minusHeight = 25;

  bool isBottomOfTheList = false;
  bool isTopOfTheList = true;

  List<String> slivers = ['1', '2', '3', '4', '5', '6', '7'];
  var fabUtils = FabUtils();
  var walletUtil = WalletUtil();
  String totalWalletBalance = '';
  String totalLockedBalance = '';
  String totalExchangeBalance = '';
  var coinsToHideList = ["USDTB"];
/*----------------------------------------------------------------------
                    INIT
----------------------------------------------------------------------*/

  init() async {
    setBusy(true);

    sharedService.context = context;
    await refreshBalancesV2();

    showDialogWarning();

    getConfirmDepositStatus();
    //buildFavCoinListV1();
    currentTabSelection = storageService.isFavCoinTabSelected ? 1 : 0;

    walletService.storeTokenListInDB();

    setBusy(false);
    await versionService.checkVersion(context, isForceUpdate: true);
  }

  assignDefaultWalletForIos() async {
    rightWalletInfo =
        await walletUtil.getWalletInfoObjFromWalletBalance(wallets[3]);
  }

  // moveDown() {
  //   walletsScrollController.animateTo(
  //       walletsScrollController.offset +
  //           walletsScrollController.position.maxScrollExtent,
  //       curve: Curves.linear,
  //       duration: Duration(milliseconds: 500));
  // }

  // moveUp() {
  //   walletsScrollController.animateTo(
  //       walletsScrollController.offset +
  //           walletsScrollController.position.minScrollExtent,
  //       curve: Curves.linear,
  //       duration: Duration(milliseconds: 500));
  // }

  routeWithWalletInfoArgs(WalletBalance wallet, String routeName) async {
    // assign address from local DB to walletinfo object
    context ??= sharedService.context;
    if (MediaQuery.of(context).size.width < largeSize) {
      FocusScope.of(context).requestFocus(FocusNode());
      var walletInfo =
          await walletUtil.getWalletInfoObjFromWalletBalance(wallet);

      log.w('routeWithWalletInfoArgs walletInfo ${walletInfo.toJson()}');
      searchCoinTextController.clear();
      // navigate accordingly
      navigationService.navigateTo(routeName, arguments: walletInfo);
    } else {
      rightWalletInfo =
          await walletUtil.getWalletInfoObjFromWalletBalance(wallet);
      (context as Element).markNeedsBuild();
    }
  }

  _scrollListener() {
    walletsScrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (walletsScrollController.hasClients) {
        if (walletsScrollController.offset >=
                walletsScrollController.position.maxScrollExtent &&
            !walletsScrollController.position.outOfRange) {
          setBusy(true);
          debugPrint('bottom');

          isBottomOfTheList = true;
          isTopOfTheList = false;
          minusHeight = 50;
          setBusy(false);
        }
        if (walletsScrollController.offset <=
                walletsScrollController.position.minScrollExtent &&
            !walletsScrollController.position.outOfRange) {
          setBusy(true);
          debugPrint('top');
          isTopOfTheList = true;
          isBottomOfTheList = false;
          minusHeight = 25;
          setBusy(false);
        }
        if (walletsScrollController.position.outOfRange) {
          debugPrint('bot in');
        }
      }
    });
  }

  updateTabSelection(int tabIndex) {
    setBusy(true);
    if (tabIndex == 0) {
      isShowFavCoins = false;
    } else {
      isShowFavCoins = true;
    }

    currentTabSelection = tabIndex;
    storageService.isFavCoinTabSelected = isShowFavCoins ? true : false;
    debugPrint(
        'current tab sel $currentTabSelection -- isShowFavCoins $isShowFavCoins');
    setBusy(false);
  }

/*----------------------------------------------------------------------
                    Search Coins By TickerName
----------------------------------------------------------------------*/
  searchFavCoinsByTickerName(String value) async {
    setBusyForObject(favWallets, true);
    var favWalletInfoListCopy = favWallets;
    debugPrint('length ${favWallets.length} -- value $value');
    try {
      for (var i = 0; i < favWalletInfoListCopy.length; i++) {
        debugPrint(
            'favWalletInfoList ${favWallets[i].coin == value.toUpperCase()}');
        if (favWalletInfoListCopy[i].coin == value.toUpperCase()) {
          favWallets = [];
          log.i('favWalletInfoListCopy ${favWalletInfoListCopy[i].toJson()}');
          favWallets.add(favWalletInfoListCopy[i]);
          setBusyForObject(favWallets, false);
          break;
        } else {
          favWallets = [];
          favWallets = favWalletInfoListCopy;
          break;
        }
      }
      // tabBarViewHeight = MediaQuery.of(context).viewInsets.bottom == 0
      //     ? MediaQuery.of(context).size.height / 2 - 250
      //     : MediaQuery.of(context).size.height / 2;
      debugPrint('favWalletInfoList length ${favWallets.length}');
    } catch (err) {
      setBusyForObject(favWallets, false);
      log.e('searchFavCoinsByTickerName CATCH');
    }

    setBusyForObject(favWallets, false);
  }

/*----------------------------------------------------------------------
                    Build Fav Coins List
----------------------------------------------------------------------*/

  buildFavCoinListV1() async {
    setBusyForObject(favWallets, true);
    isShowFavCoins = true;
    favWallets.clear();
    String favCoinsJson = storageService.favWalletCoins;
    if (favCoinsJson != null && favCoinsJson != '') {
      List<String> favWalletCoins =
          (jsonDecode(favCoinsJson) as List<dynamic>).cast<String>();

      var wallets = await refreshBalancesV2();

      for (var i = 0; i < favWalletCoins.length; i++) {
        for (var j = 0; j < wallets.length; j++) {
          if (wallets[j].coin == favWalletCoins[i].toString()) {
            favWallets.add(wallets[j]);
            break;
          }
        }
      }
      log.w('favWalletInfoList length ${favWallets.length}');
    }
    setBusyForObject(favWallets, false);
  }

  // buildFavCoinList() async {
  //   setBusyForObject(favWalletInfoList, true);

  //   favWalletInfoList.clear();
  //   String favCoinsJson = storageService.favWalletCoins;
  //   if (favCoinsJson != null && favCoinsJson != '') {
  //     List<String> favWalletCoins =
  //         (jsonDecode(favCoinsJson) as List<dynamic>).cast<String>();

  //     List<WalletInfo> walletsFromDb = [];
  //     await walletDatabaseService
  //         .getAll()
  //         .then((wallets) => walletsFromDb = wallets);

  //     //  try {
  //     for (var i = 0; i < favWalletCoins.length; i++) {
  //       for (var j = 0; j < walletsFromDb.length; j++) {
  //         if (walletsFromDb[j].tickerName == favWalletCoins[i].toString()) {
  //           favWalletInfoList.add(walletsFromDb[j]);
  //           break;
  //         }
  //       }
  //       // log.i('favWalletInfoList ${favWalletInfoList[i].toJson()}');
  //     }
  //     log.w('favWalletInfoList length ${favWalletInfoList.length}');
  //     //  setBusy(false);
  //     //   return;
  //     // } catch (err) {
  //     //   log.e('favWalletCoins CATCH');
  //     //   setBusyForObject(favWalletInfoList, false);
  //     // }
  //   }
  //   setBusyForObject(favWalletInfoList, false);
  // }

/*----------------------------------------------------------------------
                            Move Trx Usdt
----------------------------------------------------------------------*/
  moveTronUsdt() async {
    try {
      var tronUsdtWalletObj =
          wallets.singleWhere((element) => element.coin == 'USDTX');
      if (tronUsdtWalletObj != null) {
        int tronUsdtIndex = wallets.indexOf(tronUsdtWalletObj);
        if (tronUsdtIndex != 5) {
          wallets.removeAt(tronUsdtIndex);
          wallets.insert(5, tronUsdtWalletObj);
        } else {
          log.i('2nd else move tronusdt tron usdt already at #5');
        }
      } else {
        log.w('1st else move tronusdt can\'t find tron usdt');
      }
    } catch (err) {
      log.e('movetronusdt Catch $err');
    }
  }

  moveTron() {
    try {
      var tronWalletObj =
          wallets.singleWhere((element) => element.coin == 'TRX');
      if (tronWalletObj != null) {
        int tronUsdtIndex = wallets.indexOf(tronWalletObj);
        if (tronUsdtIndex != 7) {
          wallets.removeAt(tronUsdtIndex);
          wallets.insert(7, tronWalletObj);
        } else {
          log.i('2nd else moveTron tron usdt already at #7');
        }
      } else {
        log.w('1st else moveTron cant find tron usdt');
      }
    } catch (err) {
      log.e('moveTron Catch $err');
    }
  }

/*----------------------------------------------------------------------
                            Fav Tab
----------------------------------------------------------------------*/

/*----------------------------------------------------------------------
                Update wallet with new native coins
----------------------------------------------------------------------*/

  checkToUpdateWallet() async {
    setBusy(true);
    String wallet =
        await coreWalletDatabaseService.getWalletAddressByTickerName('TRX');
    if (wallet != null) {
      log.w('$wallet TRX present');
      isUpdateWallet = false;
    } else {
      isUpdateWallet = true;
      // updateWallet();
      // showUpdateWalletDialog();
    }

    setBusy(false);
  }

/*---------------------------------------------------
          Update Info dialog
--------------------------------------------------- */

  showUpdateWalletDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Platform.isIOS
            ? Theme(
                data: ThemeData.dark(),
                child: CupertinoAlertDialog(
                  title: Container(
                    margin: const EdgeInsets.only(bottom: 5.0),
                    child: Center(
                        child: Text(
                      FlutterI18n.translate(context, "appUpdateNotice"),
                      style: headText4.copyWith(
                          color: primaryColor, fontWeight: FontWeight.w500),
                    )),
                  ),
                  content: Container(
                      child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                            updateWallet();
                          },
                          child: Text(
                              FlutterI18n.translate(context, "updateNow")))),
                  actions: const <Widget>[],
                ))
            : AlertDialog(
                titlePadding: EdgeInsets.zero,
                contentPadding: const EdgeInsets.all(5.0),
                elevation: 5,
                backgroundColor: walletCardColor.withOpacity(0.85),
                title: Container(
                  padding: const EdgeInsets.all(10.0),
                  color: secondaryColor.withOpacity(0.5),
                  child: Center(
                      child: Text(
                          FlutterI18n.translate(context, "appUpdateNotice"))),
                ),
                titleTextStyle: headText4.copyWith(fontWeight: FontWeight.bold),
                contentTextStyle: const TextStyle(color: grey),
                content: Container(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        OutlinedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  primaryColor)),
                          onPressed: () async {
                            //  Navigator.of(context).pop();
                            await updateWallet().then((res) {
                              if (res) Navigator.of(context).pop();
                            });
                          },
                          child: Text(
                              FlutterI18n.translate(context, "updateNow"),
                              style: headText5),
                        ),
                      ]),
                ));
      },
    );
  }

  // add trx if not present in wallet
  //Future<bool>
  updateWallet() async {
    setBusy(true);
    //  bool isSuccess = false;
    String mnemonic = '';
    await dialogService
        .showDialog(
            title: FlutterI18n.translate(context, "enterPassword"),
            description: FlutterI18n.translate(
                context, "dialogManagerTypeSamePasswordNote"),
            buttonTitle: FlutterI18n.translate(context, "confirm"))
        .then((res) async {
      if (res.confirmed) {
        mnemonic = res.returnedText;
        var address = TronAddressUtil.generateTrxAddress(mnemonic);
        WalletInfo wi = WalletInfo(
            id: null,
            tickerName: 'TRX',
            tokenType: '',
            address: address,
            availableBalance: 0.0,
            lockedBalance: 0.0,
            usdValue: 0.0,
            name: 'Tron');

        log.i("new wallet trx generated in update wallet ${wi.toJson()}");
        isUpdateWallet = false;
        await walletDatabaseService.insert(wi);
        await refreshBalancesV2();
        //   isSuccess = true;
      } else if (res.returnedText == 'Closed') {
        //  showUpdateWalletDialog();
        setBusy(false);
      }
    });
    setBusy(false);
    //return isSuccess;
  }

/*----------------------------------------------------------------------
                        Showcase Feature
----------------------------------------------------------------------*/
  showcaseEvent(BuildContext ctx) async {
    log.e(
        'Is showvcase: ${storageService.isShowCaseView} --- gas amount: $gasAmount');
    // if (!isBusy) setBusyForObject(isShowCaseView, true);
    //   _isShowCaseView = storageService.isShowCaseView;
    //   // if (!isBusy) setBusyForObject(isShowCaseView, false);
    //   if (isShowCaseView && !isBusy) {
    //     WidgetsBinding.instance.addPostFrameCallback((_) {
    //       ShowCaseWidget.of(ctx).startShowCase([globalKeyOne, globalKeyTwo]);
    //     });
    //   }
  }

  updateShowCaseViewStatus() {
    _isShowCaseView = false;
  }

/*----------------------------------------------------------------------
                        On Single Coin Card Click
----------------------------------------------------------------------*/

  onSingleCoinCardClick(index) async {
    if (MediaQuery.of(context).size.width < largeSize) {
      FocusScope.of(context).requestFocus(FocusNode());
      navigationService.navigateTo(WalletFeaturesViewRoute,
          arguments: wallets[index]);
      searchCoinTextController.clear();
    } else {
      rightWalletInfo =
          await walletUtil.getWalletInfoObjFromWalletBalance(wallets[index]);
      (context as Element).markNeedsBuild();
    }
  }

/*----------------------------------------------------------------------
                    Search Coins By TickerName
----------------------------------------------------------------------*/

  searchCoinsByTickerName(String value) async {
    setBusy(true);

    debugPrint('length ${walletsCopy.length} -- value $value');
    for (var i = 0; i < walletsCopy.length; i++) {
      if (walletsCopy[i].coin.toUpperCase() == value.toUpperCase()) {
        setBusy(true);
        wallets = [];
        // String holder =
        //     NumberUtil.currencyFormat(walletInfoCopy[i].usdValue, 2);
        // formattedUsdValueList.add(holder);
        wallets.add(walletsCopy[i]);
        // debugPrint(
        //     'matched wallet ${walletInfoCopy[i].toJson()} --  wallet info length ${walletInfo.length}');
        setBusy(false);
        break;
      } else {
        wallets = walletsCopy;
      }
    }

    setBusy(false);
  }

  bool isFirstCharacterMatched(String value, int index) {
    debugPrint(
        'value 1st char ${value[0]} == first chracter ${wallets[index].coin[0]}');
    log.w(value.startsWith(wallets[index].coin[0]));
    return value.startsWith(wallets[index].coin[0]);
  }

/*----------------------------------------------------------------------
                    Get app version
----------------------------------------------------------------------*/

  getAppVersion() async {
    setBusy(true);
    Map<String, String> localAppVersion =
        await sharedService.getLocalAppVersion();
    String store = '';
    String appDownloadLinkOnWebsite =
        'http://exchangily.com/download/latest.apk';
    if (Platform.isIOS) {
      store = 'App Store';
    } else {
      store = 'Google Play Store';
    }
    await apiService.getApiAppVersion().then((apiAppVersion) {
      if (apiAppVersion != null) {
        log.e('condition ${localAppVersion['name'].compareTo(apiAppVersion)}');

        log.i(
            'api app version $apiAppVersion -- local version $localAppVersion');

        if (localAppVersion['name'].compareTo(apiAppVersion) == -1) {
          sharedService.alertDialog(
              FlutterI18n.translate(context, "appUpdateNotice"),
              '${FlutterI18n.translate(context, "pleaseUpdateYourAppFrom")} $localAppVersion ${FlutterI18n.translate(context, "toLatestBuild")} $apiAppVersion ${FlutterI18n.translate(context, "inText")} $store ${FlutterI18n.translate(context, "clickOnWebsiteButton")}',
              isUpdate: true,
              isLater: true,
              isWebsite: true,
              stringData: appDownloadLinkOnWebsite);
        }
      }
    }).catchError((err) {
      log.e('get app version catch $err');
    });
    setBusy(false);
  }

/*----------------------------------------------------------------------
                    get free fab
----------------------------------------------------------------------*/

  getFreeFab() async {
    String address =
        await coreWalletDatabaseService.getWalletAddressByTickerName('EXG');
    await apiService.getFreeFab(address).then((res) {
      if (res != null) {
        if (res['ok']) {
          isFreeFabNotUsed = res['ok'];
          debugPrint(res['_body']['question'].toString());
          showDialog(
              context: context,
              builder: (context) {
                return Center(
                  child: SizedBox(
                    height: 250,
                    child: ListView(
                      children: [
                        AlertDialog(
                          titlePadding: const EdgeInsets.symmetric(vertical: 5),
                          actionsPadding: const EdgeInsets.all(0),
                          elevation: 5,
                          titleTextStyle: headText4,
                          contentTextStyle: const TextStyle(color: grey),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10),
                          backgroundColor: secondaryColor.withOpacity(0.95),
                          title: Text(
                            FlutterI18n.translate(context, "question"),
                            textAlign: TextAlign.center,
                          ),
                          content: Column(
                            children: <Widget>[
                              UIHelper.verticalSpaceSmall,
                              Text(
                                res['_body']['question'].toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(color: red),
                              ),
                              TextField(
                                minLines: 1,
                                style: const TextStyle(color: black),
                                controller: freeFabAnswerTextController,
                                obscureText: false,
                                decoration: const InputDecoration(
                                  icon: Icon(
                                    Icons.question_answer,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                              UIHelper.verticalSpaceSmall,
                              postFreeFabResult != ''
                                  ? Text(postFreeFabResult)
                                  : Container()
                            ],
                          ),
                          actions: [
                            Container(
                                alignment: Alignment.center,
                                margin: const EdgeInsetsDirectional.only(
                                    bottom: 10),
                                child: StatefulBuilder(builder:
                                    (BuildContext context,
                                        StateSetter setState) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Cancel
                                      OutlinedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    primaryColor),
                                            padding: MaterialStateProperty.all(
                                                const EdgeInsets.all(0)),
                                          ),
                                          child: Center(
                                            child: Text(
                                              FlutterI18n.translate(
                                                  context, "close"),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                            setState(() =>
                                                freeFabAnswerTextController
                                                    .text = '');
                                            FocusScope.of(context)
                                                .requestFocus(FocusNode());
                                          }),
                                      UIHelper.horizontalSpaceSmall,
                                      // Confirm
                                      OutlinedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    primaryColor),
                                            padding: MaterialStateProperty.all(
                                                const EdgeInsets.all(0)),
                                          ),
                                          child: Center(
                                            child: Text(
                                              FlutterI18n.translate(
                                                  context, "confirm"),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12),
                                            ),
                                          ),
                                          onPressed: () async {
                                            String fabAddress = await sharedService
                                                .getFabAddressFromCoreWalletDatabase();
                                            postFreeFabResult = '';
                                            Map data = {
                                              "address": fabAddress,
                                              "questionair_id": res['_body']
                                                  ['_id'],
                                              "answer":
                                                  freeFabAnswerTextController
                                                      .text
                                            };
                                            log.e('free fab post data $data');
                                            await apiService
                                                .postFreeFab(data)
                                                .then(
                                              (res) {
                                                if (res != null) {
                                                  log.w(res['ok']);

                                                  if (res['ok']) {
                                                    Navigator.of(context)
                                                        .pop(false);
                                                    setState(() =>
                                                        isFreeFabNotUsed =
                                                            false);
                                                    walletService.showInfoFlushbar(
                                                        FlutterI18n.translate(
                                                            context,
                                                            "freeFabUpdate"),
                                                        FlutterI18n.translate(
                                                            context,
                                                            "freeFabSuccess"),
                                                        Icons.account_balance,
                                                        green,
                                                        context);
                                                  } else {
                                                    walletService.showInfoFlushbar(
                                                        FlutterI18n.translate(
                                                            context,
                                                            "freeFabUpdate"),
                                                        FlutterI18n.translate(
                                                            context,
                                                            "incorrectAnswer"),
                                                        Icons.cancel,
                                                        red,
                                                        context);
                                                  }
                                                } else {
                                                  walletService
                                                      .showInfoFlushbar(
                                                          FlutterI18n.translate(
                                                              context, "ice"),
                                                          FlutterI18n.translate(
                                                              context,
                                                              "genericError"),
                                                          Icons.cancel,
                                                          red,
                                                          context);
                                                }
                                              },
                                            );
                                            //  navigationService.goBack();
                                            freeFabAnswerTextController.text =
                                                '';
                                            postFreeFabResult = '';
                                            FocusScope.of(context)
                                                .requestFocus(FocusNode());
                                          }),
                                    ],
                                  );
                                })),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              });
        } else {
          debugPrint(isFreeFabNotUsed.toString());
          isFreeFabNotUsed = res['ok'];
          debugPrint(isFreeFabNotUsed.toString());

          walletService.showInfoFlushbar(
              FlutterI18n.translate(context, "notice"),
              FlutterI18n.translate(context, "freeFabUsedAlready"),
              Icons.notification_important,
              yellow,
              context);
        }
      }
    });
  }

  // Pull to refresh
  // void onRefresh() async {
  //   await refreshBalancesV2();
  //   refreshController.refreshCompleted();
  // }

  bool hideSmallAmountCheck(WalletBalance wallet) {
    bool isSuccess = false;

    if (isHideSmallAssetsButton &&
        (wallet.balance * wallet.usdValue.usd).toInt() < 0.1 &&
        wallet.balance < 0.1) {
      isSuccess = true;
    }
    return isSuccess;
  }

// Hide Small Amount Assets

  hideSmallAmountAssets() {
    setBusyForObject(isHideSmallAssetsButton, true);
    isHideSmallAssetsButton = !isHideSmallAssetsButton;
    setBusyForObject(isHideSmallAssetsButton, false);
  }

// Calculate Total Usd Balance of Coins
  calcTotalBal() {
    totalUsdBalance = '';
    totalWalletBalance = '';
    totalLockedBalance = '';
    totalExchangeBalance = '';
    var twb = 0.0;
    var tlb = 0.0;
    var teb = 0.0;
    for (var i = 0; i < wallets.length; i++) {
      if (!wallets[i].usdValue.usd.isNegative) {
        if (!wallets[i].balance.isNegative) {
          twb += wallets[i].balance * wallets[i].usdValue.usd;
        }

        if (!wallets[i].lockBalance.isNegative) {
          tlb += wallets[i].lockBalance * wallets[i].usdValue.usd;
        }

        if (!wallets[i].unlockedExchangeBalance.isNegative) {
          teb += wallets[i].unlockedExchangeBalance * wallets[i].usdValue.usd;
        }
      }
    }
    totalWalletBalance = NumberUtil.currencyFormat(twb, 2);
    totalLockedBalance = NumberUtil.currencyFormat(tlb, 2);
    totalExchangeBalance = NumberUtil.currencyFormat(teb, 2);
    var total = twb + tlb;
    totalUsdBalance = NumberUtil.currencyFormat(total, 2);
    log.i(
        'Total usd balance $totalUsdBalance -- totalWalletBalance $totalWalletBalance --totalLockedBalance $totalLockedBalance ');
  }

  // Get EXG address from wallet database
  // Future<String> getExgAddressFromWalletDatabase() async {
  //   String address = '';
  //   await walletDatabaseService
  //       .getWalletBytickerName('EXG')
  //       .then((res) => address = res.address);
  //   return address;
  // }

/*----------------------------------------------------------------------
                      Get Confirm deposit err
----------------------------------------------------------------------*/
// mpvWdFb91gYN1Q1UBfhMEmGn1Amw3BNthZ
  getConfirmDepositStatus() async {
    String address = await sharedService.getExgAddressFromCoreWalletDatabase();
    await walletService.getErrDeposit(address).then((result) async {
      List<String> pendingDepositCoins = [];
      if (result != null) {
        log.w('getConfirmDepositStatus reesult $result');
        for (var i = 0; i < result.length; i++) {
          var item = result[i];
          var coinType = item['coinType'];
          String tickerNameByCointype = newCoinTypeMap[coinType];
          if (tickerNameByCointype == null) {
            await tokenListDatabaseService.getAll().then((tokenList) {
              if (tokenList != null) {
                tickerNameByCointype = tokenList
                    .firstWhere((element) => element.coinType == coinType)
                    .tickerName;
              }
            });
          }
          log.w('tickerNameByCointype $tickerNameByCointype');
          tickerNameByCointype =
              walletUtil.updateSpecialTokensTickerNameForTxHistory(
                  tickerNameByCointype)["tickerName"];
          log.i(
              'if Special then updated tickerNameByCointype $tickerNameByCointype');
          if (tickerNameByCointype != null &&
              !pendingDepositCoins.contains(tickerNameByCointype)) {
            pendingDepositCoins.add(tickerNameByCointype);
          }
        }
        var json = jsonEncode(pendingDepositCoins);
        var listCoinsToString = jsonDecode(json);
        String holder = listCoinsToString.toString();
        String f = holder.substring(1, holder.length - 1);
        if (pendingDepositCoins.isNotEmpty) {
          showSimpleNotification(
              Text('${FlutterI18n.translate(context, "requireRedeposit")}: $f'),
              position: NotificationPosition.bottom,
              background: primaryColor);
        }
      }
    }).catchError((err) {
      log.e('getConfirmDepositStatus Catch $err');
    });
  }
/*----------------------------------------------------------------------
                      Show dialog warning
----------------------------------------------------------------------*/

  showDialogWarning() {
    log.w('in showDialogWarning isConfirmDeposit $isConfirmDeposit');
    if (gasAmount == 0.0) {
      sharedService.alertDialog(
          FlutterI18n.translate(context, "insufficientGasAmount"),
          FlutterI18n.translate(context, "pleaseAddGasToTrade"));
    }
    if (isConfirmDeposit) {
      sharedService.alertDialog(
          FlutterI18n.translate(context, "pendingConfirmDeposit"),
          '${FlutterI18n.translate(context, "pleaseConfirmYour")} ${confirmDepositCoinWallet.tickerName} ${FlutterI18n.translate(context, "deposit")}',
          path: '/walletFeatures',
          arguments: confirmDepositCoinWallet,
          isWarning: true);
    }
  }

  jsonTransformation() {
    var walletBalancesBody = jsonDecode(storageService.walletBalancesBody);
    log.i('Coin address body $walletBalancesBody');
  }

  buildFavWalletCoinsList(String tickerName) async {
    List<String> favWalletCoins = [];
    favWalletCoins.add(tickerName);
    // UserSettings userSettings = UserSettings(favWalletCoins: [tickerName]);
    // await userDatabaseService.update(userSettings);

    storageService.favWalletCoins = json.encode(favWalletCoins);
  }

/*----------------------------------------------------------------------
                      Build coin list
----------------------------------------------------------------------*/

  buildNewWalletObject(
      TokenModel newToken, WalletBalance newTokenWalletBalance) async {
    String newCoinAddress = '';

    //newCoinAddress = assignNewTokenAddress(newToken);
    double marketPrice = newTokenWalletBalance.usdValue.usd ?? 0.0;
    double availableBal = newTokenWalletBalance.balance ?? 0.0;
    double lockedBal = newTokenWalletBalance.lockBalance ?? 0.0;

    double usdValue = walletService.calculateCoinUsdBalance(
        marketPrice, availableBal, lockedBal);
    // String holder = NumberUtil.currencyFormat(usdValue, 2);
    // formattedUsdValueList.add(holder);

    WalletBalance wb = WalletBalance(
        coin: newToken.tickerName,
        balance: newTokenWalletBalance.balance,
        lockBalance: newTokenWalletBalance.lockedExchangeBalance,
        usdValue: UsdValue(usd: usdValue),
        unlockedExchangeBalance: newTokenWalletBalance.unlockedExchangeBalance);
    wallets.add(wb);
    log.e('new coin ${wb.coin} added ${wb.toJson()} in wallet info object');
  }

/*----------------------------------------------------------------------
                      Add New Token In Db
----------------------------------------------------------------------*/

  insertToken(TokenModel newToken) async {
    if (newToken.chainName == 'FAB') {
      newToken.contract = '0x' + newToken.contract;
    }
    await tokenListDatabaseService.insert(newToken);
  }

/*-------------------------------------------------------------------------------------
                          Refresh Balances
-------------------------------------------------------------------------------------*/

  Future<List<WalletBalance>> refreshBalancesV2() async {
    setBusy(true);
    List<WalletBalance> walletBalancesApiRes = [];
    // get the walletbalancebody from the DB
    var walletBalancesBodyFromDB =
        await coreWalletDatabaseService.getWalletBalancesBody();
    var finalWbb = '';
    if (walletBalancesBodyFromDB == null) {
      finalWbb = storageService.walletBalancesBody;
      var walletCoreModel = CoreWalletModel(
        id: 1,
        walletBalancesBody: finalWbb,
      );
      // store in single core database
      await coreWalletDatabaseService.insert(walletCoreModel);
    }
    if (walletBalancesBodyFromDB != null) {
      finalWbb = walletBalancesBodyFromDB['walletBalancesBody'];
    }
    if (finalWbb == null || finalWbb == '') {
      storageService.hasWalletVerified = false;
      navigationService
          .navigateUsingPushNamedAndRemoveUntil(WalletSetupViewRoute);
      return [];
    }
    walletBalancesApiRes =
        await apiService.getWalletBalance(jsonDecode(finalWbb));
    if (walletBalancesApiRes != null) {
      log.w('walletBalances LENGTH ${walletBalancesApiRes.length ?? 0}');
    }
    for (var coinToHideTicker in coinsToHideList) {
      walletBalancesApiRes
          .removeWhere((element) => element.coin == coinToHideTicker);
    }
    log.i('walletBalances LENGTH ${walletBalancesApiRes.length}');
    wallets = walletBalancesApiRes;
    walletsCopy = wallets;

    calcTotalBal();

    await checkToUpdateWallet();
    moveTronUsdt();
    moveTron();
    // get gas balance
    await walletService
        .gasBalance(
            await coreWalletDatabaseService.getWalletAddressByTickerName('EXG'))
        .then((data) => gasAmount = data)
        .catchError((onError) {
      log.e(onError);
    });
    log.w('Gas Amount $gasAmount');

    // check gas and fab balance if 0 then ask for free fab
    if (gasAmount == 0.0 && fabBalance == 0.0) {
      String address =
          await coreWalletDatabaseService.getWalletAddressByTickerName('FAB');
      if (storageService.isShowCaseView != null) {
        if (storageService.isShowCaseView) {
          storageService.isShowCaseView = true;
          _isShowCaseView = true;
        }
      } else {
        storageService.isShowCaseView = true;
        _isShowCaseView = true;
      }
      var res = await apiService.getFreeFab(address);
      if (res != null) {
        isFreeFabNotUsed = res['ok'];
      }
    } else {
      log.i('Fab or gas balance available already');
      // storageService.isShowCaseView = false;
    }

    setBusy(false);
    return walletBalancesApiRes;
  }

// test version pop up
  debugVersionPopup() async {
    // await _showNotification();

    sharedService.alertDialog(FlutterI18n.translate(context, "notice"),
        FlutterI18n.translate(context, "testVersion"),
        isWarning: false);
  }

  onBackButtonPressed() async {
    sharedService.context = context;
    await sharedService.closeApp();
  }

  updateAppbarHeight(h) {
    top = h;
  }

  getAppbarHeight() {
    return top;
  }
}

// Future<void> _showNotification() async {
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       'your channel id', 'your channel name', 'your channel description',
//       importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
//   var iOSPlatformChannelSpecifics = IOSNotificationDetails();
//   var platformChannelSpecifics = NotificationDetails(
//       androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
//   await flutterLocalNotificationsPlugin.show(0, 'Test Server Warning',
//       'You are using Test Server!', platformChannelSpecifics,
//       payload: 'item x');
// }