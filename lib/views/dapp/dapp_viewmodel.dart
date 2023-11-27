import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class DappViewmodel extends BaseViewModel {
  BuildContext? context;

  final sharedService = locator<SharedService>();
  final searchController = TextEditingController();
  final navigationService = locator<NavigationService>();

  List<String> dappNames = [
    "Biswap",
    "Exchangily",
    "PancakeSwap",
    "Uniswap",
    "SushiSwap",
    "1inch",
  ];
/*----------------------------------------------------------------------
                          INIT
----------------------------------------------------------------------*/

  init() {}

  onBackButtonPressed() async {
    await sharedService.onBackButtonPressed('/dashboard');
  }
}
