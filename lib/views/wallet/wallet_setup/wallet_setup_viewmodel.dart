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

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/models/wallet/user_settings_model.dart';
import 'package:paycool/services/db/core_wallet_database_service.dart';
import 'package:paycool/services/db/token_list_database_service.dart';
import 'package:paycool/services/db/transaction_history_database_service.dart';
import 'package:paycool/services/db/user_settings_database_service.dart';
import 'package:paycool/services/db/wallet_database_service.dart';
import 'package:paycool/services/local_auth_service.dart';
import 'package:paycool/services/local_dialog_service.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/services/navigation_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/services/version_service.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/utils/wallet/wallet_util.dart';
import 'package:paycool/widgets/web_view_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../constants/api_routes.dart';
import '../../../service_locator.dart';
import 'dart:io' show Platform;

class WalletSetupViewmodel extends BaseViewModel {
  final log = getLogger('WalletSetupViewModel');
  SharedService sharedService = locator<SharedService>();
  final walletDatabaseService = locator<WalletDatabaseService>();
  WalletService walletService = locator<WalletService>();
  final NavigationService navigationService = locator<NavigationService>();
  VersionService versionService = locator<VersionService>();
  final storageService = locator<LocalStorageService>();
  final coreWalletDatabaseService = locator<CoreWalletDatabaseService>();
  final localDialogService = locator<LocalDialogService>();

  final transactionHistoryDatabaseService =
      locator<TransactionHistoryDatabaseService>();
  final tokenListDatabaseService = locator<TokenListDatabaseService>();
  final authService = locator<LocalAuthService>();
  final userSettingsDatabaseService = locator<UserSettingsDatabaseService>();

  BuildContext context;
  bool isWallet = false;
  String errorMessage = '';

  String selectedLanguage;
  UserSettings userSettings = UserSettings();
  bool isUserSettingsEmpty = false;
  final Map<String, String> languages = {
    'en': 'English',
    'zh': '简体中文',
    'es': 'Español'
  };
  final walletUtil = WalletUtil();
  get hasAuthenticated => authService.hasAuthorized;

  // get hasAuthenticated => authService.hasAuthorized;

  bool isWalletVerifySuccess = false;
  bool isDeleting = false;

  bool isVerifying = false;
  bool hasVerificationStarted = false;
  int webViewProgress = 0;

  init() async {
    setBusy(true);
    // await setLanguageFromDb();
    await selectDefaultWalletLanguage();

    sharedService.context = context;
    //  walletDatabaseService.initDb();
    // await checkVersion();
    // await walletService.checkLanguage(context);

    if (storageService.hasPrivacyConsent) {
      await checkExistingWallet();
    } else {
      showPrivacyConsentWidget();
      return;
    }

    setBusy(false);
  }

  onBackButtonPressed() async {
    sharedService.closeApp();
  }

  int onProgress(int progress) {
    log.e('progress pass in wallet setup $progress');
    setBusyForObject(webViewProgress, true);
    webViewProgress = progress;
    setBusyForObject(webViewProgress, false);
    log.w('webViewProgress  $webViewProgress');
    return progress;
  }

  showPrivacyConsentWidget() {
    showModalBottomSheet(
        isScrollControlled: true,
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 120),
        isDismissible: false,
        enableDrag: false,
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(25.0),
        //   ),
        backgroundColor: const Color(0xffedeff0),
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: ListView(
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height / 1.4),
                  child: LocalWebViewWidget(
                      paycoolPrivacyUrl,
                      FlutterI18n.translate(context, "askPrivacyConsent"),
                      onProgress),
                ),
                UIHelper.verticalSpaceSmall,
                Container(
                  // margin: const EdgeInsets.all(5),
                  color: const Color(0xffedeff0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.symmetric(
                                      horizontal: 25, vertical: 15)),
                              elevation: MaterialStateProperty.all(10.0),
                              backgroundColor:
                                  MaterialStateProperty.all(secondaryColor),
                              shape: buttonRoundShape(secondaryColor)),
                          onPressed: (() => navigationService.goBack()),
                          child: Text(
                            FlutterI18n.translate(context, "decline"),
                            style: headText5,
                          )),
                      UIHelper.horizontalSpaceMedium,
                      ElevatedButton(
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.symmetric(
                                      horizontal: 25, vertical: 15)),
                              elevation: MaterialStateProperty.all(10.0),
                              backgroundColor:
                                  MaterialStateProperty.all(primaryColor),
                              shape: buttonRoundShape(primaryColor)),
                          onPressed: (() => setPrivacyConsent()),
                          child: Text(
                            FlutterI18n.translate(context, "accept"),
                            style: headText5.copyWith(
                                color: secondaryColor,
                                fontWeight: FontWeight.w400),
                          )),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  setPrivacyConsent() {
    storageService.hasPrivacyConsent = true;
    navigationService.goBack();
    checkExistingWallet();
  }

