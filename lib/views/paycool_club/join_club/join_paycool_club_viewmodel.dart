import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import 'package:paycool/constants/route_names.dart';
import 'package:paycool/environments/environment.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/models/wallet/wallet_balance.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/api_service.dart';
import 'package:paycool/services/db/core_wallet_database_service.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/services/navigation_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/utils/abi_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:paycool/utils/barcode_util.dart';
import 'package:paycool/utils/kanban.util.dart';
import 'package:paycool/utils/number_util.dart';
import 'package:paycool/utils/wallet/wallet_util.dart';
import 'package:paycool/views/paycool_club/join_club/join_club_payment_model.dart';
import 'package:paycool/views/paycool_club/paycool_club_service.dart';
import 'package:stacked/stacked.dart';
import 'package:paycool/services/local_dialog_service.dart';

class JoinPayCoolClubViewModel extends BaseViewModel {
  final log = getLogger('JoinPayCoolClubViewModel');
  final apiService = locator<ApiService>();
  SharedService sharedService = locator<SharedService>();
  final walletService = locator<WalletService>();
  final dialogService = locator<LocalDialogService>();
  final payCoolClubService = locator<PayCoolClubService>();
  final coreWalletDatabaseService = locator<CoreWalletDatabaseService>();
  final navigationService = locator<NavigationService>();
  final storageService = locator<LocalStorageService>();

  BuildContext context;
  bool isDUSD = false;
  int gasPrice = environment["chains"]["FAB"]["gasPrice"];
  int gasLimit = environment["chains"]["FAB"]["gasLimit"];
  int satoshisPerBytes = environment["chains"]["FAB"]["satoshisPerBytes"];
  double gasAmount = 0.0;

  String exgWalletAddress = '';
  var paycoolReferralAddress =
      environment['addresses']['smartContract']['PaycoolReferralAddress'];

  String dusdWalletAddress = '';
  double dusdExchangeBalance = 0.0;
  String usdtWalletAddress = '';
  double usdtExchangeBalance = 0.0;

  String txHash = '';
  String errorMessage = '';
  String fabAddress = '';

  final referralCode = TextEditingController();
  bool isEnoughDusdWalletBalance = true;
  double fixedAmountToPay = 10000.0;
  JoinClubPaymentModel scanToPayModel = JoinClubPaymentModel();
  bool isValidReferralAddress = false;
  String _groupValue;
  get groupValue => _groupValue;
/*--------------------------------------------------------
                    INIT
--------------------------------------------------------*/
  void init() async {
    setBusy(true);
    _groupValue = 'DUSD';
    await getExchangeBalances();
    exgWalletAddress =
        await sharedService.getExgAddressFromCoreWalletDatabase();

    log.i('Exg wallet address $exgWalletAddress');
    // CoinUtil.getCoinOfficalAddress('DUSD');
    referralCode.text = '';
    if (scanToPayModel != null && scanToPayModel.datAbiHex != null) {
      log.i('in scan to pay if ${scanToPayModel.toJson()}');
      var extractedReferralAddress =
          extractReferralAddressFromPayCoolClubScannedAbiHex(
              scanToPayModel.datAbiHex);
      setBusy(true);
      referralCode.text = extractedReferralAddress['referralAddress'];
      setBusy(false);
    }
    await getGas();
    setBusy(false);
  }

/*--------------------------------------------------------
                    On radio button selected
--------------------------------------------------------*/
  onPaymentRadioSelection(val) {
    setBusy(true);
    _groupValue = val;
    setBusy(false);
  }

  onTextFieldChange(String referralAddress) async {
    // await payCoolClubService
    //     .isValidReferralCode(referralAddress)
    //     .then((value) {
    //   if (value != null) {
    //     log.w('isValid paste $value');

    //     isValidReferralAddress = value;
    //   }
    // });
  }
/*--------------------------------------------------------
                    Extract data from abihex
--------------------------------------------------------*/

