import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/api_routes.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/constants.dart';
import 'package:paycool/environments/environment.dart';
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
  BuildContext? context;
  late AppStateProvider appStateProvider;

  final walletUtil = WalletUtil();
  final walletService = locator<WalletService>();
  final sharedService = locator<SharedService>();
  Erc20Util erc20Util = Erc20Util();
  final apiService = locator<ApiService>();
  final coinService = locator<CoinService>();
  final tokenListDatabaseService = locator<TokenListDatabaseService>();
  final LocalDialogService _dialogService = locator<LocalDialogService>();

  WalletInfo? selectedCoinWalletInfo;
  List<WalletBalance> wallets = [];
  String fromText = "Wallet";
  String toText = "Exchangily";
  bool isMoveToWallet = false;

  final amountTextController = TextEditingController();

  final gasPriceTextController = TextEditingController();
  final gasLimitTextController = TextEditingController();
  final kanbanGasPriceTextController = TextEditingController();
  final kanbanGasLimitTextController = TextEditingController();
  final satoshisPerByteTextController = TextEditingController();

  List<TextEditingController> controllersList = [];

  // move to wallet
  double gasFee = 0.0;
  double kanbanGasFee = 0.0;

  String feeMeasurement = '';
  bool isShowFabChainBalance = false;
  bool isShowTrxTsWalletBalance = false;
  bool isShowBnbTsWalletBalance = false;
  bool isShowPolygonTsWalletBalance = false;

  bool isWithdrawChoicePopup = false;
  TokenModel token = TokenModel();
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

  var ethChainBalance;
  var fabChainBalance;
  var trxTsWalletBalance;
  var bnbTsWalletBalance;
  var polygonTsWalletBalance;

  bool isShowErrorDetailsButton = false;
  bool isShowDetailsMessage = false;
  String serverError = '';

  // move to exchangily
  double? unconfirmedBalance;
  TokenModel tokenModel = TokenModel();
  int decimalLimit = 6;
  double chainBalance = 0.0;
  // double amount = 0.0;
  bool isValidAmount = false;
  bool isSpeicalTronTokenWithdraw = false;
  String message = '';

  // same parameters for both
  String? coinName;
  String? tokenType;
  String? feeUnit;
  String? specialTicker;
  double gasAmount = 0.0;

  initState() async {
    appStateProvider = Provider.of<AppStateProvider>(context!, listen: false);
    toExchangeInit();
  }

  Future<void> toExchangeInit() async {
    coinName = selectedCoinWalletInfo!.tickerName;
    tokenType = selectedCoinWalletInfo!.tokenType;

    setFee();
    await getGas();
    specialTicker = WalletUtil.updateSpecialTokensTickerName(
        selectedCoinWalletInfo!.tickerName.toString())['tickerName']!;
    refreshBalance();

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
        .getSingleTokenData((selectedCoinWalletInfo!.tickerName.toString()))
        .then((t) {
      tokenModel = t!;
      decimalLimit = t.decimal!;
    });
    if (decimalLimit == 0) decimalLimit = 8;
    if (tokenType!.isNotEmpty) await getNativeChainTickerBalance();

    notifyListeners();
  }

  Future<void> toWalletInit() async {
    setBusy(true);
    var gasPrice = environment["chains"]["KANBAN"]["gasPrice"] ?? 0;
    var gasLimit = environment["chains"]["KANBAN"]["gasLimit"] ?? 0;
    kanbanGasPriceTextController.text = gasPrice.toString();
    kanbanGasLimitTextController.text = gasLimit.toString();
    tokenType = selectedCoinWalletInfo!.tokenType;

    kanbanGasFee =
        NumberUtil.rawStringToDecimal((gasPrice * gasLimit).toString())
            .toDouble();

    if (selectedCoinWalletInfo!.tickerName == 'ETH' ||
        selectedCoinWalletInfo!.tickerName == 'USDT') {
      feeUnit = 'WEI';
    } else if (selectedCoinWalletInfo!.tickerName == 'FAB') {
      feeUnit = 'LIU';
      feeMeasurement = '10^(-8)';
    }
    selectedChain = 'ETH';
    if (selectedCoinWalletInfo!.tickerName == 'ETH' ||
        selectedCoinWalletInfo!.tokenType == 'ETH') {
      radioButtonSelection('ETH');
    } else if (selectedCoinWalletInfo!.tickerName == 'FAB' ||
        selectedCoinWalletInfo!.tokenType == 'FAB') {
      isShowFabChainBalance = true;
      radioButtonSelection('FAB');
    } else if (selectedCoinWalletInfo!.tickerName == 'USDCX' ||
        selectedCoinWalletInfo!.tickerName == 'USDTX' ||
        selectedCoinWalletInfo!.tickerName == 'TRX') {
      isShowTrxTsWalletBalance = true;
      radioButtonSelection('TRX');
    } // BNB
    else if (selectedCoinWalletInfo!.tickerName == 'FABB' ||
        selectedCoinWalletInfo!.tickerName == 'USDTB' ||
        selectedCoinWalletInfo!.tokenType == 'BNB') {
      isShowBnbTsWalletBalance = true;

      radioButtonSelection('BNB');
    }
    // POLYGON
    else if (selectedCoinWalletInfo!.tokenType == 'MATICM' ||
        selectedCoinWalletInfo!.tickerName == 'MATICM' ||
        selectedCoinWalletInfo!.tokenType == 'POLYGON') {
      isShowPolygonTsWalletBalance = true;

      radioButtonSelection('POLYGON');
    } else {
      setWithdrawLimit(selectedCoinWalletInfo!.tickerName!);
    }
    specialTicker = WalletUtil.updateSpecialTokensTickerName(
        selectedCoinWalletInfo!.tickerName.toString())['tickerName']!;
    await checkGasBalance();
    await getSingleCoinExchangeBal();

    setBusy(false);
    notifyListeners();
  }

  //----------------- move to wallet -----------------//

  /*----------------------------------------------------------------------
                      Verify Wallet Password
----------------------------------------------------------------------*/
  checkPass() async {
    setBusy(true);
    isSubmittingTx = true;
    try {
      if (amountTextController.text.isEmpty) {
        sharedService.showInfoFlushbar(
            FlutterI18n.translate(context!, "minimumAmountError"),
            FlutterI18n.translate(
                context!, "yourWithdrawMinimumAmountaIsNotSatisfied"),
            Icons.cancel,
            red,
            context!);
        setBusy(false);
        return;
      }
      await checkGasBalance();
      if (gasAmount == 0.0 || gasAmount < kanbanGasFee) {
        sharedService.alertDialog(
          FlutterI18n.translate(context!, "notice"),
          FlutterI18n.translate(context!, "insufficientGasAmount"),
        );
        setBusy(false);
        return;
      }

      var amount = double.tryParse(amountTextController.text);
      if (amount! < double.parse(token.minWithdraw!)) {
        sharedService.sharedSimpleNotification(
          FlutterI18n.translate(context!, "minimumAmountError"),
          subtitle: FlutterI18n.translate(
              context!, "yourWithdrawMinimumAmountaIsNotSatisfied"),
        );
        setBusy(false);
        return;
      }
      await getSingleCoinExchangeBal();

      if (amount > selectedCoinWalletInfo!.inExchange! ||
          amount == 0 ||
          amount.isNegative) {
        sharedService.alertDialog(
            FlutterI18n.translate(context!, "invalidAmount"),
            FlutterI18n.translate(context!, "pleaseEnterValidNumber"),
            isWarning: false);
        setBusy(false);
        return;
      }

      if (selectedChain == 'FAB' && amount > fabChainBalance) {
        sharedService.alertDialog(FlutterI18n.translate(context!, "notice"),
            '${FlutterI18n.translate(context!, "lowTsWalletBalanceErrorFirstPart")} $fabChainBalance. ${FlutterI18n.translate(context!, "lowTsWalletBalanceErrorSecondPart")}',
            isWarning: false);

        setBusy(false);
        return;
      }

      /// show warning like amount should be less than ts wallet balance
      /// instead of displaying the generic error
      if (selectedChain == 'ETH' && amount > ethChainBalance) {
        sharedService.alertDialog(FlutterI18n.translate(context!, "notice"),
            '${FlutterI18n.translate(context!, "lowTsWalletBalanceErrorFirstPart")} $ethChainBalance. ${FlutterI18n.translate(context!, "lowTsWalletBalanceErrorSecondPart")}',
            isWarning: false);

        setBusy(false);
        return;
      }
      if (selectedChain == 'TRX' && amount > trxTsWalletBalance) {
        sharedService.alertDialog(FlutterI18n.translate(context!, "notice"),
            '${FlutterI18n.translate(context!, "lowTsWalletBalanceErrorFirstPart")} $trxTsWalletBalance. ${FlutterI18n.translate(context!, "lowTsWalletBalanceErrorSecondPart")}',
            isWarning: false);
        setBusy(false);
        return;
      }
      if (selectedChain == 'BNB' && amount > bnbTsWalletBalance) {
        sharedService.alertDialog(FlutterI18n.translate(context!, "notice"),
            '${FlutterI18n.translate(context!, "lowTsWalletBalanceErrorFirstPart ")} $bnbTsWalletBalance. ${FlutterI18n.translate(context!, "lowTsWalletBalanceErrorSecondPart")}',
            isWarning: false);
        setBusy(false);
        return;
      }
      if (selectedChain == 'POLYGON' && amount > polygonTsWalletBalance) {
        sharedService.alertDialog(FlutterI18n.translate(context!, "notice"),
            '${FlutterI18n.translate(context!, "lowTsWalletBalanceErrorFirstPart")} $polygonTsWalletBalance. ${FlutterI18n.translate(context!, "lowTsWalletBalanceErrorSecondPart")}',
            isWarning: false);
        setBusy(false);
        return;
      }

      var res = await _dialogService.showDialog(
          title: FlutterI18n.translate(context!, "enterPassword"),
          description: FlutterI18n.translate(
              context!, "dialogManagerTypeSamePasswordNote"),
          buttonTitle: FlutterI18n.translate(context!, "confirm"));
      if (res.confirmed) {
        String exgAddress =
            await sharedService.getExgAddressFromCoreWalletDatabase();
        String mnemonic = res.returnedText;
        Uint8List seed = walletService.generateSeed(mnemonic);
        // if (selectedCoinWalletInfo!.tickerName == 'FAB' && ) selectedCoinWalletInfo!.tokenType = '';

        var coinName = selectedCoinWalletInfo!.tickerName;
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
          coinAddress = selectedCoinWalletInfo!.address!;
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
        if (selectedCoinWalletInfo!.tickerName == 'TRX' ||
            selectedCoinWalletInfo!.tokenType == 'TRX' ||
            selectedCoinWalletInfo!.tickerName == 'USDTX') {
          int kanbanGasPrice = environment['chains']['KANBAN']['gasPrice'];
          int kanbanGasLimit = environment['chains']['KANBAN']['gasLimit'];
          await walletService
              .withdrawTron(seed, coinName!, coinAddress, tokenType!, amount,
                  kanbanPrice, kanbanGasLimit)
              .then((ret) {
            bool success = ret["success"];
            if (success && ret['transactionHash'] != null) {
              String txId = ret['transactionHash'];
              amountTextController.text = '';
              serverError = '';
              isShowErrorDetailsButton = false;
              message = txId;
            } else {
              serverError = ret['data'].toString();
              if (serverError.isEmpty) {
                var errMsg = FlutterI18n.translate(context!, "serverError");
                error(errMsg);
                isShowErrorDetailsButton = true;
                isSubmittingTx = false;
              }
            }
            sharedService.alertDialog(
                success && ret['transactionHash'] != null
                    ? FlutterI18n.translate(
                        context!, "withdrawTransactionSuccessful")
                    : FlutterI18n.translate(
                        context!, "withdrawTransactionFailed"),
                success ? "" : FlutterI18n.translate(context!, "serverError"),
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
              amountTextController.text = '';
              serverError = '';
              isShowErrorDetailsButton = false;
              message = txId;
            } else {
              serverError = ret['data'];
              if (serverError == '') {
                var errMsg = FlutterI18n.translate(context!, "serverError");
                error(errMsg);
                isShowErrorDetailsButton = true;
                isSubmittingTx = false;
              }
            }
            sharedService.sharedSimpleNotification(
                success && ret['transactionHash'] != null
                    ? FlutterI18n.translate(
                        context!, "withdrawTransactionSuccessful")
                    : FlutterI18n.translate(
                        context!, "withdrawTransactionFailed"),
                subtitle: success
                    ? ""
                    : FlutterI18n.translate(context!, "serverError"),
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
          showNotification(context!);
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
              title: FlutterI18n.translate(context!, "withdrawPopupNote"),
              description: selectedChain,
              buttonTitle: FlutterI18n.translate(context!, "confirm"))
          .then((res) {
        if (res.confirmed) {
          debugPrint('res  ${res.confirmed}');
          checkPass();
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
      if (selectedCoinWalletInfo!.tickerName != 'FAB') tokenType = 'FAB';
      if (selectedCoinWalletInfo!.tickerName == 'FABE' &&
          isShowFabChainBalance) {
        await setWithdrawLimit('FAB');
      } else if (selectedCoinWalletInfo!.tickerName == 'DSCE' &&
          isShowFabChainBalance) {
        await setWithdrawLimit('DSC');
      } else if (selectedCoinWalletInfo!.tickerName == 'BSTE' &&
          isShowFabChainBalance) {
        await setWithdrawLimit('BST');
      } else if (selectedCoinWalletInfo!.tickerName == 'EXGE' &&
          isShowFabChainBalance) {
        await setWithdrawLimit('EXG');
      } else {
        await setWithdrawLimit(selectedCoinWalletInfo!.tickerName!);
      }
    } else if (value == 'TRX') {
      isShowPolygonTsWalletBalance = false;
      isShowBnbTsWalletBalance = false;
      isShowTrxTsWalletBalance = true;
      isSpeicalTronTokenWithdraw = true;
      if (selectedCoinWalletInfo!.tickerName == 'TRX' &&
          isShowTrxTsWalletBalance) {
        await setWithdrawLimit('TRX');
      } else if (selectedCoinWalletInfo!.tickerName == 'USDCX' &&
          isShowTrxTsWalletBalance) {
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
      if (WalletUtil.isSpecialUsdt(selectedCoinWalletInfo!.tickerName!) ||
          selectedCoinWalletInfo!.tickerName == 'USDT') {
        await setWithdrawLimit('USDTB');
      } else if (WalletUtil.isSpecialFab(selectedCoinWalletInfo!.tickerName!) ||
          selectedCoinWalletInfo!.tickerName == 'FAB') {
        await setWithdrawLimit('FABB');
      } else {
        await setWithdrawLimit(selectedCoinWalletInfo!.tickerName!);
      }
      tokenType = 'BNB';
    } else if (value == 'POLYGON') {
      isShowPolygonTsWalletBalance = true;
      isShowFabChainBalance = false;
      isShowBnbTsWalletBalance = false;
      isShowTrxTsWalletBalance = false;
      if (WalletUtil.isSpecialUsdt(selectedCoinWalletInfo!.tickerName!) ||
          selectedCoinWalletInfo!.tickerName == 'USDT') {
        await setWithdrawLimit('USDTM');
      } else {
        await setWithdrawLimit(selectedCoinWalletInfo!.tickerName!);
      }
      tokenType = 'POLYGON';
    } else {
      isShowTrxTsWalletBalance = false;
      isShowFabChainBalance = false;
      isShowPolygonTsWalletBalance = false;
      isShowBnbTsWalletBalance = false;
      tokenType = 'ETH';
      if (selectedCoinWalletInfo!.tickerName == 'FAB' &&
          !isShowFabChainBalance) {
        await setWithdrawLimit('FABE');
      } else if (selectedCoinWalletInfo!.tickerName == 'DSC' &&
          !isShowFabChainBalance) {
        await setWithdrawLimit('DSCE');
      } else if (selectedCoinWalletInfo!.tickerName == 'BST' &&
          !isShowFabChainBalance) {
        await setWithdrawLimit('BSTE');
      } else if (selectedCoinWalletInfo!.tickerName == 'EXG' &&
          !isShowFabChainBalance) {
        await setWithdrawLimit('EXGE');
      } else if (selectedCoinWalletInfo!.tickerName == 'USDTX' &&
          !isShowTrxTsWalletBalance) {
        await setWithdrawLimit('USDT');
      } else if (selectedCoinWalletInfo!.tickerName == 'USDCX' &&
          !isShowTrxTsWalletBalance) {
        await setWithdrawLimit('USDC');
      } else {
        await setWithdrawLimit(selectedCoinWalletInfo!.tickerName!);
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
    if (selectedCoinWalletInfo!.tickerName == 'DSCE' ||
        selectedCoinWalletInfo!.tickerName == 'DSC') {
      tickerName = 'DSC';
      isWithdrawChoice = true;
    } else if (selectedCoinWalletInfo!.tickerName == 'BSTE' ||
        selectedCoinWalletInfo!.tickerName == 'BST') {
      tickerName = 'BST';
      isWithdrawChoice = true;
    } else if (selectedCoinWalletInfo!.tickerName == 'FABE' ||
        selectedCoinWalletInfo!.tickerName == 'FAB') {
      tickerName = 'FAB';
      isWithdrawChoice = true;
    } else if (selectedCoinWalletInfo!.tickerName == 'EXGE' ||
        selectedCoinWalletInfo!.tickerName == 'EXG') {
      tickerName = 'EXG';
      isWithdrawChoice = true;
    } else if (selectedCoinWalletInfo!.tickerName == 'USDT' ||
        selectedCoinWalletInfo!.tickerName == 'USDTX') {
      tickerName = 'USDT';
      isWithdrawChoice = true;
      isShowFabChainBalance = false;
    } else if (selectedCoinWalletInfo!.tickerName == 'USDC' ||
        selectedCoinWalletInfo!.tickerName == 'USDCX') {
      tickerName = 'USDC';
      isWithdrawChoice = true;
      isShowFabChainBalance = false;
    } else if (selectedCoinWalletInfo!.tickerName == 'MATICM') {
      tickerName = 'MATIC';
    } else {
      tickerName = selectedCoinWalletInfo!.tickerName!;
    }
    String fabAddress =
        await sharedService.getFabAddressFromCoreWalletDatabase();
    await apiService
        .getSingleWalletBalance(
            fabAddress, tickerName, selectedCoinWalletInfo!.address!)
        .then((res) {
      selectedCoinWalletInfo!.inExchange = res[0].unlockedExchangeBalance;
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
                        TRX USDT TS Wallet Balance
----------------------------------------------------------------------*/
  getTrxUsdtTsWalletBalance() async {
    setBusy(true);

    String smartContractAddress = '';
    String ticker = '';
    if (WalletUtil.isSpecialUsdt(selectedCoinWalletInfo!.tickerName!) ||
        selectedCoinWalletInfo!.tickerName == 'USDT') {
      ticker = 'USDTX';
    } else if (selectedCoinWalletInfo!.tickerName == 'USDC' ||
        WalletUtil.isSpecialUsdc(selectedCoinWalletInfo!.tickerName!)) {
      ticker = 'USDCX';
    } else {
      ticker = selectedCoinWalletInfo!.tickerName!;
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
      trxTsWalletBalance = res / 1e6;
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
      trxTsWalletBalance = res['balance'] / 1e6;
    });
    setBusy(false);
  }

  getBnbTsWalletBalance() async {
    setBusy(true);
    String officialAddress = '';
    officialAddress = coinService.getCoinOfficalAddress('ETH');
    var fabAddress = await sharedService.getFabAddressFromCoreWalletDatabase();
    String updatedTicker = '';
    if (WalletUtil.isSpecialUsdt(selectedCoinWalletInfo!.tickerName!) ||
        selectedCoinWalletInfo!.tickerName == 'USDT') {
      updatedTicker = 'USDTB';
    } else if (selectedCoinWalletInfo!.tickerName == 'FAB' ||
        WalletUtil.isSpecialFab(selectedCoinWalletInfo!.tickerName!)) {
      updatedTicker = 'FABB';
    } else {
      updatedTicker = selectedCoinWalletInfo!.tickerName!;
    }
    await apiService
        .getSingleWalletBalance(fabAddress, updatedTicker, officialAddress)
        .then((res) {
      bnbTsWalletBalance = res[0].balance;
    });

    setBusy(false);
  }

  getPolygonTsWalletBalance() async {
    setBusy(true);
    String officialAddress = '';
    officialAddress = coinService.getCoinOfficalAddress('ETH');
    var fabAddress = await sharedService.getFabAddressFromCoreWalletDatabase();
    String updatedTicker = '';
    if (WalletUtil.isSpecialUsdt(selectedCoinWalletInfo!.tickerName!) ||
        selectedCoinWalletInfo!.tickerName == 'USDT') {
      updatedTicker = 'USDTM';
    } else {
      updatedTicker = selectedCoinWalletInfo!.tickerName!;
    }
    await apiService
        .getSingleWalletBalance(fabAddress, updatedTicker, officialAddress)
        .then((res) {
      polygonTsWalletBalance = res[0].balance;
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
    if (selectedCoinWalletInfo!.tickerName == 'FAB') {
      updateTickerForErc = 'FABE';
    } else if (selectedCoinWalletInfo!.tickerName == 'DSC') {
      updateTickerForErc = 'DSCE';
    } else if (selectedCoinWalletInfo!.tickerName == 'BST') {
      updateTickerForErc = 'BSTE';
    } else if (selectedCoinWalletInfo!.tickerName == 'EXG') {
      updateTickerForErc = 'EXGE';
    } else if (selectedCoinWalletInfo!.tickerName == 'USDTX') {
      updateTickerForErc = 'USDT';
    } else {
      updateTickerForErc = selectedCoinWalletInfo!.tickerName!;
    }
    ercSmartContractAddress = (await coinService
        .getSmartContractAddressByTickerName(updateTickerForErc))!;

    await getEthTokenBalanceByAddress(
            officialAddress, updateTickerForErc, ercSmartContractAddress)
        .then((res) {
      if (selectedCoinWalletInfo!.tickerName == 'USDT' ||
          selectedCoinWalletInfo!.tickerName == 'USDTX') {
        ethChainBalance = res['balance1e6'];
      } else if (selectedCoinWalletInfo!.tickerName == 'FABE' ||
          selectedCoinWalletInfo!.tickerName == 'FAB') {
        ethChainBalance = res['balanceIe8'];
      } else {
        ethChainBalance = res['tokenBalanceIe18'];
      }
    });
    setBusy(false);
  }

  /*---------------------------------------------------------------
                        Set Withdraw Limit
-------------------------------------------------------------- */

  setWithdrawLimit(String ticker) async {
    setBusy(true);
    if (ercChainToken.feeWithdraw != null && selectedChain == 'ETH') {
      token = ercChainToken;
      setBusy(false);
      return;
    }
    if (mainChainToken.feeWithdraw != null &&
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
      gasAmount = data;
      if (gasAmount == 0) {
        sharedService.alertDialog(
          FlutterI18n.translate(context!, "notice"),
          FlutterI18n.translate(context!, "insufficientGasAmount"),
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

  getGas() async {
    String address = await sharedService.getExgAddressFromCoreWalletDatabase();
    await walletService.gasBalance(address).then((data) {
      gasAmount = data;
      if (gasAmount < 0.5) {
        sharedService.alertDialog(
          FlutterI18n.translate(context!, "notice"),
          FlutterI18n.translate(context!, "insufficientGasAmount"),
        );
      }
    }).catchError((onError) {
      debugPrint(onError.toString());
    });
    notifyListeners();
  }

  refreshBalance() async {
    setBusy(true);
    unconfirmedBalance = 0.0;
    String fabAddress =
        await sharedService.getFabAddressFromCoreWalletDatabase();
    await apiService
        .getSingleWalletBalance(fabAddress, selectedCoinWalletInfo!.tickerName!,
            selectedCoinWalletInfo!.address!)
        .then((walletBalance) {
      if (walletBalance.isNotEmpty) {
        selectedCoinWalletInfo!.availableBalance = walletBalance[0].balance;
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
        .getSingleWalletBalance(
            fabAddress, tt!, selectedCoinWalletInfo!.address.toString())
        .then((walletBalance) => chainBalance = walletBalance.first.balance!);
  }

  fillMaxAmount() {
    setBusy(true);
    amountTextController.text = NumberUtil.roundDouble(
            selectedCoinWalletInfo!.availableBalance!,
            decimalPlaces: decimalLimit)
        .toString();

    setBusy(false);
    updateTransFee();
  }

  updateTransFee() async {
    setBusy(true);
    var to =
        coinService.getCoinOfficalAddress(coinName!, tokenType: tokenType!);
    var amount = double.tryParse(amountTextController.text)!;

    if (to == null || amount <= 0) {
      gasFee = 0.0;
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
      "tokenType": selectedCoinWalletInfo!.tokenType,
      "getTransFeeOnly": true
    };
    var address = selectedCoinWalletInfo!.address;

    var kanbanPrice = int.tryParse(kanbanGasPriceTextController.text);
    var kanbanGasLimit = int.tryParse(kanbanGasLimitTextController.text);
    double? kanbanTransFeeDouble;
    if (kanbanGasLimit != null && kanbanPrice != null) {
      var kanbanPriceBig = BigInt.from(kanbanPrice);
      var kanbanGasLimitBig = BigInt.from(kanbanGasLimit);
      var f = NumberUtil.rawStringToDecimal(
          (kanbanPriceBig * kanbanGasLimitBig).toString());
      kanbanTransFeeDouble = f.toDouble();
    }

    await walletService
        .sendTransaction(
            selectedCoinWalletInfo!.tickerName!,
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
        gasFee = ret['transFee'];
        kanbanGasFee = kanbanTransFeeDouble!;
        setBusy(false);
      }
      if (isTrx()) {
        if (gasFee == 0.0) {
          isValidAmount = false;
        }
      }
    }).catchError((onError) {
      setBusy(false);
    });

    setBusy(false);
    notifyListeners();
  }

  Future<double> amountAfterFee({bool isMaxAmount = false}) async {
    setBusy(true);
    if (amountTextController.text == '.') {
      setBusy(false);
      return 0.0;
    }
    if (amountTextController.text.isEmpty) {
      gasFee = 0.0;
      kanbanGasFee = 0.0;
      setBusy(false);
      return 0.0;
    }
    var amount = NumberUtil.roundDouble(double.parse(amountTextController.text),
        decimalPlaces: decimalLimit);
    double finalAmount = 0.0;

    if (isTrx()) {
      if (selectedCoinWalletInfo!.tickerName == 'USDTX' ||
          selectedCoinWalletInfo!.tokenType == 'TRX') {
        gasFee = double.parse(gasPriceTextController.text);
        finalAmount = amount;
        finalAmount <= selectedCoinWalletInfo!.availableBalance!
            ? isValidAmount = true
            : isValidAmount = false;
      }

      if (selectedCoinWalletInfo!.tickerName == 'TRX') {
        gasFee = double.parse(gasPriceTextController.text);
        finalAmount = isMaxAmount ? amount - gasFee : amount + gasFee;
      }
    } else {
      await updateTransFee();
      if (tokenType!.isEmpty) {
        if (isMaxAmount) {
          finalAmount = (Decimal.parse(amount.toString()) -
                  Decimal.parse(gasFee.toString()))
              .toDouble();
        } else {
          finalAmount = (Decimal.parse(gasFee.toString()) +
                  Decimal.parse(amount.toString()))
              .toDouble();
        }
      } else {
        finalAmount = amount;
      }
    }
    finalAmount = NumberUtil.truncateDoubleWithoutRouding(finalAmount,
        precision: decimalLimit);
    finalAmount <= selectedCoinWalletInfo!.availableBalance!
        ? isValidAmount = true
        : isValidAmount = false;
    setBusy(false);
    return finalAmount;
  }

  bool isTrx() {
    return selectedCoinWalletInfo!.tickerName == 'TRX' ||
            selectedCoinWalletInfo!.tokenType == 'TRX'
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
