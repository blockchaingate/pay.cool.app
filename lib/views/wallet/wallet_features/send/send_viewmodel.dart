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
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:majascan/majascan.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/constants.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/models/shared/pair_decimal_config_model.dart';
import 'package:paycool/models/wallet/transaction_history.dart';
import 'package:paycool/models/wallet/wallet.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/api_service.dart';
import 'package:paycool/services/coin_service.dart';
import 'package:paycool/services/db/core_wallet_database_service.dart';
import 'package:paycool/services/db/token_list_database_service.dart';
import 'package:paycool/services/db/transaction_history_database_service.dart';
import 'package:paycool/services/db/wallet_database_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/utils/barcode_util.dart';
import 'package:paycool/utils/number_util.dart';
import 'package:paycool/utils/string_validator.dart';
import 'package:paycool/utils/tron_util/trx_generate_address_util.dart'
    as tron_address_util;
import 'package:paycool/utils/tron_util/trx_transaction_util.dart'
    as tron_transaction_util;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paycool/environments/environment.dart';
import 'package:paycool/utils/fab_util.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:stacked/stacked.dart';

import '../../../../services/local_dialog_service.dart';

class SendViewModel extends BaseViewModel {
  final log = getLogger('SendViewModel');

  final LocalDialogService _dialogService = locator<LocalDialogService>();
  final apiService = locator<ApiService>();
  WalletService walletService = locator<WalletService>();
  SharedService sharedService = locator<SharedService>();
  TransactionHistoryDatabaseService transactionHistoryDatabaseService =
      locator<TransactionHistoryDatabaseService>();
  WalletDatabaseService walletDatabaseService =
      locator<WalletDatabaseService>();
  TokenListDatabaseService tokenListDatabaseService =
      locator<TokenListDatabaseService>();
  final coinService = locator<CoinService>();
  late BuildContext context;
  var options = {};
  String txHash = '';
  String errorMessage = '';
  var updatedBal;
  String toAddress = '';
  Decimal amount = Constants.decimalZero;
  int gasPrice = 0;
  int gasLimit = 0;
  int satoshisPerBytes = 0;
  WalletInfo walletInfo = WalletInfo();
  bool checkSendAmount = false;
  bool isShowErrorDetailsButton = false;
  bool isShowDetailsMessage = false;
  String serverError = '';
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final receiverWalletAddressTextController = TextEditingController();
  final sendAmountTextController = TextEditingController();
  final gasPriceTextController = TextEditingController();
  final gasLimitTextController = TextEditingController();
  final satoshisPerByteTextController = TextEditingController();
  double transFee = 0.0;
  bool transFeeAdvance = false;
  PairDecimalConfig singlePairDecimalConfig = PairDecimalConfig();
  String feeUnit = '';
  int decimalLimit = 8;
  var fabUtils = FabUtils();
  List<String> domainTlds = [];
  String userTypedDomain = '';

  // Init State
  initState() async {
    setBusy(true);
    sharedService.context = context;
    String coinName = walletInfo.tickerName!;
    String tokenType = walletInfo.tokenType!;
    if (coinName == 'BTC') {
      satoshisPerByteTextController.text =
          environment["chains"]["BTC"]["satoshisPerBytes"].toString();
      feeUnit = 'BTC';
    } else if (coinName == 'ETH' || tokenType == 'ETH') {
      var gasPriceReal = await walletService.getEthGasPrice();
      debugPrint('gasPriceReal====== $gasPriceReal');

      gasPriceTextController.text = gasPriceReal.toString();
      gasLimitTextController.text =
          environment["chains"]["ETH"]["gasLimit"].toString();
      if (tokenType == 'ETH') {
        gasLimitTextController.text =
            environment["chains"]["ETH"]["gasLimitToken"].toString();
      }
      feeUnit = 'ETH';
    } else if (coinName == 'FAB') {
      satoshisPerByteTextController.text =
          environment["chains"]["FAB"]["satoshisPerBytes"].toString();
      feeUnit = 'FAB';
    } else if (tokenType == 'FAB') {
      satoshisPerByteTextController.text =
          environment["chains"]["FAB"]["satoshisPerBytes"].toString();
      gasPriceTextController.text =
          environment["chains"]["FAB"]["gasPrice"].toString();
      gasLimitTextController.text =
          environment["chains"]["FAB"]["gasLimit"].toString();
      feeUnit = 'FAB';
    }
    await getDecimalData();
    await refreshBalance();
    await coinService.getSingleTokenData((walletInfo.tickerName!)).then((t) {
      decimalLimit = t!.decimal!;
    });
    if (decimalLimit == null || decimalLimit == 0) decimalLimit = 8;
    domainTlds = await apiService.getDomainSupportedTlds();
    setBusy(false);
  }

