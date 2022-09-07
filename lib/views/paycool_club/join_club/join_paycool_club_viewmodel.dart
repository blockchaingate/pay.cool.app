import 'package:exchangily_core/exchangily_core.dart';
import 'package:flutter/services.dart';
import 'package:paycool/constants/paycool_constants.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:paycool/utils/barcode_util.dart';
import 'package:paycool/views/paycool_club/paycool_club_service.dart';
import 'package:paycool/views/paycool/paycool_model.dart';

import '../../../utils/paycool_util.dart';

class JoinPayCoolClubViewModel extends BaseViewModel {
  final log = getLogger('JoinPayCoolClubViewModel');
  final apiService = localLocator<ApiService>();
  SharedService sharedService = localLocator<SharedService>();
  final walletService = localLocator<WalletService>();
  final payCoolClubService = localLocator<PayCoolClubService>();
  final coreWalletDatabaseService = localLocator<CoreWalletDatabaseService>();
  final navigationService = localLocator<NavigationService>();
  final storageService = localLocator<LocalStorageService>();
  final environmentService = locator<EnvironmentService>();
  final dialogService = locator<DialogService>();

  BuildContext context;
  bool isDUSD = false;
  Decimal gasAmount = Constants.decimalZero;

  String exgWalletAddress = '';

  String dusdWalletAddress = '';
  Decimal dusdExchangeBalance = Constants.decimalZero;
  String usdtWalletAddress = '';
  Decimal usdtExchangeBalance = Constants.decimalZero;

  String txHash = '';
  String errorMessage = '';
  String fabAddress = '';

  final referralCode = TextEditingController();
  bool isEnoughDusdWalletBalance = true;
  Decimal fixedAmountToPay = Decimal.parse("10000.0");
  ScanToPayModel scanToPayModel = ScanToPayModel();
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
          PaycoolUtil.extractReferralAddressFromAbiHex(scanToPayModel.datAbiHex,
              EnvConfig(isProd: environmentService.kReleaseMode));
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
          .setAppWallet(AppWallet(tickerName: paymentCoins[i]))
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
          .getSingleWalletBalanceV2(
              environmentService.kanbanBaseUrl(),
              fabAddress,
              paymentCoins[i],
              paymentCoins[i] == 'USDT' ? usdtWalletAddress : dusdWalletAddress)
          .then((walletBalance) async {
        if (walletBalance != null &&
            !walletBalance[0].unlockedExchangeBalance.toDouble().isNegative) {
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
    await walletService
        .gasBalance(environmentService.kanbanBaseUrl(), address)
        .then((data) {
      gasAmount = data;
    }).catchError((onError) => log.e(onError));
    log.w('gas amount $gasAmount');
  }

  // Send coin

  sendCoinFunc(
      seed, dusdCoinType, officialBindpayAddress, fixedAmountToPay) async {
    var txModel = TransactionModel(
        seed: seed,
        amount: fixedAmountToPay,
        toAddress: officialBindpayAddress);
    var kanbanEnvConfig = environmentService.chainEnvConfig('Kanban');

    var envConfig = EnvConfig(
        coinType: dusdCoinType,
        kanbanBaseUrl: kanbanEnvConfig.kanbanBaseUrl,
        gasLimit: kanbanEnvConfig.gasLimit,
        gasPrice: kanbanEnvConfig.gasPrice);

    var txHex = await walletService.txHexforSendCoin(txModel, envConfig);
    var appData =
        await sharedService.sharedAppData(Constants.exchangilyAppName);
    await KanbanUtils.sendRawKanbanTransaction(
            envConfig.kanbanBaseUrl, txHex, appData)
        .then((res) async {
      log.w('Result $res');
      txHash = res['transactionHash'];

      if (txHash != null || txHash.isNotEmpty) {
        log.w('Txhash $txHash');

        sharedService.alertDialog(
            FlutterI18n.translate(context, "orderCreatedSuccessfully"),
            FlutterI18n.translate(context, "goToDashboard"),
            path: PaycoolConstants.payCoolClubDashboardViewRoute);
      } else {
        sharedService.alertDialog(
          FlutterI18n.translate(context, "transanctionFailed"),
          FlutterI18n.translate(context, "pleaseTryAgainLater"),
        );
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

  generateRawTxAndSend(seed, abiHex, toAddress) async {
    var kanbanEnvConfig = environmentService.chainEnvConfig('Kanban');

    var transactionData = await walletService.assignTransactionData(
        seed, environmentService.envConfigExgKeyPair());

    var appData =
        await sharedService.sharedAppData(Constants.exchangilyAppName);
    var txModel = TransactionModel(
        seed: seed,
        abiHex: abiHex,
        nonce: transactionData.nonce,
        appData: appData,
        privateKey: transactionData.privateKey,
        toAddress: transactionData.toAddress,
        kanbanAddress: transactionData.kanbanAddress);

    var rawTxHex =
        await walletService.txHexforSendCoin(txModel, kanbanEnvConfig);

    var resKanban = await KanbanUtils.sendRawKanbanTransaction(
        kanbanEnvConfig.kanbanBaseUrl, rawTxHex, txModel.appData);

    var res;
    if (resKanban != null && resKanban["transactionHash"] != null) {
      res = resKanban["transactionHash"];
    }
    return res;
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

    await payCoolClubService
        .isValidReferralCode(referralCode.text)
        .then((value) {
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
    if (gasAmount == Constants.decimalZero) {
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
      var seed = MnemonicUtils.generateSeed(mnemonic);
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
          String walletAddress = PaycoolUtil.extractWalletAddressFromAbiHex(
              scanToPayModel.datAbiHex,
              EnvConfig(isProd: environmentService.kReleaseMode));
          await payCoolClubService.saveOrder(walletAddress, txId).then((res) {
            sharedService.alertDialog(
                FlutterI18n.translate(context, "orderCreatedSuccessfully"),
                FlutterI18n.translate(context, "paymentProcess"),
                path: dashboardViewRoute);
          });
          setBusy(false);
        }
        // }
      } else {
        var abiHex = PaycoolUtil.getPayCoolClubFuncABI(
            groupValue == "DUSD" ? dusdCoinType : usdtCoinType,
            fabAddress,
            referralCode.text);
        var txId = await generateRawTxAndSend(
            seed,
            abiHex,
            environmentService
                .smartContractAddress('PaycoolSmartContractAddress'));
        if (txId != null) {
          debugPrint('final else res txid $txId');
          await payCoolClubService.saveOrder(fabAddress, txId).then((res) {
            sharedService.alertDialog(
                FlutterI18n.translate(context, "orderCreatedSuccessfully"),
                FlutterI18n.translate(context, "paymentProcess"),
                path: PaycoolConstants.payCoolClubDashboardViewRoute);
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
