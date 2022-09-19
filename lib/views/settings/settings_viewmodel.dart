/*
* Copyright (c) 2020 Exchangily LLC
*
* Licensed under Apache License v2.0
* You may obtain a copy of the License at
*
*      https://www.apache.org/licenses/LICENSE-2.0
*
*----------------------------------------------------------------------
* Author: barry-ruprai@exchangily.com
*----------------------------------------------------------------------
*/

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:path_provider/path_provider.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/models/wallet/user_settings_model.dart';
import 'package:paycool/services/config_service.dart';
import 'package:paycool/services/db/core_wallet_database_service.dart';
import 'package:paycool/services/db/token_list_database_service.dart';
import 'package:paycool/services/db/transaction_history_database_service.dart';
import 'package:paycool/services/db/user_settings_database_service.dart';
import 'package:paycool/services/db/wallet_database_service.dart';
import 'package:paycool/services/local_auth_service.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/services/navigation_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/services/stoppable_service.dart';
import 'package:paycool/services/vault_service.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/views/settings/settings_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:showcaseview/showcaseview.dart';

import 'package:stacked/stacked.dart';

import '../../logger.dart';
import '../../models/dialog/dialog_response.dart';
import '../../service_locator.dart';
import '../../services/local_dialog_service.dart';

class SettingsViewmodel extends BaseViewModel with StoppableService {
  bool isVisible = false;
  String mnemonic = '';
  final log = getLogger('SettingsViewmodel');
  final dialogService = locator<LocalDialogService>();
  WalletService walletService = locator<WalletService>();
  TransactionHistoryDatabaseService transactionHistoryDatabaseService =
      locator<TransactionHistoryDatabaseService>();
  TokenListDatabaseService tokenListDatabaseService =
      locator<TokenListDatabaseService>();
  final vaultService = locator<VaultService>();
  WalletDatabaseService walletDatabaseService =
      locator<WalletDatabaseService>();
  SharedService sharedService = locator<SharedService>();
  final storageService = locator<LocalStorageService>();
  final NavigationService navigationService = locator<NavigationService>();
  UserSettingsDatabaseService userSettingsDatabaseService =
      locator<UserSettingsDatabaseService>();
  final authService = locator<LocalAuthService>();
  final localAuthService = locator<LocalAuthService>();
  final coreWalletDatabaseService = locator<CoreWalletDatabaseService>();

  final Map<String, String> languages = {
    'en': 'English',
    'zh': '简体中文',
    'es': 'Español'
  }; //,'fr':'français','ja':'日本語'};
  String selectedLanguage;
  // bool result = false;
  String errorMessage = '';
  DialogResponse dialogResponse;
  BuildContext context;
  String versionName = '';
  String buildNumber = '';
  static int initialLanguageValue = 0;
  final FixedExtentScrollController fixedScrollController =
      FixedExtentScrollController(initialItem: initialLanguageValue);
  bool isDialogDisplay = false;
  ScrollController scrollController;
  bool isDeleting = false;
  GlobalKey one;
  GlobalKey two;
  bool isShowCaseOnce;
  bool isShowPaycool;
  bool isShowPaycoolClub;
  bool isAutoStartPaycoolScan;
  String baseServerUrl;
  ConfigService configService = locator<ConfigService>();
  bool isHKServer;
  Map<String, String> versionInfo;
  UserSettings userSettings = UserSettings();
  bool isUserSettingsEmpty = false;

  Locale currentLang;
  bool _isBiometricAuth = false;
  get isBiometricAuth => _isBiometricAuth;
  final t = TextEditingController();
  bool _lockAppNow = false;
  get lockAppNow => _lockAppNow;

  @override
  void start() async {
    super.start();
    log.w(
        ' starting service -- hasAppGoneInTheBackgroundKey = ${storageService.hasAppGoneInTheBackgroundKey} -- auth in progress ${localAuthService.authInProgress}');

    if (storageService.hasInAppBiometricAuthEnabled) {
      if (!storageService.isCameraOpen) {
        if (!localAuthService.authInProgress &&
            storageService.hasAppGoneInTheBackgroundKey) {
          await localAuthService.authenticateApp();
        }
      }
    }
    storageService.hasAppGoneInTheBackgroundKey = false;
    storageService.isCameraOpen = false;
  }

  @override
  void stop() async {
    super.stop();
    log.w('stopping service');
    storageService.hasAppGoneInTheBackgroundKey = true;
  }

