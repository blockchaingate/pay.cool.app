import 'dart:async';

import 'package:flutter/material.dart';
import 'package:paycool/models/wallet/wallet_balance.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/api_service.dart';
import 'package:paycool/services/coin_service.dart';
import 'package:paycool/services/db/core_wallet_database_service.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:stacked_services/stacked_services.dart';

class AppStateProvider with ChangeNotifier {
  List<WalletBalance> _conList = [];
  var coinsToHideList = [""];
  Future<void>? isWorkingTokenList;

  final coreWalletDatabaseService = locator<CoreWalletDatabaseService>();
  final storageService = locator<LocalStorageService>();
  final navigationService = locator<NavigationService>();
  final apiService = locator<ApiService>();
  final coinService = locator<CoinService>();

//------------------------------------- Getters -------------------------------------

  List<WalletBalance> get getWalletBalances => _conList;

//------------------------------------- Setters -------------------------------------

/*Coin list*/

  Future<void> setWalletBalances(List<WalletBalance> param) async {
    _conList = param;
    print("--------------------");
    print(param.length);
    notifyListeners();
  }

  void clearTokenList(BuildContext context) {
    _conList = <WalletBalance>[];
    notifyListeners();
  }
}
