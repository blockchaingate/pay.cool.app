import 'package:hive_flutter/hive_flutter.dart';
import 'package:paycool/constants/constants.dart';
import 'package:paycool/logger.dart';

import '../../views/multisig/multisig_wallet_model.dart';

class HiveMultisigService {
  final log = getLogger('HiveMultisigService');
  static late Box<MultisigWalletModel> box;

  static HiveMultisigService? _instance;

  static Future<HiveMultisigService> getInstance() async {
    if (_instance == null) {
      _instance = HiveMultisigService();
      await _instance!.init();
    }
    return _instance!;
  }

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter<MultisigWalletModel>(MultisigWalletModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(OwnersAdapter());
    }

    box = await Hive.openBox<MultisigWalletModel>(Constants.multisigWalletBox);
  }

  // Function find multisig wallet by txid
  MultisigWalletModel findMultisigWalletByTxid(String txid) =>
      box.values.firstWhere((element) => element.txid == txid);
  MultisigWalletModel findMultisigWalletByAddress(String address) =>
      box.values.firstWhere((element) => element.address == address);
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

    log.i('updating MultisigWallet at key ${msw.key} with ${msw.toJson()}');
    try {
      await box.putAt(msw.key, msw);
      var test = box.getAt(msw.key);
      log.w('updated MultisigWallet at key ${msw.key} with ${test!.toJson()}');
    } catch (e) {
      log.e('Catch error $e }');
      log.i('decreasing key by 1');
      var length = box.length;
      log.w('box length $length');
      if (e
          .toString()
          .contains('Index out of range: index should be less than')) {
        log.e('decreasing key by 1');
        await box.putAt(msw.key - 1, msw);
      }
    }
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
      if (data.address == null || data.address!.isEmpty) {
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
