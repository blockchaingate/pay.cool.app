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

import 'package:exchangily_core/exchangily_core.dart';
import 'package:flutter/material.dart';
import 'package:paycool/constants/paycool_constants.dart';

import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/views/home/home_view.dart';
import 'package:paycool/views/settings/settings_view.dart';

class SettingsViewmodel extends BaseViewModel with StoppableService {
  bool isVisible = false;
  String mnemonic = '';
  final log = getLogger('SettingsViewmodel');
  final dialogService = locator<DialogService>();
  WalletService walletService = locator<WalletService>();
  TransactionHistoryDatabaseService transactionHistoryDatabaseService =
      locator<TransactionHistoryDatabaseService>();
  TokenDatabaseService tokenDatabaseService = locator<TokenDatabaseService>();
  final vaultService = locator<VaultService>();
  WalletDatabaseService walletDatabaseService =
      locator<WalletDatabaseService>();
  SharedService sharedService = locator<SharedService>();
  final localStorageService = locator<LocalStorageService>();
  final storageService = locator<StorageService>();
  final NavigationService navigationService = locator<NavigationService>();
  UserSettingsDatabaseService userSettingsDatabaseService =
      locator<UserSettingsDatabaseService>();
  final authService = locator<AuthService>();
  final coreWalletDatabaseService = locator<CoreWalletDatabaseService>();
  final environmentService = locator<EnvironmentService>();

  final Map<String, String> languages = {'en': 'English', 'zh': '简体中文'};
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
        ' starting service -- hasAppGoneInTheBackgroundKey = ${storageService.hasAppGoneInTheBackgroundKey} -- auth in progress ${authService.authInProgress}');

    if (storageService.hasInAppBiometricAuthEnabled) {
      if (!storageService.isCameraOpen) {
        if (!authService.authInProgress &&
            storageService.hasAppGoneInTheBackgroundKey) {
          await authService.authenticateApp();
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

    localStorageService.showPaycool == null
        ? isShowPaycool = false
        : isShowPaycool = localStorageService.showPaycool;

    localStorageService.showPaycoolClub == null
        ? isShowPaycoolClub = false
        : isShowPaycoolClub = localStorageService.showPaycoolClub;

    localStorageService.autoStartPaycoolScan == null
        ? isAutoStartPaycoolScan = false
        : isAutoStartPaycoolScan = localStorageService.autoStartPaycoolScan;

    getAppVersion();
    baseServerUrl = environmentService.kanbanBaseUrl();
    await setLanguageFromDb();
    await selectDefaultWalletLanguage();
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
    navigationService.navigateUsingPushReplacementNamed(walletSetupViewRoute);
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

/*-------------------------------------------------------------------------------------
                      selectDefaultWalletLanguage
-------------------------------------------------------------------------------------*/

  Future<String> selectDefaultWalletLanguage() async {
    setBusy(true);
    if (selectedLanguage == '' || selectedLanguage == null) {
      String key = userSettings.language ?? 'en';
      // await getSetLocalStorageDataByKey('lang');
      // log.w('key in init $key');

      // /// Created Map of languages because in dropdown if i want to show
      // /// first default value as whichever language is currently the app
      // /// is in then default value that i want to show should match with one
      // /// of the dropdownMenuItem's value

      if (languages.containsKey(key)) {
        selectedLanguage = languages[key];
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
    baseServerUrl = environmentService.kanbanBaseUrl();
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
    localStorageService.showPaycool = !localStorageService.showPaycool;
    setBusy(true);
    isShowPaycool = localStorageService.showPaycool;
    setBusy(false);
    log.w('setShowPaycool: ' + localStorageService.showPaycool.toString());
    navigationService.navigateUsingpopAndPushedNamed(settingViewRoute);
  }

  setAutoScanPaycool(bool v) {
    // set setShowPaycool
    log.i('setAutoScanPaycool $v value');
    localStorageService.autoStartPaycoolScan =
        !localStorageService.autoStartPaycoolScan;
    setBusy(true);
    isAutoStartPaycoolScan = localStorageService.autoStartPaycoolScan;
    setBusy(false);
    log.w('setautoStartPaycoolScan: ' +
        localStorageService.autoStartPaycoolScan.toString());
    navigationService.navigateUsingpopAndPushedNamed(settingViewRoute);
  }

  setShowPaycoolClub(bool v) {
    // set setShowPaycool Wallet
    log.i('setShowPaycoolClub $v value');
    localStorageService.showPaycoolClub = !localStorageService.showPaycoolClub;
    setBusy(true);
    isShowPaycoolClub = localStorageService.showPaycoolClub;
    setBusy(false);
    log.w('setShowPaycoolWallet: ' +
        localStorageService.showPaycoolClub.toString());
    navigationService.navigateUsingPushReplacementNamed(homeViewRoute,
        arguments: isShowPaycoolClub ? 4 : 3);
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

        await tokenDatabaseService
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

        localStorageService.clearStorage();
        log.e('before local storage service clear ${prefs.getKeys()}');

        log.e('all keys after clearing ${prefs.getKeys()}');
        localStorageService.showPaycoolClub = false;
        localStorageService.showPaycool = true;
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

/*-------------------------------------------------------------------------------------
                      Change wallet language
-------------------------------------------------------------------------------------*/
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
      // AppLocalizations.load(Locale('zh', 'ZH'));
      currentLang = const Locale('zh');
      await FlutterI18n.refresh(context, currentLang);
      storageService.language = 'zh';
      UserSettings us = UserSettings(id: 1, language: 'zh', theme: '');
      await walletService.updateUserSettingsDb(us, isUserSettingsEmpty);
    } else if (updatedLanguageValue == 'English' ||
        updatedLanguageValue == 'en' ||
        key == 'en') {
      log.e('in en');
      // AppLocalizations.load(Locale('en', 'EN'));
      currentLang = const Locale('en');
      await FlutterI18n.refresh(context, currentLang);
      storageService.language = 'en';
      UserSettings us = UserSettings(id: 1, language: 'en', theme: '');
      await walletService.updateUserSettingsDb(us, isUserSettingsEmpty);
    }
    navigationService.navigateUsingPushReplacementNamed(homeViewRoute,
        arguments: localStorageService.showPaycoolClub ? 4 : 3);

    // Navigator.push(
    //   context,
    //   FadeRoute(widget: const HomeView(customIndex: 4)),
    // );
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
    await sharedService.onBackButtonPressed(PaycoolConstants.payCoolViewRoute);
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
