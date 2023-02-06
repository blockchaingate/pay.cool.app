import 'dart:typed_data';
import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/environments/environment.dart';
import 'package:paycool/models/wallet/token_model.dart';
import 'package:paycool/models/wallet/wallet.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/api_service.dart';
import 'package:paycool/services/coin_service.dart';
import 'package:paycool/services/db/token_list_database_service.dart';
import 'package:paycool/services/db/wallet_database_service.dart';
import 'package:paycool/services/local_dialog_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/utils/number_util.dart';
import 'package:stacked/stacked.dart';
import '../../../../logger.dart';

class MoveToExchangeViewModel extends BaseViewModel {
  final log = getLogger('MoveToExchangeViewModel');

  final LocalDialogService _dialogService = locator<LocalDialogService>();
  WalletService walletService = locator<WalletService>();
  ApiService apiService = locator<ApiService>();
  SharedService sharedService = locator<SharedService>();
  TokenListDatabaseService tokenListDatabaseService =
      locator<TokenListDatabaseService>();
  WalletDatabaseService walletDatabaseService =
      locator<WalletDatabaseService>();
  final coinService = locator<CoinService>();
  late WalletInfo walletInfo;
  late BuildContext context;
  final gasPriceTextController = TextEditingController();
  final gasLimitTextController = TextEditingController();
  final satoshisPerByteTextController = TextEditingController();
  final kanbanGasPriceTextController = TextEditingController();
  final kanbanGasLimitTextController = TextEditingController();
  double transFee = 0.0;
  double kanbanTransFee = 0.0;
  bool transFeeAdvance = false;
  String coinName = '';
  String tokenType = '';
  String message = '';
  final amountController = TextEditingController();
  bool isValidAmount = false;
  double gasAmount = 0.0;
  bool isShowErrorDetailsButton = false;
  bool isShowDetailsMessage = false;
  String serverError = '';
  String specialTicker = '';
  var res;
  double amount = 0.0;
  String feeUnit = '';
  int decimalLimit = 6;
  double unconfirmedBalance = 0.0;
  TokenModel tokenModel = TokenModel();
  double chainBalance = 0.0;
  void initState() async {
    setBusy(true);
    coinName = walletInfo.tickerName.toString();
    if (coinName == 'FAB') walletInfo.tokenType = '';
    tokenType = walletInfo.tokenType.toString();
    //   if (coinName != 'TRX' && coinName != 'USDTX') {
    setFee();
    await getGas();
    //  }
    specialTicker = walletService.updateSpecialTokensTickerNameForTxHistory(
        walletInfo.tickerName.toString())['tickerName'];
    refreshBalance();

    if (coinName == 'BTC') {
      feeUnit = 'BTC';
    } else if (coinName == 'ETH' || tokenType == 'ETH') {
      feeUnit = 'ETH';
    } else if (coinName == 'FAB') {
      feeUnit = 'FAB';
    } else if (tokenType == 'FAB') {
      feeUnit = 'FAB';
    }
    await coinService
        .getSingleTokenData((walletInfo.tickerName.toString()))
        .then((t) {
      tokenModel = t!;
      decimalLimit = t.decimal!;
    });
    if (decimalLimit == null || decimalLimit == 0) decimalLimit = 8;
    if (tokenType.isNotEmpty) await getNativeChainTickerBalance();
    setBusy(false);
  }

  // get native chain ticker balance
  getNativeChainTickerBalance() async {
    var fabAddress = await sharedService.getFabAddressFromCoreWalletDatabase();

    var _tokenType = tokenType == 'POLYGON' ? 'MATICM' : tokenType;
    await apiService
        .getSingleWalletBalance(
            fabAddress, _tokenType, walletInfo.address.toString())
        .then((walletBalance) => chainBalance = walletBalance.first.balance!);
  }

  showDetailsMessageToggle() {
    setBusy(true);
    isShowDetailsMessage = !isShowDetailsMessage;
    setBusy(false);
  }

