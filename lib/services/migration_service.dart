import 'package:paycool/logger.dart';
import 'dart:convert';

import 'package:paycool/service_locator.dart';
import 'package:paycool/services/local_storage/hive_mutli_wallet_service.dart';
import 'package:paycool/views/wallet/wallet_setup/multi_wallet_model.dart';

import 'db/core_wallet_database_service.dart';

class MigrationService {
  final log = getLogger('MigrationService');
  final coreWalletDatabaseService = locator<CoreWalletDatabaseService>();
  final hiveMultiWalletService = locator<HiveMultiWalletService>();

  Future<int> convertToHiveDatabase() async {
    MultiWalletModel multiWalletModel = MultiWalletModel();
    multiWalletModel.name = 'Wallet';

    var encryptedMnemonicFromDb =
        await coreWalletDatabaseService.getEncryptedMnemonic();

    var walletBalancesBodyFromDb =
        await coreWalletDatabaseService.getWalletBalancesBody();

    var jsonBody = walletBalancesBodyFromDb!['walletBalancesBody'];

    if (encryptedMnemonicFromDb.isNotEmpty) {
      multiWalletModel.encryptedMnemonic = encryptedMnemonicFromDb;
    }

    Map<String, dynamic> walletBalancesBody = jsonDecode(jsonBody);
    walletBalancesBody.forEach((key, value) {
      String chain = key.split('Address')[0].toUpperCase();
      String address = value;
      multiWalletModel
          .addAddress(WalletAddressModel(tickerName: chain, address: address));
    });

    var res = await hiveMultiWalletService.addWallet(multiWalletModel);
    if (res == -1) {
      log.w('duplicate wallet ${multiWalletModel.name}');
    } else if (res == -2) {
      log.e('Failed to add wallet');
    } else {
      log.i('wallet added successfully');
    }
    return res;
  }
}
