import 'package:flutter/material.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/hive_multisig_service.dart';
import 'package:paycool/services/multisig_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/views/multisig/multisig_wallet_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class ImportMultisigViewmodel extends FutureViewModel {
  final log = getLogger('ImportMultisigViewmodel');

  final importWalletController = TextEditingController();
  final navigationService = locator<NavigationService>();
  final hiveService = locator<HiveMultisigService>();
  final sharedService = locator<SharedService>();
  final multiSigService = locator<MultiSigService>();
  bool isAddressEmpty = true;
  List<MultisigWalletModel> multisigWallets = [];
  List<MultisigWalletModel> pendinMultisigWallets = [];

  @override
  Future futureToRun() async => await hiveService.getAllMultisigWallets();

  @override
  Future<void> onData(data) async {
    multisigWallets = data;
    log.w('onData ${multisigWallets.length}');
    // call importwalletbytxid to check the address and status
    await checkAddress();
    // remove entries where address is empty
    multisigWallets.removeWhere(
        (element) => element.address == null || element.address!.isEmpty);
    log.i(
        'init MultisigDashboardViewModel multisigWallets ${multisigWallets.length}');
  }

  Future checkAddress() async {
    for (MultisigWalletModel msw in multisigWallets) {
      if (msw.address == null || msw.address!.isEmpty) {
        setBusy(true);
        var res =
            await multiSigService.importMultisigWallet(msw.txid!, isTxid: true);
        if (res.address != null && res.address!.isNotEmpty) {
          msw.address = res.address;
          msw.status = res.status;
          msw.creator = res.creator;
          notifyListeners();
          await hiveService.updateMultisigWallet(msw);
        } else {
          log.e('address is null for txid ${msw.txid}');
          pendinMultisigWallets.addAll([msw]);
          // hiveService.deleteMultisigWallet(msw.key!);
          log.e(
              'Adding to pendinMultisigWalletst ${msw.txid}-- due to null address which means its not mined properly and with null status as well');
        }
        setBusy(false);
      }
    }
  }

  isImportAddressEmpty() {
    if (importWalletController.text.isEmpty) {
      isAddressEmpty = true;
    } else {
      isAddressEmpty = false;
    }
    rebuildUi();

    return isAddressEmpty;
  }
}
