import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:paycool/models/bond/rm/register_email_model.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/api_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/utils/string_validator.dart';
import 'package:paycool/views/bond/helper.dart';
import 'package:paycool/views/bond/register/verification_code_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class BondRegisterViewModel extends BaseViewModel {
  BondRegisterViewModel({BuildContext? context});
  BuildContext? context;
  ApiService apiService = locator<ApiService>();

  SharedService sharedService = locator<SharedService>();

  final NavigationService navigationService = locator<NavigationService>();

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String? deviceId;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController repeatPasswordController = TextEditingController();
  TextEditingController referralController = TextEditingController();
  bool isReferral = false;

  bool checkBoxValue = false;

/*----------------------------------------------------------------------
                    INIT
----------------------------------------------------------------------*/

  init() async {
    getDeviceId();
  }

  getDeviceId() async {
    if (Platform.isAndroid) {
      var androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id;
    } else if (Platform.isIOS) {
      var iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor;
    }
  }

  Future<void> startRegister() async {
    if (emailController.text.isEmpty || !validateEmail(emailController.text)) {
      callSMessage(context!, 'Please enter valid email', duration: 3);
    } else if (passwordController.text.isEmpty ||
        repeatPasswordController.text.isEmpty ||
        !validatePassword(passwordController.text)) {
      callSMessage(context!,
          "Enter password which is minimum 8 characters long and contains at least 1 uppercase, lowercase, number and a special character (e.g. (@#\$*~'%^()-_))",
          duration: 3);
    } else if (passwordController.text != repeatPasswordController.text) {
      callSMessage(context!, "Password and repeat password must be same",
          duration: 3);
    } else if (checkBoxValue == false) {
      callSMessage(context!, "Please accept terms and conditions", duration: 3);
    } else {
      var param = RegisterEmailModel(
          deviceId: deviceId,
          pidReferralCode: referralController.text,
          email: emailController.text,
          password: passwordController.text);

      Navigator.push(
          context!,
          MaterialPageRoute(
              builder: (context) => VerificationCodeView(
                    data: param,
                  )));
    }
    setBusy(false);
  }
}
