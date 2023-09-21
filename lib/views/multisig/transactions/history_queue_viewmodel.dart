import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:stacked/stacked.dart';

import '../../../services/multisig_service.dart';

class HistoryQueueViewModel extends FutureViewModel {
  final String address;

  HistoryQueueViewModel({required this.address});

  final log = getLogger('HistoryQueueViewModel');
  final multisigService = locator<MultiSigService>();

  @override
  Future futureToRun() async =>
      await multisigService.getmultisigTransactions(address);

  @override
  void onData(data) {}

  // get queue transactions
  getQueueTransactions() async {
    setBusy(true);
    var data = await multisigService.getQueuetransaction(address);
    // log.i('getQueueTransactions data $data');
    setBusy(false);
  }
}
