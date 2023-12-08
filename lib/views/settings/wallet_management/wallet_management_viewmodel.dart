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
import 'package:kyc/kyc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/environments/environment_type.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/models/wallet/user_settings_model.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/config_service.dart';
import 'package:paycool/services/db/core_wallet_database_service.dart';
import 'package:paycool/services/db/token_list_database_service.dart';
import 'package:paycool/services/db/transaction_history_database_service.dart';
import 'package:paycool/services/db/user_settings_database_service.dart';
import 'package:paycool/services/db/wallet_database_service.dart';
import 'package:paycool/services/local_auth_service.dart';
import 'package:paycool/services/local_dialog_service.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/services/stoppable_service.dart';
import 'package:paycool/services/vault_service.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:showcaseview/showcaseview.dart';

import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class WalletManagementViewModel extends BaseViewModel with StoppableService {
  bool isMnemonicVisible = false;
  String mnemonic = '';
  final log = getLogger('WalletManagementViewModel');
  final dialogService = locator<LocalDialogService>();
  final walletService = locator<WalletService>();
  final transactionHistoryDatabaseService =
      locator<TransactionHistoryDatabaseService>();
  final tokenListDatabaseService = locator<TokenListDatabaseService>();
  final vaultService = locator<VaultService>();
  final walletDatabaseService = locator<WalletDatabaseService>();
  final sharedService = locator<SharedService>();
  final storageService = locator<LocalStorageService>();
  final NavigationService navigationService = locator<NavigationService>();
  final userSettingsDatabaseService = locator<UserSettingsDatabaseService>();
  final coreWalletDatabaseService = locator<CoreWalletDatabaseService>();
  String errorMessage = '';
  BuildContext? context;
  String versionName = '';
  String buildNumber = '';
  static int initialLanguageValue = 0;
  final FixedExtentScrollController fixedScrollController =
      FixedExtentScrollController(initialItem: initialLanguageValue);
  bool isDialogDisplay = false;

  bool isDeleting = false;

  // Delete wallet and local storage

  Future deleteWallet() async {
    errorMessage = '';
    setBusy(true);
    log.i('model busy $busy');
    await dialogService
        .showDialog(
            title: FlutterI18n.translate(context!, "enterPassword"),
            description: FlutterI18n.translate(
                context!, "dialogManagerTypeSamePasswordNote"),
            buttonTitle: FlutterI18n.translate(context!, "confirm"))
        .then((res) async {
      if (res.confirmed) {
        isDeleting = true;
        log.w('deleting wallet');
        await coreWalletDatabaseService
            .deleteDb()
            .whenComplete(() => log.e('core wallet database deleted!!'))
            .catchError((err) => log.e('Catch not able to delete core db'));

        await walletDatabaseService
            .deleteDb()
            .whenComplete(() => log.e('wallet database deleted!!'))
            .catchError((err) => log.e('Catch not able to delete wallet db'));

        await transactionHistoryDatabaseService
            .deleteDb()
            .whenComplete(() => log.e('trnasaction history database deleted!!'))
            .catchError((err) =>
                log.e('Catch not able to delete transaction history db'));

        await vaultService
            .deleteEncryptedData()
            .whenComplete(() => log.e('encrypted data deleted!!'))
            .catchError((err) => log.e('Catch not able to delete vault db'));

        await tokenListDatabaseService
            .deleteDb()
            .whenComplete(() => log.e('Token list database deleted!!'))
            .catchError((err) => log.e('Catch not able to delete token db'));

        await userSettingsDatabaseService
            .deleteDb()
            .whenComplete(() => log.e('User settings database deleted!!'))
            .catchError((err) => log.e('Catch not able to delete user db'));

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

        Navigator.pushNamed(context!, '/');
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
            FlutterI18n.translate(context!, "pleaseProvideTheCorrectPassword");
      }
    }).catchError((error) {
      log.e(error);
      isDeleting = false;
      setBusy(false);
      return errorMessage = '';
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

    log.w('Is isMnemonicVisible $isMnemonicVisible');
    if (isMnemonicVisible) {
      isMnemonicVisible = !isMnemonicVisible;
    } else {
      await dialogService
          .showDialog(
              title: FlutterI18n.translate(context!, "enterPassword"),
              description: FlutterI18n.translate(
                  context!, "dialogManagerTypeSamePasswordNote"),
              buttonTitle: FlutterI18n.translate(context!, "confirm"))
          .then((res) async {
        if (res.confirmed) {
          setBusy(true);
          isMnemonicVisible = !isMnemonicVisible;
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
          return errorMessage = FlutterI18n.translate(
              context!, "pleaseProvideTheCorrectPassword");
        }
      }).catchError((error) {
        log.e(error);
        setBusy(false);
        return errorMessage = '';
      });
    }
    setBusy(false);
  }
}