// import or create wallet button navigation
  importCreateNav(String actionType) async {
    // check if there is any pre existing wallet data
    String coreWalletDbData = '';
    try {
      coreWalletDbData = await coreWalletDatabaseService.getEncryptedMnemonic();
    } catch (err) {
      coreWalletDbData = '';
      log.e('importCreateNav importCreateNav CATCH err $err');
    }
    List walletDatabase;
    try {
      await walletDatabaseService.initDb();
      walletDatabase = await walletDatabaseService.getAll();
    } catch (err) {
      log.e('importCreateNav func: wallet database empty CATCH: $err');
    }
    if (storageService.walletBalancesBody.isNotEmpty ||
        coreWalletDbData.isNotEmpty ||
        walletDatabase.isNotEmpty)
    // also show the user a dialog that there is pre existing wallet
    // data, do you want to restore that wallet or not?
    {
      await localDialogService
          .showVerifyDialog(
              title: FlutterI18n.translate(context, "existingWalletFound"),
              secondaryButton: FlutterI18n.translate(context, "restore"),
              description:
                  '${FlutterI18n.translate(context, "askWalletRestore")} ?',
              buttonTitle: FlutterI18n.translate(context,
                  "importWallet")) // want to ask whether i should show Delete & Import
          .then((res) async {
        if (res.confirmed) {
          // confirmed means import wallet true
          // delete the existing wallet data
          // then import
          errorMessage = '';
          setBusyForObject(isDeleting, true);
          log.w('deleting wallet');
          // otherwise ask user for wallet password to delete the existing wallet
          await walletUtil.deleteWallet().whenComplete(() {
            // if not then just navigate to the route
            if (actionType == 'import') {
              navigationService.navigateTo(ImportWalletViewRoute,
                  arguments: actionType);
            } else if (actionType == 'create') {
              navigationService.navigateTo(BackupMnemonicViewRoute);
            }
          }).catchError((err) {
            log.e('Existing wallet deletion could not be completed');
            setBusyForObject(isDeleting, false);
            errorMessage = 'Wallet deletion failed';
          });
        } else if (res.returnedText == 'wrong password') {
          sharedService.sharedSimpleNotification(FlutterI18n.translate(
              context, "pleaseProvideTheCorrectPassword"));
        } else if (!res.confirmed && res.returnedText != 'Closed') {
          // if user wants to restore that then call check existing wallet func
          await checkExistingWallet();
        }
      });
    } else if (actionType == 'import') {
      navigationService.navigateTo(ImportWalletViewRoute,
          arguments: actionType);
    } else if (actionType == 'create') {
      navigationService.navigateTo(BackupMnemonicViewRoute);
    }
  }

  verifyWallet() async {
    var res = await localDialogService.showVerifyDialog(
        title: FlutterI18n.translate(context, "walletUpdateNoticeTitle"),
        secondaryButton: FlutterI18n.translate(context, "cancel"),
        description:
            FlutterI18n.translate(context, "walletUpdateNoticeDecription"),
        buttonTitle: FlutterI18n.translate(context, "confirm"));
    if (!res.confirmed) {
      setBusy(false);

      return;
    } else {
      isVerifying = true;
      var res = await localDialogService.showDialog(
          title: FlutterI18n.translate(context, "enterPassword"),
          description: FlutterI18n.translate(
              context, "dialogManagerTypeSamePasswordNote"),
          buttonTitle: FlutterI18n.translate(context, "confirm"));
      if (res.confirmed) {
        var walletVerificationRes =
            await walletService.verifyWalletAddresses(res.returnedText);
        isWalletVerifySuccess = walletVerificationRes['fabAddressCheck'] &&
            walletVerificationRes['trxAddressCheck'];
        // set has wallet verified to true
        storageService.hasWalletVerified = true;

        // if wallet verification is true then fill encrypted mnemonic and
        // addresses in the new corewalletdatabase
        if (isWalletVerifySuccess) {
          isVerifying = false;
          goToWalletDashboard();
        } else {
          isWalletVerifySuccess = false;
          storageService.hasWalletVerified = false;
          setBusy(false);
          // show popup
          // if wallet verification failed then generate warning
          // to delete and re-import the wallet
          // show the warning in the UI and underneath a delete wallet button
          // which will delete the wallet data and navigate to create/import view
          sharedService.context = context;
          await localDialogService
              .showVerifyDialog(
                  title: FlutterI18n.translate(
                      context, "walletVerificationFailed"),
                  description: '',
                  buttonTitle: FlutterI18n.translate(context, "deleteWallet"),
                  secondaryButton: '')
              .then((isDelete) async {
            await walletUtil.deleteWallet();
          });
        }
      } else if (res.returnedText == 'Closed') {
        log.e('Dialog Closed By User');
        // setBusy(false);
        // return errorMessage = '';
      } else {
        log.e('Wrong pass');
        setBusy(false);

        sharedService.sharedSimpleNotification(
            FlutterI18n.translate(context, "pleaseProvideTheCorrectPassword"));
      }
    }
  }

