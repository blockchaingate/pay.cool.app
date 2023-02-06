import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/services/navigation_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/views/paycool_club/purchased_package_history/purchased_package_history_model.dart';

import 'package:paycool/views/paycool_club/paycool_club_service.dart';
import 'package:paycool/widgets/pagination/pagination_model.dart';

import 'package:stacked/stacked.dart';

class PurchasedPackageViewmodel extends FutureViewModel {
  final log = getLogger('PurchasedPackageViewmodel');

  NavigationService navigationService = locator<NavigationService>();

  SharedService sharedService = locator<SharedService>();

  PayCoolClubService payCoolClubService = locator<PayCoolClubService>();
  BuildContext? context;
  String fabAddress = '';

  List<PurchasedPackageHistory> purchasedPackages = [];

  String address = '';
  PaginationModel paginationModel = PaginationModel();

  int _totalPackages = 0;
  get totalPackages => _totalPackages;
  final storageService = locator<LocalStorageService>();

/*----------------------------------------------------------------------
                    Future to Run
----------------------------------------------------------------------*/
  @override
  Future futureToRun() async {
    fabAddress = await sharedService.getFabAddressFromCoreWalletDatabase();
    return await payCoolClubService.getPurchasedPackageHistory(fabAddress,
        pageSize: paginationModel.pageSize,
        pageNumber: paginationModel.pageNumber);
  }

/*----------------------------------------------------------------------
                  After Future Data is ready
----------------------------------------------------------------------*/
  @override
  void onData(data) async {
    setBusy(true);
    purchasedPackages = data;
    _totalPackages =
        await payCoolClubService.getPurchasedPackageCount(fabAddress);
    paginationModel.totalPages =
        (_totalPackages / paginationModel.pageSize).ceil();
    paginationModel.pages = [];
    paginationModel.pages.addAll(purchasedPackages);
    log.i('paginationModel ${paginationModel.toString()}');

    setBusy(false);
  }

/*----------------------------------------------------------------------
                          INIT
----------------------------------------------------------------------*/

  init() {}

  getPaginationRewards(int pageNumber) async {
    setBusy(true);
    paginationModel.pageNumber = pageNumber;
    var paginationResults = await futureToRun();
    purchasedPackages = paginationResults;
    setBusy(false);
  }
}
