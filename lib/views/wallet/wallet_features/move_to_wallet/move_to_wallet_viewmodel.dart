import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/environments/environment.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/models/wallet/token_model.dart';
import 'package:paycool/models/wallet/wallet.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/api_service.dart';
import 'package:paycool/services/coin_service.dart';
import 'package:paycool/services/db/wallet_database_service.dart';
import 'package:paycool/services/local_dialog_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/utils/custom_http_util.dart';
import 'package:paycool/utils/number_util.dart';
import 'package:paycool/utils/string_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:paycool/services/db/token_list_database_service.dart';
import 'package:paycool/utils/eth_util.dart';
import 'dart:convert';
import 'package:paycool/utils/fab_util.dart';
import 'package:paycool/utils/wallet/wallet_util.dart';
import 'package:stacked/stacked.dart';

class MoveToWalletViewmodel extends BaseViewModel {
  final log = getLogger('MoveToWalletViewmodel');

  final client = CustomHttpUtil.createLetsEncryptUpdatedCertClient();
  final LocalDialogService _dialogService = locator<LocalDialogService>();
  WalletService walletService = locator<WalletService>();
  ApiService apiService = locator<ApiService>();
  SharedService sharedService = locator<SharedService>();
  final tokenListDatabaseService = locator<TokenListDatabaseService>();
  WalletDatabaseService walletDataBaseService =
      locator<WalletDatabaseService>();
  final coinService = locator<CoinService>();

  late WalletInfo walletInfo;
  late BuildContext context;

  String gasFeeUnit = '';
  String feeMeasurement = '';
  final kanbanGasPriceTextController = TextEditingController();
  final kanbanGasLimitTextController = TextEditingController();
  final amountController = TextEditingController();
  var kanbanTransFee;
  var minimumAmount;
  bool transFeeAdvance = false;
  double gasAmount = 0.0;

  bool isShowErrorDetailsButton = false;
  bool isShowDetailsMessage = false;
  String serverError = '';
  List<Map<String, dynamic>> chainBalances = [];
  var ethChainBalance;
  var fabChainBalance;
  var trxTsWalletBalance;
  var bnbTsWalletBalance;
  var polygonTsWalletBalance;
  bool isWithdrawChoice = false;
  String _groupValue = '';
  get groupValue => _groupValue;
  bool isShowFabChainBalance = false;
  bool isShowTrxTsWalletBalance = false;
  bool isShowBnbTsWalletBalance = false;
  bool isShowPolygonTsWalletBalance = false;
  String specialTicker = '';
  String updateTickerForErc = '';
  bool isAlert = false;
  bool isSpeicalTronTokenWithdraw = false;
  String message = '';

  bool isWithdrawChoicePopup = false;
  TokenModel token = TokenModel();
  String ercSmartContractAddress = '';
  TokenModel ercChainToken = TokenModel();
  TokenModel mainChainToken = TokenModel();

  TokenModel bnbChainToken = TokenModel();
  TokenModel polygonChainToken = TokenModel();
  bool isSubmittingTx = false;
  var tokenType;
  var fabUtils = FabUtils();

/*---------------------------------------------------
                      INIT
--------------------------------------------------- */

  void initState() async {
    setBusy(true);
    sharedService.context = context;
    var gasPrice = environment["chains"]["KANBAN"]["gasPrice"] ?? 0;
    var gasLimit = environment["chains"]["KANBAN"]["gasLimit"] ?? 0;
    kanbanGasPriceTextController.text = gasPrice.toString();
    kanbanGasLimitTextController.text = gasLimit.toString();
    tokenType = walletInfo.tokenType;
    kanbanTransFee =
        NumberUtil.rawStringToDecimal((gasPrice * gasLimit).toString())
            .toDouble();

    if (walletInfo.tickerName == 'ETH' || walletInfo.tickerName == 'USDT') {
      gasFeeUnit = 'WEI';
    } else if (walletInfo.tickerName == 'FAB') {
      gasFeeUnit = 'LIU';
      feeMeasurement = '10^(-8)';
    }
    _groupValue = 'ETH';
    if (walletInfo.tickerName == 'ETH' || walletInfo.tokenType == 'ETH') {
      radioButtonSelection('ETH');
    } else if (walletInfo.tickerName == 'FAB' ||
        walletInfo.tokenType == 'FAB') {
      isShowFabChainBalance = true;
      radioButtonSelection('FAB');
    } else if (walletInfo.tickerName == 'USDCX' ||
        walletInfo.tickerName == 'USDTX' ||
        walletInfo.tickerName == 'TRX') {
      isShowTrxTsWalletBalance = true;

      radioButtonSelection('TRX');
    } // BNB
    else if (walletInfo.tickerName == 'FABB' ||
        walletInfo.tickerName == 'USDTB' ||
        walletInfo.tokenType == 'BNB') {
      isShowBnbTsWalletBalance = true;

      radioButtonSelection('BNB');
    }
    // POLYGON
    else if (walletInfo.tokenType == 'MATICM' ||
        walletInfo.tickerName == 'MATICM' ||
        walletInfo.tokenType == 'POLYGON') {
      isShowPolygonTsWalletBalance = true;

      radioButtonSelection('POLYGON');
    } else {
      setWithdrawLimit(walletInfo.tickerName!);
    }
    specialTicker = WalletUtil.updateSpecialTokensTickerName(
        walletInfo.tickerName.toString())['tickerName']!;
    await checkGasBalance();
    await getSingleCoinExchangeBal();

    setBusy(false);
  }

/*---------------------------------------------------
        popup to confirm withdraw coin selection
--------------------------------------------------- */

  withdrawConfirmation() async {
    try {
      await _dialogService
          .showVerifyDialog(
              title: FlutterI18n.translate(context, "withdrawPopupNote"),
              description: _groupValue,
              buttonTitle: FlutterI18n.translate(context, "confirm"))
          .then((res) {
        if (res.confirmed) {
          debugPrint('res  ${res.confirmed}');
          checkPass();
        } else {
          debugPrint('res ${res.confirmed}');
        }
      });
    } catch (err) {
      log.e('withdrawConfirmation CATCH $err');
    }
  }

