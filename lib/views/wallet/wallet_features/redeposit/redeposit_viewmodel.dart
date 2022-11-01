import 'dart:typed_data';

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/constants.dart';
import 'package:paycool/environments/coins.dart';
import 'package:paycool/environments/environment.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/models/wallet/wallet.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/coin_service.dart';
import 'package:paycool/services/db/token_list_database_service.dart';
import 'package:paycool/services/db/transaction_history_database_service.dart';
import 'package:paycool/services/local_dialog_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/utils/abi_util.dart';
import 'package:paycool/utils/coin_util.dart';

import 'package:paycool/utils/kanban.util.dart';
import 'package:paycool/utils/keypair_util.dart';
import 'package:paycool/utils/number_util.dart';
import 'package:paycool/utils/string_util.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:hex/hex.dart';

class RedepositViewModel extends FutureViewModel {
  final log = getLogger('RedepositVM');
  LocalDialogService dialogService = locator<LocalDialogService>();
  WalletService walletService = locator<WalletService>();
  SharedService sharedService = locator<SharedService>();
  final tokenListDatabaseService = locator<TokenListDatabaseService>();
  final coinService = locator<CoinService>();
  final kanbanGasPriceTextController = TextEditingController();
  final kanbanGasLimitTextController = TextEditingController();
  double kanbanTransFee = 0.0;
  bool transFeeAdvance = false;

  String errDepositTransactionID;
  List errDepositList = [];
  TransactionHistoryDatabaseService transactionHistoryDatabaseService =
      locator<TransactionHistoryDatabaseService>();

  WalletInfo walletInfo;
  BuildContext context;
  String errorMessage = '';
  @override
  Future futureToRun() => getErrDeposit();

  void init() {}

/*----------------------------------------------------------------------
                      Get Error Deposit
----------------------------------------------------------------------*/

  Future getErrDeposit() async {
    setBusy(true);
    var address = await sharedService.getExgAddressFromCoreWalletDatabase();
    await walletService.getErrDeposit(address).then((errDepositData) async {
      debugPrint(
          'redeposit res length ${errDepositData.length} ---data $errDepositData');
      for (var i = 0; i < errDepositData.length; i++) {
        var item = errDepositData[i];
        log.w('errDepositData count $i $item');
        var coinType = item['coinType'];
        String tickerNameByCointype = newCoinTypeMap[coinType];
        debugPrint('tickerNameByCointype $tickerNameByCointype');
        if (tickerNameByCointype == null) {
          await tokenListDatabaseService.getAll().then((tokenList) {
            if (tokenList != null) {
              tickerNameByCointype = tokenList
                  .firstWhere((element) => element.coinType == coinType)
                  .tickerName;
              if (tickerNameByCointype == walletInfo.tickerName) {
                errDepositList.add(item);
              }
            }
          });
        } else if (tickerNameByCointype == walletInfo.tickerName) {
          errDepositList.add(item);
          log.e(
              'in else if -- coin type $coinType --  tickerNameByCointype $tickerNameByCointype');
        }
      }
    });
    log.i(' errDepositList ${errDepositList.length}');
    var gasPrice = environment["chains"]["KANBAN"]["gasPrice"];
    var gasLimit = environment["chains"]["KANBAN"]["gasLimit"];
    kanbanGasPriceTextController.text = gasPrice.toString();
    kanbanGasLimitTextController.text = gasLimit.toString();

    var kanbanTransFee =
        NumberUtil.rawStringToDecimal((gasPrice * gasLimit).toString())
            .toDouble();

    log.w('errDepositList=== $errDepositList');
    // if there is only one redeposit entry
    if (errDepositList != null && errDepositList.isNotEmpty) {
      errDepositList = errDepositList;
      errDepositTransactionID = errDepositList[0]["transactionID"];
      this.kanbanTransFee = kanbanTransFee;
    }

    setBusy(false);
    return errDepositList;
  }

/*----------------------------------------------------------------------
                    Check pass
----------------------------------------------------------------------*/

