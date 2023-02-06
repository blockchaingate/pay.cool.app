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
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/wallet/wallet_setup/confirm_mnemonic/confirm_mnemonic_viewmodel.dart';
import 'package:paycool/views/wallet/wallet_setup/confirm_mnemonic/verify_mnemonic.dart';
import 'package:stacked/stacked.dart';

class ConfirmMnemonicView extends StatelessWidget {
  final List<String> randomMnemonicListFromRoute;
  const ConfirmMnemonicView(
      {Key? key, required this.randomMnemonicListFromRoute})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ConfirmMnemonicViewModel>.reactive(
      viewModelBuilder: () => ConfirmMnemonicViewModel(),
      onViewModelReady: (model) {
        model.init();
        model.randomMnemonicList.addAll(randomMnemonicListFromRoute);
        randomMnemonicListFromRoute.shuffle();
      },
      builder: (context, model, child) => WillPopScope(
        onWillPop: () async {
          model.onBackButtonPressed();
          return Future(() => false);
        },
        child: Scaffold(
          appBar: AppBar(
              iconTheme: const IconThemeData(color: Colors.black),
              centerTitle: true,
              title: Text(
                '${FlutterI18n.translate(context, "confirm")} ${FlutterI18n.translate(context, "mnemonic")}',
                style: headText3,
              ),
              backgroundColor: secondaryColor),
          body: Container(
            padding: const EdgeInsets.all(10),
            child: ListView(
              scrollDirection: Axis.vertical,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      style: ButtonStyle(
                        side: MaterialStateProperty.all(BorderSide(
                            color: model.isTap ? primaryColor : grey)),
                        backgroundColor:
                            MaterialStateProperty.all(secondaryColor),
                        elevation: MaterialStateProperty.all(10),
                        padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 15.0)),
                        // shape: MaterialStateProperty.all(const StadiumBorder(
                        //     side: BorderSide(color: primaryColor, width: 2))
                        //     ),
                      ),
                      child: Text(
                          FlutterI18n.translate(context, "verifyMnemonicByTap"),
                          style: headText5.copyWith(
                              fontWeight: model.isTap
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                      onPressed: () {
                        //    model.shuffleStringList();
                        model.selectConfirmMethod('tap');
                      },
                    ),
                    UIHelper.verticalSpaceSmall,
                    OutlinedButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 15.0)),
                        side: MaterialStateProperty.all(BorderSide(
                            color: !model.isTap ? primaryColor : grey)),
                        backgroundColor:
                            MaterialStateProperty.all(secondaryColor),
                        elevation: MaterialStateProperty.all(5),
                      ),
                      child: Text(
                          FlutterI18n.translate(
                              context, "verifyMnemonicByWrite"),
                          style: headText5.copyWith(
                              fontWeight: !model.isTap
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                      onPressed: () => model.selectConfirmMethod('write'),
                    ),
                  ],
                ),
                UIHelper.verticalSpaceSmall,
                UIHelper.divider,
                UIHelper.verticalSpaceSmall,
                !model.isTap
                    ? VerifyMnemonicWalletView(
                        mnemonicTextController: model.controller,
                        count: model.count,
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextButton(
                                  style: ButtonStyle(
                                    side: MaterialStateProperty.all(
                                        BorderSide(color: primaryColor)),
                                  ),
                                  onPressed: () {
                                    model.clearTappedList();
                                  },
                                  Widget: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(right: 2.0),
                                        child: Icon(
                                          Icons.restore_sharp,
                                          color: grey,
                                          size: 20,
                                        ),
                                      ),
                                      Text(
                                          FlutterI18n.translate(
                                              context, "resetSelection"),
                                          style:
                                              headText3.copyWith(color: black)),
                                    ],
                                  )),
                            ),
                          ),
                          UIHelper.verticalSpaceSmall,
                          Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 10),
                            padding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 5),
                            child: GridView.extent(
                                maxCrossAxisExtent: 125,
                                padding: const EdgeInsets.all(2),
                                mainAxisSpacing: 15,
                                crossAxisSpacing: 10,
                                shrinkWrap: true,
                                childAspectRatio: 2,
                                physics: const NeverScrollableScrollPhysics(),
                                children: List.generate(model.count, (i) {
                                  var singleWord =
                                      randomMnemonicListFromRoute[i];

                                  return TextField(
                                    onTap: () {
                                      model.selectWordsInOrder(i, singleWord);
                                    },
                                    controller: model.tapTextControllerList[i],
                                    textAlign: TextAlign.center,
                                    textAlignVertical:
                                        const TextAlignVertical(y: 0.7),
                                    enableInteractiveSelection:
                                        false, // readonly
                                    // enabled: false, // if false use cant see the selection border around
                                    readOnly: true,
                                    autocorrect: false,
                                    style: TextStyle(color: black),
                                    decoration: InputDecoration(
                                      // alignLabelWithHint: true,
                                      fillColor: model
                                              .tapTextControllerList[i].text
                                              .contains(')')
                                          ? grey.withAlpha(200)
                                          : secondaryColor,
                                      filled: true,
                                      hintText: singleWord,
                                      // label:  Text(singleWord),
                                      // labelStyle: headText5,
                                      hintMaxLines: 1,
                                      hintStyle: headText4,
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: black, width: 1),
                                          borderRadius:
                                              BorderRadius.circular(30.0)),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                    ),
                                  );
                                })),
                          ),
                          UIHelper.verticalSpaceMedium,
                        ],
                      ),
                UIHelper.verticalSpaceSmall,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 10)),
                      elevation: MaterialStateProperty.all(10.0),
                      backgroundColor: MaterialStateProperty.all(primaryColor),
                      shape: MaterialStateProperty.all(const StadiumBorder(
                          side: BorderSide(color: primaryColor, width: 2))),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        FlutterI18n.translate(context, "finishWalletBackup"),
                        style: Theme.of(context).textTheme.button,
                      ),
                    ),
                    onPressed: () {
                      // if (model.isTap) model.clearTappedList();
                      model.verifyMnemonic(
                          model.isTap
                              ? model.tappedMnemonicList
                              : model.controller,
                          context,
                          model.count,
                          'create');
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
