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
  String exgAddress = '';
  @override
  Future futureToRun() async =>
      await multisigService.getmultisigTransactions(address);

  @override
  void onData(data) async {
    history = data;
    log.i('history $history');
    exgAddress = await sharedService.getExgAddressFromCoreWalletDatabase();
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

  // show confirmed by me if current wallet is one of the owners and also the signer
  bool hasConfirmedByMe(currentQueue) {
    var multisigData = currentQueue['multisig'];
    var signaturesData = currentQueue['signatures'];
    for (var walletOwner in multisigData['owners']) {
      if (walletOwner['owner'] == exgAddress) {
        for (var signature in signaturesData) {
          if (signature['signer'] == exgAddress) {
            return true;
          }
        }
      }
    }

    return false;
  }

  // show approve button if current wallet is one of the owners  and not the signer
  bool isShowApproveButton(currentQueue) {
    var multisigData = currentQueue['multisig'];
    var signaturesData = currentQueue['signatures'];
    for (var walletOwner in multisigData['owners']) {
      if (walletOwner['owner'] == exgAddress) {
        for (var signature in signaturesData) {
          if (signature['signer'] != exgAddress) {
            return true;
          }
        }
      }
    }
    return false;
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