  fillMaxAmount() {
    setBusy(true);
    amountController.text = NumberUtil()
        .truncateDoubleWithoutRouding(walletInfo.availableBalance!,
            precision: decimalLimit)
        .toString();
    amount = double.parse(amountController.text);
    setBusy(false);
    updateTransFee();
    debugPrint(transFee.toString());
  }

/*---------------------------------------------------
                      Set fee
--------------------------------------------------- */

  setFee() async {
    if (coinName == 'BTC') {
      satoshisPerByteTextController.text =
          environment["chains"]["BTC"]["satoshisPerBytes"].toString();
    } else if (coinName == 'LTC') {
      satoshisPerByteTextController.text =
          environment["chains"]["LTC"]["satoshisPerBytes"].toString();
    } else if (coinName == 'DOGE') {
      satoshisPerByteTextController.text =
          environment["chains"]["DOGE"]["satoshisPerBytes"].toString();
    } else if (coinName == 'ETH' || tokenType == 'ETH') {
      //gasPriceTextController.text =
      //    environment["chains"]["ETH"]["gasPrice"].toString();
      var gasPriceReal = await walletService.getEthGasPrice();
      gasPriceTextController.text = gasPriceReal.toString();
      gasLimitTextController.text =
          environment["chains"]["ETH"]["gasLimit"].toString();

      if (tokenType == 'ETH') {
        gasLimitTextController.text =
            environment["chains"]["ETH"]["gasLimitToken"].toString();
      }
    } else if (coinName == 'FAB') {
      satoshisPerByteTextController.text =
          environment["chains"]["FAB"]["satoshisPerBytes"].toString();
    } else if (tokenType == 'FAB') {
      satoshisPerByteTextController.text =
          environment["chains"]["FAB"]["satoshisPerBytes"].toString();
      gasPriceTextController.text =
          environment["chains"]["FAB"]["gasPrice"].toString();
      gasLimitTextController.text =
          environment["chains"]["FAB"]["gasLimit"].toString();
    }
    kanbanGasPriceTextController.text =
        environment["chains"]["KANBAN"]["gasPrice"].toString();
    kanbanGasLimitTextController.text =
        environment["chains"]["KANBAN"]["gasLimit"].toString();
  }

/*---------------------------------------------------
                      Get gas
--------------------------------------------------- */

  getGas() async {
    String address = await sharedService.getExgAddressFromCoreWalletDatabase();
    await walletService.gasBalance(address).then((data) {
      gasAmount = data;
      if (gasAmount < 0.5) {
        sharedService.alertDialog(
          FlutterI18n.translate(context, "notice"),
          FlutterI18n.translate(context, "insufficientGasAmount"),
        );
      }
    }).catchError((onError) => log.e(onError));
    log.w('gas amount $gasAmount');
    return gasAmount;
  }

  bool isTrx() {
    log.w(
        'tickername ${walletInfo.tickerName}:  isTrx ${walletInfo.tickerName == 'TRX' || walletInfo.tokenType == 'TRX'}');
    return walletInfo.tickerName == 'TRX' || walletInfo.tokenType == 'TRX'
        ? true
        : false;
  }
/*---------------------------------------------------
                Check pass and amount
--------------------------------------------------- */

