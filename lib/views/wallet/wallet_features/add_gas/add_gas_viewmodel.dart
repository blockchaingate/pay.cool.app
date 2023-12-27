import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/environments/environment.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/api_service.dart';
import 'package:paycool/services/db/wallet_database_service.dart';
import 'package:paycool/services/local_dialog_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/utils/kanban.util.dart';
import 'package:paycool/utils/number_util.dart';
import 'package:paycool/utils/string_util.dart';
import 'package:stacked/stacked.dart';

class AddGasViewModel extends FutureViewModel {
  late BuildContext context;
  final log = getLogger('AddGasVM');
  final walletService = locator<WalletService>();
  final walletDataBaseService = locator<WalletDatabaseService>();
  final sharedService = locator<SharedService>();
  final apiService = locator<ApiService>();

  final LocalDialogService _dialogService = locator<LocalDialogService>();

  final amountController = TextEditingController();
  final gasPriceTextController = TextEditingController();
  final gasLimitTextController = TextEditingController();
  double gasBalance = 0.0;
  double transFee = 0.0;
  bool isAdvance = false;
  double sliderValue = 0.0;
  bool isAmountInvalid = false;
  double totalAmount = 0.0;
  double sumUtxos = 0.0;
  String fabAddress = '';
  String? scarContractAddress;
  var contractInfo;
  var utxos = [];
  var extraAmount;
  int satoshisPerBytes = 14;
  int? bytesPerInput;
  int? feePerInput;
  double fabBalance = 0.0;

  @override
  Future futureToRun() async {
    String exgAddress =
        await sharedService.getExgAddressFromCoreWalletDatabase();
    return walletService.gasBalance(exgAddress);
  }

  init() async {
    setBusy(true);
    gasLimitTextController.text =
        environment["chains"]["FAB"]["gasLimit"].toString();
    gasPriceTextController.text = '40';
    bytesPerInput = environment["chains"]["FAB"]["bytesPerInput"];
    feePerInput = bytesPerInput! * satoshisPerBytes;
    fabAddress = await sharedService.getFabAddressFromCoreWalletDatabase();
    getSliderReady();

    await getFabBalance();
    setBusy(false);
  }

  // this is for slider in new design we dont have slider so we dont need this
  getSliderReady() async {
    utxos = await apiService.getFabUtxos(fabAddress);

    scarContractAddress = await getScarAddress();
    scarContractAddress = trimHexPrefix(scarContractAddress!);
    var gasPrice = int.tryParse(gasPriceTextController.text);
    var gasLimit = int.tryParse(gasLimitTextController.text);
    var options = {
      "gasPrice": gasPrice,
      "gasLimit": gasLimit,
    };
    var fxnDepositCallHex = '4a58db19';
    contractInfo = await walletService.getFabSmartContract(scarContractAddress!,
        fxnDepositCallHex, options['gasLimit'], options['gasPrice']);
    extraAmount = Decimal.parse(contractInfo['totalFee'].toString());

    for (var utxo in utxos) {
      var utxoValue = utxo['value'];
      debugPrint(utxoValue.toString());
      var t = Decimal.fromInt(utxoValue) / Decimal.parse('1e8');
      sumUtxos = sumUtxos + t.toDouble();
    }
  }

  @override
  void onData(data) {
    log.w(data);
    setBusy(true);

    gasBalance = data;
    setBusy(false);
  }

  getFabBalance() async {
    setBusy(true);
    await apiService
        .getSingleWalletBalance(fabAddress, 'FAB', fabAddress)
        .then((walletBalance) {
      fabBalance =
          NumberUtil.roundDouble(walletBalance[0].balance!, decimalPlaces: 6);
    });
    setBusy(false);
  }

