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

import 'package:exchangily_ui/exchangily_ui.dart' show kTextField;
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/views/wallet/wallet_setup/create_password/create_password_viewmodel.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:stacked/stacked.dart';

class CreatePasswordView extends StatelessWidget {
  final dynamic args;
  const CreatePasswordView({Key? key, this.args}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ViewModelBuilder<CreatePasswordViewModel>.reactive(
      viewModelBuilder: () => CreatePasswordViewModel(),
      onViewModelReady: (model) {
        model.randomMnemonicFromRoute = args['mnemonic'];
        model.context = context;

        model.passwordMatch = false;
      },
      builder: (context, CreatePasswordViewModel model, child) => Scaffold(
        appBar: customAppBarWithIcon(
          title: FlutterI18n.translate(context, "setPassword"),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 20,
            ),
          ),
        ),
        body: Container(
            padding: const EdgeInsets.all(15),
            child: ListView(
              scrollDirection: Axis.vertical,
              children: <Widget>[
                UIHelper.verticalSpaceSmall,
                Column(
                  children: <Widget>[
                    Text(
                      FlutterI18n.translate(context, "setPasswordConditions"),
                      style: TextStyle(
                          fontSize: 14,
                          color: black,
                          fontWeight: FontWeight.w500),
                      textAlign: TextAlign.left,
                    ),
                    UIHelper.verticalSpaceLarge,
                    kTextField(
                      controller: model.walletNameController,
                      labelText: FlutterI18n.translate(context, "walletName"),
                      hintText: FlutterI18n.translate(context, "walletName"),
                    ),
                    UIHelper.verticalSpaceSmall,
                    TextField(
                        onChanged: (String pass) {
                          model.checkPassword(pass);
                        },
                        keyboardType: TextInputType.visiblePassword,
                        focusNode: model.passFocus,
                        autofocus: true,
                        controller: model.passTextController,
                        obscureText: true,
                        maxLength: 16,
                        style: model.checkPasswordConditions
                            ? const TextStyle(color: primaryColor, fontSize: 16)
                            : const TextStyle(color: grey, fontSize: 16),
                        decoration: InputDecoration(
                            suffixIcon: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Visibility(
                                  visible: model.checkPasswordConditions &&
                                      model.password.isNotEmpty,
                                  child: const Padding(
                                      padding: EdgeInsets.only(right: 10),
                                      child: Icon(Icons.check, color: green)),
                                )
                              ],
                            ),
                            labelText:
                                FlutterI18n.translate(context, "enterPassword"),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: primaryColor, width: 1.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: bgGrey),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            prefixIcon:
                                const Icon(Icons.lock_outline, color: grey),
                            labelStyle: headText5,
                            helperStyle: headText5)),
                    UIHelper.verticalSpaceSmall,
                    TextField(
                        onChanged: (String pass) {
                          model.checkConfirmPassword(pass);
                        },
                        controller: model.confirmPassTextController,
                        obscureText: true,
                        maxLength: 16,
                        style: model.checkConfirmPasswordConditions
                            ? const TextStyle(color: primaryColor, fontSize: 16)
                            : const TextStyle(color: grey, fontSize: 16),
                        decoration: InputDecoration(
                            suffixIcon: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Visibility(
                                    visible:
                                        model.checkConfirmPasswordConditions &&
                                            model.confirmPassword.isNotEmpty,
                                    child: const Padding(
                                        padding: EdgeInsets.only(right: 10),
                                        child: Icon(Icons.check, color: green)))
                              ],
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: primaryColor, width: 1.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: bgGrey),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            labelText: FlutterI18n.translate(
                                context, "confirmPassword"),
                            prefixIcon: const Icon(Icons.lock, color: grey),
                            labelStyle: headText5,
                            helperStyle: headText5)),
                    model.password != ''
                        ? model.passwordMatch
                            ? Center(
                                child: Text(
                                FlutterI18n.translate(
                                    context, "passwordMatched"),
                                style: const TextStyle(color: grey),
                              ))
                            : model.password.isEmpty ||
                                    model.confirmPassword.isEmpty
                                ? const Text('')
                                : Center(
                                    child: Text(
                                        FlutterI18n.translate(
                                            context, "passwordDoesNotMatched"),
                                        style: const TextStyle(color: grey)))
                        : const Text(''),
                    UIHelper.verticalSpaceSmall,
                    model.isError
                        ? Center(
                            child: Text(
                                FlutterI18n.translate(
                                    context, "somethingWentWrong"),
                                style: headText5.copyWith(color: red)))
                        : Container(),
                    UIHelper.verticalSpaceLarge,
                    Container(
                      width: size.width * 0.9,
                      height: 50,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: ElevatedButton(
                        onPressed: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          model.validatePassword();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: buttonPurple,
                        ),
                        child: model.isCreatingWallet && model.isBusy
                            ? Shimmer.fromColors(
                                baseColor: primaryColor,
                                highlightColor: grey,
                                child: Text(
                                  args['isImport']
                                      ? FlutterI18n.translate(
                                          context, "importingWallet")
                                      : FlutterI18n.translate(
                                          context, "creatingWallet"),
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                              )
                            : Text(
                                args['isImport']
                                    ? FlutterI18n.translate(
                                        context, "importWallet")
                                    : FlutterI18n.translate(
                                        context, "createWallet"),
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                    UIHelper.verticalSpaceSmall,
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        FlutterI18n.translate(context, "createPasswordNote"),
                        textAlign: TextAlign.left,
                        style: headText5.copyWith(
                            fontWeight: FontWeight.w600, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            )),
      ),
    );
  }
}