  Future<double> amountAfterFee({bool isMaxAmount = false}) async {
    setBusy(true);
    if (amountController.text == '.') {
      setBusy(false);
      return 0.0;
    }
    if (amountController.text.isEmpty) {
      transFee = 0.0;
      kanbanTransFee = 0.0;
      setBusy(false);
      return 0.0;
    }
    amount = NumberUtil().truncateDoubleWithoutRouding(
        double.parse(amountController.text),
        precision: decimalLimit);
    log.w('amountAfterFee func: amount $amount');

    double finalAmount = 0.0;
    // update if transfee is 0
    await updateTransFee();
    // if tron coins then assign fee accordingly
    if (isTrx()) {
      if (walletInfo.tickerName == 'USDTX') {
        transFee = 15;
        finalAmount = amount;
        finalAmount <= walletInfo.availableBalance!
            ? isValidAmount = true
            : isValidAmount = false;
      }

      if (walletInfo.tickerName == 'TRX') {
        transFee = 1.0;
        finalAmount = isMaxAmount ? amount - transFee : amount + transFee;
      }
    } else {
      // in any token transfer, gas fee is paid in native tokens so
      // in case of non-native tokens, need to check the balance of native tokens
      // so that there is fee to pay when transffering non-native tokens
      if (tokenType.isEmpty) {
        if (isMaxAmount) {
          finalAmount = (Decimal.parse(amount.toString()) -
                  Decimal.parse(transFee.toString()))
              .toDouble();
        } else {
          finalAmount = (Decimal.parse(transFee.toString()) +
                  Decimal.parse(amount.toString()))
              .toDouble();

          log.e(
              'final amount ${finalAmount} = amount $amount  + transFee $transFee');
        }
      } else {
        finalAmount = amount;
      }
    }
    finalAmount = NumberUtil()
        .truncateDoubleWithoutRouding(finalAmount, precision: decimalLimit);
    finalAmount <= walletInfo.availableBalance!
        ? isValidAmount = true
        : isValidAmount = false;
    log.i(
        'Func:amountAfterFee --trans fee $transFee  -- entered amount $amount =  finalAmount $finalAmount -- decimal limit final amount ${NumberUtil().truncateDoubleWithoutRouding(finalAmount, precision: decimalLimit)} -- isValidAmount $isValidAmount');
    setBusy(false);
    //0.025105000000000002
    return NumberUtil()
        .truncateDoubleWithoutRouding(finalAmount, precision: decimalLimit);
  }

