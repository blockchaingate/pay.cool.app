import 'package:flutter/widgets.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../logger.dart';

class LocalStorageService {
  final log = getLogger('LocalStorageService');
  static LocalStorageService? _instance;
  static SharedPreferences? _preferences;
/*----------------------------------------------------------------------
                Local Storage Keys
----------------------------------------------------------------------*/
  static const String NoticeDialogDisplayKey = 'isDialogDisplay';
  static const String ShowCaseViewKey = 'isShowCaseView';
  static const String AppLanguagesKey = 'languages';
  static const String DarkModeKey = 'darkmode';
  static const String HKServerKey = 'isHKServer';
  static const String USServerKey = 'isUSServer';
  static const String WalletBalancesBodyKey = 'walletBalancesBody';
  static const String TokenListKey = 'tokenList';
  static const String FavWalletCoinsKey = 'favWalletCoinsKey';
  static const String FavCoinTabSelectedKey = 'favCoinTabSelectedKey';
  static const String PayCoolClubPaymentTxIdkey = 'payCoolClubPaymentTxId';
  static const String IsShowPaycool = 'IsShowPaycool';
  static const String IsShowPaycoolWallet = 'IsShowPaycoolWallet';
  static const String AutoStartPaycoolScan = 'AutoStartPaycoolScan';

  static const String WalletDecimalListKey = 'walletDecimalListKey';
  static const String InAppBiometricAuthKey = 'biometricAuthKey';
  static const String CancelBiometricAuthKey = 'cancelbiometricAuthKey';
  static const String PhoneProtectedKey = 'phoneProtectedKey';
  static const String AppGoneInTheBackgroundKey = 'appGoneInTheBackgroundKey';
  static const String WalletVerificationKey = 'walletVerificationKey';
  static const String TestingLogStringListKey = 'testingLogStringListKey';
  static const String CustomTokensKey = 'customTokensKey';
  static const String CustomTokenDataKey = 'customTokenDataKey';
  static const String CameraOpenKey = 'CameraOpenKey';
  static const String privacyConsentKey = 'privacyConsentKey';
  static const String tokenListDbUpdateTimeKey = 'tokenListDbUpdateTimeKey';
  static const String StoreDeviceIdKey = 'storeDeviceIdKey';
  static const String BiometricAuthDataKey = 'biometricAuthDataKey';
  static const String BiometricPaymentKey = 'biometricPaymentKey';
  static const String BondTokenKey = 'bondTokenKey';
  static const String MultisigEthWalletTokensKey = 'multisigEthWalletTokens';
  static const String MultisigBscWalletTokensKey = 'multisigBscWalletTokens';
  static const String MultisigKanbanWalletTokensKey =
      'multisigKanbanWalletTokens';

/*----------------------------------------------------------------------
                        Instance
----------------------------------------------------------------------*/
  static Future<LocalStorageService?> getInstance() async {
    _instance ??= LocalStorageService();

    _preferences ??= await SharedPreferences.getInstance();

    return _instance;
  }

  void clearToken() {
    _preferences!.remove(BondTokenKey);
  }

  void clearStorage() {
    _preferences!.clear();
  }

/*----------------------------------------------------------------------
            Updated _saveToDisk function that handles all types
----------------------------------------------------------------------*/

  void _saveToDisk<T>(String key, T content) {
    debugPrint(
        '(TRACE) LocalStorageService:_saveToDisk. key: $key value: $content');

    if (content is String) {
      _preferences!.setString(key, content);
    }
    if (content is bool) {
      _preferences!.setBool(key, content);
    }
    if (content is int) {
      _preferences!.setInt(key, content);
    }
    if (content is double) {
      _preferences!.setDouble(key, content);
    }
    if (content is List<String>) {
      _preferences!.setStringList(key, content);
    }
  }

/*----------------------------------------------------------------------
                Get data from disk
----------------------------------------------------------------------*/

  dynamic _getFromDisk(String key) {
    var value = _preferences!.get(key);
    // log.i('key: $key value: $value');

    return value;
  }

  String get tokenListDBUpdateTime =>
      _getFromDisk(tokenListDbUpdateTimeKey) ?? '';
  set tokenListDBUpdateTime(String value) =>
      _saveToDisk(tokenListDbUpdateTimeKey, value);

