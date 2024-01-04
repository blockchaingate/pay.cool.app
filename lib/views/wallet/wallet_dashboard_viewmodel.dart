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

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aukfa_version_checker/aukfa_version_checker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:kyc/kyc.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/constants/ui_var.dart';
import 'package:paycool/environments/coins.dart';
import 'package:paycool/environments/environment_type.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/models/wallet/core_wallet_model.dart';
import 'package:paycool/models/wallet/token_model.dart';
import 'package:paycool/models/wallet/wallet.dart';
import 'package:paycool/models/wallet/wallet_balance.dart';
import 'package:paycool/providers/app_state_provider.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/api_service.dart';
import 'package:paycool/services/coin_service.dart';
import 'package:paycool/services/db/core_wallet_database_service.dart';
import 'package:paycool/services/db/decimal_config_database_service.dart';
import 'package:paycool/services/db/token_list_database_service.dart';
import 'package:paycool/services/db/user_settings_database_service.dart';
import 'package:paycool/services/db/wallet_database_service.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/utils/fab_util.dart';
import 'package:paycool/utils/number_util.dart';
import 'package:paycool/utils/tron_util/trx_generate_address_util.dart'
    as tron_address_util;
import 'package:paycool/utils/wallet/wallet_util.dart';
import 'package:paycool/widgets/wallet/chain_list_widget.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../services/local_dialog_service.dart';

class WalletDashboardViewModel extends BaseViewModel {
  WalletDashboardViewModel({BuildContext? context});
  BuildContext? context;
  final log = getLogger('WalletDashboardViewModel');

  WalletService walletService = locator<WalletService>();
  SharedService sharedService = locator<SharedService>();

  final navigationService = locator<NavigationService>();
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
  var coreWalletDatabaseService = locator<CoreWalletDatabaseService>();
  final versionChecker = VersionChecker();

  WalletInfo? get rightWalletInfo => walletService.walletInfoDetails;

  final double elevation = 5;
  String totalUsdBalance = '';

  double gasAmount = 0;
  String? fabAddress;
  bool isHideSearch = false;
  bool isHideSmallAssetsButton = false;
  bool isConfirmDeposit = false;
  late WalletInfo confirmDepositCoinWallet;

  // var lang;

  var top = 0.0;
  final freeFabAnswerTextController = TextEditingController();
  String postFreeFabResult = '';
  bool isFreeFabNotUsed = false;
  double fabBalance = 0.0;

  final searchCoinTextController = TextEditingController();

  //vars for announcement
  bool hasApiError = false;
  List announceList = [];
  GlobalKey? globalKeyOne;
  GlobalKey? globalKeyTwo;
  double totalBalanceContainerWidth = 100.0;

  bool _isShowCaseView = false;
  get isShowCaseView => _isShowCaseView;

  int unreadMsgNum = 0;
  bool isUpdateWallet = false;
  List<WalletBalance> wallets = [];
  List<WalletBalance> walletsCopy = [];

  final List<String> chainList = [
    "All",
    "FAB",
    "ETH",
    "BTC",
    "TRX",
    "BNB",
    "FAV"
  ];

  bool isShowFavCoins = false;
  int selectedTabIndex = 0;
  ScrollController walletsScrollController = ScrollController();

  var fabUtils = FabUtils();
  var walletUtil = WalletUtil();
  String totalWalletBalance = '';
  String totalLockedBalance = '';
  String totalExchangeBalance = '';
  var coinsToHideList = [""];
  final coinService = locator<CoinService>();

  // bond page

  final kycService = locator<KycBaseService>();
  late AppStateProvider appStateProvider;
  late Completer<void> refreshIndicator;

  final formKey = GlobalKey<FormState>();

/*----------------------------------------------------------------------
                    INIT
----------------------------------------------------------------------*/

