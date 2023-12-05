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
import 'package:stacked/stacked.dart';

class ConfirmMnemonicView extends StatelessWidget {
  final List<String> randomMnemonicListFromRoute;
  const ConfirmMnemonicView(
      {Key? key, required this.randomMnemonicListFromRoute})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
          backgroundColor: bgGrey,
          appBar: customAppBarWithIcon(
            title:
                '${FlutterI18n.translate(context, "confirm")} ${FlutterI18n.translate(context, "mnemonic")}',
            leading: IconButton(
              onPressed: () => model.onBackButtonPressed(),
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
          body: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                InkWell(
                  onTap: () {
                    model.selectConfirmMethod("tap");
                  },
                  child: Text(
                      FlutterI18n.translate(context, "verifyMnemonicByTap"),
                      style: headText5.copyWith(
                          fontWeight: model.isTap
                              ? FontWeight.bold
                              : FontWeight.normal)),
                ),
                UIHelper.verticalSpaceLarge,
                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                  child: GridView.extent(
                    maxCrossAxisExtent: 125,
                    padding: const EdgeInsets.all(2),
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 10,
                    shrinkWrap: true,
                    childAspectRatio: 2,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(
                      model.count,
                      (i) {
                        var singleWord = randomMnemonicListFromRoute[i];

                        return TextField(
                          onTap: () {
                            model.selectWordsInOrder(i, singleWord);
                          },
                          controller: model.tapTextControllerList[i],
                          textAlign: TextAlign.center,
                          textAlignVertical: const TextAlignVertical(y: 0.7),
                          enableInteractiveSelection: false, // readonly
                          // enabled: false, // if false use cant see the selection border around
                          readOnly: true,
                          autocorrect: false,
                          style: TextStyle(
                              fontSize: 14,
                              color: black,
                              fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            fillColor: model.regex.hasMatch(
                                    model.tapTextControllerList[i].text)
                                ? bgLightRed
                                : secondaryColor,
                            filled: true,
                            hintText: singleWord,
                            hintMaxLines: 1,
                            hintStyle: TextStyle(
                                fontSize: 14,
                                color: black,
                                fontWeight: FontWeight.w600),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(10.0)),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                UIHelper.verticalSpaceSmall,
                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                        style: ButtonStyle(
                          side: MaterialStateProperty.all(
                              const BorderSide(color: primaryColor)),
                        ),
                        onPressed: () {
                          model.clearTappedList();
                        },
                        child: Row(
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
                                style: headText3.copyWith(color: black)),
                          ],
                        )),
                  ),
                ),
                Expanded(child: SizedBox()),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: size.width * 0.9,
                    height: 50,
                    margin: EdgeInsets.only(bottom: 50),
                    child: ElevatedButton(
                      onPressed: () {
                        model.verifyMnemonic(
                            model.isTap
                                ? model.tappedMnemonicList
                                : model.controller,
                            context,
                            model.count,
                            'create');
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: buttonPurple,
                      ),
                      child: Text(
                        FlutterI18n.translate(context, "finishWalletCreation"),
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
  }
}
