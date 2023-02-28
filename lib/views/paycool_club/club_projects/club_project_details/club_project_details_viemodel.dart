import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/constants.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/services/navigation_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/utils/number_util.dart';
import 'package:paycool/views/paycool_club/club_dashboard_model.dart';
import 'package:paycool/views/paycool_club/club_projects/models/club_project_model.dart';
import 'package:paycool/views/paycool_club/paycool_club_service.dart';
import 'package:stacked/stacked.dart';

class ClubProjectDetailsViewModel extends BaseViewModel {
  final storageService = locator<LocalStorageService>();
  final navigationService = locator<NavigationService>();
  final clubService = locator<PayCoolClubService>();
  final sharedService = locator<SharedService>();
  BuildContext? context;
  int referralCount = 0;
  String fabAddress = '';

  final log = getLogger('ClubProjectDetailsViewModel');

  List<ClubProject> genericClubProjects = [];
  int purchasedPackagesCount = 0;

  init() async {
    try {
      fabAddress = await sharedService.getFabAddressFromCoreWalletDatabase();
    } catch (err) {
      log.e('catch fab address fetching from database');
    }
    purchasedPackagesCount =
        await clubService.getPurchasedPackageCount(fabAddress);
    log.e("purchasedPackagesCount $purchasedPackagesCount");
    await getProjects();
  }

  goToRewardsView(Summary summary) async {
    Map<String, Decimal> rewardTokenPriceMap = {};
    var totatRewardDollarVal = Constants.decimalZero;
    for (var reward in summary.totalReward!) {
      if (reward.coin != null) {
        var rtp = Constants.decimalZero;
        try {
          // reward token price
          rtp = await clubService.getPriceOfRewardToken(reward.coin!);
        } catch (err) {
          log.e('CATCH getPriceOfRewardToken getting price for ${reward.coin}');
        }

        var res = reward.amount! * rtp;
        log.w('res $res');
        totatRewardDollarVal +=
            NumberUtil.decimalLimiter(res, decimalPrecision: 8);
        log.e('totatRewardDollarVal $totatRewardDollarVal');
        rewardTokenPriceMap.addAll({reward.coin!: rtp});
      }
    }
    List<Summary> s = [];
    s.add(summary);
    navigationService.navigateTo(clubRewardsViewRoute,
        arguments: ClubRewardsArgs(
            summary: s,
            rewardTokenPriceMap: rewardTokenPriceMap,
            totalRewardsDollarValue: totatRewardDollarVal));
  }

  ClubProject? selectedProject(String summaryProjectId) {
    ClubProject clubProject = ClubProject();
    for (var p in genericClubProjects) {
      if (p.id == summaryProjectId) {
        clubProject = p;
      }
    }
    return clubProject;
  }

  String assignMemberType({int? status}) {
    var condition = status;
    if (condition == 0) {
      return FlutterI18n.translate(context!, "noPartner");
    } else if (condition == 1) {
      return FlutterI18n.translate(context!, "basicPartner");
    } else if (condition == 2) {
      return FlutterI18n.translate(context!, "juniorPartner");
    } else if (condition == 3) {
      return FlutterI18n.translate(context!, "seniorPartner");
    } else if (condition == 4) {
      return FlutterI18n.translate(context!, "executivePartner");
    } else {
      return FlutterI18n.translate(context!, "noPartner");
    }
  }

  // rewards

  //referrals

  // referral count
  getReferralCount() async {
    setBusy(true);
    await clubService
        .getUserReferralCount(
      fabAddress,
    )
        .then((refCount) {
      referralCount = refCount;
      log.w('getReferralCount $referralCount');
    }).timeout(const Duration(seconds: 5), onTimeout: () async {
      log.e('time out');

      setBusy(false);
      return;
    });
    // setBusy(false);
  }

  // stacked packages

  goToProjectPackages(Project project) async {
    var id = selectedProject(project.id.toString())!.projectId!;
    var projectDetails = await clubService.getProjectDetails(id, fabAddress);
    navigationService.navigateTo(clubPackageDetailsViewRoute,
        arguments: projectDetails);
  }

  // get all generic project list
  getProjects() async {
    setBusy(true);
    try {
      await clubService.getClubProjects().then((data) {
        if (data != null && data.isNotEmpty) genericClubProjects = data;
      });
    } catch (err) {
      log.e('getProjects CATCH $err');

      return;
    }
    setBusy(false);
  }
}
