import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class TransferViewModel extends BaseViewModel {
  BuildContext? context;
  final amountTextController = TextEditingController(text: ("0.5"));
  final gasPriceTextController = TextEditingController(text: ("90"));
  final gasLimitTextController = TextEditingController(text: ("21000"));
  final kanbanGasPriceTextController = TextEditingController(text: ("5000000"));
  final kanbanGasLimitTextController = TextEditingController(text: ("2000000"));

  String fromText = "Wallet";
  String toText = "Exchangily";

  double gasPrice = 0.0;
  double gasLimit = 0.0;
  double transFee = 0.0;
  String feeUnit = '';

  initState() async {}
}
