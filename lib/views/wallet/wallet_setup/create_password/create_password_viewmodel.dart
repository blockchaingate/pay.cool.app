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
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/environments/environment_type.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/utils/string_validator.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class CreatePasswordViewModel extends BaseViewModel {
  final log = getLogger('CreatePasswordViewModel');

  final WalletService _walletService = locator<WalletService>();
  final NavigationService navigationService = locator<NavigationService>();

  final storageService = locator<LocalStorageService>();
  bool checkPasswordConditions = false;
  bool passwordMatch = false;
  bool checkConfirmPasswordConditions = false;
  String randomMnemonicFromRoute = '';
  late BuildContext context;
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
  bool isCreatingWallet = false;

  toggelPassword() {
    setBusyForObject(isShowPass, true);
    _isShowPass = !_isShowPass;
    setBusyForObject(isShowPass, false);
  }

/* ---------------------------------------------------
                    Create Offline Wallets
    -------------------------------------------------- */

  Future createOfflineWallets() async {
    isCreatingWallet = true;
    setBusy(true);

    await _walletService
        .createOfflineWalletsV1(
            randomMnemonicFromRoute, passTextController.text)
        .then((data) {
      navigationService.pushNamedAndRemoveUntil(DashboardViewRoute);
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
    isCreatingWallet = false;
    setBusy(false);
  }

/* ---------------------------------------------------
                      Validate Pass
    -------------------------------------------------- */
  bool checkPassword(String pass) {
    setBusy(true);
    password = pass;
    var res = RegexValidator(pattern.toString()).isValid(password);
    checkPasswordConditions = res;
    password == confirmPassword ? passwordMatch = true : passwordMatch = false;
    if (passwordMatch) isError = false;

    setBusy(false);
    return checkPasswordConditions;
  }

  bool checkConfirmPassword(String confirmPass) {
    setBusy(true);
    confirmPassword = confirmPass;
    var res = RegexValidator(pattern.toString()).isValid(confirmPass);
    checkConfirmPasswordConditions = res;
    password == confirmPass ? passwordMatch = true : passwordMatch = false;
    if (passwordMatch) isError = false;
    setBusy(false);
    return checkConfirmPasswordConditions;
  }

  Future validatePassword() async {
    RegExp regex = RegExp(pattern.toString());
    String pass = passTextController.text;
    String confirmPass = confirmPassTextController.text;
    if (pass.isEmpty) {
      setBusy(true);
      password = '';
      confirmPassword = '';
      checkPasswordConditions = false;
      checkConfirmPasswordConditions = false;

      showSimpleNotification(
          Text(FlutterI18n.translate(context, "emptyPassword"),
              style: headText4.copyWith(
                  fontWeight: FontWeight.bold, color: Colors.red)),
          position: NotificationPosition.bottom,
          background: bgLightRed,
          subtitle: Text(
              FlutterI18n.translate(context, "pleaseFillBothPasswordFields"),
              style: TextStyle(color: Colors.red)));

      if (!isProduction) {
        String? localEnv;
        try {
          localEnv = dotenv.env['PASSWORD'];
        } catch (err) {
          localEnv = null;
          log.e('dot env can not find local env password');
        }
        passTextController.text = localEnv ?? '';
        if (passTextController.text.isNotEmpty) {
          createOfflineWallets();
        }
      }

      setBusy(false);
      return;
    } else if (!regex.hasMatch(pass)) {
      showSimpleNotification(
        Text(FlutterI18n.translate(context, "passwordConditionsMismatch"),
            style: headText4.copyWith(
                fontWeight: FontWeight.bold, color: Colors.red)),
        position: NotificationPosition.bottom,
        background: bgLightRed,
        subtitle: Text(FlutterI18n.translate(context, "passwordConditions"),
            style: TextStyle(color: Colors.red)),
      );

      setBusy(false);
      return;
    } else if (pass != confirmPass) {
      showSimpleNotification(
          Text(FlutterI18n.translate(context, "passwordConditionsMismatch"),
              style: headText4.copyWith(
                  fontWeight: FontWeight.bold, color: Colors.red)),
          position: NotificationPosition.bottom,
          background: bgLightRed,
          subtitle: Text(FlutterI18n.translate(context, "passwordRetype"),
              style: TextStyle(color: Colors.red)));

      setBusy(false);
      return;
    } else {
      createOfflineWallets();
      passTextController.text = '';
      confirmPassTextController.text = '';
    }
  }
}