  init() async {
    setBusy(true);

    Future.delayed(Duration.zero, () async {
      currentLang = FlutterI18n.currentLocale(context);
    });

    storageService.isShowCaseView == null
        ? isShowCaseOnce = false
        : isShowCaseOnce = storageService.isShowCaseView;

    storageService.showPaycool == null
        ? isShowPaycool = false
        : isShowPaycool = storageService.showPaycool;

    storageService.showPaycoolClub == null
        ? isShowPaycoolClub = false
        : isShowPaycoolClub = storageService.showPaycoolClub;

    storageService.autoStartPaycoolScan == null
        ? isAutoStartPaycoolScan = false
        : isAutoStartPaycoolScan = storageService.autoStartPaycoolScan;

    getAppVersion();
    baseServerUrl = configService.getKanbanBaseUrl();

    try {
      await selectDefaultWalletLanguage();
    } catch (err) {
      log.e('CATCH selectDefaultWalletLanguage failed');
    }
    setBusy(false);
  }

  // changeLanguage() async {
  //   debugPrint("currentLang.languageCode: " + currentLang.languageCode.toString());
  //   debugPrint("currentLang: " + currentLang.toString());
  //   currentLang =
  //       currentLang.languageCode == 'en' ? Locale('zh') : Locale('en');
  //   await FlutterI18n.refresh(context, currentLang);
  //   navigationService.navigateUsingpopAndPushedNamed(SettingViewRoute);
  // }

  // app authentication

  setLockAppNowValue() {
    setBusyForObject(lockAppNow, true);
    _lockAppNow = !_lockAppNow;
    navigationService.navigateUsingPushReplacementNamed(WalletSetupViewRoute);
    setBusyForObject(lockAppNow, false);
  }

// Set biometric auth

  setBiometricAuth() async {
    setBusyForObject(isBiometricAuth, true);

    bool hasAuthorized = await authService.authenticateApp();

    if (hasAuthorized) {
      storageService.hasInAppBiometricAuthEnabled =
          !storageService.hasInAppBiometricAuthEnabled;
      storageService.hasPhoneProtectionEnabled = true;
    } else if (!hasAuthorized) {
      if (authService.isLockedOut) {
        sharedService.sharedSimpleNotification(
            FlutterI18n.translate(context, "lockedOutTemp"));
      } else if (authService.isLockedOutPerm) {
        sharedService.sharedSimpleNotification(
            FlutterI18n.translate(context, "lockedOutPerm"));
      }

      if (!storageService.hasPhoneProtectionEnabled) {
        sharedService.sharedSimpleNotification(
            FlutterI18n.translate(context, "pleaseSetupDeviceSecurity"));
        storageService.hasCancelledBiometricAuth = false;
        storageService.hasInAppBiometricAuthEnabled = false;
      }
      _isBiometricAuth = storageService.hasInAppBiometricAuthEnabled;
      setBusyForObject(isBiometricAuth, false);
    }
  }

/*-------------------------------------------------------------------------------------
                      setLanguageFromDb
-------------------------------------------------------------------------------------*/
  setLanguageFromDb() async {
    setBusy(true);
    await userSettingsDatabaseService.getById(1).then((res) {
      if (res != null) {
        userSettings.language = res.language;
        log.i('user settings db not null');
      } else {
        userSettings.language = Platform.localeName.substring(0, 2);
        isUserSettingsEmpty = true;
        log.i(
            'user settings db null-- isUserSettingsEmpty $isUserSettingsEmpty');
      }
    }).catchError((err) => log.e('user settings db empty $err'));
    setBusy(false);
  }

  Future<String> selectDefaultWalletLanguage() async {
    setBusy(true);
    if (selectedLanguage == '' || selectedLanguage == null) {
      String key = storageService.language;

      if (key.isEmpty) {
        key = 'en';
      }

      // /// Created Map of languages because in dropdown if i want to show
      // /// first default value as whichever language is currently the app
      // /// is in then default value that i want to show should match with one
      // /// of the dropdownMenuItem's value

      if (languages.containsKey(key)) {
        selectedLanguage = languages[key];
        currentLang = Locale(key);
        await FlutterI18n.refresh(context, currentLang);
      }
      // else if (languages.containsValue(key)) {
      //   String keyIsValue = key;

      //   selectedLanguage =
      //       languages.keys.firstWhere((k) => languages[k] == keyIsValue);
      // }
      log.i('selectedLanguage $selectedLanguage');
    }
    setBusy(false);
    return selectedLanguage;
  }

/*-------------------------------------------------------------------------------------
                      Reload app
-------------------------------------------------------------------------------------*/

  changeBaseAppUrl() {
    setBusy(true);
    //  log.i('1');
    storageService.isHKServer = !storageService.isHKServer;

    storageService.isUSServer = storageService.isHKServer ? false : true;
    // Phoenix.rebirth(context);
    //  log.i('2');
    baseServerUrl = configService.getKanbanBaseUrl();
    isHKServer = storageService.isHKServer;
    log.e('GLobal kanban url $baseServerUrl');
    setBusy(false);
  }

/*-------------------------------------------------------------------------------------
                      Showcase Event Start
-------------------------------------------------------------------------------------*/

