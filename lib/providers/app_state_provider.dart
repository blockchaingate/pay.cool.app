import 'dart:async';

import 'package:flutter/material.dart';
import 'package:paycool/models/wallet/provider_address_model.dart';
import 'package:paycool/models/wallet/wallet_balance.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/db/core_wallet_database_service.dart';

class AppStateProvider with ChangeNotifier {
  final coreWalletDatabaseService = locator<CoreWalletDatabaseService>();
  List<WalletBalance> _conList = [];
  bool _doubleBackToExitPressedOnce = false;
  List<ProviderAddressModel> providerAddressList = [];
  final List<String> chainList = [
    "BTC",
    "ETH",
    "FAB",
    "LTC",
    "DOGE",
    "BCH",
    "TRX"
  ];

//------------------------------------- Getters -------------------------------------

  List<WalletBalance> get getWalletBalances => _conList;
  List<ProviderAddressModel> get getProviderAddressList => providerAddressList;
  bool get getDoubleBackToExitPressedOnce => _doubleBackToExitPressedOnce;

//------------------------------------- Setters -------------------------------------

/*Coin list*/

  Future<void> setProviderAddress(String name) async {
    String address =
        await coreWalletDatabaseService.getWalletAddressByTickerName(name);

    ProviderAddressModel param =
        ProviderAddressModel(name: name, address: address);

    // Check if an object with the same properties already exists in the list
    bool alreadyExists = providerAddressList.any((existingParam) =>
        existingParam.name == param.name &&
        existingParam.address == param.address);

    if (address.isNotEmpty && !alreadyExists) {
      providerAddressList.add(param);
      notifyListeners();
    }
  }

  Future<void> setWalletBalances(List<WalletBalance> param) async {
    _conList = param;
    notifyListeners();
  }

  void clearProviderAddress(BuildContext context) {
    providerAddressList = [];
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
