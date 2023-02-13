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
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/shared/ui_helpers.dart';

import 'package:paycool/views/wallet/wallet_setup/backup_mnemonic_view.dart/backup_mnemonic_viewmodel.dart';
import 'package:stacked/stacked.dart';

class BackupMnemonicWalletView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<BackupMnemonicViewModel>.reactive(
        createNewViewModelOnInsert: true,
        viewModelBuilder: () => BackupMnemonicViewModel(),
        onViewModelReady: (model) async {
          //   model.context = context;
          model.init();
        },
        builder: (context, BackupMnemonicViewModel model, child) {
          return WillPopScope(
            onWillPop: () {
              model.onBackButtonPressed();
              return Future(() => false);
            },
            child: Scaffold(
              appBar: AppBar(
                iconTheme: const IconThemeData(color: Colors.black),
                leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => model.onBackButtonPressed()),
                centerTitle: true,
                elevation: 0,
                title: Text(FlutterI18n.translate(context, "backupMnemonic"),
                    style: headText3),
                backgroundColor: secondaryColor,
                actions: <Widget>[
                  // action button
                  IconButton(
                      icon: const Icon(
                        Icons.help,
                        size: 18,
                        color: primaryColor,
                      ),
                      onPressed: () {
                        showModalBottomSheet<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return ListView(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 32.0, horizontal: 20),
                                children: [
                                  Container(
                                      padding: EdgeInsets.all(5.0),
                                      child: Text(
                                        FlutterI18n.translate(context,
                                            "backupMnemonicNoticeTitle"),
                                        // textAlign: TextAlign.center,
                                        style: headText3,
                                      )),
                                  const SizedBox(height: 20),
                                  Container(
                                      padding: EdgeInsets.all(5.0),
                                      // padding: EdgeInsets.symmetric(horizontal: 20),
                                      child: Text(
                                        FlutterI18n.translate(context,
                                            "backupMnemonicNoticeContent"),
                                        style: headText5,
                                      ))
                                ],
                              );
                            });
                      }),
                ],
              ),
              body: Container(
                padding: const EdgeInsets.all(10),
                child: ListView(
                  // mainAxisSize: MainAxisSize.min,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    UIHelper.verticalSpaceMedium,
                    Container(
                      margin: EdgeInsets.all(5),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      decoration: BoxDecoration(
                          color: sellPrice,
                          borderRadius: BorderRadius.circular(30)
                          // shape: BoxShape.circle
                          ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.info,
                            color: white,
                            size: 25,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            FlutterI18n.translate(context, "important"),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 1,
                                fontSize: 14),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 5),
                          child: Text(
                            FlutterI18n.translate(
                                context, "warningBackupMnemonic"),
                            style: headText4,
                          ),
                        )),
                      ],
                    ),

                    Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 5),
                      child: GridView.extent(
                        physics: const NeverScrollableScrollPhysics(),
                        maxCrossAxisExtent: 125,
                        padding: const EdgeInsets.all(2),
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 10,
                        shrinkWrap: true,
                        childAspectRatio: 2.2,
                        children: List.generate(model.count, (i) {
                          var sw = model.randomMnemonicList[i];
                          return Container(
                              child: TextField(
                            textAlign: TextAlign.center,
                            textAlignVertical: const TextAlignVertical(y: 0.7),
                            enableInteractiveSelection: false, // readonly
                            // enabled: false, // if false use cant see the selection border around
                            readOnly: true,
                            autocorrect: false,
                            decoration: InputDecoration(
                              // alignLabelWithHint: true,
                              fillColor: secondaryColor,
                              filled: true,
                              hintText: sw,
                              hintMaxLines: 1,
                              hintStyle: const TextStyle(
                                  color: black, fontWeight: FontWeight.w400),
                              focusedBorder: OutlineInputBorder(
                                  // borderSide: const BorderSide(
                                  //     color: primaryColor, width: 2),
                                  borderRadius: BorderRadius.circular(30.0)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                          ));
                        }),
                      ),
                    ),
                    // UIHelper.verticalSpaceSmall,
                    Container(
                      padding: const EdgeInsets.all(15),
                      child: ElevatedButton(
                        style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 18)),
                            elevation: MaterialStateProperty.all(10.0),
                            backgroundColor:
                                MaterialStateProperty.all(primaryColor),
                            shape: buttonRoundShape(primaryColor)),
                        child: Text(
                          FlutterI18n.translate(context, "confirm"),
                          style: Theme.of(context).textTheme.button,
                        ),
                        onPressed: () {
                          model.navigationService.navigateTo(
                              ConfirmMnemonicViewRoute,
                              arguments: model.randomMnemonicList);
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
