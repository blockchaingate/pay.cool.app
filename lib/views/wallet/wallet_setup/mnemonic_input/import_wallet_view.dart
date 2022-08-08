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
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/wallet/wallet_setup/confirm_mnemonic/confirm_mnemonic_viewmodel.dart';
import 'package:stacked/stacked.dart';

import '../confirm_mnemonic/verify_mnemonic.dart';

class ImportWalletView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ConfirmMnemonicViewModel>.reactive(
      viewModelBuilder: () => ConfirmMnemonicViewModel(),
      onModelReady: (model) {
        model.route = 'import';
      },
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            centerTitle: true,
            title: Text(
              FlutterI18n.translate(context, "importWallet"),
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            backgroundColor: secondaryColor),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(10),
          child: ListView(
            children: <Widget>[
              UIHelper.verticalSpaceMedium,
              Center(
                child: VerifyMnemonicWalletView(
                  mnemonicTextController: model.importMnemonicController,
                  count: model.count,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(15),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(primaryColor),
                    elevation: MaterialStateProperty.all(5),
                    shape: MaterialStateProperty.all(const StadiumBorder(
                        side: BorderSide(color: primaryColor, width: 2))),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      FlutterI18n.translate(context, "confirm"),
                      style: Theme.of(context).textTheme.button,
                    ),
                  ),
                  onPressed: () {
                    model.verifyMnemonic(model.importMnemonicController,
                        context, model.count, model.route);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