  clearAddress() {
    receiverWalletAddressTextController.text = '';
    userTypedDomain = '';
    notifyListeners();
    setBusyForObject(userTypedDomain, false);
  }

  checkDomain(String domainName) async {
    setBusyForObject(userTypedDomain, true);
    bool isValidDomainFormat = false;
    userTypedDomain = '';
    if (domainTlds == null || domainTlds.isEmpty) {
      domainTlds = await apiService.getDomainSupportedTlds();
    }
    if ((domainTlds != null || domainTlds.isNotEmpty) &&
        domainName.contains('.')) {
      isValidDomainFormat = domainTlds.contains(domainName.split('.')[1]);
    }

    if (isValidDomainFormat) {
      var domainInfo = await apiService.getDomainRecord(domainName);
      log.w('get domain data for $domainName -- $domainInfo');
      String ticker = walletInfo.tokenType!.isEmpty
          ? walletInfo.tickerName!
          : walletInfo.tokenType!;
      String domainAddress = domainInfo['records']['crypto.$ticker.address'];
      String owner = domainInfo['meta']['owner'];

      if (domainAddress != null) {
        receiverWalletAddressTextController.text = domainAddress;
        userTypedDomain = domainName;
      } else if ((owner != null && owner.isNotEmpty) && domainAddress == null) {
        userTypedDomain = FlutterI18n.translate(context, "addressNotSet");
      } else {
        userTypedDomain = FlutterI18n.translate(context, "invalidDomain");
      }
      notifyListeners();
    } else {
      log.e('invalid domain format');
      setBusyForObject(userTypedDomain, false);
    }
  }

  bool isTrx() {
    log.i(
        'isTrx ${walletInfo.tickerName == 'TRX' || walletInfo.tickerName == 'USDTX'}');
    return walletInfo.tickerName == 'TRX' || walletInfo.tickerName == 'USDTX'
        ? true
        : false;
  }

  fillMaxAmount() {
    setBusy(true);
    sendAmountTextController.text = NumberUtil()
        .truncateDoubleWithoutRouding(walletInfo.availableBalance!,
            precision: singlePairDecimalConfig.qtyDecimal)
        .toString();
    log.i(sendAmountTextController.text);
    setBusy(false);
    amount = NumberUtil.convertStringToDecimal(sendAmountTextController.text);
    checkAmount();
  }

  getDecimalData() async {
    setBusy(true);
    singlePairDecimalConfig =
        await sharedService.getSinglePairDecimalConfig(walletInfo.tickerName!);
    log.i('singlePairDecimalConfig ${singlePairDecimalConfig.toJson()}');
    setBusy(false);
  }

  showDetailsMessageToggle() {
    setBusy(true);
    isShowDetailsMessage = !isShowDetailsMessage;
    setBusy(false);
  }

  getGasBalance() async {
    // await walletService.gasBalance(addr)
  }

  // getExgWalletAddr() async {
  //   // Get coin details which we are making transaction through like USDT
  //   await walletDataBaseService.getBytickerName('EXG').then((res) {
  //     exgWalletAddress = res.address;
  //     log.w('Exg wallet address $exgWalletAddress');
  //   });
  // }

