import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/api_routes.dart';
import 'package:paycool/constants/constants.dart';
import 'package:paycool/environments/environment.dart';
import 'package:paycool/models/wallet/token_model.dart';
import 'package:paycool/models/wallet/wallet.dart';
import 'package:paycool/models/wallet/wallet_balance.dart';
import 'package:paycool/providers/app_state_provider.dart';
import 'package:paycool/services/api_service.dart';
import 'package:paycool/services/coin_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/utils/number_util.dart';
import 'package:paycool/utils/wallet/erc20_util.dart';
import 'package:paycool/utils/wallet/wallet_util.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';

class TransferViewModel extends BaseViewModel {
  BuildContext? context;
  late AppStateProvider appStateProvider;

  final walletUtil = WalletUtil();
  final walletService = WalletService();
  final sharedService = SharedService();
  Erc20Util erc20Util = Erc20Util();
  final apiService = ApiService();
  final coinService = CoinService();

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
  final trxGasValueTextController = TextEditingController();

  // move to wallet
  double gasFee = 0.0;
  double kanbanGasFee = 0.0;

  List<String> chainNames = ["FAB", "ETH", "BNB", "POLYGON", "TRX"];
  String? selectedChain;

  // move to exchangily
  double? unconfirmedBalance;
  TokenModel tokenModel = TokenModel();
  int decimalLimit = 6;
  double chainBalance = 0.0;
  double amount = 0.0;
  bool isValidAmount = false;

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

  //----------------- move to wallet -----------------//

  //----------------- move to exchangily -----------------//

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
      trxGasValueTextController.text = Constants.tronUsdtFee.toString();
    } else if (coinName == 'TRX') {
      trxGasValueTextController.text = Constants.tronFee.toString();
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
    amount = double.tryParse(amountTextController.text)!;

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
    amount = NumberUtil.roundDouble(double.parse(amountTextController.text),
        decimalPlaces: decimalLimit);
    double finalAmount = 0.0;

    if (isTrx()) {
      if (selectedCoinWalletInfo!.tickerName == 'USDTX' ||
          selectedCoinWalletInfo!.tokenType == 'TRX') {
        gasFee = double.parse(trxGasValueTextController.text);
        finalAmount = amount;
        finalAmount <= selectedCoinWalletInfo!.availableBalance!
            ? isValidAmount = true
            : isValidAmount = false;
      }

      if (selectedCoinWalletInfo!.tickerName == 'TRX') {
        gasFee = double.parse(trxGasValueTextController.text);
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
}
