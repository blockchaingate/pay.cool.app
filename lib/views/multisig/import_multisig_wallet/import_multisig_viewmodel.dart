import 'package:flutter/material.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/hive_service.dart';
import 'package:paycool/services/multisig_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/views/multisig/multisig_wallet_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class ImportMultisigViewmodel extends FutureViewModel {
  final log = getLogger('ImportMultisigViewmodel');

  final importWalletController = TextEditingController();
  final navigationService = locator<NavigationService>();
  final hiveService = locator<HiveService>();
  final sharedService = locator<SharedService>();
  final multiSigService = locator<MultiSigService>();
  bool isAddressEmpty = true;
  List<MultisigWalletModel> multisigWallets = [];

  @override
  Future futureToRun() async => await hiveService.getAllMultisigWallets();

  @override
  void onData(data) {
    multisigWallets = data;
  }

  isImportAddressEmpty() {
    if (importWalletController.text.isEmpty) {
      isAddressEmpty = true;
    } else {
      isAddressEmpty = false;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    return isAddressEmpty;
  }
}
