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
  const CreatePasswordView({Key? key, this.args}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CreatePasswordViewModel>.reactive(
      viewModelBuilder: () => CreatePasswordViewModel(),
      onViewModelReady: (model) {
        model.randomMnemonicFromRoute = args['mnemonic'];
        model.context = context;

        model.passwordMatch = false;
      },
      builder: (context, CreatePasswordViewModel model, child) => Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black),
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
                      style: headText6,
                      textAlign: TextAlign.left,
                    ),
                    UIHelper.verticalSpaceLarge,
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
                                Visibility(
                                  visible: model.checkPasswordConditions &&
                                      model.password.isNotEmpty,
                                  child: const Padding(
                                      padding: EdgeInsets.only(right: 10),
                                      child: Icon(Icons.check, color: green)),
                                )
                                // model.checkPasswordConditions &&
                                //         model.password.isNotEmpty
                                //     ? const Padding(
                                //         padding: EdgeInsets.only(right: 0),
                                //         child: Icon(Icons.check,
                                //             color: primaryColor))
                                //     : const Padding(
                                //         padding: EdgeInsets.only(right: 0),
                                //         child: Icon(Icons.clear, color: grey)),
                              ],
                            ),
                            labelText:
                                FlutterI18n.translate(context, "enterPassword"),
                            focusedBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: primaryColor, width: 1.5),
                            ),
                            prefixIcon:
                                const Icon(Icons.lock_outline, color: grey),
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

                    Center(
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
                            : ButtonTheme(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                minWidth: double.infinity,
                                child: MaterialButton(
                                  elevation: 20,
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
                                    style: headText4.copyWith(color: white),
                                  ),
                                ),
                              )),
                    UIHelper.verticalSpaceSmall,
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        FlutterI18n.translate(context, "createPasswordNote"),
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
