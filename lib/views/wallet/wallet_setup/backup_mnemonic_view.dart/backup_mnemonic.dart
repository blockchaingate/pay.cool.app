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
    Size size = MediaQuery.of(context).size;
    return ViewModelBuilder<BackupMnemonicViewModel>.reactive(
        createNewViewModelOnInsert: true,
        viewModelBuilder: () => BackupMnemonicViewModel(),
        onViewModelReady: (model) async {
          model.init();
        },
        builder: (context, BackupMnemonicViewModel model, child) {
          return PopScope(
            canPop: false,
            onPopInvoked: (x) async {
              model.onBackButtonPressed();
            },
            child: Scaffold(
              backgroundColor: bgGrey,
              appBar: customAppBarWithIcon(
                title: FlutterI18n.translate(context, "backupMnemonic"),
                leading: IconButton(
                  onPressed: () => model.onBackButtonPressed(),
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
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
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text(
                                        FlutterI18n.translate(context,
                                            "backupMnemonicNoticeTitle"),
                                        style: headText3,
                                      )),
                                  const SizedBox(height: 20),
                                  Container(
                                      padding: const EdgeInsets.all(5.0),
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
                height: size.height,
                width: size.width,
                padding: const EdgeInsets.all(10),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      UIHelper.verticalSpaceMedium,
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          "Please copy the following mnemonics in order",
                          style: TextStyle(
                              fontSize: 14,
                              color: black,
                              fontWeight: FontWeight.w500),
                        ),
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
                            return TextField(
                              textAlign: TextAlign.center,
                              textAlignVertical:
                                  const TextAlignVertical(y: 0.7),
                              readOnly: true,
                              decoration: InputDecoration(
                                fillColor: secondaryColor,
                                filled: true,
                                hintText: sw,
                                hintMaxLines: 1,
                                prefixText: (i + 1).toString(),
                                prefixStyle: const TextStyle(
                                    color: black,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12),
                                hintStyle: const TextStyle(
                                    color: black,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(10.0)),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      Container(
                        width: size.width * 0.9,
                        margin: const EdgeInsets.all(5),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        decoration: BoxDecoration(
                            color: bgLightRed,
                            borderRadius: BorderRadius.circular(30)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info,
                              color: Colors.red[100],
                              size: 25,
                            ),
                            UIHelper.horizontalSpaceSmall,
                            Text(
                              FlutterI18n.translate(context, "important"),
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 1,
                                  fontSize: 14),
                            )
                          ],
                        ),
                      ),
                      ListTile(
                        horizontalTitleGap: 0,
                        leading: Container(
                          width: 4.0,
                          height: 4.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black, // Change color as needed
                          ),
                        ),
                        title: Text(
                          FlutterI18n.translate(
                              context, "warningBackupMnemonic"),
                          style: TextStyle(
                              fontSize: 14,
                              color: black,
                              wordSpacing: 2,
                              height: 1.7,
                              fontWeight: FontWeight.w300),
                        ),
                      ),
                      UIHelper.verticalSpaceSmall,
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: size.width * 0.9,
                          height: 50,
                          margin: EdgeInsets.only(bottom: 50),
                          child: ElevatedButton(
                            onPressed: () {
                              model.navigationService.navigateTo(
                                  ConfirmMnemonicViewRoute,
                                  arguments: model.randomMnemonicList);
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: buttonPurple,
                            ),
                            child: Text(
                              FlutterI18n.translate(
                                  context, "I'm done backing up"),
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
