import 'package:exchangily_core/exchangily_core.dart';
import 'package:flutter/widgets.dart';

class LocalStorageService {
  final log = getLogger('LocalStorageService');
  static LocalStorageService _instance;
  static SharedPreferences _preferences;

  static const String payCoolClubPaymentTxIdkey = 'payCoolClubPaymentTxId';
  static const String isShowPaycoolKey = 'IsShowPaycool';
  static const String isShowPaycoolWalletkey = 'IsShowPaycoolWallet';
  static const String autoStartPaycoolScanKey = 'AutoStartPaycoolScan';

/*----------------------------------------------------------------------
                        Instance
----------------------------------------------------------------------*/
  static Future<LocalStorageService> getInstance() async {
    _instance ??= LocalStorageService();

    _preferences ??= await SharedPreferences.getInstance();

    return _instance;
  }

  void clearStorage() {
    _preferences.clear();
  }

/*----------------------------------------------------------------------
            Updated _saveToDisk function that handles all types
----------------------------------------------------------------------*/

  void _saveToDisk<T>(String key, T content) {
    debugPrint(
        '(TRACE) LocalStorageService:_saveToDisk. key: $key value: $content');

    if (content is String) {
      _preferences.setString(key, content);
    }
    if (content is bool) {
      _preferences.setBool(key, content);
    }
    if (content is int) {
      _preferences.setInt(key, content);
    }
    if (content is double) {
      _preferences.setDouble(key, content);
    }
    if (content is List<String>) {
      _preferences.setStringList(key, content);
    }
  }

/*----------------------------------------------------------------------
                Get data from disk
----------------------------------------------------------------------*/

  dynamic _getFromDisk(String key) {
    var value = _preferences.get(key);
    // log.i('key: $key value: $value');

    return value;
  }

/*----------------------------------------------------------------------
                  Languages getter/setter
----------------------------------------------------------------------*/
  String get payCoolClubPaymentReceipt =>
      _getFromDisk(payCoolClubPaymentTxIdkey);
  set payCoolClubPaymentReceipt(String txId) =>
      _saveToDisk(payCoolClubPaymentTxIdkey, txId);

/*----------------------------------------------------------------------
                Paycool pay getter/setter
----------------------------------------------------------------------*/
  bool get showPaycool => _getFromDisk(isShowPaycoolKey) ?? false;
  set showPaycool(bool value) => _saveToDisk(isShowPaycoolKey, value);

/*----------------------------------------------------------------------
                Paycool wallet getter/setter
----------------------------------------------------------------------*/
  bool get showPaycoolClub => _getFromDisk(isShowPaycoolWalletkey) ?? false;
  set showPaycoolClub(bool value) => _saveToDisk(isShowPaycoolWalletkey, value);

/*----------------------------------------------------------------------
                auto Start Paycool Scan getter/setter
----------------------------------------------------------------------*/
  bool get autoStartPaycoolScan =>
      _getFromDisk(autoStartPaycoolScanKey) ?? false;
  set autoStartPaycoolScan(bool value) =>
      _saveToDisk(autoStartPaycoolScanKey, value);
}
