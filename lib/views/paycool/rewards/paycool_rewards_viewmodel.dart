import 'package:flutter/material.dart';
import 'package:pagination_widget/pagination_widget.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/views/paycool/paycool_service.dart';
import 'package:paycool/views/paycool/rewards/payment_rewards_model.dart';
import 'package:stacked/stacked.dart';

class PayCoolRewardsViewModel extends FutureViewModel
    implements ReactiveViewModel {
  final log = getLogger('PayCoolRewardsViewModel');
  final payCoolService = locator<PayCoolService>();
  final sharedService = locator<SharedService>();
  String fabAddress = '';
  BuildContext? context;
  List<PaymentReward> paymentRewards = [];

  PaginationModel paginationModel = PaginationModel();
  int pageNumber = 1;
  int pageSize = 10;
  final int _totalRewardListCount = 0;

  @override
  List<ListenableServiceMixin> get listenableServices => [payCoolService];
  @override
  Future futureToRun() async {
    fabAddress = await sharedService.getFabAddressFromCoreWalletDatabase();
    return await payCoolService.getPaymentRewards(fabAddress,
        pageSize: paginationModel.pageSize,
        pageNumber: paginationModel.pageNumber);
  }

  @override
  void onData(data) async {
    setBusy(true);
    paymentRewards = data;
    await paginationModel
        .getTotalPages(() => payCoolService.getPaymentRewardCount(fabAddress));

    log.i('paginationModel ${paginationModel.toString()}');
    setBusy(false);
  }

  getPaginationData(int pageNumber) async {
    setBusy(true);
    paginationModel.pageNumber = pageNumber;
    var res = await futureToRun();
    paymentRewards = res;

    setBusy(false);
  }
}
