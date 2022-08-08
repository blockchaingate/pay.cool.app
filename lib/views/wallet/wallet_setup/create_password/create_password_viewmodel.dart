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
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/services/navigation_service.dart';
import 'package:paycool/services/vault_service.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/utils/string_validator.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class CreatePasswordViewModel extends BaseViewModel {
  final log = getLogger('CreatePasswordViewModel');

  final WalletService _walletService = locator<WalletService>();
  final VaultService _vaultService = locator<VaultService>();
  final NavigationService navigationService = locator<NavigationService>();

  final storageService = locator<LocalStorageService>();
  bool checkPasswordConditions = false;
  bool passwordMatch = false;
  bool checkConfirmPasswordConditions = false;
  String randomMnemonicFromRoute = '';
  BuildContext context;
  String password = '';
  String confirmPassword = '';
  bool isError = false;
  Pattern pattern =
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[`~!@#\$%\^&*\(\)-_\+\=\{\[\}\]]).{8,}$';

  FocusNode passFocus = FocusNode();
  TextEditingController passTextController = TextEditingController();
  TextEditingController confirmPassTextController = TextEditingController();
  WalletService walletService = locator<WalletService>();

  bool _isShowPass = false;
  get isShowPass => _isShowPass;

  toggelPassword() {
    setBusyForObject(isShowPass, true);
    _isShowPass = !_isShowPass;
    setBusyForObject(isShowPass, false);
  }

/* ---------------------------------------------------
                    Create Offline Wallets
    -------------------------------------------------- */

  Future createOfflineWallets() async {
    setBusy(true);

    await _walletService
        .createOfflineWalletsV1(
            randomMnemonicFromRoute, passTextController.text)
        .then((data) {
      //  _walletInfo = data;
      // Navigator.pushNamed(context, '/mainNav', arguments: _walletInfo);
      //  navigationService.navigateTo('/mainNav', arguments: 0);

      // navigationService.navigateUsingPushNamedAndRemoveUntil(
      //     PayCoolClubDashboardViewRoute);

      navigationService.navigateUsingPushNamedAndRemoveUntil(PayCoolViewRoute);
      storageService.showPaycoolClub = false;
      randomMnemonicFromRoute = '';
      passTextController.text = '';
      confirmPassTextController.text = '';
    }).catchError((onError) {
      passwordMatch = false;
      password = '';
      confirmPassword = '';
      isError = true;
      log.e(onError);
      setBusy(false);
    });
    setBusy(false);
  }

/* ---------------------------------------------------
                      Validate Pass
    -------------------------------------------------- */
  bool checkPassword(String pass) {
    setBusy(true);
    password = pass;
    var res = RegexValidator(pattern).isValid(password);
    checkPasswordConditions = res;
    password == confirmPassword ? passwordMatch = true : passwordMatch = false;
    if (passwordMatch) isError = false;

    setBusy(false);
    return checkPasswordConditions;
  }

  bool checkConfirmPassword(String confirmPass) {
    setBusy(true);
    confirmPassword = confirmPass;
    var res = RegexValidator(pattern).isValid(confirmPass);
    checkConfirmPasswordConditions = res;
    password == confirmPass ? passwordMatch = true : passwordMatch = false;
    if (passwordMatch) isError = false;
    setBusy(false);
    return checkConfirmPasswordConditions;
  }

  Future validatePassword() async {
    setBusy(true);
    RegExp regex = RegExp(pattern);
    String pass = passTextController.text;
    String confirmPass = confirmPassTextController.text;
    if (pass.isEmpty) {
      password = '';
      confirmPassword = '';
      checkPasswordConditions = false;
      checkConfirmPasswordConditions = false;
      showSimpleNotification(
          Text(FlutterI18n.translate(context, "emptyPassword"),
              style: headText4.copyWith(color: red)),
          position: NotificationPosition.bottom,
          subtitle: Text(
              FlutterI18n.translate(context, "pleaseFillBothPasswordFields")));

      setBusy(false);
      return;
    } else {
      if (!regex.hasMatch(pass)) {
        showSimpleNotification(
            Text(FlutterI18n.translate(context, "passwordConditionsMismatch"),
                style: headText4.copyWith(color: red)),
            position: NotificationPosition.bottom,
            subtitle:
                Text(FlutterI18n.translate(context, "passwordConditions")));

        setBusy(false);
        return;
      } else if (pass != confirmPass) {
        showSimpleNotification(
            Text(FlutterI18n.translate(context, "passwordConditionsMismatch"),
                style: headText4.copyWith(color: red)),
            position: NotificationPosition.bottom,
            subtitle: Text(FlutterI18n.translate(context, "passwordRetype")));

        setBusy(false);
        return;
      } else {
        setBusy(true);
        await createOfflineWallets();
        passTextController.text = '';
        confirmPassTextController.text = '';
      }
    }
    setBusy(false);
  }
}
