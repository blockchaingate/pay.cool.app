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
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/views/wallet/wallet_setup/create_password/create_password_viewmodel.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:stacked/stacked.dart';

class CreatePasswordView extends StatelessWidget {
  final args;
  const CreatePasswordView({Key key, this.args}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CreatePasswordViewModel>.reactive(
      viewModelBuilder: () => CreatePasswordViewModel(),
      onModelReady: (model) {
        model.randomMnemonicFromRoute = args['mnemonic'];
        model.context = context;

        model.passwordMatch = false;
      },
      builder: (context, CreatePasswordViewModel model, child) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(FlutterI18n.translate(context, "secureYourWallet"),
              style: headText4),
          backgroundColor: secondaryColor,
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
                      style: Theme.of(context).textTheme.bodyText1,
                      textAlign: TextAlign.left,
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
                        // model.isShowPass ? true : false,
                        maxLength: 16,
                        style: model.checkPasswordConditions
                            ? const TextStyle(color: primaryColor, fontSize: 16)
                            : const TextStyle(color: grey, fontSize: 16),
                        decoration: InputDecoration(
                            suffixIcon: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // IconButton(
                                //     icon: Icon(
                                //       model.isShowPass
                                //           ? Icons.remove_red_eye
                                //           : Icons.remove_red_eye_outlined,
                                //       color: model.isShowPass
                                //           ? primaryColor
                                //           : grey,
                                //     ),
                                //     onPressed: () => model.toggelPassword()),
                                model.checkPasswordConditions &&
                                        model.password.isNotEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.only(right: 0),
                                        child: Icon(Icons.check,
                                            color: primaryColor))
                                    : const Padding(
                                        padding: EdgeInsets.only(right: 0),
                                        child: Icon(Icons.clear, color: grey)),
                              ],
                            ),
                            labelText:
                                FlutterI18n.translate(context, "enterPassword"),
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: Colors.white),
                            labelStyle: headText5,
                            helperStyle: headText5)),
                    //_buildPasswordTextField(model),
                    UIHelper.verticalSpaceSmall,
                    //  _buildConfirmPasswordTextField(model),
                    TextField(
                        onChanged: (String pass) {
                          model.checkConfirmPassword(pass);
                        },
                        controller: model.confirmPassTextController,
                        obscureText: true,
                        //model.isShowPass ? true : false,
                        maxLength: 16,
                        style: model.checkConfirmPasswordConditions
                            ? const TextStyle(color: primaryColor, fontSize: 16)
                            : const TextStyle(color: grey, fontSize: 16),
                        decoration: InputDecoration(
                            suffixIcon: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // IconButton(
                                //     icon: Icon(
                                //       model.isShowPass
                                //           ? Icons.remove_red_eye
                                //           : Icons.remove_red_eye_outlined,
                                //       color: model.isShowPass
                                //           ? primaryColor
                                //           : grey,
                                //     ),
                                //     onPressed: () => model.toggelPassword()),
                                model.checkConfirmPasswordConditions &&
                                        model.confirmPassword.isNotEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.only(right: 0),
                                        child: Icon(Icons.check,
                                            color: primaryColor))
                                    : const Padding(
                                        padding: EdgeInsets.only(right: 0),
                                        child: Icon(Icons.clear, color: grey)),
                              ],
                            ),
                            labelText: FlutterI18n.translate(
                                context, "confirmPassword"),
                            prefixIcon:
                                const Icon(Icons.lock, color: Colors.white),
                            labelStyle: headText5,
                            helperStyle: headText5)),
                    model.password != ''
                        ? model.passwordMatch
                            ? Center(
                                child: Text(
                                FlutterI18n.translate(
                                    context, "passwordMatched"),
                                style: const TextStyle(color: white),
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

                    Center(
                        child: model.isBusy
                            ? Shimmer.fromColors(
                                baseColor: primaryColor,
                                highlightColor: grey,
                                child: Text(
                                  args['isImport']
                                      ? FlutterI18n.translate(
                                          context, "importingWallet")
                                      : FlutterI18n.translate(
                                          context, "creatingWallet"),
                                  style: Theme.of(context).textTheme.button,
                                ),
                              )
                            : ButtonTheme(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                minWidth: double.infinity,
                                child: MaterialButton(
                                  padding: const EdgeInsets.all(15),
                                  color: primaryColor,
                                  textColor: Colors.white,
                                  onPressed: () {
                                    // Remove the on screen keyboard by shifting focus to unused focus node

                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                    model.validatePassword();
                                  },
                                  child: Text(
                                    args['isImport']
                                        ? FlutterI18n.translate(
                                            context, "importWallet")
                                        : FlutterI18n.translate(
                                            context, "createWallet"),
                                    style: headText4,
                                  ),
                                ),
                              )),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        FlutterI18n.translate(context, "setPasswordNote"),
                        textAlign: TextAlign.left,
                        style: headText5.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            )),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        // floatingActionButton: Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: Text(
        //     FlutterI18n.translate(context, "setPasswordNote"),
        //     textAlign: TextAlign.left,
        //     style: headText5
        //         .copyWith(fontWeight: FontWeight.bold),
        //   ),
        // ),
      ),
    );
  }
}
