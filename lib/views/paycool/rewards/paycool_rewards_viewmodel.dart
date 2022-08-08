import 'package:flutter/material.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/views/paycool/rewards/paycool_rewards_model.dart';
import 'package:paycool/views/paycool/paycool_service.dart';
import 'package:paycool/widgets/pagination/pagination_model.dart';
import 'package:stacked/stacked.dart';

class PayCoolRewardsViewModel extends FutureViewModel
    implements ReactiveViewModel {
  final log = getLogger('PayCoolRewardsViewModel');
  final payCoolService = locator<PayCoolService>();
  final sharedService = locator<SharedService>();
  String fabAddress = '';
  BuildContext context;
  List<PayCoolRewardsModel> rewards = [];
  List<String> rewardCoins = ['FAB', 'EXG', 'BST'];
  bool isShowAllTxIds = false;
  String selectedTxId = '';
  PaginationModel paginationModel = PaginationModel();
  int pageNumber = 1;
  int pageSize = 10;
  int _totalRewardListCount = 0;

  @override
  List<ReactiveServiceMixin> get reactiveServices => [payCoolService];
  @override
  Future futureToRun() async {
    fabAddress = await sharedService.getFabAddressFromCoreWalletDatabase();
    return await payCoolService.getPayCoolRewards(fabAddress,
        pageSize: paginationModel.pageSize,
        pageNumber: paginationModel.pageNumber);
  }

  @override
  void onData(data) async {
    setBusy(true);
    rewards = data;

    _totalRewardListCount = await payCoolService.getRewardListCount(fabAddress);
    paginationModel.totalPages =
        (_totalRewardListCount / paginationModel.pageSize).ceil();
    paginationModel.pages = [];
    paginationModel.pages.addAll(rewards);
    log.i('paginationModel ${paginationModel.toString()}');
    setBusy(false);
  }

  init() {}
  // update() {
  //   getPaginationRewards();
  //   return sharedService.loadingIndicator();
  // }

  getPaginationRewards(int pageNumber) async {
    setBusy(true);
    paginationModel.pageNumber = pageNumber;
    var paginationResults = await futureToRun();
    rewards = paginationResults;

    setBusy(false);
  }

  showAllTxIds(String firstTxId) {
    setBusyForObject(isShowAllTxIds, true);
    if (selectedTxId == firstTxId) {
      isShowAllTxIds = !isShowAllTxIds;
      setBusyForObject(isShowAllTxIds, false);
      return;
    }

    selectedTxId = '';
    selectedTxId = firstTxId;

    isShowAllTxIds = true;
    setBusyForObject(isShowAllTxIds, false);
  }
}