  checkPass() async {
    //TransactionHistory transactionByTxId = new TransactionHistory();
    setBusy(true);
    errorMessage = '';
    setBusy(false);
    var res = await dialogService.showDialog(
        title: FlutterI18n.translate(context, "enterPassword"),
        description:
            FlutterI18n.translate(context, "dialogManagerTypeSamePasswordNote"),
        buttonTitle: FlutterI18n.translate(context, "confirm"));
    if (res.confirmed) {
      String mnemonic = res.returnedText;
      Uint8List seed = walletService.generateSeed(mnemonic);
      var keyPairKanban = getExgKeyPair(seed);
      var exgAddress = keyPairKanban['address'];
      var nonce = await getNonce(exgAddress);

      var errDepositItem;
      for (var i = 0; i < errDepositList.length; i++) {
        if (errDepositList[i]["transactionID"] == errDepositTransactionID) {
          errDepositItem = errDepositList[i];
          break;
        }
      }

      if (errDepositItem == null) {
        sharedService.showInfoFlushbar(
            FlutterI18n.translate(context, "redepositError"),
            FlutterI18n.translate(context, "redepositItemNotSelected"),
            Icons.cancel,
            red,
            context);
      }

      log.w('errDepositItem $errDepositItem');
      var errDepositAmount = double.parse(errDepositItem['amount']);
      log.i('errDepositAmount $errDepositAmount');
      var amountInBigInt = errDepositAmount.toString().contains('e')
          ? BigInt.parse(errDepositItem['amount'])
          : BigInt.from(errDepositAmount);
      debugPrint('amountInLink $amountInBigInt');
      var coinType = errDepositItem['coinType'];
      var transactionID = errDepositItem['transactionID'];
      var addressInKanban = keyPairKanban["address"];

      var originalMessage = walletService.getOriginalMessage(
          coinType,
          trimHexPrefix(transactionID),
          amountInBigInt,
          trimHexPrefix(addressInKanban));

      var signedMess = await signedMessage(
          originalMessage, seed, walletInfo.tickerName, walletInfo.tokenType);

      var resRedeposit = await submitredeposit(amountInBigInt, keyPairKanban,
          nonce, coinType, transactionID, signedMess,
          chainType: walletInfo.tokenType);

      if ((resRedeposit != null) && (resRedeposit['success'])) {
        log.w('resRedeposit $resRedeposit');
        var newTransactionId = resRedeposit['data']['transactionID'];

        sharedService.alertDialog(
            FlutterI18n.translate(context, "redepositCompleted"),
            FlutterI18n.translate(context, "transactionId") +
                ': ' +
                newTransactionId,
            path: '/dashboard');
      } else if (resRedeposit['message'] != '') {
        setBusy(true);
        errorMessage = resRedeposit['message'];
        setBusy(false);
      } else {
        sharedService.showInfoFlushbar(
            FlutterI18n.translate(context, "redepositFailedError"),
            FlutterI18n.translate(context, "networkIssue"),
            Icons.cancel,
            red,
            context);
      }
    } else {
      if (res.returnedText != 'Closed') {
        showNotification(context);
      }
    }
  }

  submitredeposit(
      amountInLink, keyPairKanban, nonce, coinType, txHash, signedMess,
      {String chainType = ''}) async {
    var abiHex;
    String addressInKanban = keyPairKanban['address'];
    log.w('transactionID for submitredeposit:' + txHash);
    var coinPoolAddress = await getCoinPoolAddress();
    //var signedMess = {'r': r, 's': s, 'v': v};
    String coinName = '';
    bool isSpecial = false;
    int specialCoinType;
    coinName = newCoinTypeMap[coinType];
    if (coinName == null) {
      await tokenListDatabaseService
          .getTickerNameByCoinType(coinType)
          .then((ticker) {
        coinName = ticker;
        log.w('submit redeposit ticker $ticker');
      });
    }
    for (var specialTokenTicker in Constants.specialTokens) {
      if (coinName == specialTokenTicker) isSpecial = true;
    }
    if (isSpecial) {
      specialCoinType = await coinService
          .getCoinTypeByTickerName(coinName.substring(0, coinName.length - 1));
    }
    abiHex = getDepositFuncABI(isSpecial ? specialCoinType : coinType, txHash,
        amountInLink, addressInKanban, signedMess,
        chain: chainType, isSpecialDeposit: isSpecial);

    var kanbanPrice = int.tryParse(kanbanGasPriceTextController.text);
    var kanbanGasLimit = int.tryParse(kanbanGasLimitTextController.text);

    var txKanbanHex = await signAbiHexWithPrivateKey(
        abiHex,
        HEX.encode(keyPairKanban["privateKey"]),
        coinPoolAddress,
        nonce,
        kanbanPrice,
        kanbanGasLimit);

    var res = await submitReDeposit(txKanbanHex);
    return res;
  }

  showNotification(context) {
    sharedService.showInfoFlushbar(
        FlutterI18n.translate(context, "passwordMismatch"),
        FlutterI18n.translate(context, "pleaseProvideTheCorrectPassword"),
        Icons.cancel,
        red,
        context);
  }

  updateTransFee() async {
    var kanbanPrice = int.tryParse(kanbanGasPriceTextController.text);
    var kanbanGasLimit = int.tryParse(kanbanGasLimitTextController.text);
    var kanbanTransFeeDouble =
        NumberUtil.rawStringToDecimal((kanbanPrice * kanbanGasLimit).toString())
            .toDouble();

    kanbanTransFee = kanbanTransFeeDouble;
  }
}