  init() async {
    setBusy(true);
    appStateProvider = Provider.of<AppStateProvider>(context!, listen: false);
    refreshIndicator = Completer<void>();
    fabAddress = await sharedService.getFabAddressFromCoreWalletDatabase();

    await walletService.storeTokenListInDB();
    await refreshBalancesV2().then((walletBalances) async {
      for (var i = 0; i < walletBalances.length; i++) {
        try {
          appStateProvider.setProviderAddress(wallets[i].coin!);
          await coinService
              .getCoinTypeByTickerName(wallets[i].coin!)
              .then((value) async {
            wallets[i].tokenType = WalletUtil().getTokenType(value);
          });
        } catch (error) {
          debugPrint("getWalletInfoObjFromWalletBalance ===> $error");
        }
      }
    }).whenComplete(() {
      appStateProvider.setWalletBalances(wallets);
      setWalletDetails(wallets[3]);
    });

    showDialogWarning();

    getConfirmDepositStatus();
    selectedTabIndex = storageService.isFavCoinTabSelected ? 1 : 0;

    setBusy(false);
    try {
      await versionChecker
          .check(
        context!,
        //test: true, testVersion: "2.3.126"
      )
          .timeout(const Duration(seconds: 2), onTimeout: () {
        debugPrint('time out version checker after waiting for 2 seconds');
      });
    } catch (err) {
      debugPrint('version checker catch $err');
    }
  }

  checkKycStatusV2() async {
    kycService.setPrimaryColor(primaryColor);
    if (storageService.bondToken.isEmpty) {
      log.e('kyc token is empty');
      await sharedService
          .navigateWithAnimation(KycLogin(onFormSubmit: onLoginFormSubmit));
      return;
    } else {
      kycService.updateXAccessToken(storageService.bondToken);

      navigationService.navigateToView(const KycStatus());
    }
  }

  onLoginFormSubmit(UserLoginModel user) async {
    setBusy(true);

    try {
      final kycService = locator<KycBaseService>();

      String url =
          isProduction ? KycConstants.prodBaseUrl : KycConstants.testBaseUrl;
      final Map<String, dynamic> res;

      if (user.email!.isNotEmpty && user.password!.isNotEmpty) {
        res = await kycService.login(url, user);
        if (res['success']) {
          storageService.bondToken = res['data']['token'];
        }
      } else {
        res = {
          'success': false,
          'error': FlutterI18n.translate(
              context!, 'pleaseFillAllTheTextFieldsCorrectly')
        };
      }
      return res;
    } catch (e) {
      debugPrint('CATCH error $e');
    }

    setBusy(false);
  }

  List<WalletBalance> getSortedWalletList(String chainName) {
    return wallets
        .where((wallet) =>
            wallet.tokenType == chainName || wallet.coin == chainName)
        .toList();
  }

  setWalletDetails(WalletBalance wallet) async {
    walletService.setWalletInfoDetails(
        await walletUtil.getWalletInfoObjFromWalletBalance(wallet));
    walletService.setSpecialTickerName();
  }

  routeWithWalletInfoArgs(WalletBalance wallet, String routeName) async {
    // assign address from local DB to walletinfo object

    // if (MediaQuery.of(context!).size.width < largeSize) {
    // FocusScope.of(context!).requestFocus(FocusNode());
    var walletInfo = await walletUtil.getWalletInfoObjFromWalletBalance(wallet);

    log.w('routeWithWalletInfoArgs walletInfo ${walletInfo.toJson()}');
    searchCoinTextController.clear();
    // navigate accordingly
    navigationService.navigateTo(routeName);
    // }
    setWalletDetails(wallet);
  }

  updateTabSelection(int tabIndex) {
    setBusy(true);
    setBusyForObject(selectedTabIndex, true);

    selectedTabIndex = tabIndex;
    isHideSmallAssetsButton = true;
    isHideSearch = true;

    notifyListeners();

    if (tabIndex == 0) {
      isHideSmallAssetsButton = false;
      isHideSearch = false;
    } else if (tabIndex == 5) {
      isShowFavCoins = true;
    } else {
      isHideSmallAssetsButton = false;
      isHideSearch = false;
    }

    storageService.isFavCoinTabSelected = isShowFavCoins ? true : false;
    debugPrint(
        'current tab sel $selectedTabIndex -- isShowFavCoins $isShowFavCoins');

    setBusy(false);
    setBusyForObject(selectedTabIndex, false);
  }

