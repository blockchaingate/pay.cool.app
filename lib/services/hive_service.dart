import 'package:hive_flutter/hive_flutter.dart';
import 'package:paycool/constants/constants.dart';
import 'package:paycool/logger.dart';

import '../views/multisig/multisig_wallet_model.dart';

class HiveService {
  final log = getLogger('HiveService');
  final multisigWallets =
      Hive.box<MultisigWalletModel>(Constants.multisigWalletBox);

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter<MultisigWalletModel>(MultisigWalletModelAdapter());
    Hive.registerAdapter(OwnersAdapter());
    await Hive.openBox<MultisigWalletModel>(Constants.multisigWalletBox);
  }

  // Function find multisig wallet by txid
  MultisigWalletModel findMultisigWalletByTxid(String txid) =>
      multisigWallets.values.firstWhere((element) => element.txid == txid);
  MultisigWalletModel findMultisigWalletByAddress(String address) =>
      multisigWallets.values
          .firstWhere((element) => element.address == address);
  // msw = MultisigWallet
  Future<void> addMultisigWallet(MultisigWalletModel msw) async {
    final box = Hive.box<MultisigWalletModel>(Constants.multisigWalletBox);
    if (isUniqueEntry(msw)) {
      await box.add(msw);
    } else {
      log.w('duplicate wallet ${msw.name}-- ${msw.address}');
    }
  }

  Future<void> updateMultisigWallet(MultisigWalletModel msw) async {
    final box = Hive.box<MultisigWalletModel>(Constants.multisigWalletBox);
    await box.putAt(msw.key, msw);
  }

  Future<void> deleteMultisigWallet(int index) async {
    final box = Hive.box<MultisigWalletModel>(Constants.multisigWalletBox);
    await box.deleteAt(index);
  }

  Future<void> deleteMultisigWalletByAddress(String address) async {
    final box = Hive.box<MultisigWalletModel>(Constants.multisigWalletBox);
    var index =
        box.values.toList().indexWhere((element) => element.address == address);
    await box.deleteAt(index).then((value) => log.e('deleted $address'));
  }

  MultisigWalletModel getMultisigWallet(int index) {
    final box = Hive.box<MultisigWalletModel>(Constants.multisigWalletBox);
    return box.getAt(index)!;
  }

  Future<List<MultisigWalletModel>> getAllMultisigWallets() async {
    final box = Hive.box<MultisigWalletModel>(Constants.multisigWalletBox);

    log.w('getAllMultisigWallets ${box.values.map((e) => e.name)}');

    List<MultisigWalletModel> uniquelist = [];
    box.values.toList().forEach((savedWallet) {
      var data = uniquelist.firstWhere(
          (element) => element.address == savedWallet.address,
          orElse: () => MultisigWalletModel(address: ''));
      if (data.address!.isEmpty) {
        uniquelist.add(savedWallet);
      } else
        log.w('duplicate ${savedWallet.name}');
    });
    log.e('-------------------------------');
    log.e(uniquelist);
    return uniquelist;
  }

  bool isUniqueEntry(MultisigWalletModel wallet) {
    bool isUnique = true;
    final box = Hive.box<MultisigWalletModel>(Constants.multisigWalletBox);

    isUnique = box.values
        .toList()
        .firstWhere(
          (element) => element.address == wallet.address,
          orElse: () => MultisigWalletModel(address: ''),
        )
        .address!
        .isEmpty;
    return isUnique;
  }
}
