import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:local_auth/local_auth.dart';
import 'package:paycool/routes.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/config_service.dart';
import 'package:paycool/services/local_dialog_service.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/services/stoppable_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class SettingsViewModel extends BaseViewModel with StoppableService {
  final storageService = locator<LocalStorageService>();
  final navigationService = locator<NavigationService>();
  final sharedService = locator<SharedService>();
  final dialogService = locator<LocalDialogService>();
  final configService = locator<ConfigService>();

  BuildContext? context;
  String? errorMessage;
  String? baseServerUrl;
  bool? isHKServer;

  String? selectedLanguage = "English";
  Locale? currentLang;
  final Map<String, String> languages = {
    "en": "English",
    "zh": "简体中文",
    "es": "Español",
    "tr": "Türkçe",
    "fr": "Français",
    "ja": "日本",
    "hi": "हिंदी",
  };
  final Map<String, String> languageWithIsoCode = {
    "en": "US",
    "zh": "CN",
    "es": "ES",
    "tr": "TR",
    "fr": "FR",
    "ja": "JP",
    "hi": "IN",
  };

  bool isAutoStartPaycoolScan = false;

  init() async {
    setBusy(true);
    selectedLanguage = languages[storageService.language];
    log.i('selectedLanguage $selectedLanguage');
    isAutoStartPaycoolScan = storageService.autoStartPaycoolScan;
    setBusy(false);
  }

  changeWalletLanguage(String updatedLanguageValue) async {
    setBusy(true);
    //remove cached announcement Data in different language
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('announceData');
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
    log.w("selectedLanguage $selectedLanguage");
    if (updatedLanguageValue == "Chinese" ||
        updatedLanguageValue == "zh" ||
        key == "zh") {
      log.e("in zh");
      currentLang = const Locale("zh");
      await FlutterI18n.refresh(context!, currentLang);
      storageService.language = "zh";
    } else if (updatedLanguageValue == "English" ||
        updatedLanguageValue == "en" ||
        key == "en") {
      log.e("in en");
      currentLang = const Locale("en");
      await FlutterI18n.refresh(context!, currentLang);
      storageService.language = "en";
    } else if (updatedLanguageValue == "Spanish" ||
        updatedLanguageValue == "es" ||
        key == "es") {
      log.e("in es");
      currentLang = const Locale("es");
      await FlutterI18n.refresh(context!, currentLang);
      storageService.language = "es";
    } else if (updatedLanguageValue == "Français" ||
        updatedLanguageValue == "fr" ||
        key == "fr") {
      log.e("in fr");
      currentLang = const Locale("fr");
      await FlutterI18n.refresh(context!, currentLang);
      storageService.language = "fr";
    } else if (updatedLanguageValue == "Türkçe" ||
        updatedLanguageValue == "tr" ||
        key == "tr") {
      log.e("in tr");
      currentLang = const Locale("tr");
      await FlutterI18n.refresh(context!, currentLang);
      storageService.language = "tr";
    } else if (updatedLanguageValue == "日本" ||
        updatedLanguageValue == "ja" ||
        key == "ja") {
      log.e("in ja");
      currentLang = const Locale("ja");
      await FlutterI18n.refresh(context!, currentLang);
      storageService.language = "ja";
    } else if (updatedLanguageValue == "हिंदी" ||
        updatedLanguageValue == "hi" ||
        key == "hi") {
      log.e("in hi");
      currentLang = const Locale("hi");
      await FlutterI18n.refresh(context!, currentLang);
      storageService.language = "hi";
    }

    selectedLanguage = updatedLanguageValue;
    notifyListeners();
    Navigator.of(context!).pop();
    setBusy(false);
  }

  setAutoScanPaycool(bool v) {
    log.i('setAutoScanPaycool $v value');
    storageService.autoStartPaycoolScan = !storageService.autoStartPaycoolScan;
    isAutoStartPaycoolScan = storageService.autoStartPaycoolScan;
    log.w('setautoStartPaycoolScan: ${storageService.autoStartPaycoolScan}');
    notifyListeners();
  }

  // set biometric payment
  toggleBiometricPayment() async {
    errorMessage = '';
    final localAuth = LocalAuthentication();

    await localAuth
        .authenticate(
      localizedReason:
          FlutterI18n.translate(context!, "pleaseAuthenticateToProceed"),
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
        sensitiveTransaction: true,
      ),
    )
        .then((value) async {
      if (value) {
        log.w('biometric value $value');
        storageService.enableBiometricPayment =
            !storageService.enableBiometricPayment;

        if (!storageService.enableBiometricPayment) {
          storageService.biometricAuthData = '';
        } else {
          try {
            await sharedService.storeDeviceId();
          } catch (err) {
            log.e('store device id err $err');
            storageService.enableBiometricPayment = false;
            sharedService.sharedSimpleNotification(
                FlutterI18n.translate(sharedService.context, "failed"),
                isError: true);
            setBusy(false);
            return '';
          }

          var res = await dialogService.showDialog(
              title: FlutterI18n.translate(context!, "enterPassword"),
              description: FlutterI18n.translate(
                  context!, "dialogManagerTypeSamePasswordNote"),
              buttonTitle: FlutterI18n.translate(context!, "confirm"),
              isBiometricPayment: true);

          if (res.confirmed) {
            storageService.enableBiometricPayment = true;

            sharedService.sharedSimpleNotification(
                FlutterI18n.translate(context!, "success"),
                isError: false);
          } else if (res.returnedText == 'Closed' && !res.confirmed) {
            log.e('Dialog Closed By User');

            storageService.enableBiometricPayment =
                !storageService.enableBiometricPayment;
            setBusy(false);
            return errorMessage = '';
          } else {
            log.e('Wrong pass');
            storageService.enableBiometricPayment =
                !storageService.enableBiometricPayment;
            setBusy(false);

            return errorMessage = FlutterI18n.translate(
                context!, "pleaseProvideTheCorrectPassword");
          }
        }
      } else {
        log.e('failed to verify biometric');
      }
    }).catchError((err) {
      sharedService.sharedSimpleNotification(
          FlutterI18n.translate(sharedService.context, "failed"),
          isError: true);

      setBusy(false);
      return '';
    });

    setBusy(false);
  }

  changeBaseAppUrl() {
    setBusy(true);
    storageService.isHKServer = !storageService.isHKServer;
    storageService.isUSServer = storageService.isHKServer ? false : true;

    baseServerUrl = configService.getKanbanBaseUrl();
    isHKServer = storageService.isHKServer;
    log.e('GLobal kanban url $baseServerUrl');
    setBusy(false);
  }
}
