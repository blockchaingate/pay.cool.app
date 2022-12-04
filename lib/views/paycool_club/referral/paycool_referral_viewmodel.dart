import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:paycool/environments/environment_type.example.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/navigation_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/views/paycool_club/referral/referral_model.dart';
import 'package:paycool/views/paycool_club/paycool_club_service.dart';
import 'package:paycool/widgets/pagination/pagination_model.dart';

import 'package:stacked/stacked.dart';

class PaycoolReferralViewmodel extends BaseViewModel {
  final log = getLogger('PaycoolReferralViewmodel');

  NavigationService navigationService = locator<NavigationService>();

  SharedService sharedService = locator<SharedService>();

  PayCoolClubService payCoolClubService = locator<PayCoolClubService>();
  BuildContext context;
  String fabAddress = '';
  PaycoolReferral parent = PaycoolReferral();
  List<PaycoolReferral> referrals = [];

  String address = '';
  PaginationModel paginationModel = PaginationModel();

  int _totalReferrals = 0;
  get totalReferrals => _totalReferrals;
  var downlineReferralCount;
  int currentTabSelection = 0;

/*----------------------------------------------------------------------
                          INIT
----------------------------------------------------------------------*/

  init() async {
    setBusy(true);
    var fabAddress = await sharedService.getFabAddressFromCoreWalletDatabase();
    var data = currentTabSelection == 1
        ? await payCoolClubService.getReferrals(
            address != null && address.isNotEmpty ? address : fabAddress,
            isProject: true,
            projectId: isProduction ? 1 : 9,
            pageSize: paginationModel.pageSize,
            pageNumber: paginationModel.pageNumber)
        : await payCoolClubService.getReferrals(
            address != null && address.isNotEmpty ? address : fabAddress,
            pageSize: paginationModel.pageSize,
            pageNumber: paginationModel.pageNumber);

    debugPrint('in on data');

    referrals = data;
    _totalReferrals = currentTabSelection == 1
        ? await payCoolClubService.getUserReferralCount(fabAddress,
            isProject: true, projectId: isProduction ? 1 : 9)
        : await payCoolClubService.getUserReferralCount(fabAddress);
    paginationModel.totalPages =
        (_totalReferrals / paginationModel.pageSize).ceil();
    paginationModel.pages = [];
    paginationModel.pages.addAll(referrals);
    log.i('paginationModel ${paginationModel.toString()}');
    //await getDownlineCount();
    setBusy(false);
  }

  updateTabSelection(int tabIndex) async {
    setBusy(true);
    currentTabSelection = tabIndex;
    await init();
    setBusy(false);
    // notifyListeners();
  }

  getPaginationRewards(int pageNumber) async {
    setBusy(true);
    paginationModel.pageNumber = pageNumber;
    var paginationResults = await init();
    referrals = paginationResults;
    setBusy(false);
  }

  // getDownlineCount() async {
  //   for (var referral in children) {
  //     int index = children.indexWhere((element) => element.id == referral.id);
  //     await payCoolClubService
  //         .getReferrals(referral.userAddress)
  //         .then((downlineReferralList) {
  //       setBusy(true);
  //       // debugPrint(downlineReferralList);
  //       downlineReferralCount = downlineReferralList.length;
  //     });
  //     setBusy(false);
  //   }
  // }
}