  // Paste Clipboard Data In Receiver Address

  pasteClipBoardData() async {
    setBusy(true);
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null) {
      log.i('paste data ${data.text}');
      receiverWalletAddressTextController.text = data.text!;
      toAddress = receiverWalletAddressTextController.text;
    }
    setBusy(false);
  }

/*----------------------------------------------------------------------
                      Verify Password
----------------------------------------------------------------------*/

  Future sendTransaction() async {
    setBusy(true);
    var dialogResponse = await _dialogService.showDialog(
        title: FlutterI18n.translate(context, "enterPassword"),
        description:
            FlutterI18n.translate(context, "dialogManagerTypeSamePasswordNote"),
        buttonTitle: FlutterI18n.translate(context, "confirm"));
    if (dialogResponse.confirmed) {
      String mnemonic = dialogResponse.returnedText;
      Uint8List seed = walletService.generateSeed(mnemonic);
      String tickerName = walletInfo.tickerName!.toUpperCase();
      String tokenType = walletInfo.tokenType!.toUpperCase();
      if (tickerName == 'USDT') {
        tokenType = 'ETH';

        // Check if ETH is available for making USDT transaction
        // Same for Fab token based coins

        // WalletInfo ethWallet =
        //     await walletDatabaseService.getBytickerName('ETH');
        // if (ethWallet.availableBalance < 0.05) {
        //   sharedService.alertDialog('Send Notice',
        //       'To send ETH or USDT you need atleast .05 eth balance available in your wallet.',
        //       isWarning: false);
        // }
      } else if (tickerName == 'EXG') {
        tokenType = 'FAB';
      }

      if ((tickerName != null) &&
          (tickerName != '') &&
          (tokenType != null) &&
          (tokenType != '')) {
        int decimal = 0;
        String contractAddr =
            environment["addresses"]["smartContract"][tickerName];

        if (contractAddr == null) {
          await tokenListDatabaseService
              .getByTickerName(tickerName)
              .then((token) {
            contractAddr = token!.contract!;
            decimal = token.decimal!;
          });
        }
        options = {
          'tokenType': tokenType,
          'contractAddress': contractAddr,
          'gasPrice': gasPrice,
          'gasLimit': gasLimit,
          'satoshisPerBytes': satoshisPerBytes,
          'decimal': decimal
        };
      } else {
        options = {
          'gasPrice': gasPrice,
          'gasLimit': gasLimit,
          'satoshisPerBytes': satoshisPerBytes
        };
      }

      // Convert FAB to EXG format
      if (walletInfo.tokenType == 'FAB') {
        if (!toAddress.startsWith('0x')) {
          toAddress = fabUtils.fabToExgAddress(toAddress);
        }
      }
      log.i('OPTIONS before send $options');

      // TRON Transaction
      if (walletInfo.tickerName == 'TRX' || walletInfo.tickerName == 'USDTX') {
        log.i('sending tron ${walletInfo.tickerName}');
        var privateKey = tron_address_util.generateTrxPrivKey(mnemonic);
        var ca;
        if (walletInfo.tickerName == 'USDTX') {
          // get trx-usdt contract address
          ca = environment["addresses"]["smartContract"][tickerName];
          if (ca == null) {
            await tokenListDatabaseService
                .getByTickerName(tickerName)
                .then((token) async {
              if (token != null) {
                ca = token.contract;
              } else {
                await apiService.getTokenListUpdates().then((tokenList) {
                  for (var token in tokenList) {
                    if (token.tickerName == 'USDTX') {
                      ca = token.contract;
                    }
                  }
                });
              }
            });
          }
          log.i('contract address $ca');
        }
        await tron_transaction_util
            .generateTrxTransactionContract(
                contractAddressTronUsdt: ca,
                privateKey: privateKey,
                fromAddr: walletInfo.address!,
                toAddr: toAddress,
                amount: amount.toDouble(),
                isTrxUsdt: walletInfo.tickerName == 'USDTX' ? true : false,
                tickerName: walletInfo.tickerName!,
                isBroadcast: true)
            .then((res) {
          log.i('send screen state ${walletInfo.tickerName} res: $res');
          var txRes = res['broadcastTronTransactionRes'];
          if (txRes['code'] == 'SUCCESS') {
            log.w('trx tx res $res');
            txHash = txRes['txid'];
            isShowErrorDetailsButton = false;
            isShowDetailsMessage = false;

            String t = '';
            walletInfo.tickerName == 'USDTX'
                ? t = 'USDT(TRC20)'
                : t = walletInfo.tickerName!;
            sharedService.alertDialog(
              FlutterI18n.translate(context, "sendTransactionComplete"),
              '$t ${FlutterI18n.translate(context, "isOnItsWay")}',
            );
            // add tx to db
            addSendTransactionToDB(walletInfo, amount.toDouble(), txHash);
            Future.delayed(const Duration(milliseconds: 3), () {
              refreshBalance();
            });
          } else if (res['broadcastTronTransactionRes']['result'] == 'false') {
            String errMsg =
                res['broadcastTronTransactionRes']['message'].toString();
            log.e('In Catch error - $errMsg');

            isShowErrorDetailsButton = true;
            isShowDetailsMessage = true;
            serverError = errMsg;
            setBusy(false);
          }
          setBusy(false);
        }).timeout(const Duration(seconds: 25), onTimeout: () {
          log.e('In time out');
          setBusy(false);
          isShowErrorDetailsButton = false;
          isShowDetailsMessage = false;
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
          isShowErrorDetailsButton = true;
          isShowDetailsMessage = true;
          serverError = error.toString();
          setBusy(false);
        });
      } else {
        // Other coins transaction
        await walletService
            .sendTransaction(tickerName, seed, [0], [], toAddress,
                amount.toDouble(), options, true)
            .then((res) async {
          log.w('Result $res');
          txHash = res["txHash"];
          errorMessage = res["errMsg"] ?? '';

          if (txHash.isNotEmpty) {
            log.w('Txhash $txHash');
            clearAddress();
            sendAmountTextController.text = '';
            isShowErrorDetailsButton = false;
            isShowDetailsMessage = false;
            sharedService.alertDialog(
              FlutterI18n.translate(context, "sendTransactionComplete"),
              '$tickerName ${FlutterI18n.translate(context, "isOnItsWay")}',
            );
            //   var allTxids = res["txids"];
            //  walletService.addTxids(allTxids);
            // add tx to db
            addSendTransactionToDB(walletInfo, amount.toDouble(), txHash);
            Future.delayed(const Duration(milliseconds: 30), () {
              refreshBalance();
            });
            return txHash;
          } else if (txHash == '' && errorMessage == '') {
            log.e('Both TxHash and Error Message are empty $errorMessage');
            sharedService.alertDialog(
              "",
              '$tickerName ${FlutterI18n.translate(context, "transanctionFailed")}',
            );
            isShowErrorDetailsButton = false;
            isShowDetailsMessage = false;
            setBusy(false);
          } else if (txHash.isEmpty && errorMessage.isNotEmpty) {
            log.e('Error Message $errorMessage');
            sharedService.alertDialog(
              "",
              '$tickerName ${FlutterI18n.translate(context, "transanctionFailed")}',
            );
            isShowErrorDetailsButton = true;
            isShowDetailsMessage = true;
            serverError = errorMessage;
            setBusy(false);
          }
          setBusy(false);
        }).timeout(const Duration(seconds: 25), onTimeout: () {
          log.e('In time out');
          isShowErrorDetailsButton = false;
          isShowDetailsMessage = false;
          setBusy(false);
          return errorMessage = FlutterI18n.translate(
              context, "serverTimeoutPleaseTryAgainLater");
        }).catchError((error) {
          log.e('In Catch error - $error');
          sharedService.alertDialog(
              FlutterI18n.translate(context, "networkIssue"),
              '$tickerName ${FlutterI18n.translate(context, "transanctionFailed")}',
              isWarning: false);
          isShowErrorDetailsButton = true;
          isShowDetailsMessage = true;
          serverError = error.toString();
          setBusy(false);
        });
      }
    } else if (dialogResponse.returnedText != 'Closed') {
      setBusy(false);
      return errorMessage =
          FlutterI18n.translate(context, "pleaseProvideTheCorrectPassword");
    } else {
      setBusy(false);
    }
  }

