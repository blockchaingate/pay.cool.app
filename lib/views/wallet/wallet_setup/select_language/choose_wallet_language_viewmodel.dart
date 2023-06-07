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

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/models/wallet/user_settings_model.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/db/user_settings_database_service.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/services/navigation_service.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class ChooseWalletLanguageViewModel extends BaseViewModel {
  final log = getLogger('ChooseWalletLanguageScreenState');
  late BuildContext context;

  UserSettingsDatabaseService userSettingsDatabaseService =
      locator<UserSettingsDatabaseService>();
  final NavigationService navigationService = locator<NavigationService>();
  final LocalStorageService storageService = locator<LocalStorageService>();
  final walletService = locator<WalletService>();
  String errorMessage = '';
  bool isUserSettingsEmpty = false;

  Future checkLanguage() async {
    setBusy(true);
    String lang = '';

    //  SharedPreferences prefs = await SharedPreferences.getInstance();
    lang = await userSettingsDatabaseService
        .getById(1)
        .then((res) => res!.language!);
    if (lang == '') {
      log.e('language empty');
    } else {
      setBusy(false);
      setLangauge(lang);
      storageService.language = lang;
      navigationService.navigateTo('/walletSetup');
    }
    setBusy(false);
  }

  setLangauge(String languageCode) async {
    setBusy(true);
    //  SharedPreferences prefs = await SharedPreferences.getInstance();
    UserSettings userSettings = UserSettings(language: languageCode, theme: '');
    await userSettingsDatabaseService.getById(1).then((res) {
      if (res != null) {
        //   userSettings.language = res.language;
        isUserSettingsEmpty = false;
        log.i('user settings db not null --$res');
      } else {
        isUserSettingsEmpty = true;
        log.i('user settings db null --$res');
      }
    }).catchError((err) => log.e('user settings db empty $err'));
    await walletService.updateUserSettingsDb(userSettings, isUserSettingsEmpty);
    storageService.language = languageCode;
    // AppLocalizations.load(Locale(languageCode, languageCode.toUpperCase()));
    await FlutterI18n.refresh(
        context, Locale(languageCode, languageCode.toUpperCase()));
    (context as Element).markNeedsBuild();
    setBusy(false);
  }
}
