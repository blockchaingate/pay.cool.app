import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/local_auth_service.dart';
import 'package:paycool/services/local_dialog_service.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:stacked_services/stacked_services.dart';

class PaymentBiometricAuthWidget {
  static storeDeviceId() async {
    final log = getLogger("PaymentBiometricAuth");
    final storageService = locator<LocalStorageService>();
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      var androidInfo = await deviceInfo.androidInfo;
      log.w("androidInfo $androidInfo");
      storageService.deviceId = androidInfo.id.toString();
    } else if (Platform.isIOS) {
      var iosInfo = await deviceInfo.iosInfo;
      log.w("iosInfo $iosInfo");
      storageService.deviceId = iosInfo.identifierForVendor.toString();
    }
  }

  static setupPaymentBiometricAuth(BuildContext context) async {
    final localDialogService = locator<LocalDialogService>();
    // final bottomSheetService = locator<BottomSheetService>();
    // final authService = locator<LocalAuthService>();
    final storageService = locator<LocalStorageService>();

    print('bottom sheet confirmed');
    var res = await localDialogService.showDialog(
      title: 'Enter Password',
      description: 'Test Dialog Description',
      buttonTitle: "Confirm",
    );

    if (res.confirmed) {
      storageService.biometricAuthData = res.returnedText;

      print("------------------------------------");
      print(res.confirmed);
      print(res.returnedText);
      // print('pass confirmed');
      // var isAuthenticate = await authService.authenticateApp(
      //   isBiometricOnly: false,
      //   isStickyAuth: true,
      //   isSensitiveTransaction: true,
      // );
      // if (isAuthenticate) {
      //   print('isAuthenticate true');
      //   String deviceId = storageService.deviceId;
      //   //  String data = vaultService.encryptMnemonic(pass, mnemonic);
      // }
    }
  }
}