  bool get hasPrivacyConsent => _getFromDisk(privacyConsentKey) ?? false;
  set hasPrivacyConsent(bool value) => _saveToDisk(privacyConsentKey, value);

  // is camera open

  bool get isCameraOpen => _getFromDisk(CameraOpenKey) ?? false;
  set isCameraOpen(bool value) => _saveToDisk(CameraOpenKey, value);

  // Custom token Data

  String get customTokenData => _getFromDisk(CustomTokenDataKey) ?? '';

  set customTokenData(String value) => _saveToDisk(CustomTokenDataKey, value);

  // Custom tokens

  String get customTokens => _getFromDisk(CustomTokensKey) ?? '';

  set customTokens(String value) => _saveToDisk(CustomTokensKey, value);

  //Multisig  Wallet tokens

  String get multisigEthWalletTokens =>
      _getFromDisk(MultisigEthWalletTokensKey) ?? '';

  set multisigEthWalletTokens(String value) =>
      _saveToDisk(MultisigEthWalletTokensKey, value);

  String get multisigBscWalletTokens =>
      _getFromDisk(MultisigBscWalletTokensKey) ?? '';

  set multisigBscWalletTokens(String value) =>
      _saveToDisk(MultisigBscWalletTokensKey, value);

  String get multisigKanbanWalletTokens =>
      _getFromDisk(MultisigKanbanWalletTokensKey) ?? '';

  set multisigKanbanWalletTokens(String value) =>
      _saveToDisk(MultisigKanbanWalletTokensKey, value);

/*----------------------------------------------------------------------
                Testing Log String List
----------------------------------------------------------------------  */
  String get testingLogStringList =>
      _getFromDisk(TestingLogStringListKey) ?? '';

  set testingLogStringList(String value) =>
      _saveToDisk(TestingLogStringListKey, value);

/*----------------------------------------------------------------------
                Biometric auth getter/setter
----------------------------------------------------------------------  */
  String get deviceId => _getFromDisk(StoreDeviceIdKey) ?? '';

  set deviceId(String value) => _saveToDisk(StoreDeviceIdKey, value);

  String get biometricAuthData => _getFromDisk(BiometricAuthDataKey) ?? '';

  set biometricAuthData(String value) =>
      _saveToDisk(BiometricAuthDataKey, value);

/*----------------------------------------------------------------------
                Biometric auth getter/setter
----------------------------------------------------------------------*/
  bool get hasAppGoneInTheBackgroundKey =>
      _getFromDisk(AppGoneInTheBackgroundKey) ?? false;
  set hasAppGoneInTheBackgroundKey(bool value) =>
      _saveToDisk(AppGoneInTheBackgroundKey, value);

  bool get hasPhoneProtectionEnabled =>
      _getFromDisk(PhoneProtectedKey) ?? false;
  set hasPhoneProtectionEnabled(bool value) =>
      _saveToDisk(PhoneProtectedKey, value);

  bool get hasInAppBiometricAuthEnabled =>
      _getFromDisk(InAppBiometricAuthKey) ?? false;
  set hasInAppBiometricAuthEnabled(bool value) =>
      _saveToDisk(InAppBiometricAuthKey, value);

// is cancel biometric authentication
  bool get hasCancelledBiometricAuth =>
      _getFromDisk(CancelBiometricAuthKey) ?? false;
  set hasCancelledBiometricAuth(bool value) =>
      _saveToDisk(CancelBiometricAuthKey, value);

  bool get enableBiometricPayment => _getFromDisk(BiometricPaymentKey) ?? false;
  set enableBiometricPayment(bool value) =>
      _saveToDisk(BiometricPaymentKey, value);

/*----------------------------------------------------------------------
                wallet verification
----------------------------------------------------------------------*/
  bool get hasWalletVerified => _getFromDisk(WalletVerificationKey) ?? false;
  set hasWalletVerified(bool value) =>
      _saveToDisk(WalletVerificationKey, value);

/*----------------------------------------------------------------------
                Wallet Decimal List
----------------------------------------------------------------------  */
  String get walletDecimalList => _getFromDisk(WalletDecimalListKey) ?? '';

