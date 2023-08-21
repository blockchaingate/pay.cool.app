import 'package:flutter/material.dart';
import 'package:paycool/models/bond/vm/bond_history_model.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/api_service.dart';
import 'package:stacked/stacked.dart';

class BondHistoryViewModel extends BaseViewModel with WidgetsBindingObserver {
  BondHistoryViewModel({BuildContext? context});
  ApiService apiService = locator<ApiService>();

  BuildContext? context;

  List<BondHistoryModel> bondHistoryVm = [];
  List<Card> txHistoryListWidgets = [];

  int page = 0;

  init() async {
    getRequest();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> getRequest({bool isForward = true}) async {
    await apiService.getBondHistory(context!, page).then((value) {
      if (value == null || value.isEmpty) {
        if (isForward) {
          page--;
        } else {
          page++;
        }
      } else {
        bondHistoryVm = value;
        notifyListeners();
        // bondHistoryVm.addAll(value);
      }
    });
  }
}