  extractDataFromAbiHex() {
    String abiHex = scanToPayModel.datAbiHex;
    String abi = abiHex.substring(0, 10);
    debugPrint(abi.toString());
    // String orderIdHex = abiHex.substring(10, 74);
    // debugPrint('orderIdHex $orderIdHex');
    String coinTypeHex = abiHex.substring(74, 138);
    int coinType = NumberUtil.hexToInt(coinTypeHex);
    debugPrint('coin type $coinType');
    var amountHex = abiHex.substring(138, abiHex.length);
    fixedAmountToPay = NumberUtil.hexToDouble(amountHex);
    // StringUtils.hexToAscii(orderIdHex);
  }

/*--------------------------------------------------------
                      pasteClipBoardData
--------------------------------------------------------*/
  pasteClipBoardData() async {
    FocusScope.of(context).requestFocus(FocusNode());
    ClipboardData data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null) {
      setBusy(true);
      referralCode.text = '';
      referralCode.text = data.text;
      log.i('paste data ${referralCode.text}');
      setBusy(false);
    }
  }

/*--------------------------------------------------------
                      Barcode Scan
--------------------------------------------------------*/
  scanBarCode() async {
    log.i("Barcode: going to scan");
    setBusy(true);

    try {
      FocusScope.of(context).requestFocus(FocusNode());
      log.i("Barcode: try");
      String barcode = '';

      var result = await BarcodeUtils().scanQR(context);
      barcode = result;
      log.i("Barcode Res: $result ");

      referralCode.text = barcode;
      setBusy(false);
    } on PlatformException catch (e) {
      FocusScope.of(context).requestFocus(FocusNode());
      log.i("Barcode PlatformException : ");
      log.i(e.toString());
      if (e.code == "PERMISSION_NOT_GRANTED") {
        setBusy(false);
        sharedService.alertDialog(
            '', FlutterI18n.translate(context, "userAccessDenied"),
            isWarning: false);
        // receiverWalletAddressTextController.text =
        //     FlutterI18n.translate(context, "userAccessDenied");
      } else {
        setBusy(false);
        sharedService.alertDialog(
            '', FlutterI18n.translate(context, "unknownError"),
            isWarning: false);
        // receiverWalletAddressTextController.text =
        //     '${FlutterI18n.translate(context, "unknownError")}: $e';
      }
    } on FormatException {
      FocusScope.of(context).requestFocus(FocusNode());
      log.i("Barcode FormatException : ");
      // log.i(e.toString());
      setBusy(false);
      // sharedService.alertDialog(FlutterI18n.translate(context, "scanCancelled"),
      //     FlutterI18n.translate(context, "userReturnedByPressingBackButton"),
      //     isWarning: false);
    } catch (e) {
      log.i("Barcode error : ");
      log.i(e.toString());
      setBusy(false);
      sharedService.alertDialog(
          '', FlutterI18n.translate(context, "unknownError"),
          isWarning: false);
      // receiverWalletAddressTextController.text =
      //     '${FlutterI18n.translate(context, "unknownError")}: $e';
    }
    setBusy(false);
  }

/*----------------------------------------------------------------------
                    Get Dusd exchange balance
----------------------------------------------------------------------*/
  getExchangeBalances() async {
    setBusy(true);
    List<String> paymentCoins = ['DUSD', 'USDT'];
    fabAddress = await sharedService.getFabAddressFromCoreWalletDatabase();
    var walletUtil = WalletUtil();
    for (var i = 0; i < paymentCoins.length; i++) {
      await walletUtil
          .getWalletInfoObjFromWalletBalance(
              WalletBalance(coin: paymentCoins[i]))
          .then((wallet) {
        if (paymentCoins[i] == 'DUSD') {
          dusdWalletAddress = wallet.address;
        } else {
          usdtWalletAddress = wallet.address;
        }
      });
    }

    log.i('dusdWalletAddress $dusdWalletAddress');
    log.i('usdtWalletAddress $usdtWalletAddress');
    // Get single wallet balance
    for (var i = 0; i < paymentCoins.length; i++) {
      await apiService
          .getSingleWalletBalance(fabAddress, paymentCoins[i],
              paymentCoins[i] == 'USDT' ? usdtWalletAddress : dusdWalletAddress)
          .then((walletBalance) async {
        if (walletBalance != null &&
            !walletBalance[0].unlockedExchangeBalance.isNegative) {
          log.w(walletBalance[0].unlockedExchangeBalance);
          paymentCoins[i] == 'USDT'
              ? usdtExchangeBalance = walletBalance[0].unlockedExchangeBalance
              : dusdExchangeBalance = walletBalance[0].unlockedExchangeBalance;
        }
        //  else {
        //   String address = await walletService.getExgAddressFromWalletDatabase();
        //   await walletService
        //       .getAllExchangeBalances(address)
        //       .then((exchangeBalanceList) {
        //     if (exchangeBalanceList != null) {
        //       exchangeBalanceList.forEach(() {});
        //     }
        //   });
        // }
      }).catchError((err) {
        log.e(err);
        setBusy(false);
        throw Exception(err);
      });
    }
    setBusy(false);
  }