  popupToConfirmWithdrawSelection() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return
              //  Platform.isIOS
              //     ? Theme(
              //         data: ThemeData.dark(),
              //         child: CupertinoAlertDialog(
              //           title: Container(
              //             margin: EdgeInsets.only(bottom: 5.0),
              //             child: Center(
              //                 child: Text(
              //               '${FlutterI18n.translate(context, "withdrawPopupNote")}',
              //               style: headText4.copyWith(
              //                   color: primaryColor, fontWeight: FontWeight.w500),
              //             )),
              //           ),
              //           content: Container(
              //             child: Row(children: [
              //               Text(FlutterI18n.translate(context, "tsWalletNote"),
              //                   style: headText5),
              //               Padding(
              //                 padding: const EdgeInsets.symmetric(vertical: 8.0),
              //                 child: Text(
              //                     FlutterI18n.translate(context, "specialWithdrawNote"),
              //                     style: headText5),
              //               ),
              //               UIHelper.verticalSpaceSmall,
              //               Text(
              //                   AppLocalizations.of(context)
              //                       .specialWithdrawFailNote,
              //                   style: headText5),
              //             ]),
              //           ),
              //           actions: <Widget>[
              //             Container(
              //               margin: EdgeInsets.all(5),
              //               child: Row(
              //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //                 children: [
              //                   CupertinoButton(
              //                     padding: EdgeInsets.only(left: 5),
              //                     borderRadius:
              //                         BorderRadius.all(Radius.circular(4)),
              //                     child: Text(
              //                       FlutterI18n.translate(context, "close"),
              //                       style: Theme.of(context)
              //                           .textTheme
              //                           .bodyText2
              //                           .copyWith(fontWeight: FontWeight.bold),
              //                     ),
              //                     onPressed: () {
              //                       Navigator.of(context).pop(true);
              //                       checkPass();
              //                     },
              //                   ),
              //                 ],
              //               ),
              //             ),
              //           ],
              //         ))
              // android alert
              //:
              AlertDialog(
            titlePadding: EdgeInsets.zero,
            contentPadding: const EdgeInsets.all(5.0),
            elevation: 5,
            backgroundColor: secondaryColor,
            title: Container(
              padding: const EdgeInsets.all(10.0),
              color: secondaryColor.withOpacity(0.5),
              child: Center(
                  child: Text(
                      FlutterI18n.translate(context, "withdrawPopupNote"))),
            ),
            titleTextStyle: headText5,
            contentTextStyle: const TextStyle(color: grey),
            content: Container(
              padding: const EdgeInsets.all(5.0),
              child: isWithdrawChoice
                  ? Container(
                      padding: const EdgeInsets.all(8),
                      child: StatefulBuilder(builder:
                          (BuildContext context, StateSetter setState) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                isShowTrxTsWalletBalance ||
                                        WalletUtil.isSpecialUsdt(
                                            walletInfo.tickerName!) ||
                                        walletInfo.tickerName == "USDTX"
                                    ? Row(
                                        children: <Widget>[
                                          SizedBox(
                                            height: 10,
                                            width: 10,
                                            child: Radio(
                                                activeColor: primaryColor,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _groupValue =
                                                        value.toString();

                                                    radioButtonSelection(value);
                                                  });
                                                },
                                                groupValue: groupValue,
                                                value: 'TRX'),
                                          ),
                                          UIHelper.horizontalSpaceSmall,
                                          Text('TRC20', style: headText6),
                                        ],
                                      )
                                    : Row(
                                        children: <Widget>[
                                          SizedBox(
                                            height: 10,
                                            width: 20,
                                            child: Radio(
                                                //  model.groupValue == 'FAB'? fillColor: MaterialStateColor
                                                //       .resolveWith(
                                                //           (states) => Colors.blue),
                                                activeColor: primaryColor,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _groupValue =
                                                        value.toString();
                                                    if (value == 'FAB') {
                                                      isShowFabChainBalance =
                                                          true;
                                                      isShowTrxTsWalletBalance =
                                                          false;
                                                      if (walletInfo
                                                              .tickerName !=
                                                          'FAB') {
                                                        walletInfo.tokenType =
                                                            'FAB';
                                                      }
                                                      if (walletInfo
                                                              .tickerName ==
                                                          'FAB') {
                                                        walletInfo.tokenType =
                                                            '';
                                                      }
                                                      updateTickerForErc =
                                                          walletInfo
                                                              .tickerName!;
                                                      log.i(
                                                          'chain type ${walletInfo.tokenType}');
                                                      setWithdrawLimit(
                                                          walletInfo
                                                              .tickerName!);
                                                    } else if (value == 'TRX') {
                                                      isShowTrxTsWalletBalance =
                                                          true;
                                                      if (walletInfo
                                                              .tickerName !=
                                                          'TRX') {
                                                        walletInfo.tokenType =
                                                            'TRX';
                                                      }

                                                      isSpeicalTronTokenWithdraw =
                                                          true;
                                                      //  walletInfo.tokenType = 'TRX';
                                                      log.i(
                                                          'chain type ${walletInfo.tokenType}');
                                                      setWithdrawLimit('USDTX');
                                                    }
                                                    // else if (walletInfo.tickerName == 'TRX' && !isShowTrxTsWalletBalance) {
                                                    //   await tokenListDatabaseService
                                                    //       .getByTickerName('USDTX')
                                                    //       .then((token) => withdrawLimit = double.parse(token.minWithdraw));
                                                    //   log.i('withdrawLimit $withdrawLimit');
                                                    // }
                                                    else {
                                                      isShowTrxTsWalletBalance =
                                                          false;
                                                      isShowFabChainBalance =
                                                          false;
                                                      walletInfo.tokenType =
                                                          'ETH';
                                                      log.i(
                                                          'chain type ${walletInfo.tokenType}');
                                                      if (walletInfo
                                                                  .tickerName ==
                                                              'FAB' &&
                                                          !isShowFabChainBalance) {
                                                        setWithdrawLimit(
                                                            'FABE');
                                                      } else if (walletInfo
                                                                  .tickerName ==
                                                              'DSC' &&
                                                          !isShowFabChainBalance) {
                                                        setWithdrawLimit(
                                                            'DSCE');
                                                      } else if (walletInfo
                                                                  .tickerName ==
                                                              'BST' &&
                                                          !isShowFabChainBalance) {
                                                        setWithdrawLimit(
                                                            'BSTE');
                                                      } else if (walletInfo
                                                                  .tickerName ==
                                                              'EXG' &&
                                                          !isShowFabChainBalance) {
                                                        setWithdrawLimit(
                                                            'EXGE');
                                                      } else if (walletInfo
                                                                  .tickerName ==
                                                              'USDTX' &&
                                                          !isShowTrxTsWalletBalance) {
                                                        setWithdrawLimit(
                                                            'USDT');
                                                      } else {
                                                        setWithdrawLimit(
                                                            walletInfo
                                                                .tickerName!);
                                                      }
                                                      setBusy(false);
                                                    }
                                                  });
                                                  radioButtonSelection(value);
                                                },
                                                groupValue: groupValue,
                                                value: 'FAB'),
                                          ),
                                          UIHelper.horizontalSpaceSmall,
                                          Text('FAB Chain', style: headText6),
                                        ],
                                      ),
                                UIHelper.horizontalSpaceMedium,
                                // erc20 radio button
                                Row(
                                  // mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    SizedBox(
                                      height: 10,
                                      width: 20,
                                      child: Radio(
                                          activeColor: primaryColor,
                                          onChanged: (value) {
                                            setState(() {
                                              _groupValue = value.toString();
                                              //   if (value == 'FAB') {
                                              //     isShowFabChainBalance =
                                              //         true;
                                              //     isShowTrxTsWalletBalance =
                                              //         false;
                                              //     if (walletInfo
                                              //             .tickerName !=
                                              //         'FAB')
                                              //       walletInfo.tokenType =
                                              //           'FAB';
                                              //     if (walletInfo
                                              //             .tickerName ==
                                              //         'FAB')
                                              //       walletInfo.tokenType =
                                              //           '';
                                              //     updateTickerForErc =
                                              //         walletInfo.tickerName;
                                              //     log.i(
                                              //         'chain type ${walletInfo.tokenType}');
                                              //     setWithdrawLimit(
                                              //         walletInfo
                                              //             .tickerName);
                                              //   } else if (value == 'TRX') {
                                              //     isShowTrxTsWalletBalance =
                                              //         true;
                                              //     if (walletInfo
                                              //             .tickerName !=
                                              //         'TRX')
                                              //       walletInfo.tokenType =
                                              //           'TRX';

                                              //     isSpeicalTronTokenWithdraw =
                                              //         true;
                                              //     //  walletInfo.tokenType = 'TRX';
                                              //     log.i(
                                              //         'chain type ${walletInfo.tokenType}');
                                              //     setWithdrawLimit('USDTX');
                                              //   }
                                              //   // else if (walletInfo.tickerName == 'TRX' && !isShowTrxTsWalletBalance) {
                                              //   //   await tokenListDatabaseService
                                              //   //       .getByTickerName('USDTX')
                                              //   //       .then((token) => withdrawLimit = double.parse(token.minWithdraw));
                                              //   //   log.i('withdrawLimit $withdrawLimit');
                                              //   // }
                                              //   else {
                                              //     isShowTrxTsWalletBalance =
                                              //         false;
                                              //     isShowFabChainBalance =
                                              //         false;
                                              //     walletInfo.tokenType =
                                              //         'ETH';
                                              //     log.i(
                                              //         'chain type ${walletInfo.tokenType}');
                                              //     if (walletInfo
                                              //                 .tickerName ==
                                              //             'FAB' &&
                                              //         !isShowFabChainBalance) {
                                              //       setWithdrawLimit(
                                              //           'FABE');
                                              //     } else if (walletInfo
                                              //                 .tickerName ==
                                              //             'DSC' &&
                                              //         !isShowFabChainBalance) {
                                              //       setWithdrawLimit(
                                              //           'DSCE');
                                              //     } else if (walletInfo
                                              //                 .tickerName ==
                                              //             'BST' &&
                                              //         !isShowFabChainBalance) {
                                              //       setWithdrawLimit(
                                              //           'BSTE');
                                              //     } else if (walletInfo
                                              //                 .tickerName ==
                                              //             'EXG' &&
                                              //         !isShowFabChainBalance) {
                                              //       setWithdrawLimit(
                                              //           'EXGE');
                                              //     } else if (walletInfo
                                              //                 .tickerName ==
                                              //             'USDTX' &&
                                              //         !isShowTrxTsWalletBalance) {
                                              //       setWithdrawLimit(
                                              //           'USDT');
                                              //     } else
                                              //       setWithdrawLimit(
                                              //           walletInfo
                                              //               .tickerName);
                                              //     setBusy(false);
                                              //   }
                                              radioButtonSelection(value);
                                            });
                                          },
                                          groupValue: groupValue,
                                          value: 'ETH'),
                                    ),
                                    UIHelper.horizontalSpaceSmall,
                                    Text('ERC20', style: headText6),
                                  ],
                                ),
                              ],
                            ),
                            // radioChoiceRow(context, isUsedInView: false),
                            UIHelper.verticalSpaceMedium,
                            // ok button to go ahead and sign and send transaction
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  OutlinedButton(
                                    // padding: EdgeInsets.only(left: 5),
                                    // borderRadius:
                                    //     BorderRadius.all(Radius.circular(4)),
                                    child: Text(
                                      FlutterI18n.translate(
                                          context, "withdraw"),
                                      style: headText5.copyWith(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();

                                      checkPass();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }))
                  : Container(),
            ),
            // actions: [
            //   Container(
            //     child: StatefulBuilder(
            //         builder:
            //             (BuildContext context, StateSetter setState) {}),
            //   )
            // ],
          );
        });
  }

  Row radioChoiceRow(BuildContext context, {isUsedInView = true}) {
    return Row(
      mainAxisAlignment:
          // isUsedInView ? MainAxisAlignment.start :
          MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        isShowTrxTsWalletBalance ||
                WalletUtil.isSpecialUsdt(walletInfo.tickerName!) ||
                walletInfo.tickerName == "USDCX" ||
                walletInfo.tickerName == "USDC"
            ? Row(
                children: <Widget>[
                  SizedBox(
                    height: 10,
                    width: 10,
                    child: Radio(
                        activeColor: primaryColor,
                        onChanged: (value) {
                          radioButtonSelection(value);
                        },
                        groupValue: groupValue,
                        value: 'TRX'),
                  ),
                  UIHelper.horizontalSpaceSmall,
                  Text('TRC20', style: headText6),
                ],
              )
            : Row(
                children: <Widget>[
                  SizedBox(
                    height: 10,
                    width: 20,
                    child: Radio(
                        //  model.groupValue == 'FAB'? fillColor: MaterialStateColor
                        //       .resolveWith(
                        //           (states) => Colors.blue),
                        activeColor: primaryColor,
                        onChanged: (value) {
                          radioButtonSelection(value);
                        },
                        groupValue: groupValue,
                        value: 'FAB'),
                  ),
                  UIHelper.horizontalSpaceSmall,
                  Text('FAB Chain', style: headText6),
                ],
              ),
        UIHelper.horizontalSpaceMedium,
        // erc20 radio button
        Row(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 10,
              width: 20,
              child: Radio(
                  activeColor: primaryColor,
                  onChanged: (value) {
                    radioButtonSelection(value);
                  },
                  groupValue: groupValue,
                  value: 'ETH'),
            ),
            UIHelper.horizontalSpaceSmall,
            Text('ETH Chain', style: headText6),
          ],
        ),
        UIHelper.horizontalSpaceMedium,
        Row(
          // mainAxisAlignment: MainAxisAlignment.start,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BNB radio button
            isShowBnbTsWalletBalance ||
                    WalletUtil.isSpecialUsdt(walletInfo.tickerName!) ||
                    WalletUtil.isSpecialFab(walletInfo.tickerName!) ||
                    walletInfo.tickerName == 'FAB' ||
                    walletInfo.tickerName == 'USDT'
                ? Row(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                        width: 20,
                        child: Radio(
                            activeColor: primaryColor,
                            onChanged: (value) {
                              radioButtonSelection(value);
                            },
                            groupValue: groupValue,
                            value: 'BNB'),
                      ),
                      UIHelper.horizontalSpaceSmall,
                      Text('BNB Chain', style: headText6),
                    ],
                  )
                : Container(),
            UIHelper.horizontalSpaceMedium,

            // MATIC radio button
            isShowPolygonTsWalletBalance ||
                    WalletUtil.isSpecialUsdt(walletInfo.tickerName!) ||
                    walletInfo.tickerName == 'USDT'
                ? Row(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                        width: 20,
                        child: Radio(
                            activeColor: primaryColor,
                            onChanged: (value) {
                              radioButtonSelection(value);
                            },
                            groupValue: groupValue,
                            value: 'POLYGON'),
                      ),
                      UIHelper.horizontalSpaceSmall,
                      Text('POLYGON Chain', style: headText6),
                    ],
                  )
                : Container(),
          ],
        )
      ],
    );
  }

