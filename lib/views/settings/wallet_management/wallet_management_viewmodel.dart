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
import 'package:path_provider/path_provider.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/db/core_wallet_database_service.dart';
import 'package:paycool/services/db/token_list_database_service.dart';
import 'package:paycool/services/db/transaction_history_database_service.dart';
import 'package:paycool/services/db/user_settings_database_service.dart';
import 'package:paycool/services/db/wallet_database_service.dart';
import 'package:paycool/services/local_dialog_service.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/services/stoppable_service.dart';
import 'package:paycool/services/vault_service.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  String? errorMessage;
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
    errorMessage = null;
    setBusy(true);
    log.i('model busy $busy');
    await showPasswordDilaog().then((res) async {
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

// add import and create wallet functions

  Future<dynamic> showPasswordDilaog() async {
    errorMessage = null;
    notifyListeners();
    return await dialogService.showDialog(
        title: FlutterI18n.translate(context!, "enterPassword"),
        description: FlutterI18n.translate(
            context!, "dialogManagerTypeSamePasswordNote"),
        buttonTitle: FlutterI18n.translate(context!, "confirm"));
  }

  Future displayMnemonic() async {
    errorMessage = null;

    await showPasswordDilaog().then((res) async {
      if (res!.confirmed) {
        showMnemonicDialog(res.returnedText);
      } else if (res.returnedText == 'Closed') {
        errorMessage = null;
        notifyListeners();
      } else {
        errorMessage =
            FlutterI18n.translate(context!, "pleaseProvideTheCorrectPassword");
        notifyListeners();
      }
    }).catchError((error) {
      errorMessage = error.toString();
      notifyListeners();
    });
  }

  showMnemonicDialog(String? mnemonic) {
    List<String> resultList = mnemonic!.split(' ');
    showDialog(
        context: context!,
        builder: (BuildContext context) {
          Size size = MediaQuery.of(context).size;
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            insetPadding: EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: size.height * 0.5,
              width: size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    FlutterI18n.translate(context, "mnemonic"),
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: black),
                  ),
                  UIHelper.verticalSpaceMedium,
                  Expanded(
                    child: GridView.builder(
                        itemCount: resultList.length,
                        itemBuilder: (context, index) {
                          return getContainer(index + 1, resultList[index]);
                        },
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 4 / 2)),
                  ),
                  SizedBox(
                    width: size.width,
                    child: Text(
                      FlutterI18n.translate(context, "pleaseEnsure"),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: black,
                      ),
                    ),
                  ),
                  UIHelper.verticalSpaceMedium,
                  Container(
                      height: 50,
                      width: size.width * 0.4,
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: buttonPurple,
                        ),
                        child: Text(
                          FlutterI18n.translate(context, "close"),
                        ),
                      )),
                ],
              ),
            ),
          );
        });
  }

  getContainer(int index, String word) {
    return Container(
      decoration: BoxDecoration(
        color: bgGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            index.toString(),
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black54),
          ),
          Text(
            word,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black54),
          ),
          SizedBox()
        ],
      ),
    );
  }
}
