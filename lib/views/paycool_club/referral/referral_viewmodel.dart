import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:paycool/environments/environment_type.example.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/navigation_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/views/paycool_club/club_dashboard_model.dart';
import 'package:paycool/views/paycool_club/referral/referral_model.dart';
import 'package:paycool/views/paycool_club/paycool_club_service.dart';
import 'package:paycool/widgets/pagination/pagination_model.dart';

import 'package:stacked/stacked.dart';

class ReferralViewmodel extends BaseViewModel {
  final log = getLogger('ReferralViewmodel');

  NavigationService navigationService = locator<NavigationService>();

  SharedService sharedService = locator<SharedService>();

  PayCoolClubService payCoolClubService = locator<PayCoolClubService>();
  BuildContext context;
  String fabAddress = '';
  PaycoolReferral parent = PaycoolReferral();

  List<Project> projects = [];
  Map<int, List<PaycoolReferral>> idReferralsMap = {};

  PaginationModel paginationModel = PaginationModel();

  int _totalReferrals = 0;
  get totalReferrals => _totalReferrals;
  var downlineReferralCount;
  int currentTabSelection = 0;
  ReferalRoute referalRoute = ReferalRoute();

/*----------------------------------------------------------------------
                          INIT
----------------------------------------------------------------------*/

  init() async {
    setBusy(true);
    var fabAddress = await sharedService.getFabAddressFromCoreWalletDatabase();
    String addressUsed =
        referalRoute.address != null && referalRoute.address.isNotEmpty
            ? referalRoute.address
            : fabAddress;

    if (projects.isEmpty || projects == null) {
      if (referalRoute.project.id == 0 &&
          referalRoute.project.en == 'Paycool') {
        var refs = await payCoolClubService.getReferrals(addressUsed,
            pageSize: paginationModel.pageSize,
            pageNumber: paginationModel.pageNumber);
        idReferralsMap.addAll({referalRoute.project.id: refs});
      } else {
        var refs = await payCoolClubService.getReferrals(addressUsed,
            isProject: true,
            projectId: referalRoute.project.id,
            pageSize: paginationModel.pageSize,
            pageNumber: paginationModel.pageNumber);
        idReferralsMap.addAll({referalRoute.project.id: refs});
      }
    } else {
      for (var p in projects) {
        if (p.id == 0 && p.en == 'Paycool') {
          var refs = await payCoolClubService.getReferrals(addressUsed,
              pageSize: paginationModel.pageSize,
              pageNumber: paginationModel.pageNumber);
          idReferralsMap.addAll({p.id: refs});
        } else {
          var refs = await payCoolClubService.getReferrals(addressUsed,
              isProject: true,
              projectId: p.id,
              pageSize: paginationModel.pageSize,
              pageNumber: paginationModel.pageNumber);
          idReferralsMap.addAll({p.id: refs});
        }
      }
    }
    debugPrint('idReferralsMap $idReferralsMap');

    if (referalRoute.address != null ||
        (referalRoute.project != null && referalRoute.project.id == 0)) {
      _totalReferrals = referalRoute.project.id != 0
          ? await payCoolClubService.getUserReferralCount(addressUsed,
              isProject: true, projectId: referalRoute.project.id)
          : await payCoolClubService.getUserReferralCount(addressUsed);
      paginationModel.totalPages =
          (_totalReferrals / paginationModel.pageSize).ceil();
      paginationModel.pages = [];
      referalRoute.referrals = idReferralsMap[referalRoute.project.id];
      if (referalRoute.referrals != null)
        paginationModel.pages.addAll(referalRoute.referrals);
      log.i('paginationModel ${paginationModel.toString()}');
    }
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
    referalRoute.referrals = paginationResults;
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