/*---------------------------------------------------
                Info about TS wallet balance
--------------------------------------------------- */
  updateIsAlert(bool value) {
    setBusy(true);
    isAlert = value;
    log.i('update isAlert $isAlert');
    setBusy(false);
  }

  //       Info dialog

  showInfoDialog(bool isTSWalletInfo) {
    updateIsAlert(true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Platform.isIOS
            ? Theme(
                data: ThemeData.light(),
                child: CupertinoAlertDialog(
                  title: Container(
                    margin: const EdgeInsets.only(bottom: 5.0),
                    child: Center(
                        child: Text(
                      FlutterI18n.translate(context, "note"),
                      style: headText4.copyWith(
                          color: primaryColor, fontWeight: FontWeight.w500),
                    )),
                  ),
                  content: Container(
                    child: !isTSWalletInfo
                        ? Column(children: [
                            Text(
                                FlutterI18n.translate(
                                    context, "specialExchangeBalanceNote"),
                                style: headText5),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text('e.g. FAB and FAB(ETH)',
                                  style: headText5),
                            ),
                          ])
                        : Column(children: [
                            Text(FlutterI18n.translate(context, "tsWalletNote"),
                                style: headText5),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                  FlutterI18n.translate(
                                      context, "specialWithdrawNote"),
                                  style: headText5),
                            ),
                            UIHelper.verticalSpaceSmall,
                            Text(
                                FlutterI18n.translate(
                                    context, "specialWithdrawFailNote"),
                                style: headText5),
                          ]),
                  ),
                  actions: <Widget>[
                    Container(
                      margin: const EdgeInsets.all(5),
                      child: Center(
                        child: CupertinoButton(
                          padding: const EdgeInsets.only(left: 5),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(4)),
                          child: Text(
                            FlutterI18n.translate(context, "close"),
                            style:
                                bodyText2.copyWith(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                            updateIsAlert(false);
                          },
                        ),
                      ),
                    ),
                  ],
                ))
            : AlertDialog(
                titlePadding: EdgeInsets.zero,
                contentPadding: const EdgeInsets.all(5.0),
                elevation: 5,
                backgroundColor: secondaryColor,
                title: Container(
                  padding: const EdgeInsets.all(10.0),
                  color: secondaryColor.withOpacity(0.5),
                  child: Center(
                      child: Text(FlutterI18n.translate(context, "note"))),
                ),
                titleTextStyle: headText4.copyWith(fontWeight: FontWeight.bold),
                contentTextStyle: const TextStyle(color: grey),
                content: Container(
                  padding: const EdgeInsets.all(5.0),
                  child: !isTSWalletInfo
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          //  mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                              Text(
                                  FlutterI18n.translate(
                                      context, "specialExchangeBalanceNote"),
                                  style: headText5),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text('e.g. FAB and FAB(ETH)',
                                    style: headText5),
                              ),
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    updateIsAlert(false);
                                  },
                                  child: Text(
                                    FlutterI18n.translate(context, "close"),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: red),
                                  ),
                                ),
                              )
                            ])
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                              Text(
                                  FlutterI18n.translate(
                                      context, "tsWalletNote"),
                                  style: headText5),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                    FlutterI18n.translate(
                                        context, "specialWithdrawNote"),
                                    style: headText5),
                              ),
                              UIHelper.verticalSpaceSmall,
                              Text(
                                  FlutterI18n.translate(
                                      context, "specialWithdrawFailNote"),
                                  style: headText5),
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    updateIsAlert(false);
                                  },
                                  child: Text(
                                    FlutterI18n.translate(context, "close"),
                                    style: const TextStyle(color: red),
                                  ),
                                ),
                              )
                            ]),
                ));
      },
    );
  }