  checkPass() async {
    setBusy(true);

    if (amountController.text.isEmpty) {
      sharedService.showInfoFlushbar(
          FlutterI18n.translate(context, "amountMissing"),
          FlutterI18n.translate(context, "pleaseEnterValidNumber"),
          Icons.cancel,
          red,
          context);
      setBusy(false);
      return;
    }
    if (gasAmount == 0.0 || gasAmount < 0.1) {
      sharedService.showInfoFlushbar(
          FlutterI18n.translate(context, "notice"),
          FlutterI18n.translate(context, "insufficientGasAmount"),
          Icons.cancel,
          red,
          context);

      setBusy(false);
      return;
    }
    var checkTransFeeAgainst;
    if (tokenType.isEmpty) {
      checkTransFeeAgainst = walletInfo.availableBalance;
    } else {
      checkTransFeeAgainst = chainBalance;
    }
    if (transFee > checkTransFeeAgainst &&
        walletInfo.tickerName != 'TRX' &&
        walletInfo.tickerName != 'USDTX' &&
        walletInfo.tickerName != 'TRX') {
      sharedService.showInfoFlushbar(
          FlutterI18n.translate(context, "notice"),
          FlutterI18n.translate(context, "insufficientBalance"),
          Icons.cancel,
          red,
          context);
      setBusy(false);
      return;
    }
    var amount = double.tryParse(amountController.text);
    await refreshBalance();
    var finalAmount;
    if (!isTrx()) {
      finalAmount = await amountAfterFee();
    }
    if (amount == null ||
        finalAmount > walletInfo.availableBalance ||
        amount == 0 ||
        amount.isNegative) {
      log.e('amount $amount --- wallet bal: ${walletInfo.availableBalance}');
      sharedService.alertDialog(FlutterI18n.translate(context, "invalidAmount"),
          FlutterI18n.translate(context, "insufficientBalance"),
          isWarning: false);
      setBusy(false);
      return;
    }
// check trx balance if tron usdt deposit
    if (walletInfo.tickerName == 'USDTX') {
      log.e('amount $amount --- wallet bal: ${walletInfo.availableBalance}');
      bool isCorrectAmount = true;
      await walletService
          .checkCoinWalletBalance(15, 'TRX')
          .then((res) => isCorrectAmount = res);

      if (amount > walletInfo.availableBalance!) {
        sharedService.sharedSimpleNotification(
          FlutterI18n.translate(context, "insufficientBalance"),
        );
        setBusy(false);
        return;
      }
      log.w('isCorrectAmount $isCorrectAmount');
      if (!isCorrectAmount) {
        sharedService.alertDialog(
            '${FlutterI18n.translate(context, "fee")} ${FlutterI18n.translate(context, "notice")}',
            'TRX ${FlutterI18n.translate(context, "insufficientBalance")}',
            isWarning: false);
        setBusy(false);
        return;
      }
    }

    if (walletInfo.tickerName == 'TRX') {
      log.e('amount $amount --- wallet bal: ${walletInfo.availableBalance}');
      bool isCorrectAmount = true;
      if (amount + 1 > walletInfo.availableBalance!) isCorrectAmount = false;
      if (!isCorrectAmount) {
        sharedService.alertDialog(
            '${FlutterI18n.translate(context, "fee")} ${FlutterI18n.translate(context, "notice")}',
            'TRX ${FlutterI18n.translate(context, "insufficientBalance")}',
            isWarning: false);
        setBusy(false);
        return;
      }
    }

    // check chain balance
    if (tokenType.isNotEmpty) {
      bool hasSufficientChainBalance = await walletService
          .checkCoinWalletBalance(transFee, walletInfo.tokenType!);
      if (!hasSufficientChainBalance) {
        log.e('Chain $tokenType -- insufficient balance');
        sharedService.sharedSimpleNotification(walletInfo.tokenType!,
            subtitle: FlutterI18n.translate(context, "insufficientGasBalance"));
        setBusy(false);
        return;
      }
    }

    message = '';
    var res = await _dialogService.showDialog(
        title: FlutterI18n.translate(context, "enterPassword"),
        description:
            FlutterI18n.translate(context, "dialogManagerTypeSamePasswordNote"),
        buttonTitle: FlutterI18n.translate(context, "confirm"));
    if (res.confirmed) {
      var seed;
      String mnemonic = res.returnedText;
      if (walletInfo.tickerName != 'TRX' && walletInfo.tickerName != 'USDTX') {
        seed = walletService.generateSeed(mnemonic);
      }
      log.i('wallet info  ${walletInfo.toJson()}');
      // if (coinName == 'USDT' || coinName == 'HOT') {
      //   tokenType = 'ETH';
      // }
      // if (coinName == 'EXG') {
      //   tokenType = 'FAB';
      // }

      var gasPrice = int.tryParse(gasPriceTextController.text);
      var gasLimit = int.tryParse(gasLimitTextController.text);
      var satoshisPerBytes = int.tryParse(satoshisPerByteTextController.text);
      var kanbanGasPrice = int.tryParse(kanbanGasPriceTextController.text);
      var kanbanGasLimit = int.tryParse(kanbanGasLimitTextController.text);
      String tickerName = walletInfo.tickerName!;
      int decimal;
      //  BigInt bigIntAmount = BigInt.tryParse(amountController.text);
      // log.w('Big int amount $bigIntAmount');
      String contractAddr = '';
      if (walletInfo.tokenType!.isNotEmpty) {
        contractAddr = environment["addresses"]["smartContract"][tickerName];
      }
      if (contractAddr == null && tokenType != '') {
        log.i(
            '$tickerName with token type $tokenType contract is null so fetching from token database');

        await tokenListDatabaseService
            .getByTickerName(tickerName)
            .then((token) {
          contractAddr = token!.contract!;
          decimal = token.decimal!;
        });
      }

      var option = {
        "gasPrice": gasPrice ?? 0,
        "gasLimit": gasLimit ?? 0,
        "satoshisPerBytes": satoshisPerBytes ?? 0,
        'kanbanGasPrice': kanbanGasPrice,
        'kanbanGasLimit': kanbanGasLimit,
        'tokenType': walletInfo.tokenType,
        'contractAddress': contractAddr,
        'decimal': decimalLimit
      };
      log.i('3 - -- ${walletInfo.tickerName}, --   $amount, - - $option');

      // TRON Transaction
      if (walletInfo.tickerName == 'TRX' || walletInfo.tickerName == 'USDTX') {
        setBusy(true);
        log.i('depositing tron ${walletInfo.tickerName}');

        await walletService
            .depositTron(
                mnemonic: mnemonic,
                walletInfo: walletInfo,
                amount: finalAmount,
                isTrxUsdt: walletInfo.tickerName == 'USDTX' ? true : false,
                isBroadcast: false,
                options: option)
            .then((res) {
          bool success = res["success"];
          if (success) {
            amountController.text = '';
            String txId = res['data']['transactionID'];

            isShowErrorDetailsButton = false;
            isShowDetailsMessage = false;
            message = txId.toString();

            sharedService.alertDialog(
              FlutterI18n.translate(context, "sendTransactionComplete"),
              '$specialTicker ${FlutterI18n.translate(context, "isOnItsWay")}',
            );
          } else {
            if (res.containsKey("error") && res["error"] != null) {
              serverError = res['error'].toString();
              isShowErrorDetailsButton = true;
            } else if (res["message"] != null) {
              serverError = res['message'].toString();
              isShowErrorDetailsButton = true;
            }
          }
        }).timeout(const Duration(seconds: 25), onTimeout: () {
          log.e('In time out');
          setBusy(false);
          sharedService.alertDialog(
              FlutterI18n.translate(context, "notice"),
              FlutterI18n.translate(
                  context, "serverTimeoutPleaseTryAgainLater"),
              isWarning: false);
        }).catchError((error) {
          log.e('In Catch error - $error');
          sharedService.alertDialog(
              FlutterI18n.translate(context, "serverError"),
              '$tickerName ${FlutterI18n.translate(context, "transanctionFailed")}',
              isWarning: false);

          setBusy(false);
        });
      }

      // Normal DEPOSIT

      else {
        await walletService
            .depositDo(seed, walletInfo.tickerName!, walletInfo.tokenType!,
                amount, option)
            .then((ret) {
          log.w(ret);

          bool success = ret["success"];
          if (success) {
            amountController.text = '';
            String txId = ret['data']['transactionID'];

            //  var allTxids = ret["txids"];
            // walletService.addTxids(allTxids);
            isShowErrorDetailsButton = false;
            isShowDetailsMessage = false;
            message = txId.toString();
          } else {
            if (ret.containsKey("error") && ret["error"] != null) {
              serverError = ret['error'].toString();
              isShowErrorDetailsButton = true;
            } else if (ret["message"] != null) {
              serverError = ret['message'].toString();
              isShowErrorDetailsButton = true;
            }
          }
          showSimpleNotification(
              Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    success
                        ? Text(FlutterI18n.translate(
                            context, "depositTransactionSuccess"))
                        : Text(FlutterI18n.translate(
                            context, "depositTransactionFailed")),
                    success
                        ? const Text("")
                        : ret["data"] != null
                            ? Text(ret["data"].toString())
                            : Text(
                                FlutterI18n.translate(context, "serverError")),
                  ]),
              position: NotificationPosition.bottom,
              background: primaryColor);

          // sharedService.alertDialog(
          //     success
          //         ? FlutterI18n.translate(context, "depositTransactionSuccess")
          //         : FlutterI18n.translate(context, "depositTransactionFailed"),
          //     success
          //         ? ""
          //         : ret.containsKey("error") && ret["error"] != null
          //             ? ret["error"]
          //             : FlutterI18n.translate(context, "serverError"),
          //     isWarning: false);
        }).catchError((onError) {
          log.e('Deposit Catch $onError');

          sharedService.alertDialog(
              FlutterI18n.translate(context, "depositTransactionFailed"),
              FlutterI18n.translate(context, "serverError"),
              isWarning: false);
          serverError = onError.toString();
        });
      }
    } else if (res.returnedText == 'Closed' && !res.confirmed) {
      log.e('Dialog Closed By User');

      setBusy(false);
    } else {
      log.e('Wrong pass');
      setBusy(false);
      showNotification(context);
    }
    setBusy(false);
  }