/*----------------------------------------------------------------------
              Add send tx to transaction database  
----------------------------------------------------------------------*/
  void addSendTransactionToDB(
      WalletInfo walletInfo, double amount, String txHash) {
    String date = DateTime.now().toLocal().toString();

    TransactionHistory transactionHistory = TransactionHistory(
      id: null,
      tickerName: walletInfo.tickerName!,
      address: '',
      amount: 0.0,
      date: date,
      kanbanTxId: '',
      tickerChainTxId: txHash,
      quantity: amount,
      tag: 'send',
      chainName: walletInfo.tokenType!,
    );
    walletService.insertTransactionInDatabase(transactionHistory);
  }

/*----------------------------------------------------------------------
              Check transaction status not working yet  
----------------------------------------------------------------------*/
  checkTxStatus(String tickerName, String txHash) async {
    Timer? timer;
    if (tickerName == 'FAB') {
      await walletService.getFabTxStatus(txHash).then((res) {
        if (res != null) {
          var confirmations = res['confirmations'];
          // timer?.cancel();
          log.w('$tickerName Not null $confirmations');
        }

        log.w('$tickerName TX Status response $res');
      }).catchError((onError) {
        timer!.cancel();
        log.e(onError);
      });
      //  Navigator.pushNamed(context, '/walletFeatures');
    } else if (tickerName == 'ETH') {
      await walletService.getEthTxStatus(txHash).then((res) {
        timer!.cancel();
        log.w('$tickerName TX Status response $res');
      }).catchError((onError) {
        timer!.cancel();
        log.e(onError);
      });
      //  Navigator.pushNamed(context, '/walletFeatures');
    } else {
      timer!.cancel();
      log.e('No Check TX Status found');
    }
  }

  /*----------------------------------------------------------------------
                    Refresh Balance
----------------------------------------------------------------------*/
  refreshBalance() async {
    setBusy(true);

    String fabAddress =
        await sharedService.getFabAddressFromCoreWalletDatabase();
    await apiService
        .getSingleWalletBalance(
            fabAddress, walletInfo.tickerName!, walletInfo.address!)
        .then((walletBalance) {
      if (walletBalance != null) {
        log.w(walletBalance);

        walletInfo.availableBalance = walletBalance[0].balance;
      }
    }).catchError((err) {
      log.e(err);
      setBusy(false);
      throw Exception(err);
    });
    setBusy(false);
  }