/*---------------------------------------------------
                    Details message toggle
--------------------------------------------------- */
  showDetailsMessageToggle() {
    setBusy(true);
    isShowDetailsMessage = !isShowDetailsMessage;
    setBusy(false);
  }

/*---------------------------------------------------------------
                        Set Withdraw Limit
-------------------------------------------------------------- */

  setWithdrawLimit(String ticker) async {
    setBusy(true);
    if (ercChainToken.feeWithdraw != null && _groupValue == 'ETH') {
      token = ercChainToken;
      setBusy(false);
      return;
    }
    if (mainChainToken.feeWithdraw != null &&
        (_groupValue == 'TRX' || _groupValue == 'FAB')) {
      token = mainChainToken;
      setBusy(false);
      return;
    }
    token = TokenModel();
    int ct = 0;
    await coinService.getCoinTypeByTickerName(ticker).then((value) {
      ct = value;
      log.i('setWithdrawLimit coin type $ct');
    });

    await tokenListDatabaseService.getByCointype(ct).then((res) async {
      if (res != null &&
          res.feeWithdraw!.isNotEmpty &&
          res.feeWithdraw! != "null") {
        token = res;
        assignToken(token);
      } else {
        await coinService
            .getSingleTokenData(ticker, coinType: ct)
            .then((resFromApi) {
          if (resFromApi != null) {
            debugPrint('token from api res ${resFromApi.toJson()}');
            token = resFromApi;
            assignToken(token);
          }
        });
      }
    });

    setBusy(false);
  }

  assignToken(TokenModel token) {
    if (_groupValue == 'ETH') ercChainToken = token;
    if (_groupValue == 'BNB') bnbChainToken = token;
    if (_groupValue == 'POLYGON') polygonChainToken = token;
    if (_groupValue == 'TRX' || _groupValue == 'FAB') {
      mainChainToken = token;
    }
  }
