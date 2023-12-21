import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:paycool/constants/api_routes.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/constants.dart';
import 'package:paycool/environments/environment.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/models/wallet/token_model.dart';
import 'package:paycool/models/wallet/wallet.dart';
import 'package:paycool/models/wallet/wallet_balance.dart';
import 'package:paycool/providers/app_state_provider.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/api_service.dart';
import 'package:paycool/services/coin_service.dart';
import 'package:paycool/services/db/token_list_database_service.dart';
import 'package:paycool/services/local_dialog_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/utils/eth_util.dart';
import 'package:paycool/utils/fab_util.dart';
import 'package:paycool/utils/number_util.dart';
import 'package:paycool/utils/string_util.dart';
import 'package:paycool/utils/wallet/erc20_util.dart';
import 'package:paycool/utils/wallet/wallet_util.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';

class TransferViewModel extends BaseViewModel {
  final BuildContext context;
  final WalletInfo walletInfo;
  TransferViewModel({required this.context, required this.walletInfo});

  final log = getLogger('TransferViewModel');
  // late AppStateProvider appStateProvider;

  final walletUtil = WalletUtil();
  final walletService = locator<WalletService>();
  final sharedService = locator<SharedService>();
  Erc20Util erc20Util = Erc20Util();
  final apiService = locator<ApiService>();
  final coinService = locator<CoinService>();
  final tokenListDatabaseService = locator<TokenListDatabaseService>();
  final LocalDialogService _dialogService = locator<LocalDialogService>();

  List<WalletBalance> wallets = [];

  final amountController = TextEditingController();

  final gasPriceTextController = TextEditingController();
  final gasLimitTextController = TextEditingController();
  final kanbanGasPriceTextController = TextEditingController();
  final kanbanGasLimitTextController = TextEditingController();
  final satoshisPerByteTextController = TextEditingController();
  final trxGasValueTextController = TextEditingController();

  List<TextEditingController> controllersList = [];

  Decimal transFee = Constants.decimalZero;
  Decimal kanbanGasFee = Constants.decimalZero;
  Decimal amount = Constants.decimalZero;

  String feeMeasurement = '';
  bool isShowFabChainBalance = false;
  bool isShowTrxTsWalletBalance = false;
  bool isShowBnbTsWalletBalance = false;
  bool isShowPolygonTsWalletBalance = false;

  bool isWithdrawChoicePopup = false;
  String ercSmartContractAddress = '';
  TokenModel ercChainToken = TokenModel();
  TokenModel mainChainToken = TokenModel();

  TokenModel bnbChainToken = TokenModel();
  TokenModel polygonChainToken = TokenModel();

  List<String> chainNames = ["FAB", "ETH", "BNB", "POLYGON", "TRX"];
  String? selectedChain = 'FAB';
  bool isWithdrawChoice = false;
  bool isSubmittingTx = false;
  String updateTickerForErc = '';
  var fabUtils = FabUtils();

  Decimal fabChainBalance = Decimal.zero;
  Decimal ethChainBalance = Decimal.zero;
  Decimal trxTsWalletBalance = Decimal.zero;
  Decimal bnbTsWalletBalance = Decimal.zero;
  Decimal polygonTsWalletBalance = Decimal.zero;

  bool isShowErrorDetailsButton = false;
  bool isShowDetailsMessage = false;
  String serverError = '';

  // move to exchangily
  double? unconfirmedBalance;
  TokenModel token = TokenModel();
  int decimalLimit = 6;
  Decimal chainBalance = Constants.decimalZero;
  bool isValidAmount = false;
  bool isSpeicalTronTokenWithdraw = false;
  String message = '';

  // same parameters for both
  String? coinName;
  String? tokenType;
  String? feeUnit;
  String? specialTicker;
  Decimal gasAmount = Decimal.zero;
  bool isDeposit = true;

  swapFunction() {
    isDeposit = !isDeposit;
    isDeposit ? toExchangeInit() : toWalletInit();
    notifyListeners();
  }

  Future<void> toExchangeInit() async {
    setBusy(true);
    coinName = walletInfo.tickerName;
    tokenType = walletInfo.tokenType;

    await setFee();
    await checkGasBalance();
    specialTicker = WalletUtil.updateSpecialTokensTickerName(
        walletInfo.tickerName.toString())['tickerName']!;
    await refreshBalance();

    if (coinName == 'BTC') {
      feeUnit = 'BTC';
    } else if (coinName == 'ETH' || tokenType == 'ETH') {
      feeUnit = 'ETH';
    } else if (coinName == 'FAB') {
      feeUnit = 'FAB';
    } else if (tokenType == 'FAB') {
      feeUnit = 'FAB';
    } else if (coinName == 'MATICM' || tokenType == 'POLYGON') {
      feeUnit = 'MATIC(POLYGON)';
    } else if (coinName == 'BNB' || tokenType == 'BNB') {
      feeUnit = 'BNB';
    }
    await coinService
        .getSingleTokenData((walletInfo.tickerName.toString()))
        .then((t) {
      token = t!;
      decimalLimit = t.decimal ?? 8;
    });
    if (tokenType!.isNotEmpty) await getNativeChainTickerBalance();
    setBusy(false);
  }