/*-----------------------------------------------------------------------------------
    Check Fields to see if user has filled both address and amount fields correctly
------------------------------------------------------------------------------------*/
  checkFields(context) async {
    debugPrint('in check fields');
    txHash = '';
    errorMessage = '';
    //walletInfo = walletInfo;
    if (sendAmountTextController.text == '') {
      debugPrint('amount empty');
      sharedService.alertDialog(FlutterI18n.translate(context, "amountMissing"),
          FlutterI18n.translate(context, "invalidAmount"),
          isWarning: false);
      return;
    }
    amount = NumberUtil.convertStringToDecimal(sendAmountTextController.text);
    toAddress = receiverWalletAddressTextController.text;
    if (!isTrx()) {
      gasPrice = int.tryParse(gasPriceTextController.text) ?? 0;
      gasLimit = int.tryParse(gasLimitTextController.text) ?? 0;
    }
    satoshisPerBytes = int.tryParse(satoshisPerByteTextController.text)!;
    //await refreshBalance();
    if (toAddress == '') {
      debugPrint('address empty');
      sharedService.alertDialog(FlutterI18n.translate(context, "emptyAddress"),
          FlutterI18n.translate(context, "pleaseEnterAnAddress"),
          isWarning: false);
      return;
    }
    if ((isTrx()) && !toAddress.startsWith('T')) {
      debugPrint('invalid tron address');
      sharedService.alertDialog(
          FlutterI18n.translate(context, "invalidAddress"),
          FlutterI18n.translate(
              context, "pleaseCorrectTheFormatOfReceiveAddress"),
          isWarning: false);
      return;
    }
    // double totalAmount = amount + transFee;
    if (amount == null ||
        amount == Constants.decimalZero ||
        amount.toDouble().isNegative ||
        !checkSendAmount ||
        amount.toDouble() > walletInfo.availableBalance!) {
      debugPrint('amount no good');
      sharedService.alertDialog(FlutterI18n.translate(context, "invalidAmount"),
          FlutterI18n.translate(context, "pleaseEnterValidNumber"),
          isWarning: false);
      return;
    }

    if (transFee < 0.0001 && !isTrx()) {
      debugPrint('fee issue');
      showSimpleNotification(
          Center(
              child: Column(
            children: [
              Text(FlutterI18n.translate(context, "notice"),
                  style: Theme.of(context).textTheme.bodyMedium),
              Text(FlutterI18n.translate(context, "insufficientGasAmount"),
                  style: headText6),
            ],
          )),
          position: NotificationPosition.top);
      await updateTransFee();
      return;
    }
    //amount = NumberUtil().roundDownLastDigit(amount);

    // if (walletInfo.tickerName == 'USDTX') {
    //   log.e('amount $amount --- wallet bal: ${walletInfo.availableBalance}');
    //   // bool isCorrectAmount = true;
    //   // await walletService
    //   //     .checkCoinWalletBalance(amount, 'TRX')
    //   //     .then((res) => isCorrectAmount = res);

    //   if (amount >= walletInfo.availableBalance) {
    //     sharedService.alertDialog(
    //         '${FlutterI18n.translate(context, "fee")} ${FlutterI18n.translate(context, "notice")}',
    //         'TRX ${FlutterI18n.translate(context, "insufficientBalance")}',
    //         isWarning: false);
    //     setBusy(false);
    //     return;
    //   }
    // }

    debugPrint('else');
    FocusScope.of(context).requestFocus(FocusNode());
    if (transFee == 0 && !isTrx()) await updateTransFee();
    sendTransaction();
    // await updateBalance(widget.walletInfo.address);
    // widget.walletInfo.availableBalance = model.updatedBal['balance'];
  }