/*---------------------------------------------------
                      Get gas
--------------------------------------------------- */

  checkGasBalance() async {
    String address = '';
    try {
      address = await sharedService.getExgAddressFromCoreWalletDatabase();
    } catch (err) {
      log.e('catch: fetching fab address from db');
    }
    await walletService.gasBalance(address).then((data) {
      gasAmount = data;
      log.i('gas balance $gasAmount');
      if (gasAmount == 0) {
        sharedService.alertDialog(
          FlutterI18n.translate(context, "notice"),
          FlutterI18n.translate(context, "insufficientGasAmount"),
        );
      }
    }).catchError((onError) => log.e(onError));
    log.w('gas amount $gasAmount');
    return gasAmount;
  }

  // Check single coin exchange balance
  Future getSingleCoinExchangeBal() async {
    setBusy(true);
    String tickerName = '';
    if (walletInfo.tickerName == 'DSCE' || walletInfo.tickerName == 'DSC') {
      tickerName = 'DSC';
      isWithdrawChoice = true;
    } else if (walletInfo.tickerName == 'BSTE' ||
        walletInfo.tickerName == 'BST') {
      tickerName = 'BST';
      isWithdrawChoice = true;
    } else if (walletInfo.tickerName == 'FABE' ||
        walletInfo.tickerName == 'FAB') {
      tickerName = 'FAB';
      isWithdrawChoice = true;
    } else if (walletInfo.tickerName == 'EXGE' ||
        walletInfo.tickerName == 'EXG') {
      tickerName = 'EXG';
      isWithdrawChoice = true;
    } else if (walletInfo.tickerName == 'USDT' ||
        walletInfo.tickerName == 'USDTX') {
      tickerName = 'USDT';
      isWithdrawChoice = true;
      isShowFabChainBalance = false;
    } else if (walletInfo.tickerName == 'USDC' ||
        walletInfo.tickerName == 'USDCX') {
      tickerName = 'USDC';
      isWithdrawChoice = true;
      isShowFabChainBalance = false;
    } else if (walletInfo.tickerName == 'MATICM') {
      tickerName = 'MATIC';
    }
    //  else if (walletInfo.tickerName == 'USDTX') {
    //   tickerName = 'USDT';
    //   isWithdrawChoice = true;
    //   isShowFabChainBalance = false;
    //   isShowTrxTsWalletBalance = true;
    // }
    else {
      tickerName = walletInfo.tickerName!;
    }
    String fabAddress =
        await sharedService.getFabAddressFromCoreWalletDatabase();
    await apiService
        .getSingleWalletBalance(fabAddress, tickerName, walletInfo.address!)
        .then((res) {
      walletInfo.inExchange = res[0].unlockedExchangeBalance;
      log.w('single coin exchange balance check ${walletInfo.inExchange}');
    });

    if (isSubmittingTx) {
      log.i(
          'is withdraw choice and is submitting is true-- fetching ts wallet balance of group $_groupValue');
      if (_groupValue == 'ETH') await getEthChainBalance();
      if (_groupValue == 'TRX') {
        tickerName == 'TRX'
            ? await getTrxTsWalletBalance()
            : await getTrxUsdtTsWalletBalance();
      }
      if (_groupValue == 'BNB') await getBnbTsWalletBalance();
      if (_groupValue == 'POLYGON') await getPolygonTsWalletBalance();
      if (_groupValue == 'FAB') {
        tickerName == 'FAB'
            ? await getFabBalance()
            : await getFabChainBalance(tickerName);
      }
    }
    setBusy(false);
  }

/*----------------------------------------------------------------------
                        TRX 20 TS Wallet Balance
----------------------------------------------------------------------*/
  getTrxTsWalletBalance() async {
    setBusy(true);
    String trxOfficialddress = coinService.getCoinOfficalAddress('TRX');
    await apiService.getTronTsWalletBalance(trxOfficialddress).then((res) {
      trxTsWalletBalance = res['balance'] / 1e6;
      log.e('getTrxTsWalletBalance $trxTsWalletBalance');
    });
    setBusy(false);
  }

  getBnbTsWalletBalance() async {
    setBusy(true);
    String officialAddress = '';
    officialAddress = coinService.getCoinOfficalAddress('ETH');
    var fabAddress = await sharedService.getFabAddressFromCoreWalletDatabase();
    String updatedTicker = '';
    if (WalletUtil.isSpecialUsdt(walletInfo.tickerName!) ||
        walletInfo.tickerName == 'USDT') {
      updatedTicker = 'USDTB';
    } else if (walletInfo.tickerName == 'FAB' ||
        WalletUtil.isSpecialFab(walletInfo.tickerName!)) {
      updatedTicker = 'FABB';
    } else {
      updatedTicker = walletInfo.tickerName!;
    }
    await apiService
        .getSingleWalletBalance(fabAddress, updatedTicker, officialAddress)
        .then((res) {
      bnbTsWalletBalance = res[0].balance;
    });

    log.w('bnbTsWalletBalance $bnbTsWalletBalance');

    setBusy(false);
  }

  getPolygonTsWalletBalance() async {
    setBusy(true);
    String officialAddress = '';
    officialAddress = coinService.getCoinOfficalAddress('ETH');
    var fabAddress = await sharedService.getFabAddressFromCoreWalletDatabase();
    String updatedTicker = '';
    if (WalletUtil.isSpecialUsdt(walletInfo.tickerName!) ||
        walletInfo.tickerName == 'USDT') {
      updatedTicker = 'USDTM';
    } else {
      updatedTicker = walletInfo.tickerName!;
    }
    await apiService
        .getSingleWalletBalance(fabAddress, updatedTicker, officialAddress)
        .then((res) {
      polygonTsWalletBalance = res[0].balance;
    });

    log.w('POLYGON TsWalletBalance $polygonTsWalletBalance');

    setBusy(false);
  }

/*----------------------------------------------------------------------
                        TRX USDT TS Wallet Balance
----------------------------------------------------------------------*/
  getTrxUsdtTsWalletBalance() async {
    setBusy(true);

    String smartContractAddress = '';
    String ticker = '';
    if (WalletUtil.isSpecialUsdt(walletInfo.tickerName!) ||
        walletInfo.tickerName == 'USDT') {
      ticker = 'USDTX';
    } else if (walletInfo.tickerName == 'USDC' ||
        WalletUtil.isSpecialUsdc(walletInfo.tickerName!)) {
      ticker = 'USDCX';
    } else {
      ticker = walletInfo.tickerName!;
    }
    log.e(
        'getFabChainBalance tokenlist db empty, in else now-- getting data from api');
    await apiService.getTokenListUpdates().then((tokens) {
      smartContractAddress = tokens
          .firstWhere((element) => element.tickerName == ticker)
          .contract!;
    });

    String trxOfficialddress = coinService.getCoinOfficalAddress('TRX');
    await apiService
        .getTronUsdtTsWalletBalance(trxOfficialddress, smartContractAddress)
        .then((res) {
      trxTsWalletBalance = res / 1e6;
      log.e('getTrxTsWalletBalance $trxTsWalletBalance');
    });
    setBusy(false);
  }