  Future<void> toWalletInit() async {
    setBusy(true);
    var gasPrice = environment["chains"]["KANBAN"]["gasPrice"] ?? 0;
    var gasLimit = environment["chains"]["KANBAN"]["gasLimit"] ?? 0;
    kanbanGasPriceTextController.text = gasPrice.toString();
    kanbanGasLimitTextController.text = gasLimit.toString();
    tokenType = walletInfo.tokenType;

    kanbanGasFee =
        NumberUtil.rawStringToDecimal((gasPrice * gasLimit).toString());

    if (walletInfo.tickerName == 'ETH' || walletInfo.tickerName == 'USDT') {
      feeUnit = 'WEI';
    } else if (walletInfo.tickerName == 'FAB') {
      feeUnit = 'LIU';
      feeMeasurement = '10^(-8)';
    }
    selectedChain = 'ETH';
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
    notifyListeners();
  }

  verifyFields() async {
    if (amountController.text.isEmpty ||
        double.parse(amountController.text) <= 0) {
      sharedService.sharedSimpleNotification(
          FlutterI18n.translate(context, "amountMissing"),
          subtitle: FlutterI18n.translate(context, "pleaseEnterValidNumber"));

      setBusy(false);
      return;
    }
    await checkGasBalance();
    if (gasAmount == Decimal.zero || gasAmount < kanbanGasFee) {
      sharedService.alertDialog(
        FlutterI18n.translate(context, "notice"),
        FlutterI18n.translate(context, "insufficientGasAmount"),
      );
      setBusy(false);
      return;
    }
    var amount = Decimal.parse(amountController.text);
    // deposit check
    if (isDeposit) {
      Decimal finalAmount = Constants.decimalZero;
      Decimal checkTransFeeAgainst = Constants.decimalZero;
      if (tokenType!.isEmpty) {
        checkTransFeeAgainst =
            NumberUtil.parseDoubleToDecimal(walletInfo.availableBalance!);
      } else {
        checkTransFeeAgainst = chainBalance;
      }
      if (transFee > checkTransFeeAgainst && !isTrx()) {
        sharedService.sharedSimpleNotification(
            FlutterI18n.translate(context, "notice"),
            subtitle: FlutterI18n.translate(context, "insufficientGasAmount"));

        setBusy(false);
        return;
      }
      await refreshBalance();

      finalAmount = await amountAfterFee();

      if (amount == Constants.decimalZero) {
        log.e(
            'amount $amount --- final amount with fee: $finalAmount -- wallet bal: ${walletInfo.availableBalance}');
        sharedService.alertDialog(
            FlutterI18n.translate(context, "invalidAmount"),
            FlutterI18n.translate(context, "pleaseEnterValidNumber"),
            isWarning: false);
        setBusy(false);
        return;
      }

      if (finalAmount >
          NumberUtil.parseDoubleToDecimal(walletInfo.availableBalance!)) {
        log.e(
            'amount $amount --- final amount with fee: $finalAmount -- wallet bal: ${walletInfo.availableBalance}');
        sharedService.alertDialog(
            FlutterI18n.translate(context, "invalidAmount"),
            FlutterI18n.translate(context, "insufficientBalance"),
            isWarning: false);
        setBusy(false);
        return;
      }

      deposit();
    } else {
      //withdraw check
      if (amount > Decimal.parse(walletInfo.inExchange.toString())) {
        sharedService.alertDialog(
            FlutterI18n.translate(context, "invalidAmount"),
            FlutterI18n.translate(context, "pleaseEnterValidNumber"),
            isWarning: false);
        setBusy(false);
        return;
      }
      if (amount < Decimal.parse(token.minWithdraw!.toString())) {
        sharedService.sharedSimpleNotification(
          FlutterI18n.translate(context, "minimumAmountError"),
          subtitle: FlutterI18n.translate(
              context, "yourWithdrawMinimumAmountaIsNotSatisfied"),
        );
        setBusy(false);
        return;
      }
      // initiate withdraw
      isWithdrawChoice ? withdrawConfirmation() : withdraw();
    }
  }