/*----------------------------------------------------------------------
                    Check Send Amount
----------------------------------------------------------------------*/
  checkAmount() async {
    setBusy(true);
    Pattern pattern = r'^(0|(\d+)|\.(\d+))(\.(\d+))?$';
    log.e(amount);
    var res = RegexValidator(pattern.toString()).isValid(amount.toString());

    if (res) {
      if (!isTrx()) {
        log.i('checkAmount ${walletInfo.tickerName}');

        await updateTransFee();
        double totalAmount = 0.0;
        if (walletInfo.tickerName == 'FAB') {
          totalAmount = amount.toDouble() + transFee;
        } else {
          totalAmount = amount.toDouble();
        }
        log.i('total amount $totalAmount');
        log.w('wallet bal ${walletInfo.availableBalance}');
        if (totalAmount <= walletInfo.availableBalance!) {
          checkSendAmount = true;
        } else {
          checkSendAmount = false;
        }
      } else if (walletInfo.tickerName == 'TRX') {
        if (amount.toDouble() + 1 <= walletInfo.availableBalance!) {
          checkSendAmount = true;
        } else {
          checkSendAmount = false;
        }
      } else if (walletInfo.tickerName == 'USDTX') {
        double trxBalance = 0.0;

        trxBalance = await getTrxBalance();
        log.w('checkAmount trx bal $trxBalance');
        if (amount.toDouble() <= walletInfo.availableBalance! &&
            trxBalance >= 15) {
          checkSendAmount = true;
        } else {
          checkSendAmount = false;
          if (trxBalance < 15) {
            showSimpleNotification(
                Center(
                  child: Text(
                      '${FlutterI18n.translate(context, "low")} TRX ${FlutterI18n.translate(context, "balance")}'),
                ),
                position: NotificationPosition.top,
                background: sellPrice);
          }
        }
      }
      log.i('check send amount $checkSendAmount');
    }
    setBusy(false);
  }

  Future<double> getTrxBalance() async {
    double balance = 0.0;
    String trxWalletAddress = '';
    final coreWalletDbService = locator<CoreWalletDatabaseService>();
    trxWalletAddress =
        await coreWalletDbService.getWalletAddressByTickerName('TRX');
    String fabAddress =
        await sharedService.getFabAddressFromCoreWalletDatabase();
    await apiService
        .getSingleWalletBalance(fabAddress, 'TRX', trxWalletAddress)
        .then((walletBalance) {
      if (walletBalance != null) {
        balance = walletBalance[0].balance!;
      }
    }).catchError((err) {
      log.e(err);
      setBusy(false);
      throw Exception(err);
    });
    return balance;
  }