  showcaseEvent(BuildContext test) async {
    setBusy(true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //ShowCaseWidget.of(test).startShowCase([one, two]);
    });
    setBusy(false);
  }

  setIsShowcase(bool v) {
    // set updated value
    log.i('setIsShowcase $v value');
    storageService.isShowCaseView = !storageService.isShowCaseView;

    // get new value and assign it to the viewmodel variable
    setBusy(true);
    isShowCaseOnce = storageService.isShowCaseView;
    setBusy(false);
    log.w('is show case once value $isShowCaseOnce');
  }

  setShowPaycool(bool v) {
    // set setShowPaycool
    log.i('setShowPaycool $v value');
    storageService.showPaycool = !storageService.showPaycool;
    setBusy(true);
    isShowPaycool = storageService.showPaycool;
    setBusy(false);
    log.w('setShowPaycool: ' + storageService.showPaycool.toString());
    navigationService.navigateUsingpopAndPushedNamed(SettingViewRoute);
  }

  setAutoScanPaycool(bool v) {
    // set setShowPaycool
    log.i('setAutoScanPaycool $v value');
    storageService.autoStartPaycoolScan = !storageService.autoStartPaycoolScan;
    setBusy(true);
    isAutoStartPaycoolScan = storageService.autoStartPaycoolScan;
    setBusy(false);
    log.w('setautoStartPaycoolScan: ' +
        storageService.autoStartPaycoolScan.toString());
    navigationService.navigateUsingpopAndPushedNamed(SettingViewRoute);
  }

  setShowPaycoolClub(bool v) {
    // set setShowPaycool Wallet
    log.i('setShowPaycoolClub $v value');
    storageService.showPaycoolClub = !storageService.showPaycoolClub;
    setBusy(true);
    isShowPaycoolClub = storageService.showPaycoolClub;
    setBusy(false);
    log.w('setShowPaycoolWallet: ' + storageService.showPaycoolClub.toString());
    navigationService.navigateUsingPushReplacementNamed(SettingViewRoute);
    // storageService.showPaycoolClub?
    // navigationService.navigateUsingpopAndPushedNamed(PayCoolClubDashboardViewRoute):
    // navigationService.navigateUsingpopAndPushedNamed(DashboardViewRoute);
  }

/*-------------------------------------------------------------------------------------
                      Set the display warning value to local storage
-------------------------------------------------------------------------------------*/

  setIsDialogWarningValue(value) async {
    storageService.isNoticeDialogDisplay =
        !storageService.isNoticeDialogDisplay;
    setBusy(true);
    //sharedService.setDialogWarningsStatus(value);
    isDialogDisplay = storageService.isNoticeDialogDisplay;
    setBusy(false);
  }

  void showMnemonic() async {
    await displayMnemonic();
    isVisible = !isVisible;
  }

  // Delete wallet and local storage

  Future deleteWallet() async {
    errorMessage = '';
    setBusy(true);
    log.i('model busy $busy');
    await dialogService
        .showDialog(
            title: FlutterI18n.translate(context, "enterPassword"),
            description: FlutterI18n.translate(
                context, "dialogManagerTypeSamePasswordNote"),
            buttonTitle: FlutterI18n.translate(context, "confirm"))
        .then((res) async {
      if (res.confirmed) {
        isDeleting = true;
        log.w('deleting wallet');
        await coreWalletDatabaseService
            .deleteDb()
            .whenComplete(() => log.e('core wallet database deleted!!'));

        await walletDatabaseService
            .deleteDb()
            .whenComplete(() => log.e('wallet database deleted!!'));

        await transactionHistoryDatabaseService.deleteDb().whenComplete(
            () => log.e('trnasaction history database deleted!!'));

        await vaultService
            .deleteEncryptedData()
            .whenComplete(() => log.e('encrypted data deleted!!'));

        await tokenListDatabaseService
            .deleteDb()
            .whenComplete(() => log.e('Token list database deleted!!'));

        await userSettingsDatabaseService
            .deleteDb()
            .whenComplete(() => log.e('User settings database deleted!!'));

        storageService.walletBalancesBody = '';
        storageService.isShowCaseView = true;

        SharedPreferences prefs = await SharedPreferences.getInstance();
        log.e('before wallet removal, local storage has ${prefs.getKeys()}');
        prefs.clear();

        storageService.clearStorage();
        log.e('before local storage service clear ${prefs.getKeys()}');

        log.e('all keys after clearing ${prefs.getKeys()}');
        storageService.showPaycoolClub = false;
        storageService.showPaycool = true;
        try {
          await _deleteCacheDir();
          await _deleteAppDir();
        } catch (err) {
          log.e('delete cache dir err $err');
        }

        Navigator.pushNamed(context, '/');
      } else if (res.returnedText == 'Closed' && !res.confirmed) {
        log.e('Dialog Closed By User');
        isDeleting = false;
        setBusy(false);
        return errorMessage = '';
      } else {
        log.e('Wrong pass');
        setBusy(false);
        isDeleting = false;
        return errorMessage =
            FlutterI18n.translate(context, "pleaseProvideTheCorrectPassword");
      }
    }).catchError((error) {
      log.e(error);
      isDeleting = false;
      setBusy(false);
    });
    isDeleting = false;
    setBusy(false);
  }

  Future<void> _deleteCacheDir() async {
    final cacheDir = await getTemporaryDirectory();

    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
  }

  Future<void> _deleteAppDir() async {
    final appDir = await getApplicationSupportDirectory();

    if (appDir.existsSync()) {
      appDir.deleteSync(recursive: true);
    }
  }

