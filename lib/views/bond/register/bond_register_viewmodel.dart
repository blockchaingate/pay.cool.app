import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:paycool/models/bond/rm/register_email_model.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/api_service.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/utils/string_validator.dart';
import 'package:paycool/views/bond/register/verification_code_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class BondRegisterViewModel extends BaseViewModel {
  BondRegisterViewModel({BuildContext? context}) : _context = context;
  final BuildContext? _context;
  ApiService apiService = locator<ApiService>();

  SharedService sharedService = locator<SharedService>();
  final storageService = locator<LocalStorageService>();
  final NavigationService navigationService = locator<NavigationService>();

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String? deviceId;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController referralController = TextEditingController();
  bool isReferral = false;

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

  void startRegister() async {
    if (emailController.text.isEmpty || !validateEmail(emailController.text)) {
      var snackBar = SnackBar(content: Text('Please enter valid email'));
      ScaffoldMessenger.of(_context!).showSnackBar(snackBar);
    } else if (passwordController.text.isEmpty ||
        !validatePassword(passwordController.text)) {
      var snackBar = SnackBar(
          content: Text(
              "Enter password which is minimum 8 characters long and contains at least 1 uppercase, lowercase, number and a special character (e.g. (@#\$*~'%^()-_))"));
      ScaffoldMessenger.of(_context!).showSnackBar(snackBar);
    } else {
      var param = RegisterEmailModel(
          // deviceId: deviceId,
          pidReferralCode: referralController.text,
          email: emailController.text,
          password: passwordController.text);

      await apiService.registerWithEmail(_context!, param).then((value) async {
        if (value != null) {
          storageService.bondToken = value.token!;

          Navigator.push(
              _context!,
              MaterialPageRoute(
                  builder: (context) => VerificationCodeView(
                        data: value,
                      )));
        }
      });
    }
  }
}