/*----------------------------------------------------------------------
                      Copy Address
----------------------------------------------------------------------*/

  copyAddress(context) {
    Clipboard.setData(ClipboardData(text: txHash));
    showSimpleNotification(
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${FlutterI18n.translate(context, "transactionId")} '),
            Text(FlutterI18n.translate(context, "copiedSuccessfully")),
          ],
        ),
        position: NotificationPosition.bottom,
        background: primaryColor);
    // sharedService.alertDialog(FlutterI18n.translate(context, "transactionId"),
    //     FlutterI18n.translate(context, "copiedSuccessfully"),
    //     isWarning: false);
  }

/*----------------------------------------------------------------------
                Update Trans Fee
----------------------------------------------------------------------*/

  updateTransFee() async {
    setBusy(true);
    log.i('in update trans fee');
    var to = coinService.getCoinOfficalAddress(
        walletInfo.tickerName!.toUpperCase(),
        tokenType: walletInfo.tokenType!.toUpperCase());
    amount = NumberUtil.convertStringToDecimal(sendAmountTextController.text);
    var gasPrice = int.tryParse(gasPriceTextController.text);
    var gasLimit = int.tryParse(gasLimitTextController.text);
    var satoshisPerBytes = int.tryParse(satoshisPerByteTextController.text);
    var options = {
      "gasPrice": gasPrice,
      "gasLimit": gasLimit,
      "satoshisPerBytes": satoshisPerBytes,
      "tokenType": walletInfo.tokenType,
      "getTransFeeOnly": true
    };

    var address = walletInfo.address;

    await walletService
        .sendTransaction(
            walletInfo.tickerName!,
            Uint8List.fromList(
                [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]),
            [0],
            [address],
            to,
            amount.toDouble(),
            options,
            false)
        .then((ret) {
      if (ret != null && ret['transFee'] != null) {
        transFee = ret['transFee'];
        log.w('trans fee $ret');
      }
      setBusy(false);
    }).catchError((err) {
      setBusy(false);
      setBusy(false);
      log.e(err);
      sharedService.alertDialog(FlutterI18n.translate(context, "genericError"),
          FlutterI18n.translate(context, "transanctionFailed"),
          isWarning: false);
    });
    setBusy(false);
  }

/*--------------------------------------------------------
                      Barcode Scan
--------------------------------------------------------*/

  Future scan() async {
    log.i("Barcode: going to scan");
    setBusy(true);

    try {
      log.i("Barcode: try");
      String barcode = '';

      var scanResult = await BarcodeUtils().majaScan(context);
      barcode = scanResult.toString();
      log.i("Barcode Res: $barcode");

      receiverWalletAddressTextController.text = barcode;
      setBusy(false);
    } on PlatformException catch (e) {
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
}