  set walletDecimalList(String value) =>
      _saveToDisk(WalletDecimalListKey, value);

/*----------------------------------------------------------------------
                  Languages getter/setter
----------------------------------------------------------------------*/
  String get payCoolClubPaymentReceipt =>
      _getFromDisk(PayCoolClubPaymentTxIdkey);
  set payCoolClubPaymentReceipt(String txId) =>
      _saveToDisk(PayCoolClubPaymentTxIdkey, txId);

/*----------------------------------------------------------------------
                  Languages getter/setter
----------------------------------------------------------------------*/
  String get language => _getFromDisk(AppLanguagesKey) ?? '';
  set language(String appLanguage) => _saveToDisk(AppLanguagesKey, appLanguage);

  String get langCodeSC => language == 'zh' ? 'sc' : language;

/*----------------------------------------------------------------------
                Dark mode getter/setter
----------------------------------------------------------------------*/
  bool get isDarkMode => _getFromDisk(DarkModeKey) ?? false;
  set isDarkMode(bool value) => _saveToDisk(DarkModeKey, value);

/*----------------------------------------------------------------------
                Pay.cool pay getter/setter
----------------------------------------------------------------------*/
  bool get showPaycool => _getFromDisk(IsShowPaycool) ?? false;
  set showPaycool(bool value) => _saveToDisk(IsShowPaycool, value);

/*----------------------------------------------------------------------
                Pay.cool wallet getter/setter
----------------------------------------------------------------------*/
  bool get showPaycoolClub => _getFromDisk(IsShowPaycoolWallet) ?? false;
  set showPaycoolClub(bool value) => _saveToDisk(IsShowPaycoolWallet, value);

/*----------------------------------------------------------------------
                auto Start Pay.cool Scan getter/setter
----------------------------------------------------------------------*/
  bool get autoStartPaycoolScan => _getFromDisk(AutoStartPaycoolScan) ?? false;
  set autoStartPaycoolScan(bool value) =>
      _saveToDisk(AutoStartPaycoolScan, value);

/*----------------------------------------------------------------------
                Notice Dialog getter/setter
----------------------------------------------------------------------  */
  bool get isNoticeDialogDisplay =>
      _getFromDisk(NoticeDialogDisplayKey) ?? false;

  set isNoticeDialogDisplay(bool value) =>
      _saveToDisk(NoticeDialogDisplayKey, value);

/*----------------------------------------------------------------------
                Showcase View getter/setter
----------------------------------------------------------------------  */
  bool get isShowCaseView => _getFromDisk(ShowCaseViewKey) ?? false;

  set isShowCaseView(bool value) => _saveToDisk(ShowCaseViewKey, value);

/*----------------------------------------------------------------------
                Is HK server getter/setter
----------------------------------------------------------------------  */
  bool get isHKServer => _getFromDisk(HKServerKey) ?? false;

  set isHKServer(bool value) => _saveToDisk(HKServerKey, value);

/*----------------------------------------------------------------------
                Is USD server getter/setter
----------------------------------------------------------------------  */
  bool get isUSServer => _getFromDisk(USServerKey) ?? false;

  set isUSServer(bool value) => _saveToDisk(USServerKey, value);

/*----------------------------------------------------------------------
                Wallet balance body
----------------------------------------------------------------------  */
  String get walletBalancesBody => _getFromDisk(WalletBalancesBodyKey) ?? '';

  set walletBalancesBody(String value) =>
      _saveToDisk(WalletBalancesBodyKey, value);

/*----------------------------------------------------------------------
                Fav wallet coins
----------------------------------------------------------------------  */
  String get favWalletCoins => _getFromDisk(FavWalletCoinsKey) ?? '';

  set favWalletCoins(String value) => _saveToDisk(FavWalletCoinsKey, value);

/*----------------------------------------------------------------------
                    Token List
----------------------------------------------------------------------  */
  List<String> get tokenList => _getFromDisk(TokenListKey) ?? false;

  set tokenList(List<String> value) => _saveToDisk(TokenListKey, value);

/*----------------------------------------------------------------------
                   Bond Token 
----------------------------------------------------------------------  */
  String get bondToken => _getFromDisk(BondTokenKey) ?? '';

  set bondToken(String value) => _saveToDisk(BondTokenKey, value);

/*----------------------------------------------------------------------
                Showcase View getter/setter
----------------------------------------------------------------------  */
  bool get isFavCoinTabSelected => _getFromDisk(FavCoinTabSelectedKey) ?? false;

  set isFavCoinTabSelected(bool value) =>
      _saveToDisk(FavCoinTabSelectedKey, value);
}