/*----------------------------------------------------------------------
                Display mnemonic
----------------------------------------------------------------------*/
  displayMnemonic() async {
    errorMessage = '';

    log.w('Is visible $isVisible');
    if (isVisible) {
      isVisible = !isVisible;
    } else {
      await dialogService
          .showDialog(
              title: FlutterI18n.translate(context, "enterPassword"),
              description: FlutterI18n.translate(
                  context, "dialogManagerTypeSamePasswordNote"),
              buttonTitle: FlutterI18n.translate(context, "confirm"))
          .then((res) async {
        if (res.confirmed) {
          setBusy(true);
          isVisible = !isVisible;
          mnemonic = res.returnedText;

          setBusy(false);
          return '';
        } else if (res.returnedText == 'Closed') {
          log.e('Dialog Closed By User');
          // setBusy(false);
          // return errorMessage = '';
        } else {
          log.e('Wrong pass');
          setBusy(false);
          return errorMessage =
              FlutterI18n.translate(context, "pleaseProvideTheCorrectPassword");
        }
      }).catchError((error) {
        log.e(error);
        setBusy(false);
      });
    }
    setBusy(false);
  }

  changeWalletLanguage(String updatedLanguageValue) async {
    setBusy(true);

    //remove cached announcement Data in different language
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("announceData");

    // Get the Map key using value
    // String key = languages.keys.firstWhere((k) => languages[k] == lang);
    String key = '';
    log.e('KEY or Value $updatedLanguageValue');
    if (languages.containsValue(updatedLanguageValue)) {
      key = languages.keys
          .firstWhere((k) => languages[k] == updatedLanguageValue);
      log.i('key in changeWalletLanguage $key');
    } else {
      key = updatedLanguageValue;
    }
// selected language should be English,Chinese or other language selected not its lang code
    selectedLanguage = key.isEmpty ? updatedLanguageValue : languages[key];
    log.w('selectedLanguage $selectedLanguage');
    if (updatedLanguageValue == 'Chinese' ||
        updatedLanguageValue == 'zh' ||
        key == 'zh') {
      log.e('in zh');

      currentLang = const Locale('zh');
      await FlutterI18n.refresh(context, currentLang);
      storageService.language = 'zh';
    } else if (updatedLanguageValue == 'English' ||
        updatedLanguageValue == 'en' ||
        key == 'en') {
      log.e('in en');

      currentLang = const Locale('en');
      await FlutterI18n.refresh(context, currentLang);
      storageService.language = 'en';
    } else if (updatedLanguageValue == 'Spanish' ||
        updatedLanguageValue == 'es' ||
        key == 'es') {
      log.e('in es');

      currentLang = const Locale('es');
      await FlutterI18n.refresh(context, currentLang);
      storageService.language = 'es';
    }
    navigationService.navigateUsingpopAndPushedNamed(SettingViewRoute);

    setBusy(false);
  }

  // Pin code

  // Change password

  // Change theme

  // Get app version Code

  getAppVersion() async {
    setBusy(true);
    log.w('in app getappver');
    versionInfo = await sharedService.getLocalAppVersion();
    log.i('getAppVersion $versionInfo');
    versionName = versionInfo['name'];
    buildNumber = versionInfo['buildNumber'];
    log.i('getAppVersion name $versionName');

    setBusy(false);
  }

/*----------------------------------------------------------------------
                    onBackButtonPressed
----------------------------------------------------------------------*/
  onBackButtonPressed() async {
    await sharedService.onBackButtonPressed(PayCoolViewRoute);
  }
}

class SlideRightRoute extends PageRouteBuilder {
  final Widget widget;
  SlideRightRoute({this.widget})
      : super(pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return widget;
        }, transitionsBuilder: (BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child) {
          return FadeTransition(opacity: animation, child: child);
        });
}

class FadeRoute extends PageRouteBuilder {
  final Widget widget;
  FadeRoute({this.widget})
      : super(pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return widget;
        }, transitionsBuilder: (BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        });
}