/*----------------------------------------------------------------------
                    Refresh Balance
----------------------------------------------------------------------*/
  refreshBalance() async {
    setBusy(true);
    unconfirmedBalance = 0.0;
    String fabAddress =
        await sharedService.getFabAddressFromCoreWalletDatabase();
    await apiService
        .getSingleWalletBalance(
            fabAddress, walletInfo.tickerName!, walletInfo.address!)
        .then((walletBalance) {
      if (walletBalance != null) {
        log.w(walletBalance[0].balance);
        walletInfo.availableBalance = walletBalance[0].balance;
        unconfirmedBalance = walletBalance[0].unconfirmedBalance!;
      }
    }).catchError((err) {
      log.e(err);
      setBusy(false);
      throw Exception(err);
    });
    setBusy(false);
  }

/*----------------------------------------------------------------------
                    ShowNotification
----------------------------------------------------------------------*/

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

/*----------------------------------------------------------------------
                    Update Transaction Fee
----------------------------------------------------------------------*/
  updateTransFee() async {
    setBusy(true);
    var to = coinService.getCoinOfficalAddress(coinName, tokenType: tokenType);
    amount = double.tryParse(amountController.text)!;

    if (to == null || amount == null || amount <= 0) {
      transFee = 0.0;
      setBusy(false);
      return;
    }
    isValidAmount = true;
    var gasPrice = int.tryParse(gasPriceTextController.text) ?? 0;
    var gasLimit = int.tryParse(gasLimitTextController.text) ?? 0;
    var satoshisPerBytes = int.tryParse(satoshisPerByteTextController.text);

    var options = {
      "gasPrice": gasPrice,
      "gasLimit": gasLimit,
      "satoshisPerBytes": satoshisPerBytes,
      "tokenType": walletInfo.tokenType,
      "getTransFeeOnly": true
    };
    var address = walletInfo.address;

    var kanbanPrice = int.tryParse(kanbanGasPriceTextController.text);
    var kanbanGasLimit = int.tryParse(kanbanGasLimitTextController.text);
    var kanbanTransFeeDouble;
    if (kanbanGasLimit != null && kanbanPrice != null) {
      var kanbanPriceBig = BigInt.from(kanbanPrice);
      var kanbanGasLimitBig = BigInt.from(kanbanGasLimit);
      kanbanTransFeeDouble = NumberUtil.rawStringToDecimal(
              (kanbanPriceBig * kanbanGasLimitBig).toString())
          .toDouble();
      //  kanbanTransFee = kanbanTransFeeDouble;
      log.w('fee $kanbanPrice $kanbanGasLimit $kanbanTransFeeDouble');
    }

    await walletService
        .sendTransaction(
            walletInfo.tickerName!,
            Uint8List.fromList(
                [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]),
            [0],
            [address],
            to,
            amount,
            options,
            false)
        .then((ret) {
      log.w('updateTransFee $ret');
      if (ret != null && ret['transFee'] != null) {
        transFee = ret['transFee'];
        kanbanTransFee = kanbanTransFeeDouble;
        setBusy(false);
      }
      if (walletInfo.tickerName != 'TRX' &&
          walletInfo.tickerName != 'USDTX') if (transFee == 0.0) {
        isValidAmount = false;
      }
      //  log.e('total amount with fee ${amount + kanbanTransFee + transFee}');
      log.i('availableBalance ${walletInfo.availableBalance}');
    }).catchError((onError) {
      setBusy(false);
      log.e(onError);
    });

    setBusy(false);
  }

// Copy txid and display flushbar
  copyAndShowNotification(String message) {
    sharedService.copyAddress(context, message);
  }
}
