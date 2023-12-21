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
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/views/wallet/wallet_setup/confirm_mnemonic/confirm_mnemonic_viewmodel.dart';
import 'package:stacked/stacked.dart';

import '../confirm_mnemonic/verify_mnemonic.dart';

class ImportWalletView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ViewModelBuilder<ConfirmMnemonicViewModel>.reactive(
      viewModelBuilder: () => ConfirmMnemonicViewModel(),
      onViewModelReady: (model) {
        model.route = 'import';
      },
      builder: (context, model, child) => Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: bgGrey,
        appBar: customAppBarWithIcon(
          title: FlutterI18n.translate(context, "importWallet"),
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
          height: size.height,
          alignment: Alignment.center,
          padding: EdgeInsets.fromLTRB(10, 50, 10, 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  FlutterI18n.translate(context, "inputMnemonic"),
                  style: headText3.copyWith(color: black),
                  textAlign: TextAlign.start,
                ),
              ),
              Center(
                child: VerifyMnemonicWalletView(
                  mnemonicTextController: model.importMnemonicController,
                  count: model.count,
                ),
              ),
              Expanded(child: SizedBox()),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: size.width * 0.9,
                  height: 50,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      model.verifyMnemonic(model.importMnemonicController,
                          context, model.count, model.route);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: buttonPurple,
                    ),
                    child: Text(
                      FlutterI18n.translate(context, "next"),
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
