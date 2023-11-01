import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pagination_widget/pagination_widget.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/views/paycool_club/club_dashboard_model.dart';
import 'package:paycool/views/paycool_club/referral/referral_model.dart';
import 'package:paycool/views/paycool_club/paycool_club_service.dart';

import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class ReferralViewmodel extends BaseViewModel {
  final log = getLogger('ReferralViewmodel');

  NavigationService navigationService = locator<NavigationService>();

  SharedService sharedService = locator<SharedService>();

  PayCoolClubService payCoolClubService = locator<PayCoolClubService>();
  late BuildContext context;
  String fabAddress = '';
  PaycoolReferral parent = PaycoolReferral();

  List<Project> projects = [];
  Map<int, List<PaycoolReferral>> idReferralsMap = {};
  Map<int, int> idReferralCountMap = {};

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
        referalRoute.address != null && referalRoute.address!.isNotEmpty
            ? referalRoute.address!
            : fabAddress;

    if (projects.isEmpty) {
      if (referalRoute.project!.id == 0 &&
          referalRoute.project!.en == 'Paycool') {
        var refs = await payCoolClubService.getReferrals(addressUsed,
            pageSize: paginationModel.pageSize,
            pageNumber: paginationModel.pageNumber);
        idReferralsMap.addAll({referalRoute.project!.id!: refs});
      } else {
        var refs = await payCoolClubService.getReferrals(addressUsed,
            isProject: true,
            projectId: referalRoute.project!.id!,
            pageSize: paginationModel.pageSize,
            pageNumber: paginationModel.pageNumber);
        idReferralsMap.addAll({referalRoute.project!.id!: refs});
      }
    } else {
      for (var p in projects) {
        if (p.id == 0 && p.en == 'Paycool') {
          var refs = await payCoolClubService.getReferrals(addressUsed,
              pageSize: paginationModel.pageSize,
              pageNumber: paginationModel.pageNumber);
          idReferralsMap.addAll({p.id!: refs});
          var refCount =
              await payCoolClubService.getUserReferralCount(addressUsed);
          idReferralCountMap.addAll({p.id!: refCount});
        } else {
          var refs = await payCoolClubService.getReferrals(addressUsed,
              isProject: true,
              projectId: p.id!,
              pageSize: paginationModel.pageSize,
              pageNumber: paginationModel.pageNumber);
          idReferralsMap.addAll({p.id!: refs});
          var refCount = await payCoolClubService.getUserReferralCount(
              addressUsed,
              isProject: true,
              projectId: p.id!);
          idReferralCountMap.addAll({p.id!: refCount});
        }
      }
    }
    debugPrint('idReferralsMap $idReferralsMap');

    if (referalRoute.address != null || (referalRoute.project != null)) {
      _totalReferrals = referalRoute.project!.id != 0
          ? await payCoolClubService.getUserReferralCount(addressUsed,
              isProject: true, projectId: referalRoute.project!.id!)
          : await payCoolClubService.getUserReferralCount(addressUsed);
      paginationModel.totalPages =
          (_totalReferrals / paginationModel.pageSize).ceil();
      paginationModel.pages = [];
      referalRoute.referrals = idReferralsMap[referalRoute.project!.id];
      if (referalRoute.referrals != null) {
        paginationModel.pages.addAll(referalRoute.referrals!);
      }
      notifyListeners();
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
    await init();
    // referalRoute.referrals = paginationResults;
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