/*---------------------------------------------------
                      Get gas
--------------------------------------------------- */

  getGas() async {
    String address = await sharedService.getExgAddressFromCoreWalletDatabase();
    await walletService.gasBalance(address).then((data) {
      gasAmount = data;
    }).catchError((onError) => log.e(onError));
    log.w('gas amount $gasAmount');
  }

  // Send coin

  sendCoinFunc(
      seed, dusdCoinType, officialBindpayAddress, fixedAmountToPay) async {
    await walletService
        .sendCoin(seed, dusdCoinType, officialBindpayAddress, fixedAmountToPay)
        .then((res) async {
      log.w('Result $res');
      txHash = res['transactionHash'];

      if (txHash != null || txHash.isNotEmpty) {
        log.w('Txhash $txHash');

        sharedService.alertDialog(
            FlutterI18n.translate(context, "orderCreatedSuccessfully"),
            FlutterI18n.translate(context, "goToDashboard"),
            path: PayCoolClubDashboardViewRoute);
        // PaycoolCreateOrderModel paycoolCreateOrder =
        //     new PaycoolCreateOrderModel(
        //         walletAddress: fabAddress,
        //         referralAddress: referralCode.text,
        //         currency: 'DUSD',
        //         campaignId: 2,
        //         amount: fixedAmountToPay,
        //         transactionId: txHash);
        // await payCoolClubService
        //     .createOrder(paycoolCreateOrder)
        //     .then((res) {
        //   // if (res != null) {
        //   log.w('create order res $res');
        //   // }
        //   // else {
        //   //   setBusy(false);
        //   //   navigationService.navigateUsingPushReplacementNamed(
        //   //       PayCoolClubDashboardViewRoute);
        //   // }
        // });

      } else {
        sharedService.alertDialog(
            FlutterI18n.translate(context, "transanctionFailed"),
            FlutterI18n.translate(context, "pleaseTryAgainLater"));
      }
      setBusy(false);
    }).timeout(const Duration(seconds: 25), onTimeout: () {
      log.e('In time out');
      setBusy(false);
      sharedService.alertDialog(
          '', FlutterI18n.translate(context, "pleaseTryAgainLater"),
          isWarning: false);
      return;
    }).catchError((error) {
      log.e('In Catch error - $error');
      sharedService.alertDialog(FlutterI18n.translate(context, "networkIssue"),
          FlutterI18n.translate(context, "transanctionFailed"),
          isWarning: false);

      setBusy(false);
    });
  }

// generate raw tx and send
  generateRawTxAndSend(seed, abiHex, toAddress) async {
    // var rawTxHex = await walletService.generateRawTx(seed, abiHex, toAddress);
    // var resKanban = await sendKanbanRawTransaction(rawTxHex);
    // var res;
    // if (resKanban != null && resKanban["transactionHash"] != null) {
    //   res = resKanban["transactionHash"];
    // }
    // return res;
  }
