import 'package:hive_flutter/hive_flutter.dart';
import 'package:paycool/constants/constants.dart';
import 'package:paycool/enums/chain_enum.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/models/wallet/token_model.dart';
import 'package:paycool/views/wallet/wallet_setup/multi_wallet_model.dart';

import '../../views/multisig/multisig_wallet_model.dart';

class HiveMultiWalletService {
  final log = getLogger('HiveMultiWalletService');

  static late Box<MultiWalletModel> box;

  static HiveMultiWalletService? _instance;

  static Future<HiveMultiWalletService> getInstance() async {
    if (_instance == null) {
      _instance = HiveMultiWalletService();
      await _instance!.init();
    }
    return _instance!;
  }

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter<MultiWalletModel>(MultiWalletModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(OwnersAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter<TokenModel>(TokenModelAdapter());
    }
    box = await Hive.openBox<MultiWalletModel>(Constants.multiWalletBox);
  }

  MultiWalletModel findMultiWalletByName(String name) =>
      box.values.firstWhere((element) => element.name == name);

  MultiWalletModel findMultiWalletByAddress(String faAddress) =>
      box.values.firstWhere(
          (element) => element.getAddressByChain(Chain.fab) == faAddress);

  Future<int> addWallet(MultiWalletModel wallet) async {
    final box = Hive.box<MultiWalletModel>(Constants.multisigWalletBox);
    if (doesWalletExist(wallet)) {
      try {
        int key = await box.add(wallet);
        return key; // return the key if the wallet was added successfully
      } catch (e) {
        log.e('Failed to add wallet: $e');
        return -2; // return -2 if adding the wallet failed
      }
    } else {
      log.w('duplicate wallet ${wallet.name}');
      return -1;
    }
  }

  Future<void> updateMultiWallet(MultiWalletModel wallet) async {
    final box = Hive.box<MultiWalletModel>(Constants.multiWalletBox);

    log.i(
        'updating MultiWallet with key ${wallet.key} with ${wallet.toJson()}');
    try {
      await box.put(wallet.key, wallet);
      var test = box.get(wallet.key);
      log.w(
          'updated MultiWallet with key ${wallet.key} with ${test!.toJson()}');
    } catch (e) {
      log.e('Catch error $e }');
    }
  }

  // Future<void> deleteSelectedWallet() async {
  //   final box = Hive.box<MultiWalletModel>(Constants.multiWalletBox);
  //   var index =
  //       box.values.toList().indexWhere((element) => element.isSelected!);

  //   if (index != -1) {
  //     await box
  //         .deleteAt(index)
  //         .then((value) => log.e('deleted selected wallet'));
  //   } else {
  //     log.e('No selected wallet found');
  //   }
  // }

  Future<void> deleteWalletByFabAddress(String fabAddress) async {
    final box = Hive.box<MultiWalletModel>(Constants.multiWalletBox);
    var index = box.values.toList().indexWhere(
        (wallet) => wallet.getAddressByChain(Chain.fab) == fabAddress);
    if (index != -1) {
      await box
          .deleteAt(index)
          .then((value) => log.e('deleted wallet $fabAddress'));
    } else {
      log.e('No wallet found with address $fabAddress on fab chain');
    }
  }

  Future<void> selectWallet(int index) async {
    final box = Hive.box<MultiWalletModel>(Constants.multisigWalletBox);
    for (var i = 0; i < box.length; i++) {
      var wallet = box.getAt(i);
      if (wallet != null) {
        wallet.isSelected = i == index;
        box.putAt(i, wallet);
      }
    }
  }

  MultiWalletModel? getSelectedWallet() {
    final box = Hive.box<MultiWalletModel>(Constants.multisigWalletBox);
    for (var i = 0; i < box.length; i++) {
      MultiWalletModel? wallet = box.getAt(i);
      if (wallet!.isSelected!) {
        return wallet;
      }
    }
    return null;
  }

  Future<int> getWalletCount() async {
    final box = Hive.box<MultiWalletModel>(Constants.multisigWalletBox);
    return box.length;
  }

  Future<List<MultiWalletModel>> getAllWallets() async {
    log.w('getAll MultiWallets ${box.values.map((e) => e.name)}');
    return box.values.toList();
  }

  bool doesWalletExist(MultiWalletModel newWallet) {
    bool walletExists = box.values.toList().any(
          (element) =>
              element.name == newWallet.name &&
              element.encryptedMnemonic == newWallet.encryptedMnemonic &&
              element.getAddressByChain(Chain.fab) ==
                  newWallet.getAddressByChain(Chain.fab),
        );
    return walletExists;
  }
}
