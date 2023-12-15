import 'dart:async';

import 'package:flutter/material.dart';
import 'package:paycool/models/wallet/wallet_balance.dart';

class AppStateProvider with ChangeNotifier {
  List<WalletBalance> _conList = [];
  bool _doubleBackToExitPressedOnce = false;

//------------------------------------- Getters -------------------------------------

  List<WalletBalance> get getWalletBalances => _conList;
  bool get getDoubleBackToExitPressedOnce => _doubleBackToExitPressedOnce;

//------------------------------------- Setters -------------------------------------

/*Coin list*/
  Future<void> setWalletBalances(List<WalletBalance> param) async {
    _conList = param;
    notifyListeners();
  }

  void clearTokenList(BuildContext context) {
    _conList = <WalletBalance>[];
    notifyListeners();
  }

  void setDoubleBackToExitPressedOnce(bool param) {
    _doubleBackToExitPressedOnce = param;
    notifyListeners();
  }
}