/*----------------------------------------------------------------------
                    Join Club
----------------------------------------------------------------------*/

  joinClub() async {
    setBusy(true);

    if (referralCode.text.isEmpty) {
      sharedService.sharedSimpleNotification(
          FlutterI18n.translate(context, "invalidReferralCode"));
      setBusy(false);
      return;
    }

    await payCoolClubService.isValidMember(referralCode.text).then((value) {
      if (value != null) {
        log.w('isValid paste $value');

        isValidReferralAddress = value;
      }
    });
    if (!isValidReferralAddress) {
      sharedService.sharedSimpleNotification(
          FlutterI18n.translate(context, "invalidReferralCode"));
      setBusy(false);
      return;
    }

    await getGas();
    if (gasAmount == 0.0) {
      sharedService.sharedSimpleNotification(
          FlutterI18n.translate(context, "notice"),
          subtitle: FlutterI18n.translate(context, "insufficientGasAmount"));
      setBusy(false);
      return;
    }
    // await walletService
    //     .checkCoinWalletBalance(.5, 'FAB')
    //     .then((isCorrectAmount) {
    //   if (!isCorrectAmount) {
    //     sharedService.errorSimpleNotification('FAB',
    //         subtitle: FlutterI18n.translate(context, "insufficientBalance"));
    //     setBusy(false);
    //     return;
    //   }
    // });
    // Check DUSD balance if less than $2000 then return
    await getExchangeBalances();
    if (dusdExchangeBalance < fixedAmountToPay && groupValue == 'DUSD') {
      sharedService.sharedSimpleNotification('DUSD',
          subtitle: FlutterI18n.translate(context, "insufficientBalance"));
      setBusy(false);
      return;
    }
    if (usdtExchangeBalance < fixedAmountToPay && groupValue == 'USDT') {
      sharedService.sharedSimpleNotification('USDT',
          subtitle: FlutterI18n.translate(context, "insufficientBalance"));
      setBusy(false);
      return;
    }

    //var coinPoolAddress = await getCoinPoolAddress();

    var dialogResponse = await dialogService.showDialog(
        title: FlutterI18n.translate(context, "enterPassword"),
        description:
            FlutterI18n.translate(context, "dialogManagerTypeSamePasswordNote"),
        buttonTitle: FlutterI18n.translate(context, "confirm"));

    if (dialogResponse.confirmed) {
      errorMessage = '';
      String mnemonic = dialogResponse.returnedText;
      var seed = walletService.generateSeed(mnemonic);
      int dusdCoinType = 131074;
      int usdtCoinType = 196609;
      if (scanToPayModel != null) {
        log.i('in scan to pay if ${scanToPayModel.toJson()}');

        // if (scanToPayModel.toAddress == coinPoolAddress)
        //   await sendCoinFunc(
        //       seed, dusdCoinType, officialBindpayAddress, fixedAmountToPay);
        // else {
        //   extractDataFromAbiHex();
        var txId = await generateRawTxAndSend(
            seed, scanToPayModel.datAbiHex, scanToPayModel.toAddress);
        if (txId != null) {
          debugPrint('final if res txid $txId');
          String walletAddress =
              extractWalletAddressFromPayCoolClubScannedAbiHex(
                  scanToPayModel.datAbiHex);
          await payCoolClubService.saveOrder(walletAddress, txId).then((res) {
            sharedService.alertDialog(
                FlutterI18n.translate(context, "orderCreatedSuccessfully"),
                FlutterI18n.translate(context, "paymentProcess"),
                path: DashboardViewRoute);
          });
          setBusy(false);
        }
        // }
      } else {
        var abiHex = getPayCoolClubFuncABI(
            groupValue == "DUSD" ? dusdCoinType : usdtCoinType,
            fabAddress,
            referralCode.text);
        var txId =
            await generateRawTxAndSend(seed, abiHex, paycoolReferralAddress);
        if (txId != null) {
          debugPrint('final else res txid $txId');
          await payCoolClubService.saveOrder(fabAddress, txId).then((res) {
            sharedService.alertDialog(
                FlutterI18n.translate(context, "orderCreatedSuccessfully"),
                FlutterI18n.translate(context, "paymentProcess"),
                path: PayCoolClubDashboardViewRoute);
          });
          storageService.payCoolClubPaymentReceipt = txId;
          setBusy(false);
        }
      }
    } else if (dialogResponse.returnedText != 'Closed' &&
        !dialogResponse.confirmed) {
      setBusy(false);
      return errorMessage =
          FlutterI18n.translate(context, "pleaseProvideTheCorrectPassword");
    } else {
      setBusy(false);
    }
  }
}