/*----------------------------------------------------------------------
                        Fab Chain Balance
----------------------------------------------------------------------*/

  getFabBalance() async {
    setBusy(true);
    String fabAddress = coinService.getCoinOfficalAddress('FAB');
    await walletService.coinBalanceByAddress('FAB', fabAddress, '').then((res) {
      log.e('fab res $res');
      fabChainBalance = res['balance'];
    });
    setBusy(false);
  }

  getFabChainBalance(String tickerName) async {
    setBusy(true);
    var address = sharedService.getEXGOfficialAddress();

    String smartContractAddress = '';
    await coinService
        .getSmartContractAddressByTickerName(tickerName)
        .then((value) => smartContractAddress = value!);

    String balanceInfoABI = '70a08231';

    var body = {
      'address': trimHexPrefix(smartContractAddress),
      'data': balanceInfoABI + fixLength(trimHexPrefix(address), 64)
    };
    double tokenBalance;
    var url = '${fabUtils.fabBaseUrl}callcontract';
    debugPrint(
        'Fab_util -- address $address getFabTokenBalanceForABI balance by address url -- $url -- body $body');

    var response = await client.post(Uri.parse(url), body: body);
    var json = jsonDecode(response.body);
    var unlockBalance = json['executionResult']['output'];
    // if (unlockBalance == null || unlockBalance == '') {
    //   return 0.0;

    var unlockInt = BigInt.parse(unlockBalance, radix: 16);

    // if ((decimal != null) && (decimal > 0)) {
    //   tokenBalance = ((unlockInt) / BigInt.parse(pow(10, decimal).toString()));
    // } else {
    tokenBalance = NumberUtil.rawStringToDecimal(unlockInt.toString(),
            decimalPrecision: token.decimal!)
        .toDouble();

    fabChainBalance = tokenBalance;
    debugPrint('$tickerName fab chain balance $fabChainBalance');
    setBusy(false);
  }

/*----------------------------------------------------------------------
                        ETH Chain Balance
----------------------------------------------------------------------*/
  getEthChainBalance() async {
    setBusy(true);
    String officialAddress = '';
    officialAddress = coinService.getCoinOfficalAddress('ETH');
    // call to get token balance
    if (walletInfo.tickerName == 'FAB') {
      updateTickerForErc = 'FABE';
    } else if (walletInfo.tickerName == 'DSC') {
      updateTickerForErc = 'DSCE';
    } else if (walletInfo.tickerName == 'BST') {
      updateTickerForErc = 'BSTE';
    } else if (walletInfo.tickerName == 'EXG') {
      updateTickerForErc = 'EXGE';
    } else if (walletInfo.tickerName == 'USDTX') {
      updateTickerForErc = 'USDT';
    } else {
      updateTickerForErc = walletInfo.tickerName!;
    }
    ercSmartContractAddress = (await coinService
        .getSmartContractAddressByTickerName(updateTickerForErc))!;

    await getEthTokenBalanceByAddress(
            officialAddress, updateTickerForErc, ercSmartContractAddress)
        .then((res) {
      log.e('getEthChainBalance $res');
      if (walletInfo.tickerName == 'USDT' || walletInfo.tickerName == 'USDTX') {
        ethChainBalance = res['balance1e6'];
      } else if (walletInfo.tickerName == 'FABE' ||
          walletInfo.tickerName == 'FAB') {
        ethChainBalance = res['balanceIe8'];
      } else {
        ethChainBalance = res['tokenBalanceIe18'];
      }

      log.w('ethChainBalance $ethChainBalance');
    });
    setBusy(false);
  }

/*----------------------------------------------------------------------
                Radio button selection
----------------------------------------------------------------------*/

  radioButtonSelection(value) async {
    setBusy(true);
    debugPrint(value);
    _groupValue = value;
    if (value == 'FAB') {
      isShowFabChainBalance = true;
      isShowTrxTsWalletBalance = false;
      isShowPolygonTsWalletBalance = false;
      isShowBnbTsWalletBalance = false;
      if (walletInfo.tickerName != 'FAB') tokenType = 'FAB';
      // if (walletInfo.tickerName == 'FAB') walletInfo.tokenType = '';
      // updateTickerForErc = walletInfo.tickerName;
      log.i('chain type ${walletInfo.tokenType}');
      if (walletInfo.tickerName == 'FABE' && isShowFabChainBalance) {
        await setWithdrawLimit('FAB');
      } else if (walletInfo.tickerName == 'DSCE' && isShowFabChainBalance) {
        await setWithdrawLimit('DSC');
      } else if (walletInfo.tickerName == 'BSTE' && isShowFabChainBalance) {
        await setWithdrawLimit('BST');
      } else if (walletInfo.tickerName == 'EXGE' && isShowFabChainBalance) {
        await setWithdrawLimit('EXG');
      } else {
        await setWithdrawLimit(walletInfo.tickerName!);
      }
    } else if (value == 'TRX') {
      isShowPolygonTsWalletBalance = false;
      isShowBnbTsWalletBalance = false;
      isShowTrxTsWalletBalance = true;
      //   if (walletInfo.tickerName != 'TRX') walletInfo.tokenType = 'TRX';

      isSpeicalTronTokenWithdraw = true;
      if (walletInfo.tickerName == 'TRX' && isShowTrxTsWalletBalance) {
        await setWithdrawLimit('TRX');
      } else if (walletInfo.tickerName == 'USDCX' && isShowTrxTsWalletBalance) {
        await setWithdrawLimit('USDCX');
        tokenType = 'TRX';
      } else {
        await setWithdrawLimit('USDTX');
        tokenType = 'TRX';
      }
    } else if (value == 'BNB') {
      isShowBnbTsWalletBalance = true;
      isShowTrxTsWalletBalance = false;
      isShowFabChainBalance = false;
      isShowPolygonTsWalletBalance = false;
      if (WalletUtil.isSpecialUsdt(walletInfo.tickerName!) ||
          walletInfo.tickerName == 'USDT') {
        await setWithdrawLimit('USDTB');
      } else if (WalletUtil.isSpecialFab(walletInfo.tickerName!) ||
          walletInfo.tickerName == 'FAB') {
        await setWithdrawLimit('FABB');
      } else {
        await setWithdrawLimit(walletInfo.tickerName!);
      }
      tokenType = 'BNB';
    } else if (value == 'POLYGON') {
      isShowPolygonTsWalletBalance = true;
      isShowFabChainBalance = false;
      isShowBnbTsWalletBalance = false;
      isShowTrxTsWalletBalance = false;
      if (WalletUtil.isSpecialUsdt(walletInfo.tickerName!) ||
          walletInfo.tickerName == 'USDT') {
        await setWithdrawLimit('USDTM');
      } else {
        await setWithdrawLimit(walletInfo.tickerName!);
      }
      tokenType = 'POLYGON';
    } else {
      isShowTrxTsWalletBalance = false;
      isShowFabChainBalance = false;
      isShowPolygonTsWalletBalance = false;
      isShowBnbTsWalletBalance = false;
      tokenType = 'ETH';
      log.i('chain type ${walletInfo.tokenType}');
      if (walletInfo.tickerName == 'FAB' && !isShowFabChainBalance) {
        await setWithdrawLimit('FABE');
      } else if (walletInfo.tickerName == 'DSC' && !isShowFabChainBalance) {
        await setWithdrawLimit('DSCE');
      } else if (walletInfo.tickerName == 'BST' && !isShowFabChainBalance) {
        await setWithdrawLimit('BSTE');
      } else if (walletInfo.tickerName == 'EXG' && !isShowFabChainBalance) {
        await setWithdrawLimit('EXGE');
      } else if (walletInfo.tickerName == 'USDTX' &&
          !isShowTrxTsWalletBalance) {
        await setWithdrawLimit('USDT');
      } else if (walletInfo.tickerName == 'USDCX' &&
          !isShowTrxTsWalletBalance) {
        await setWithdrawLimit('USDC');
      } else {
        await setWithdrawLimit(walletInfo.tickerName!);
      }
      setBusy(false);
    }
  }

