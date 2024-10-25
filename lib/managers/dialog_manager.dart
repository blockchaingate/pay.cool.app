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
import 'package:overlay_support/overlay_support.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:stacked_services/stacked_services.dart' show NavigationService;

import '../constants/colors.dart';
import '../constants/custom_styles.dart';
import '../logger.dart';
import '../models/dialog/dialog_request.dart';
import '../models/dialog/dialog_response.dart';
import '../service_locator.dart';
import '../services/db/core_wallet_database_service.dart';
import '../services/local_dialog_service.dart';
import '../services/vault_service.dart';

class DialogManager extends StatefulWidget {
  final Widget child;
  const DialogManager({Key? key, required this.child}) : super(key: key);

  @override
  _DialogManagerState createState() => _DialogManagerState();
}

class _DialogManagerState extends State<DialogManager> {
  final log = getLogger('DialogManager');
  final _dialogService = locator<LocalDialogService>();
  final _vaultService = locator<VaultService>();
  final navigationService = locator<NavigationService>();
  TextEditingController controller = TextEditingController();
  bool hidePassword = true;

  @override
  void initState() {
    super.initState();
    _dialogService.registerDialogListener(_showDialog);
    _dialogService.registerBasicDialogListener(_showBasicDialog);
    _dialogService.registerVerifyDialogListener(_showVerifyDialog);
    controller.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void showBasicSnackbar(DialogRequest request) {
    showSimpleNotification(
      Center(child: Text(request.title, style: headText6)),
    );
  }

  void _showVerifyDialog(
    DialogRequest request,
    // {bool isSecondaryChoice = false}
  ) {
    Alert(
        style: AlertStyle(
            animationType: AnimationType.grow,
            isOverlayTapDismiss: false,
            alertAlignment: Alignment.center,
            backgroundColor: secondaryColor,
            descStyle: headText4,
            titleStyle: headText3.copyWith(fontWeight: FontWeight.bold)),
        context: context,
        title: request.title,
        desc: request.description,
        closeFunction: () {
          FocusScope.of(context).requestFocus(FocusNode());
          _dialogService.dialogComplete(
              DialogResponse(returnedText: 'Closed', confirmed: false));
          controller.text = '';

          Navigator.of(context).pop();
        },
        // content: Column(
        //   children: <Widget>[
        //     Text(request.description)

        //   ],
        // ),
        buttons: [
          if (request.secondaryButton!.isNotEmpty)
            DialogButton(
              color: red,
              onPressed: () {
                _dialogService.dialogComplete(
                    DialogResponse(returnedText: '', confirmed: false));

                Navigator.of(context).pop();
              },
              child: Text(
                request.secondaryButton!,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          DialogButton(
            color: primaryColor,
            onPressed: () {
              _dialogService.dialogComplete(
                  DialogResponse(returnedText: '', confirmed: true));

              Navigator.of(context).pop();
            },
            child: Text(
              request.buttonTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          )
        ]).show();
  }

  void _showBasicDialog(DialogRequest request) {
    Alert(
        style: AlertStyle(
            animationType: AnimationType.grow,
            isOverlayTapDismiss: false,
            backgroundColor: secondaryColor,
            alertAlignment: Alignment.center,
            descStyle: headText6,
            titleStyle: headText3.copyWith(fontWeight: FontWeight.bold)),
        context: context,
        title: request.title,
        desc: request.description,
        closeFunction: () {
          FocusScope.of(context).requestFocus(FocusNode());
          Navigator.of(context).pop();
          _dialogService.dialogComplete(
              DialogResponse(returnedText: 'Closed', confirmed: false));
        },
        buttons: [
          DialogButton(
            color: primaryColor,
            onPressed: () {
              _dialogService.dialogComplete(
                  DialogResponse(returnedText: '', confirmed: true));
              Navigator.of(context).pop();
            },
            child: Text(
              request.buttonTitle,
              style: buttonText,
            ),
          )
        ]).show();
  }

  void _showDialog(DialogRequest request) {
    Alert(
        context: context,
        style: AlertStyle(
            alertElevation: 6,
            alertAlignment: Alignment.center,
            animationType: AnimationType.fromTop,
            animationDuration: const Duration(milliseconds: 300),
            isOverlayTapDismiss: false,
            backgroundColor: secondaryColor,
            descStyle: headText6,
            titleStyle: headText4.copyWith(fontWeight: FontWeight.bold)),
        title: request.title,
        desc: request.description,
        closeFunction: () {
          Navigator.of(context).pop();
          controller.text = '';
          FocusScope.of(context).requestFocus(FocusNode());
          _dialogService.dialogComplete(
              DialogResponse(returnedText: 'Closed', confirmed: false));
          controller.text = '';
          debugPrint('popping');
          //if (!Platform.isIOS)
          debugPrint('popped');
        },
        content: StatefulBuilder(
          builder: (context, setState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  UIHelper.verticalSpaceSmall,
                  TextField(
                    autofocus: true,
                    style: const TextStyle(color: black),
                    controller: controller,
                    obscureText: hidePassword,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: !hidePassword
                            ? Icon(Icons.remove_red_eye, color: primaryColor)
                            : Icon(Icons.remove_red_eye_outlined,
                                color: primaryColor),
                        onPressed: () {
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        },
                      ),
                      labelStyle: headText6,
                      focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: primaryColor)),
                      enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: grey)),
                      icon: const Icon(
                        Icons.security,
                        color: primaryColor,
                      ),
                      labelText: FlutterI18n.translate(
                          context, "typeYourWalletPassword"),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        buttons: [
          DialogButton(
            color: grey,
            onPressed: () {
              Navigator.of(context).pop();
              controller.text = '';
              _dialogService.dialogComplete(
                  DialogResponse(returnedText: 'Closed', confirmed: false));
            },
            child: Text(
              FlutterI18n.translate(context, "cancel"),
              style: headText4.copyWith(color: Colors.black),
            ),
          ),
          DialogButton(
            color: primaryColor,
            onPressed: () async {
              if (controller.text != '') {
                FocusScope.of(context).requestFocus(FocusNode());

                String encryptedMnemonic = '';
                var finalRes = '';
                try {
                  var coreWalletDatabaseService =
                      locator<CoreWalletDatabaseService>();
                  // todo: just check using new format first
                  // todo:  then check with old format if new format decryption is not available

                  encryptedMnemonic =
                      await coreWalletDatabaseService.getEncryptedMnemonic();
                  // try {
                  //   encryptedMnemonic ??= '';
                  // } catch (err) {
                  //   log.e(
                  //       'failed to assign empty string to null encrypted mnemonic variable');
                  // }
                  if (encryptedMnemonic.isEmpty) {
                    // if there is no encrypted mnemonic saved in the new core wallet db
                    // then get the unencrypted mnemonic from the file

                    finalRes =
                        await _vaultService.readEncryptedData(controller.text);
                  } else if (encryptedMnemonic.isNotEmpty) {
                    await _vaultService
                        .decryptData(controller.text, encryptedMnemonic)
                        .then((data) {
                      finalRes = data;
                    });
                  }
                  if (finalRes != '') {
                    // if biometric payment call then encrypt password with device id
                    // then store that in local storage
                    if (request.isBiometricPayment!) {
                      LocalStorageService localStorageService =
                          locator<LocalStorageService>();
                      var encryptedBiometricAuthData =
                          _vaultService.encryptData(
                              localStorageService.deviceId, controller.text);
                      localStorageService.biometricAuthData =
                          encryptedBiometricAuthData;
                      log.i(
                          ' localStorageService.biometricAuthData ${localStorageService.biometricAuthData}');
                    }
                    Navigator.of(context).pop();
                    controller.text = '';
                    _dialogService.dialogComplete(DialogResponse(
                      returnedText: finalRes,
                      confirmed: true,
                    ));
                  } else {
                    Navigator.of(context).pop();
                    controller.text = '';
                    _dialogService.dialogComplete(DialogResponse(
                      confirmed: false,
                      returnedText: 'wrong password',
                    ));
                  }
                } catch (err) {
                  log.e('Getting mnemonic failed -- $err');
                }
              }
            },
            child: Text(
              request.buttonTitle,
              style: headText4.copyWith(color: white),
            ),
          ),
        ]).show();
  }
}
