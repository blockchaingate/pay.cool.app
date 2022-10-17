import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/navigation_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/views/paycool_club/referral/referral_model.dart';
import 'package:paycool/views/paycool_club/paycool_club_service.dart';
import 'package:paycool/widgets/pagination/pagination_model.dart';

import 'package:stacked/stacked.dart';

class PaycoolReferralViewmodel extends FutureViewModel {
  final log = getLogger('PaycoolReferralViewmodel');

  NavigationService navigationService = locator<NavigationService>();

  SharedService sharedService = locator<SharedService>();

  PayCoolClubService payCoolClubService = locator<PayCoolClubService>();
  BuildContext context;
  String fabAddress = '';
  PaycoolReferral parent = PaycoolReferral();
  List<PaycoolReferral> children = [];

  String address = '';
  PaginationModel paginationModel = PaginationModel();

  int _totalReferrals = 0;
  get totalReferrals => _totalReferrals;
  var downlineReferralCount;

/*----------------------------------------------------------------------
                    Default Future to Run
----------------------------------------------------------------------*/
  @override
  Future futureToRun() async {
    fabAddress = await sharedService.getFabAddressFromCoreWalletDatabase();
    return await payCoolClubService.getDownlineByAddress(
        address != null && address.isNotEmpty ? address : fabAddress,
        pageSize: paginationModel.pageSize,
        pageNumber: paginationModel.pageNumber);
  }

/*----------------------------------------------------------------------
                  After Future Data is ready
----------------------------------------------------------------------*/
  @override
  void onData(data) async {
    setBusy(true);
    children = data;
    _totalReferrals = await payCoolClubService.getUserReferralCount(fabAddress);
    paginationModel.totalPages =
        (_totalReferrals / paginationModel.pageSize).ceil();
    paginationModel.pages = [];
    paginationModel.pages.addAll(children);
    log.i('paginationModel ${paginationModel.toString()}');
    await getDownlineCount();
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
    children = paginationResults;
    setBusy(false);
  }

  getDownlineCount() async {
    for (var referral in children) {
      int index = children.indexWhere((element) => element.id == referral.id);
      await payCoolClubService
          .getChildrenByAddress(referral.id)
          .then((downlineReferralList) {
        setBusy(true);
        // debugPrint(downlineReferralList);
        downlineReferralCount = downlineReferralList.length;
      });
      setBusy(false);
    }
  }
}
