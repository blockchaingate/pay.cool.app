import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:stacked/stacked.dart';

import '../../../services/multisig_service.dart';

class MultisigHistoryQueueViewModel extends FutureViewModel {
  final String address;
  MultisigHistoryQueueViewModel({required this.address});

  final sharedService = locator<SharedService>();
  List history = [];
  List queue = [];

  final log = getLogger('HistoryQueueViewModel');
  final multisigService = locator<MultiSigService>();

  @override
  Future futureToRun() async =>
      await multisigService.getmultisigTransactions(address);

  @override
  void onData(data) {
    history = data;
    log.i('history $history');
  }

  onTap(int index) async {
    log.i('onTap $index');
    if (index == 0) {
      await futureToRun();
    } else {
      await getQueueTransactions();
    }
    notifyListeners();
  }

  // get queue transactions
  getQueueTransactions() async {
    setBusy(true);
    queue = await multisigService.getQueuetransaction(address);
    log.i(
        'getQueueTransactions length ${queue.length} -- data ${queue[0]['request']['amount']}');
    setBusy(false);
  }

  // approve transaction
  approveTransaction(String txid) async {
    setBusy(true);
    //  await multisigService.approveTransaction(txid);
    setBusy(false);
  }
}