  checkPass(Decimal amount, context) async {
    setBusy(true);
    if (isAmountInvalid) {
      sharedService.showInfoFlushbar(
          FlutterI18n.translate(context, "notice"),
          "FAB ${FlutterI18n.translate(context, "insufficientBalance")}",
          Icons.cancel,
          red,
          context);
      return;
    }
    var gasPrice = int.tryParse(gasPriceTextController.text);
    var gasLimit = int.tryParse(gasLimitTextController.text);
    var res = await _dialogService.showDialog(
        title: FlutterI18n.translate(context, "enterPassword"),
        description:
            FlutterI18n.translate(context, "dialogManagerTypeSamePasswordNote"),
        buttonTitle: FlutterI18n.translate(context, "confirm"));
    if (res.confirmed) {
      String mnemonic = res.returnedText;
      var options = {
        "gasPrice": gasPrice ?? 50,
        "gasLimit": gasLimit ?? 800000
      };
      Uint8List seed = walletService.generateSeed(mnemonic);
      var ret = await walletService.addGasDo(seed, amount, options: options);
      log.w('res $ret');
      //{'txHex': txHex, 'txHash': txHash, 'errMsg': errMsg}
      String formattedErrorMsg = '';
      if (ret["errMsg"] != '' && ret["errMsg"] != null) {
        String errorMsg = ret["errMsg"];

        formattedErrorMsg = firstCharToUppercase(errorMsg);
      }
      amountController.text = '';
      sharedService.alertDialog(
          context!,
          (ret["errMsg"] == '')
              ? FlutterI18n.translate(context, "addGasTransactionSuccess")
              : FlutterI18n.translate(context, "addGasTransactionFailed"),
          (ret["errMsg"] == '') ? ret['txHash'] : formattedErrorMsg,
          isWarning: false,
          isCopyTxId: ret["errMsg"] == '' ? true : false,
          path: (ret["errMsg"] == '') ? DashboardViewRoute : '');
    } else {
      if (res.returnedText != 'Closed') {
        wrongPasswordNotification(context);
      }
    }
    setBusy(false);
  }

/*----------------------------------------------------------------------
                    Update Transaction Fee
----------------------------------------------------------------------*/
  updateTransFee() {
    setBusy(true);
    var amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      transFee = 0.0;
      setBusy(false);
      return;
    }

    debugPrint(contractInfo.toString());

    int utxosNeeded = 0;

// Calculated trans fee

    // Get Utxos

    int totalUtxos = utxos.length;
    totalAmount = amount;
    //+ extraAmount;
    utxosNeeded = calculateUtxosNeeded(totalAmount, utxos);
    var fee = (utxosNeeded) * feePerInput! + (2 * 34 + 10) * satoshisPerBytes;
    transFee = ((Decimal.parse(extraAmount.toString()) +
            (Decimal.parse(fee.toString()) / Decimal.parse('1e8')).toDecimal())
        .toDouble());

    totalAmount = totalAmount + transFee;
    utxosNeeded = calculateUtxosNeeded(totalAmount, utxos);
    bool isRequiredUtxoValueIsMore = totalUtxos < utxosNeeded;
    if (isRequiredUtxoValueIsMore || utxosNeeded == 0) {
      isAmountInvalid = true;
    } else {
      isAmountInvalid = false;
    }
    setBusy(false);
  }

// calculate how many utxos needed
  int calculateUtxosNeeded(double totalAmount, List utxos) {
    int utxosNeeded = 0;
    sumUtxos = 0.0;
    int i = 1;

    for (var utxo in utxos) {
      var utxoValue = utxo['value'];
      debugPrint(utxoValue.toString());
      var t = Decimal.fromInt(utxoValue) / Decimal.parse('1e8');
      sumUtxos = sumUtxos + t.toDouble();
      if (totalAmount <= sumUtxos) {
        utxosNeeded = i;
      }
      i++;
    }
    log.e('totalAmount $totalAmount -- sumUtxos $sumUtxos');
    log.i('utxosNeeded $utxosNeeded');

    return utxosNeeded;
  }

/*----------------------------------------------------------------------
                   Slider On change
----------------------------------------------------------------------*/
  // sliderOnchange(newValue) {
  //   setBusy(true);
  //   sliderValue = newValue;
  //   if (transFee == 0.0) updateTransFee();

  //   var changeAmountWithSlider = (fabBalance - transFee) * sliderValue / 100;
  //   amountController.text =
  //       NumberUtil.roundDouble(changeAmountWithSlider, decimalPlaces: 6)
  //           .toString();
  //   setBusy(false);
  // }

  wrongPasswordNotification(context) {
    sharedService.showInfoFlushbar(
        FlutterI18n.translate(context, "passwordMismatch"),
        FlutterI18n.translate(context, "pleaseProvideTheCorrectPassword"),
        Icons.cancel,
        red,
        context);
  }
}