  List<WalletBalance> getFavCoins() {
    List<WalletBalance> favWallets = [];
    String favCoinsJson = storageService.favWalletCoins;
    if (favCoinsJson != '') {
      List<String> favWalletCoins =
          (jsonDecode(favCoinsJson) as List<dynamic>).cast<String>();

      for (var i = 0; i < favWalletCoins.length; i++) {
        for (var j = 0; j < wallets.length; j++) {
          if (wallets[j].coin == favWalletCoins[i].toString()) {
            favWallets.add(wallets[j]);
          }
        }
      }

      return favWallets;
    } else {
      return [];
    }
  }

/*----------------------------------------------------------------------
                Update wallet with new native coins
----------------------------------------------------------------------*/

  checkToUpdateWallet() async {
    setBusy(true);
    String wallet =
        await coreWalletDatabaseService.getWalletAddressByTickerName('TRX');
    if (wallet.isNotEmpty) {
      log.w('$wallet TRX present');
      isUpdateWallet = false;
    } else {
      isUpdateWallet = true;
    }

    setBusy(false);
  }

/*---------------------------------------------------
          Update Info dialog
--------------------------------------------------- */

  showUpdateWalletDialog() {
    showDialog(
      context: context!,
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
                  content: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                        updateWallet();
                      },
                      child: Text(FlutterI18n.translate(context, "updateNow"))),
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
            title: FlutterI18n.translate(context!, "enterPassword"),
            description: FlutterI18n.translate(
                context!, "dialogManagerTypeSamePasswordNote"),
            buttonTitle: FlutterI18n.translate(context!, "confirm"))
        .then((res) async {
      if (res.confirmed) {
        mnemonic = res.returnedText;
        var address = tron_address_util.generateTrxAddress(mnemonic);
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
                        On Single Coin Card Click
----------------------------------------------------------------------*/

  onSingleCoinCardClick(index) async {
    if (MediaQuery.of(context!).size.width < largeSize) {
      FocusScope.of(context!).requestFocus(FocusNode());
      navigationService.navigateTo(walletFeaturesViewRoute,
          arguments: wallets[index]);
      searchCoinTextController.clear();
    } else {
      setWalletDetails(wallets[index]);
    }
  }

/*----------------------------------------------------------------------
                    Search Coins By TickerName
----------------------------------------------------------------------*/
  searchCoinsByTickerName(String value) async {
    setBusy(true);

    debugPrint('length ${walletsCopy.length} -- value $value');
    for (var i = 0; i < walletsCopy.length; i++) {
      if (value.isNotEmpty) {
        setBusy(true);
        wallets = walletsCopy
            .where((element) =>
                element.coin!.toLowerCase().contains(value.toLowerCase()))
            .toList();

        setBusy(false);
      } else {
        wallets = walletsCopy;
      }
    }

    setBusy(false);
  }

  bool isFirstCharacterMatched(String value, int index) {
    debugPrint(
        'value 1st char ${value[0]} == first chracter ${wallets[index].coin![0]}');
    log.w(value.startsWith(wallets[index].coin![0]));
    return value.startsWith(wallets[index].coin![0]);
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
        log.e('condition ${localAppVersion['name']!.compareTo(apiAppVersion)}');

        log.i(
            'api app version $apiAppVersion -- local version $localAppVersion');

        if (localAppVersion['name']!.compareTo(apiAppVersion) == -1) {
          sharedService.alertDialog(
              context!,
              FlutterI18n.translate(context!, "appUpdateNotice"),
              '${FlutterI18n.translate(context!, "pleaseUpdateYourAppFrom")} $localAppVersion ${FlutterI18n.translate(context!, "toLatestBuild")} $apiAppVersion ${FlutterI18n.translate(context!, "inText")} $store ${FlutterI18n.translate(context!, "clickOnWebsiteButton")}',
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
              context: context!,
              builder: (context) {
                return Center(
                  child: SizedBox(
                    height: 250,
                    child: ListView(
                      children: [
                        AlertDialog(
                          titlePadding:
                              const EdgeInsets.symmetric(vertical: 15),
                          actionsPadding: const EdgeInsets.all(0),
                          elevation: 5,
                          titleTextStyle:
                              headText4.copyWith(fontWeight: FontWeight.bold),
                          contentTextStyle: const TextStyle(color: grey),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10),
                          backgroundColor: secondaryColor,
                          title: Text(
                            FlutterI18n.translate(
                                context, "freeGasQuestionNote"),
                            textAlign: TextAlign.center,
                          ),
                          content: Column(
                            children: <Widget>[
                              UIHelper.verticalSpaceSmall,
                              Text(
                                res['_body']['question'].toString(),
                                style: headText4.copyWith(
                                    color: red, letterSpacing: 5.0),
                              ),
                              TextField(
                                minLines: 1,
                                style: const TextStyle(color: black),
                                controller: freeFabAnswerTextController,
                                obscureText: false,
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: grey, width: 1)),
                                  focusedBorder: const UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: primaryColor)),
                                  icon: const Icon(
                                    Icons.question_answer,
                                    color: primaryColor,
                                    size: 18,
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
                                          style: generalButtonStyle(
                                              secondaryColor),
                                          child: Center(
                                            child: Text(
                                              FlutterI18n.translate(
                                                  context, "close"),
                                              style: const TextStyle(
                                                  fontSize: 12, color: black),
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
                                          style:
                                              generalButtonStyle(primaryColor),
                                          child: Center(
                                            child: Text(
                                              FlutterI18n.translate(
                                                  context, "confirm"),
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: secondaryColor),
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
                                                    sharedService
                                                        .sharedSimpleNotification(
                                                            FlutterI18n.translate(
                                                                context,
                                                                "freeFabUpdate"),
                                                            subtitle: FlutterI18n
                                                                .translate(
                                                                    context,
                                                                    "freeFabSuccess"),
                                                            isError: false);
                                                  } else {
                                                    sharedService
                                                        .sharedSimpleNotification(
                                                      FlutterI18n.translate(
                                                          context,
                                                          "freeFabUpdate"),
                                                      subtitle:
                                                          FlutterI18n.translate(
                                                              context,
                                                              "incorrectAnswer"),
                                                    );
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
              FlutterI18n.translate(context!, "notice"),
              FlutterI18n.translate(context!, "freeFabUsedAlready"),
              Icons.notification_important,
              yellow,
              context!);
        }
      }
    });
  }

  bool hideSmallAmountCheck(WalletBalance wallet) {
    bool isSuccess = false;

    if (isHideSmallAssetsButton &&
        (wallet.balance! * wallet.usdValue!.usd!).toInt() < 0.1 &&
        wallet.balance! < 0.1) {
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
      if (!wallets[i].usdValue!.usd!.isNegative) {
        if (!wallets[i].balance!.isNegative) {
          twb += wallets[i].balance! * wallets[i].usdValue!.usd!;
        }

        if (!wallets[i].lockBalance!.isNegative) {
          tlb += wallets[i].lockBalance! * wallets[i].usdValue!.usd!;
        }

        if (!wallets[i].unlockedExchangeBalance!.isNegative &&
            wallets[i].unlockedExchangeBalance != 0.0) {
          debugPrint('ticker ${wallets[i].coin}');
          debugPrint(
              'exchange balance ${wallets[i].unlockedExchangeBalance!} -- usd value ${wallets[i].usdValue!.usd!}');

          teb +=
              wallets[i].unlockedExchangeBalance! * wallets[i].usdValue!.usd!;
          debugPrint('teb $teb');
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
          tickerNameByCointype = WalletUtil.updateSpecialTokensTickerName(
              tickerNameByCointype)["tickerName"]!;
          log.i(
              'if Special then updated tickerNameByCointype $tickerNameByCointype');
          if (tickerNameByCointype.isNotEmpty &&
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
              Text(
                '${FlutterI18n.translate(context!, "requireRedeposit")}: $f',
                textAlign: TextAlign.center,
                style: headText4.copyWith(color: secondaryColor),
              ),
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
          context!,
          FlutterI18n.translate(context!, "insufficientGasAmount"),
          FlutterI18n.translate(context!, "pleaseAddGasToTrade"));
    }
    if (isConfirmDeposit) {
      sharedService.alertDialog(
          context!,
          FlutterI18n.translate(context!, "pendingConfirmDeposit"),
          '${FlutterI18n.translate(context!, "pleaseConfirmYour")} ${confirmDepositCoinWallet.tickerName} ${FlutterI18n.translate(context!, "deposit")}',
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
    // String newCoinAddress = '';

    //newCoinAddress = assignNewTokenAddress(newToken);
    double marketPrice = newTokenWalletBalance.usdValue!.usd ?? 0.0;
    double availableBal = newTokenWalletBalance.balance ?? 0.0;
    double lockedBal = newTokenWalletBalance.lockBalance ?? 0.0;

    double? usdValue = walletService.calculateCoinUsdBalance(
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
      newToken.contract = '0x${newToken.contract}';
    }
    await tokenListDatabaseService.insert(newToken);
  }

// move coin in the list
  moveCoin(String tickerName, int desiredIndexPosition) {
    try {
      var walletObj =
          wallets.singleWhere((element) => element.coin == tickerName);
      if (walletObj.coin!.isNotEmpty) {
        int walletObjIndex = wallets.indexOf(walletObj);
        if (walletObjIndex != desiredIndexPosition) {
          wallets.removeAt(walletObjIndex);
          wallets.insert(desiredIndexPosition, walletObj);
        } else {
          log.i(
              '2nd else moveCoin $tickerName already at $desiredIndexPosition');
        }
      } else {
        log.w('1st else moveCoin cant find $tickerName');
      }
    } catch (err) {
      log.e('moveCoin Catch $err');
    }
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
    if (finalWbb.isEmpty) {
      storageService.hasWalletVerified = false;
      navigationService.pushNamedAndRemoveUntil(WalletSetupViewRoute);
      return [];
    }
    walletBalancesApiRes =
        await apiService.getWalletBalance(jsonDecode(finalWbb));

    for (var coinToHideTicker in coinsToHideList) {
      walletBalancesApiRes
          .removeWhere((element) => element.coin == coinToHideTicker);
    }
    log.i('walletBalances LENGTH ${walletBalancesApiRes.length}');
    wallets = walletBalancesApiRes;
    walletsCopy = wallets;

    calcTotalBal();

    await checkToUpdateWallet();
    moveCoin('USDTX', 5);
    moveCoin('BNB', 6);
    moveCoin('TRX', 7);

    // get gas balance
    await walletService
        .gasBalance(
            await coreWalletDatabaseService.getWalletAddressByTickerName('EXG'))
        .then((data) => gasAmount = data)
        .catchError((onError) {
      log.e(onError);
      return 0.0;
    });
    log.w('Gas Amount $gasAmount');

    // check gas and fab balance if 0 then ask for free fab
    if (gasAmount == 0.0 && fabBalance == 0.0) {
      String address =
          await coreWalletDatabaseService.getWalletAddressByTickerName('FAB');

      if (storageService.isShowCaseView) {
        storageService.isShowCaseView = true;
        _isShowCaseView = true;
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

    sharedService.alertDialog(
        context!,
        FlutterI18n.translate(context!, "notice"),
        FlutterI18n.translate(context!, "testVersion"),
        isWarning: false);
  }

  onBackButtonPressed() async {
    sharedService.context = context!;
    await sharedService.closeApp();
  }

  goToChainList(size) async {
    showModalBottomSheet(
      context: context!,
      isScrollControlled: true,
      barrierColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        side: BorderSide.lerp(
            BorderSide(color: Colors.black12), BorderSide.none, 0),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      builder: (BuildContext context) => chainListWidget(
          context, size, wallets, appStateProvider.getProviderAddressList),
    ).then((value) async {
      if (value != null) {
        updateTabSelection(value);
      }
    }).whenComplete(() {
      notifyListeners();
    });
  }
}