  // move to exchange
  deposit() async {
    setBusy(true);

    Decimal checkTransFeeAgainst = Constants.decimalZero;
    if (tokenType!.isEmpty) {
      checkTransFeeAgainst =
          NumberUtil.parseDoubleToDecimal(walletInfo.availableBalance!);
    } else {
      checkTransFeeAgainst = chainBalance;
    }
    if (transFee > checkTransFeeAgainst && !isTrx()) {
      sharedService.sharedSimpleNotification(
          FlutterI18n.translate(context, "insufficientBalance"),
          subtitle:
              '${FlutterI18n.translate(context, "gasFee")} $transFee > ${FlutterI18n.translate(context, "walletbalance")} ${walletInfo.availableBalance}');

      setBusy(false);
      return;
    }

    await refreshBalance();

    Decimal finalAmount = Constants.decimalZero;
    if (!isTrx()) {
      finalAmount = await amountAfterFee();
    }
    if (amount == Constants.decimalZero) {
      log.e(
          'amount $amount --- final amount with fee: $finalAmount -- wallet bal: ${walletInfo.availableBalance}');
      sharedService.alertDialog(FlutterI18n.translate(context, "invalidAmount"),
          FlutterI18n.translate(context, "pleaseEnterValidNumber"),
          isWarning: false);
      setBusy(false);
      return;
    }

    if (finalAmount >
        NumberUtil.parseDoubleToDecimal(walletInfo.availableBalance!)) {
      log.e(
          'amount $amount --- final amount with fee: $finalAmount -- wallet bal: ${walletInfo.availableBalance}');
      sharedService.alertDialog(FlutterI18n.translate(context, "invalidAmount"),
          FlutterI18n.translate(context, "insufficientBalance"),
          isWarning: false);
      setBusy(false);
      return;
    }

    /// check chain balance
    /// whether native token has enough balance to cover transaction fee
    if (tokenType!.isNotEmpty) {
      var tt = tokenType == 'POLYGON' ? 'MATICM' : tokenType;
      bool hasSufficientChainBalance = await walletService
          .hasSufficientWalletBalance(transFee.toDouble(), tt!);
      if (!hasSufficientChainBalance) {
        log.e('Chain $tokenType -- insufficient balance');
        sharedService.sharedSimpleNotification(walletInfo.tokenType!,
            subtitle: FlutterI18n.translate(context, "insufficientBalance"));
        setBusy(false);
        return;
      }
    }

// * checking trx balance required
    if (walletInfo.tickerName == 'USDTX') {
      log.e('amount $amount --- wallet bal: ${walletInfo.availableBalance}');
      bool isCorrectAmount = true;
      await walletService
          .hasSufficientWalletBalance(
              double.parse(trxGasValueTextController.text), 'TRX')
          .then((res) => isCorrectAmount = res);
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
      Decimal totalAmount =
          amount + Decimal.parse(trxGasValueTextController.text);
      if (totalAmount >
          NumberUtil.parseDoubleToDecimal(walletInfo.availableBalance!)) {
        isCorrectAmount = false;
      }
      if (!isCorrectAmount) {
        sharedService.alertDialog(
            '${FlutterI18n.translate(context, "fee")} ${FlutterI18n.translate(context, "notice")}',
            'TRX ${FlutterI18n.translate(context, "insufficientBalance")}',
            isWarning: false);
        setBusy(false);
        return;
      }
    }
// 541.81
// -4.123456789
// 7881.2
    message = '';
    var res = await _dialogService.showDialog(
        title: FlutterI18n.translate(context, "enterPassword"),
        description:
            FlutterI18n.translate(context, "dialogManagerTypeSamePasswordNote"),
        buttonTitle: FlutterI18n.translate(context, "confirm"));
    if (res.confirmed) {
      setBusy(true);
      Uint8List? seed;
      String? mnemonic = res.returnedText;
      if (walletInfo.tickerName != 'TRX' && walletInfo.tickerName != 'USDTX') {
        seed = walletService.generateSeed(mnemonic);
      }

      var gasPrice = int.tryParse(gasPriceTextController.text);
      var gasLimit = isTrx()
          ? int.tryParse(trxGasValueTextController.text)
          : int.tryParse(gasLimitTextController.text);
      var satoshisPerBytes = int.tryParse(satoshisPerByteTextController.text);
      var kanbanGasPrice = int.tryParse(kanbanGasPriceTextController.text);
      var kanbanGasLimit = int.tryParse(kanbanGasLimitTextController.text);
      String tickerName = walletInfo.tickerName!;
      int? decimal;
      //  BigInt bigIntAmount = BigInt.tryParse(amountController.text);
      // log.w('Big int amount $bigIntAmount');
      String? contractAddr = '';
      if (walletInfo.tokenType!.isNotEmpty) {
        contractAddr = environment["addresses"]["smartContract"][tickerName];
      }
      if (contractAddr == null && tokenType != '') {
        log.i(
            '$tickerName with token type $tokenType contract is null so fetching from token database');
        await tokenListDatabaseService
            .getByTickerName(tickerName)
            .then((token) {
          contractAddr = token!.contract;
          decimal = token.decimal;
        });
      }
      decimal ??= decimalLimit;
      var option = {
        "gasPrice": gasPrice ?? 0,
        "gasLimit": gasLimit ?? 0,
        "satoshisPerBytes": satoshisPerBytes ?? 0,
        'kanbanGasPrice': kanbanGasPrice,
        'kanbanGasLimit': kanbanGasLimit,
        'tokenType': walletInfo.tokenType,
        'contractAddress': contractAddr,
        'decimal': decimal
      };
      log.i('OPTIONS-- ${walletInfo.tickerName}, --   $amount, - - $option');

      // TRON Transaction
      if (walletInfo.tickerName == 'TRX' || walletInfo.tickerName == 'USDTX') {
        setBusy(true);
        log.i('depositing tron ${walletInfo.tickerName}');

        await walletService
            .depositTron(
                mnemonic: mnemonic,
                walletInfo: walletInfo,
                amount: amount,
                isTrxUsdt: walletInfo.tickerName == 'USDTX' ||
                        walletInfo.tickerName == 'USDCX'
                    ? true
                    : false,
                isBroadcast: false,
                options: option)
            .then((res) {
          bool success = res["success"];
          if (success) {
            amountController.text = '';
            String? txId = res['data']['transactionID'];

            isShowErrorDetailsButton = false;
            isShowDetailsMessage = false;
            message = txId.toString();

            sharedService.sharedSimpleNotification(
                FlutterI18n.translate(context, "depositTransactionSuccess"),
                subtitle:
                    '$specialTicker ${FlutterI18n.translate(context, "isOnItsWay")}',
                isError: false);
            Future.delayed(const Duration(seconds: 3), () {
              refreshBalance();
            });
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
              FlutterI18n.translate(context, "networkIssue"),
              '$tickerName ${FlutterI18n.translate(context, "transanctionFailed")}',
              isWarning: false);

          setBusy(false);
        });
      }

      // Normal DEPOSIT

      else {
        await walletService
            .depositDo(seed, walletInfo.tickerName!, walletInfo.tokenType!,
                finalAmount, option)
            .then((ret) {
          log.w('deposit res $ret');

          bool success = ret["success"];
          if (success) {
            amountController.text = '';
            String? txId = ret['data']['transactionID'];

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
                            ? Text(ret["data"] ==
                                    'incorrect amount for two transactions'
                                ? FlutterI18n.translate(
                                    context, "incorrectDepositAmountOfTwoTx")
                                : ret["data"])
                            : Text(
                                FlutterI18n.translate(context, "networkIssue")),
                  ]),
              position: NotificationPosition.bottom,
              background: primaryColor);
          Future.delayed(const Duration(seconds: 3), () {
            refreshBalance();
          });

          // sharedService.alertDialog(
          //     success
          //         ? AppLocalizations.of(context).depositTransactionSuccess
          //         : AppLocalizations.of(context).depositTransactionFailed,
          //     success
          //         ? ""
          //         : ret.containsKey("error") && ret["error"] != null
          //             ? ret["error"]
          //             : AppLocalizations.of(context).serverError,
          //     isWarning: false);
        }).catchError((onError) {
          log.e('Deposit Catch $onError');

          sharedService.alertDialog(
              FlutterI18n.translate(context, "depositTransactionFailed"),
              FlutterI18n.translate(context, "networkIssue"),
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

  showDetailsMessageToggle() {
    setBusy(true);
    isShowDetailsMessage = !isShowDetailsMessage;
    setBusy(false);
  }

  //----------------- move to wallet -----------------//

  /*----------------------------------------------------------------------
                      Verify Wallet Password
----------------------------------------------------------------------*/
  withdraw() async {
    setBusy(true);
    isSubmittingTx = true;
    try {
      var amount = Decimal.parse(amountController.text);

      await getSingleCoinExchangeBal();

      if (selectedChain == 'FAB' && amount > fabChainBalance) {
        sharedService.alertDialog(FlutterI18n.translate(context, "notice"),
            '${FlutterI18n.translate(context, "lowTsWalletBalanceErrorFirstPart")} $fabChainBalance. ${FlutterI18n.translate(context, "lowTsWalletBalanceErrorSecondPart")}',
            isWarning: false);

        setBusy(false);
        return;
      }

      /// show warning like amount should be less than ts wallet balance
      /// instead of displaying the generic error
      if (selectedChain == 'ETH' && amount > ethChainBalance) {
        sharedService.alertDialog(FlutterI18n.translate(context, "notice"),
            '${FlutterI18n.translate(context, "lowTsWalletBalanceErrorFirstPart")} $ethChainBalance. ${FlutterI18n.translate(context, "lowTsWalletBalanceErrorSecondPart")}',
            isWarning: false);

        setBusy(false);
        return;
      }
      if (selectedChain == 'TRX' && amount > trxTsWalletBalance) {
        sharedService.alertDialog(FlutterI18n.translate(context, "notice"),
            '${FlutterI18n.translate(context, "lowTsWalletBalanceErrorFirstPart")} $trxTsWalletBalance. ${FlutterI18n.translate(context, "lowTsWalletBalanceErrorSecondPart")}',
            isWarning: false);
        setBusy(false);
        return;
      }
      if (selectedChain == 'BNB' && amount > bnbTsWalletBalance) {
        sharedService.alertDialog(FlutterI18n.translate(context, "notice"),
            '${FlutterI18n.translate(context, "lowTsWalletBalanceErrorFirstPart ")} $bnbTsWalletBalance. ${FlutterI18n.translate(context, "lowTsWalletBalanceErrorSecondPart")}',
            isWarning: false);
        setBusy(false);
        return;
      }
      if (selectedChain == 'POLYGON' && amount > polygonTsWalletBalance) {
        sharedService.alertDialog(FlutterI18n.translate(context, "notice"),
            '${FlutterI18n.translate(context, "lowTsWalletBalanceErrorFirstPart")} $polygonTsWalletBalance. ${FlutterI18n.translate(context, "lowTsWalletBalanceErrorSecondPart")}',
            isWarning: false);
        setBusy(false);
        return;
      }

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
        // if (selectedCoinWalletInfo!.tickerName == 'FAB' && ) selectedCoinWalletInfo!.tokenType = '';

        var coinName = walletInfo.tickerName;
        var coinAddress = '';
        if (isShowFabChainBalance &&
            coinName != 'FAB' &&
            !WalletUtil.isSpecialFab(coinName!)) {
          coinAddress = exgAddress;
          tokenType = 'FAB';
        }

        /// Ticker is FAB but fab chain balance is false then
        /// take coin address as ETH wallet address because coin is an erc20
        else if (coinName == 'FAB' && !isShowFabChainBalance) {
          await sharedService
              .getCoinAddressFromCoreWalletDatabase('ETH')
              .then((walletAddress) => coinAddress = walletAddress);
        } // i.e when user is in FABB and selects FAB withdraw
        // then token type set to empty and uses fab address
        else if ((coinName != 'FAB' && isShowFabChainBalance) &&
            WalletUtil.isSpecialFab(coinName!)) {
          coinAddress =
              await sharedService.getFabAddressFromCoreWalletDatabase();
          tokenType = '';
          coinName = 'FAB';
        } else if (coinName == 'USDT' && isShowTrxTsWalletBalance) {
          await sharedService
              .getCoinAddressFromCoreWalletDatabase('TRX')
              .then((walletAddress) => coinAddress = walletAddress);
        } else if (coinName == 'EXG' && !isShowFabChainBalance) {
          coinAddress = exgAddress;
        } else if ((coinName == 'USDT' ||
                WalletUtil.isSpecialUsdt(coinName!)) &&
            isShowTrxTsWalletBalance) {
          coinAddress =
              await sharedService.getCoinAddressFromCoreWalletDatabase('TRX');
          coinName = 'USDTX';
        } else {
          coinAddress = walletInfo.address!;
        }
        if (coinName == 'BCH') {
          await walletService
              .getBchAddressDetails(coinAddress)
              .then((addressDetails) =>
                  coinAddress = addressDetails['legacyAddress'])
              .catchError((err) {});
        }

        var kanbanPrice = int.tryParse(kanbanGasPriceTextController.text);
        var kanbanGasLimit = int.tryParse(kanbanGasLimitTextController.text);
        if (walletInfo.tickerName == 'TRX' ||
            walletInfo.tokenType == 'TRX' ||
            walletInfo.tickerName == 'USDTX') {
          int kanbanGasPrice = environment['chains']['KANBAN']['gasPrice'];
          int kanbanGasLimit = environment['chains']['KANBAN']['gasLimit'];
          await walletService
              .withdrawTron(seed, coinName!, coinAddress, tokenType!, amount,
                  kanbanPrice, kanbanGasLimit)
              .then((ret) {
            bool success = ret["success"];
            if (success && ret['transactionHash'] != null) {
              String txId = ret['transactionHash'];
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
            isShowErrorDetailsButton = true;
            isSubmittingTx = false;
            serverError = err.toString();
          });
        } else {
          // withdraw function
          await walletService
              .withdrawDo(seed, coinName!, coinAddress, tokenType!, amount,
                  kanbanPrice, kanbanGasLimit, isSpeicalTronTokenWithdraw)
              .then((ret) {
            bool success = ret["success"];
            if (success && ret['transactionHash'] != null) {
              String txId = ret['transactionHash'];
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
      isSubmittingTx = false;
    }
    isSubmittingTx = false;
    setBusy(false);
  }

  withdrawConfirmation() async {
    try {
      await _dialogService
          .showVerifyDialog(
              title: FlutterI18n.translate(context, "withdrawPopupNote"),
              description: selectedChain,
              buttonTitle: FlutterI18n.translate(context, "confirm"))
          .then((res) {
        if (res.confirmed) {
          debugPrint('res  ${res.confirmed}');
          withdraw();
        } else {
          debugPrint('res ${res.confirmed}');
        }
      });
    } catch (err) {
      debugPrint('withdrawConfirmation CATCH $err');
    }
  }

  radioButtonSelection(value) async {
    setBusy(true);
    debugPrint("--------------------");
    debugPrint(value);
    selectedChain = value;
    if (value == 'FAB') {
      isShowFabChainBalance = true;
      isShowTrxTsWalletBalance = false;
      isShowPolygonTsWalletBalance = false;
      isShowBnbTsWalletBalance = false;
      if (walletInfo.tickerName != 'FAB') tokenType = 'FAB';
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

  assignToken(TokenModel token) {
    if (selectedChain == 'ETH') ercChainToken = token;
    if (selectedChain == 'BNB') bnbChainToken = token;
    if (selectedChain == 'POLYGON') polygonChainToken = token;
    if (selectedChain == 'TRX' || selectedChain == 'FAB') {
      mainChainToken = token;
    }
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
    } else {
      tickerName = walletInfo.tickerName!;
    }
    String fabAddress =
        await sharedService.getFabAddressFromCoreWalletDatabase();
    await apiService
        .getSingleWalletBalance(fabAddress, tickerName, walletInfo.address!)
        .then((res) {
      walletInfo.inExchange = res[0].unlockedExchangeBalance;
    });

    if (isSubmittingTx) {
      if (selectedChain == 'ETH') await getEthChainBalance();
      if (selectedChain == 'TRX') {
        tickerName == 'TRX'
            ? await getTrxTsWalletBalance()
            : await getTrxUsdtTsWalletBalance();
      }
      if (selectedChain == 'BNB') await getBnbTsWalletBalance();
      if (selectedChain == 'POLYGON') await getPolygonTsWalletBalance();
      if (selectedChain == 'FAB') {
        tickerName == 'FAB'
            ? await getFabBalance()
            : await getFabChainBalance(tickerName);
      }
    }
    setBusy(false);
  }

  /*----------------------------------------------------------------------
                        Fab Chain Balance
----------------------------------------------------------------------*/

  getFabBalance() async {
    setBusy(true);
    String fabAddress = coinService.getCoinOfficalAddress('FAB');
    await walletService.coinBalanceByAddress('FAB', fabAddress, '').then((res) {
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
    Decimal tokenBalance;
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
        decimalPrecision: token.decimal!);

    fabChainBalance = tokenBalance;
    debugPrint('$tickerName fab chain balance $fabChainBalance');
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
    await apiService.getTokenListUpdates().then((tokens) {
      smartContractAddress = tokens
          .firstWhere((element) => element.tickerName == ticker)
          .contract!;
    });

    String trxOfficialddress = coinService.getCoinOfficalAddress('TRX');
    await apiService
        .getTronUsdtTsWalletBalance(trxOfficialddress, smartContractAddress)
        .then((res) {
      trxTsWalletBalance =
          NumberUtil.rawStringToDecimal(res, decimalPrecision: 6);
    });
    setBusy(false);
  }

  /*----------------------------------------------------------------------
                        TRX 20 TS Wallet Balance
----------------------------------------------------------------------*/
  getTrxTsWalletBalance() async {
    setBusy(true);
    String trxOfficialddress = coinService.getCoinOfficalAddress('TRX');
    await apiService.getTronTsWalletBalance(trxOfficialddress).then((res) {
      trxTsWalletBalance =
          NumberUtil.rawStringToDecimal(res['balance'], decimalPrecision: 6);
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
      bnbTsWalletBalance = NumberUtil.parseDoubleToDecimal(res[0].balance!);
    });

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
      polygonTsWalletBalance = NumberUtil.parseDoubleToDecimal(res[0].balance!);
    });

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
      if (walletInfo.tickerName == 'USDT' || walletInfo.tickerName == 'USDTX') {
        ethChainBalance = res['balance1e6']!;
      } else if (walletInfo.tickerName == 'FABE' ||
          walletInfo.tickerName == 'FAB') {
        ethChainBalance = res['balanceIe8']!;
      } else {
        ethChainBalance = res['tokenBalanceIe18']!;
      }
    });
    setBusy(false);
  }

  /*---------------------------------------------------------------
                        Set Withdraw Limit
-------------------------------------------------------------- */

  setWithdrawLimit(String ticker) async {
    setBusy(true);
    if (ercChainToken.feeWithdraw != null &&
        ercChainToken.feeWithdraw != 'null' &&
        selectedChain == 'ETH') {
      token = ercChainToken;
      setBusy(false);
      return;
    }
    if (mainChainToken.feeWithdraw != null &&
        mainChainToken.feeWithdraw != 'null' &&
        (selectedChain == 'TRX' || selectedChain == 'FAB')) {
      token = mainChainToken;
      setBusy(false);
      return;
    }
    token = TokenModel();
    int ct = 0;
    await coinService.getCoinTypeByTickerName(ticker).then((value) {
      ct = value;
    });

    await tokenListDatabaseService.getByCointype(ct).then((res) async {
      if (res != null &&
          res.feeWithdraw!.isNotEmpty &&
          res.feeWithdraw! != "null") {
        token = res;
      } else {
        await coinService
            .getSingleTokenData(ticker, coinType: ct)
            .then((resFromApi) {
          if (resFromApi != null) {
            debugPrint('token from api res ${resFromApi.toJson()}');
            token = resFromApi;
          }
        });
      }
    });
    assignToken(token);
    setBusy(false);
  }

  /*---------------------------------------------------
                      Get gas
--------------------------------------------------- */

  checkGasBalance() async {
    String address = '';
    try {
      address = await sharedService.getExgAddressFromCoreWalletDatabase();
    } catch (err) {
      debugPrint(err.toString());
    }
    await walletService.gasBalance(address).then((data) {
      gasAmount = NumberUtil.parseDoubleToDecimal(data);
      if (gasAmount == Decimal.zero) {
        sharedService.alertDialog(
          FlutterI18n.translate(context, "notice"),
          FlutterI18n.translate(context, "insufficientGasAmount"),
        );
      }
    }).catchError((onError) {
      debugPrint(onError.toString());
    });
    return gasAmount;
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

  updateKanbanGasFee() async {
    setBusy(true);
    var kanbanPrice = int.tryParse(kanbanGasPriceTextController.text);
    var kanbanGasLimit = int.tryParse(kanbanGasLimitTextController.text);

    var kanbanPriceBig = BigInt.from(kanbanPrice!);
    var kanbanGasLimitBig = BigInt.from(kanbanGasLimit!);
    var kanbanTransFeeDouble = NumberUtil.rawStringToDecimal(
        (kanbanPriceBig * kanbanGasLimitBig).toString());
    debugPrint('Update trans fee $kanbanTransFeeDouble');

    kanbanGasFee = kanbanTransFeeDouble;
    setBusy(false);
  }

  //----------------- move to exchangily -------------------------------------------------------------------------------------------//

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
    } else if (coinName == 'BNB' || tokenType == 'BNB') {
      var gasPriceReal = await erc20Util.getGasPrice(ApiRoutes.bnbBaseUrl);
      gasPriceTextController.text = gasPriceReal.toString();
      gasLimitTextController.text =
          environment["chains"]["BNB"]["gasLimit"].toString();

      if (tokenType == 'BNB') {
        gasLimitTextController.text =
            environment["chains"]["BNB"]["gasLimitToken"].toString();
      }
    } else if (coinName == 'MATICM' || tokenType == 'POLYGON') {
      var gasPriceReal = await erc20Util.getGasPrice(ApiRoutes.maticmBaseUrl);
      gasPriceTextController.text = gasPriceReal.toString();
      gasLimitTextController.text =
          environment["chains"]["MATICM"]["gasLimit"].toString();

      if (tokenType == 'POLYGON') {
        gasLimitTextController.text =
            environment["chains"]["POLYGON"]["gasLimitToken"].toString();
      }
    } else if (coinName == 'USDTX' || coinName == 'USDCX') {
      gasPriceTextController.text = Constants.tronUsdtFee.toString();
    } else if (coinName == 'TRX') {
      gasPriceTextController.text = Constants.tronFee.toString();
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

    controllersList = [
      gasPriceTextController,
      gasLimitTextController,
      kanbanGasPriceTextController,
      kanbanGasLimitTextController,
      satoshisPerByteTextController,
    ];

    controllersList.removeWhere((controller) => controller.text.trim().isEmpty);
  }

  refreshBalance() async {
    setBusy(true);
    unconfirmedBalance = 0.0;
    String fabAddress =
        await sharedService.getFabAddressFromCoreWalletDatabase();
    await apiService
        .getSingleWalletBalance(
            fabAddress, walletInfo.tickerName!, walletInfo.address!)
        .then((walletBalance) {
      if (walletBalance.isNotEmpty) {
        walletInfo.availableBalance = walletBalance[0].balance;
        unconfirmedBalance = walletBalance[0].unconfirmedBalance!;
      }
    }).catchError((err) {
      setBusy(false);
      throw Exception(err);
    });
    setBusy(false);
  }

  getNativeChainTickerBalance() async {
    var fabAddress = await sharedService.getFabAddressFromCoreWalletDatabase();

    var tt = tokenType == 'POLYGON' ? 'MATICM' : tokenType;
    await apiService
        .getSingleWalletBalance(fabAddress, tt!, walletInfo.address.toString())
        .then((walletBalance) => chainBalance =
            NumberUtil.parseDoubleToDecimal(walletBalance.first.balance!));
  }

  fillMaxAmount() {
    setBusy(true);
    amountController.text = NumberUtil.roundDouble(walletInfo.availableBalance!,
            decimalPlaces: decimalLimit)
        .toString();

    setBusy(false);
    updateTransFee();
  }

  updateTransFee() async {
    setBusy(true);
    var to =
        coinService.getCoinOfficalAddress(coinName!, tokenType: tokenType!);
    var amount = Decimal.parse(amountController.text);

    if (to == null || amount <= Decimal.zero) {
      transFee = Decimal.zero;
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
    Decimal? kanbanFee;
    if (kanbanGasLimit != null && kanbanPrice != null) {
      var kanbanPriceBig = BigInt.from(kanbanPrice);
      var kanbanGasLimitBig = BigInt.from(kanbanGasLimit);
      var f = NumberUtil.rawStringToDecimal(
          (kanbanPriceBig * kanbanGasLimitBig).toString());
      kanbanFee = f;
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
      if (ret != null && ret['transFee'] != null) {
        transFee = Decimal.parse(ret['transFee'].toString());
        kanbanGasFee = kanbanFee!;
        setBusy(false);
      }
      if (isTrx()) {
        if (transFee == Decimal.zero) {
          isValidAmount = false;
        }
      }
    }).catchError((onError) {
      log.e('updateTransFee error $onError');
      setBusy(false);
    });

    setBusy(false);
  }

  Future<Decimal> amountAfterFee({bool isMaxAmount = false}) async {
    setBusy(true);
    if (amountController.text == '.') {
      setBusy(false);
      return Constants.decimalZero;
    }
    if (amountController.text.isEmpty) {
      transFee = Constants.decimalZero;
      kanbanGasFee = Constants.decimalZero;
      setBusy(false);
      return Constants.decimalZero;
    }
    amount = NumberUtil.decimalLimiter(Decimal.parse(amountController.text),
        decimalPlaces: decimalLimit);
    log.w('amountAfterFee func: amount $amount');

    Decimal finalAmount = Constants.decimalZero;
    // update if transfee is 0

    // if tron coins then assign fee accordingly
    if (isTrx()) {
      if (walletInfo.tickerName == 'USDTX' || walletInfo.tokenType == 'TRX') {
        transFee = Decimal.parse(trxGasValueTextController.text);
        finalAmount = amount;
        finalAmount <=
                NumberUtil.parseDoubleToDecimal(walletInfo.availableBalance!)
            ? isValidAmount = true
            : isValidAmount = false;
      }

      if (walletInfo.tickerName == 'TRX') {
        transFee = Decimal.parse(trxGasValueTextController.text);
        finalAmount = isMaxAmount ? amount - transFee : amount + transFee;
      }
    } else {
      await updateTransFee();
      // in any token transfer, gas fee is paid in native tokens so
      // in case of non-native tokens, need to check the balance of native tokens
      // so that there is fee to pay when transffering non-native tokens
      if (tokenType!.isEmpty) {
        if (isMaxAmount) {
          finalAmount = (Decimal.parse(amount.toString()) -
              Decimal.parse(transFee.toString()));
        } else {
          finalAmount = (Decimal.parse(transFee.toString()) +
              Decimal.parse(amount.toString()));

          log.e(
              'final amount $finalAmount = amount $amount  + transFee $transFee');
        }
      } else {
        finalAmount = amount;
      }
    }

    finalAmount <= NumberUtil.parseDoubleToDecimal(walletInfo.availableBalance!)
        ? isValidAmount = true
        : isValidAmount = false;
    log.i(
        'Func:amountAfterFee --trans fee $transFee  -- entered amount $amount =  finalAmount $finalAmount -- decimal limit final amount $finalAmount-- isValidAmount $isValidAmount');
    setBusy(false);
    // It happens because floating-point numbers cannot always precisely represent decimal fractions. Instead, they represent them as binary fractions, which can sometimes result in rounding errors.
    //0.025105000000000002
    return finalAmount;
  }

  bool isTrx() {
    return walletInfo.tickerName == 'TRX' || walletInfo.tokenType == 'TRX'
        ? true
        : false;
  }

  List<Widget> getFeeWidget(BuildContext context, Size size) {
    List<Widget> widgets = [];

    for (var element in controllersList) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            width: size.width,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Center(
                  child: Text(
                    getControllerName(context, element),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: textHintGrey),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: element,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      element.selection = TextSelection.fromPosition(
                        TextPosition(offset: element.text.length),
                      );

                      notifyListeners();
                    },
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "90",
                      hintStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                      contentPadding: EdgeInsets.only(left: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  String getControllerName(
      BuildContext context, TextEditingController controller) {
    if (controller == gasPriceTextController) {
      return FlutterI18n.translate(context, "gasPrice");
    } else if (controller == gasLimitTextController) {
      return FlutterI18n.translate(context, "gasLimit");
    } else if (controller == kanbanGasPriceTextController) {
      return FlutterI18n.translate(context, "kanbanGasPrice");
    } else if (controller == kanbanGasLimitTextController) {
      return FlutterI18n.translate(context, "kanbanGasLimit");
    } else if (controller == satoshisPerByteTextController) {
      return FlutterI18n.translate(context, "satoshisPerByte");
    } else {
      return '';
    }
  }
}