/*----------------------------------------------------------------------
                      Verify Wallet Password
----------------------------------------------------------------------*/
  checkPass() async {
    setBusy(true);
    isSubmittingTx = true;
    try {
      if (amountController.text.isEmpty) {
        sharedService.showInfoFlushbar(
            FlutterI18n.translate(context, "minimumAmountError"),
            FlutterI18n.translate(
                context, "yourWithdrawMinimumAmountaIsNotSatisfied"),
            Icons.cancel,
            red,
            context);
        setBusy(false);
        return;
      }
      await checkGasBalance();
      if (gasAmount == 0.0 || gasAmount < kanbanTransFee) {
        sharedService.alertDialog(
          FlutterI18n.translate(context, "notice"),
          FlutterI18n.translate(context, "insufficientGasAmount"),
        );
        setBusy(false);
        return;
      }

      var amount = double.tryParse(amountController.text);
      if (amount! < double.parse(token.minWithdraw!)) {
        sharedService.sharedSimpleNotification(
          FlutterI18n.translate(context, "minimumAmountError"),
          subtitle: FlutterI18n.translate(
              context, "yourWithdrawMinimumAmountaIsNotSatisfied"),
        );
        setBusy(false);
        return;
      }
      await getSingleCoinExchangeBal();

      if (amount > walletInfo.inExchange! || amount == 0 || amount.isNegative) {
        sharedService.alertDialog(
            FlutterI18n.translate(context, "invalidAmount"),
            FlutterI18n.translate(context, "pleaseEnterValidNumber"),
            isWarning: false);
        setBusy(false);
        return;
      }

      if (groupValue == 'FAB' && amount > fabChainBalance) {
        sharedService.alertDialog(FlutterI18n.translate(context, "notice"),
            '${FlutterI18n.translate(context, "lowTsWalletBalanceErrorFirstPart")} $fabChainBalance. ${FlutterI18n.translate(context, "lowTsWalletBalanceErrorSecondPart")}',
            isWarning: false);

        setBusy(false);
        return;
      }

      /// show warning like amount should be less than ts wallet balance
      /// instead of displaying the generic error
      if (groupValue == 'ETH' && amount > ethChainBalance) {
        sharedService.alertDialog(FlutterI18n.translate(context, "notice"),
            '${FlutterI18n.translate(context, "lowTsWalletBalanceErrorFirstPart")} $ethChainBalance. ${FlutterI18n.translate(context, "lowTsWalletBalanceErrorSecondPart")}',
            isWarning: false);

        setBusy(false);
        return;
      }
      if (groupValue == 'TRX' && amount > trxTsWalletBalance) {
        sharedService.alertDialog(FlutterI18n.translate(context, "notice"),
            '${FlutterI18n.translate(context, "lowTsWalletBalanceErrorFirstPart")} $trxTsWalletBalance. ${FlutterI18n.translate(context, "lowTsWalletBalanceErrorSecondPart")}',
            isWarning: false);
        setBusy(false);
        return;
      }
      if (groupValue == 'BNB' && amount > bnbTsWalletBalance) {
        sharedService.alertDialog(FlutterI18n.translate(context, "notice"),
            '${FlutterI18n.translate(context, "lowTsWalletBalanceErrorFirstPart ")} $bnbTsWalletBalance. ${FlutterI18n.translate(context, "lowTsWalletBalanceErrorSecondPart")}',
            isWarning: false);
        setBusy(false);
        return;
      }
      if (groupValue == 'POLYGON' && amount > polygonTsWalletBalance) {
        sharedService.alertDialog(FlutterI18n.translate(context, "notice"),
            '${FlutterI18n.translate(context, "lowTsWalletBalanceErrorFirstPart")} $polygonTsWalletBalance. ${FlutterI18n.translate(context, "lowTsWalletBalanceErrorSecondPart")}',
            isWarning: false);
        setBusy(false);
        return;
      }
      message = '';
      var res = await _dialogService.showDialog(
          title: FlutterI18n.translate(context, "enterPassword"),
          description: FlutterI18n.translate(
              context, "dialogManagerTypeSamePasswordNote"),
          buttonTitle: FlutterI18n.translate(context, "confirm"));
      if (res.confirmed) {
        String exgAddress =
            await sharedService.getExgAddressFromCoreWalletDatabase();
        String mnemonic = res.returnedText;
        Uint8List seed = walletService.generateSeed(mnemonic);
        // if (walletInfo.tickerName == 'FAB' && ) walletInfo.tokenType = '';

        var coinName = walletInfo.tickerName;
        var coinAddress = '';
        if (isShowFabChainBalance &&
            coinName != 'FAB' &&
            !WalletUtil.isSpecialFab(coinName!)) {
          coinAddress = exgAddress;
          tokenType = 'FAB';
          log.i('coin address is exg address');
        }

        /// Ticker is FAB but fab chain balance is false then
        /// take coin address as ETH wallet address because coin is an erc20
        else if (coinName == 'FAB' && !isShowFabChainBalance) {
          await sharedService
              .getCoinAddressFromCoreWalletDatabase('ETH')
              .then((walletAddress) => coinAddress = walletAddress);
          log.i('coin address is ETH address');
        } // i.e when user is in FABB and selects FAB withdraw
        // then token type set to empty and uses fab address
        else if ((coinName != 'FAB' && isShowFabChainBalance) &&
            WalletUtil.isSpecialFab(coinName!)) {
          coinAddress =
              await sharedService.getFabAddressFromCoreWalletDatabase();
          tokenType = '';
          coinName = 'FAB';
          log.i('coin address is FAB address');
        } else if (coinName == 'USDT' && isShowTrxTsWalletBalance) {
          await sharedService
              .getCoinAddressFromCoreWalletDatabase('TRX')
              .then((walletAddress) => coinAddress = walletAddress);
          log.i('coin address is TRX address');
        } else if (coinName == 'EXG' && !isShowFabChainBalance) {
          coinAddress = exgAddress;
          log.i('coin address is EXG address');
        } else if ((coinName == 'USDT' ||
                WalletUtil.isSpecialUsdt(coinName!)) &&
            isShowTrxTsWalletBalance) {
          coinAddress =
              await sharedService.getCoinAddressFromCoreWalletDatabase('TRX');
          log.i('coin address is TRX address');
          coinName = 'USDTX';
        } else {
          coinAddress = walletInfo.address!;
          log.i('coin address is its own wallet info address');
        }
        // if (!isShowFabChainBalance) {
        //   amount = BigInt.tryParse(amountController.text);
        // }
        if (coinName == 'BCH') {
          await walletService
              .getBchAddressDetails(coinAddress)
              .then((addressDetails) =>
                  coinAddress = addressDetails['legacyAddress'])
              .catchError((err) {
            log.e('get bch address details Catch - $err');
          });
        }

        var kanbanPrice = int.tryParse(kanbanGasPriceTextController.text);
        var kanbanGasLimit = int.tryParse(kanbanGasLimitTextController.text);
        // BigInt bigIntAmount = BigInt.tryParse(amountController.text);
        // log.w('Big int from amount string $bigIntAmount');
        // if (bigIntAmount == null) {
        //   bigIntAmount = BigInt.from(amount);
        //   log.w('Bigint $bigIntAmount from amount $amount ');
        // }

        if (walletInfo.tickerName == 'TRX' ||
            walletInfo.tokenType == 'TRX' ||
            walletInfo.tickerName == 'USDTX') {
          int kanbanGasPrice = environment['chains']['KANBAN']['gasPrice'];
          int kanbanGasLimit = environment['chains']['KANBAN']['gasLimit'];
          await walletService
              .withdrawTron(seed, coinName!, coinAddress, tokenType, amount,
                  kanbanPrice, kanbanGasLimit)
              .then((ret) {
            log.w(ret);
            bool success = ret["success"];
            if (success && ret['transactionHash'] != null) {
              String txId = ret['transactionHash'];
              log.i('txid $txId');
              amountController.text = '';
              serverError = '';
              isShowErrorDetailsButton = false;
              message = txId;
            } else {
              serverError = ret['data'].toString();
              if (serverError.isEmpty) {
                var errMsg = FlutterI18n.translate(context, "serverError");
                error(errMsg);
                isShowErrorDetailsButton = true;
                isSubmittingTx = false;
              }
            }
            sharedService.alertDialog(
                success && ret['transactionHash'] != null
                    ? FlutterI18n.translate(
                        context, "withdrawTransactionSuccessful")
                    : FlutterI18n.translate(
                        context, "withdrawTransactionFailed"),
                success ? "" : FlutterI18n.translate(context, "serverError"),
                isWarning: false);
          }).catchError((err) {
            log.e('Withdraw catch $err');
            isShowErrorDetailsButton = true;
            isSubmittingTx = false;
            serverError = err.toString();
          });
        } else {
          // withdraw function
          await walletService
              .withdrawDo(seed, coinName!, coinAddress, tokenType, amount,
                  kanbanPrice, kanbanGasLimit, isSpeicalTronTokenWithdraw)
              .then((ret) {
            log.w(ret);
            bool success = ret["success"];
            if (success && ret['transactionHash'] != null) {
              String txId = ret['transactionHash'];
              log.i('txid $txId');
              amountController.text = '';
              serverError = '';
              isShowErrorDetailsButton = false;
              message = txId;
            } else {
              serverError = ret['data'];
              if (serverError == '') {
                var errMsg = FlutterI18n.translate(context, "serverError");
                error(errMsg);
                isShowErrorDetailsButton = true;
                isSubmittingTx = false;
              }
            }
            sharedService.sharedSimpleNotification(
                success && ret['transactionHash'] != null
                    ? FlutterI18n.translate(
                        context, "withdrawTransactionSuccessful")
                    : FlutterI18n.translate(
                        context, "withdrawTransactionFailed"),
                subtitle: success
                    ? ""
                    : FlutterI18n.translate(context, "serverError"),
                isError: !success ? true : false);
          }).catchError((err) {
            log.e('Withdraw catch $err');
            isShowErrorDetailsButton = true;
            serverError = err.toString();
            isSubmittingTx = false;
          });
        }
      } else if (!res.confirmed && res.returnedText == 'Closed') {
        debugPrint('else if close button pressed');
        isSubmittingTx = false;
      } else {
        debugPrint('else');
        if (res.returnedText != 'Closed') {
          showNotification(context);
          isSubmittingTx = false;
        }
      }
    } catch (err) {
      isShowErrorDetailsButton = true;
      serverError = err.toString();
      log.e('Withdraw catch $err');
      isSubmittingTx = false;
    }
    isSubmittingTx = false;
    setBusy(false);
  }

  showNotification(context) {
    setBusy(true);
    sharedService.showInfoFlushbar(
        FlutterI18n.translate(context, "passwordMismatch"),
        FlutterI18n.translate(context, "pleaseProvideTheCorrectPassword"),
        Icons.cancel,
        red,
        context);
    setBusy(false);
  }

  // update Transaction Fee

  updateTransFee() async {
    setBusy(true);
    var kanbanPrice = int.tryParse(kanbanGasPriceTextController.text);
    var kanbanGasLimit = int.tryParse(kanbanGasLimitTextController.text);

    var kanbanPriceBig = BigInt.from(kanbanPrice!);
    var kanbanGasLimitBig = BigInt.from(kanbanGasLimit!);
    var kanbanTransFeeDouble = NumberUtil.rawStringToDecimal(
            (kanbanPriceBig * kanbanGasLimitBig).toString())
        .toDouble();
    debugPrint('Update trans fee $kanbanTransFeeDouble');

    kanbanTransFee = kanbanTransFeeDouble;
    setBusy(false);
  }

// Copy txid and display flushbar
  copyAndShowNotificatio(String message) {
    sharedService.copyAddress(context, message);
  }
}