// Check existing wallet
  Future checkExistingWallet() async {
    setBusy(true);

    String coreWalletDbData;
    try {
      coreWalletDbData = await coreWalletDatabaseService.getEncryptedMnemonic();
    } catch (err) {
      coreWalletDbData = '';
      log.e('checkExistingWallet func: getEncryptedMnemonic CATCH err $err');
    }
    if (coreWalletDbData == null || coreWalletDbData.isEmpty) {
      log.w('coreWalletDbData is null or empty');
      List walletDatabase;
      try {
        await walletDatabaseService.initDb();
        walletDatabase = await walletDatabaseService.getAll();
      } catch (err) {
        walletDatabase = [];
      }
      // CHECK TO VERIFY IF OLD DATA IS SAVED IN STORAGE
      if (storageService.walletBalancesBody.isNotEmpty ||
          walletDatabase.isNotEmpty) {
        // ask user's permission to verify the wallet addresses
        // show dialog to user for this reason
        if (!storageService.hasWalletVerified) {
          await verifyWallet();
        } else {
          isVerifying = false;
          goToWalletDashboard();
        }
      } else {
        isWallet = false;
        isVerifying = false;
      }
    }
    // IF THERE IS NO OLD DATA IN STORAGE BUT NEW CORE WALLET DATA IS PRESENT IN DATABASE
    // THEN VERIFY AGAIN IF STORED DATA IS NOT PREVIOUSLY VERIFIED
    else if (coreWalletDbData != null || coreWalletDbData.isNotEmpty) {
      isVerifying = false;
      goToWalletDashboard();
    }
    hasVerificationStarted = false;
    setBusy(false);
  }

  // Go to wallet dashboard

  goToWalletDashboard() async {
    isWalletVerifySuccess = true;
    isWallet = true;
    // add here the biometric check
    if (storageService.hasInAppBiometricAuthEnabled) {
      if (!authService.isCancelled) await authService.authenticateApp();
      if (hasAuthenticated) {
        navigationService.navigateUsingpopAndPushedNamed(DashboardViewRoute);
        storageService.hasAppGoneInTheBackgroundKey = false;
      }
      if (authService.isCancelled || !hasAuthenticated) {
        isWallet = false;
        setBusy(false);
        authService.setIsCancelledValueFalse();
      }
      // bool isDeviceSupported = await authService.isDeviceSupported();
      if (!storageService.hasPhoneProtectionEnabled) {
        navigationService.navigateUsingpopAndPushedNamed(DashboardViewRoute);
      }
    } else {
      navigationService.navigateUsingpopAndPushedNamed(DashboardViewRoute);
    }
    setBusy(false);

    walletService.storeTokenListInDB();
  }

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
      String key = '';
      if (storageService.language == null || storageService.language.isEmpty) {
        storageService.language = 'en';
      } else {
        key = storageService.language;
      }
      if (key.isEmpty) {
        key = 'en';
        storageService.language = 'en';
      }

      // /// Created Map of languages because in dropdown if i want to show
      // /// first default value as whichever language is currently the app
      // /// is in then default value that i want to show should match with one
      // /// of the dropdownMenuItem's value

      if (languages.containsKey(key)) {
        selectedLanguage = languages[key];

        await FlutterI18n.refresh(context, Locale(key));
      }

      log.i('selectedLanguage $selectedLanguage');
    }
    setBusy(false);
    return selectedLanguage;
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
      // AppLocalizations.load(Locale('zh', 'ZH'));
      await FlutterI18n.refresh(context, const Locale('zh'));

      UserSettings us = UserSettings(id: 1, language: 'zh', theme: '');
      await walletService.updateUserSettingsDb(us, isUserSettingsEmpty);
      storageService.language = 'zh';
    } else if (updatedLanguageValue == 'English' ||
        updatedLanguageValue == 'en' ||
        key == 'en') {
      log.e('in en');
      // AppLocalizations.load(Locale('en', 'EN'));
      await FlutterI18n.refresh(context, const Locale('en'));
      storageService.language = 'en';
      UserSettings us = UserSettings(id: 1, language: 'en', theme: '');
      await walletService.updateUserSettingsDb(us, isUserSettingsEmpty);
    } else if (updatedLanguageValue == 'Spanish' ||
        updatedLanguageValue == 'es' ||
        key == 'es') {
      log.e('in es');
      // AppLocalizations.load(Locale('en', 'EN'));
      await FlutterI18n.refresh(context, const Locale('es'));
      storageService.language = 'es';
      UserSettings us = UserSettings(id: 1, language: 'es', theme: '');
      await walletService.updateUserSettingsDb(us, isUserSettingsEmpty);
    }
    (context as Element).markNeedsBuild();
    setBusy(false);
  }
}
