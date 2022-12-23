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
import 'package:paycool/environments/environment_type.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/wallet/wallet_setup/wallet_setup_viewmodel.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_svg/svg.dart';

class WalletSetupView extends StatelessWidget {
  const WalletSetupView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width >= 768.0;
    return ViewModelBuilder<WalletSetupViewmodel>.reactive(
      viewModelBuilder: () => WalletSetupViewmodel(),
      onModelReady: (WalletSetupViewmodel model) async {
        model.context = context;
        model.init();
      },
      builder: (context, WalletSetupViewmodel model, child) => WillPopScope(
        onWillPop: () async {
          model.onBackButtonPressed();
          return Future(() => false);
        },
        child: Scaffold(
          body: Stack(
            children: [
              Image.asset(
                "assets/images/tulum/background.jpg",
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.cover,
              ),
              Container(
                height: MediaQuery.of(context).size.height,
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
                // color: walletCardColor,
                decoration: const BoxDecoration(
                    color: isTulum ? Colors.transparent : secondaryColor,
                    image: isTulum
                        ? DecorationImage(
                            image:
                                AssetImage("assets/images/tulum/Plants2.png"),
                            fit: BoxFit.fitWidth,
                            alignment: Alignment.topCenter)
                        : null),
                child: Column(
                  //  mainAxisSize: MainAxisSize.min,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Logo Container
                    Container(
                      padding: const EdgeInsets.all(10),
                      // width: MediaQuery.of(context).size.width * 0.65,
                      // height: MediaQuery.of(context).size.width * 0.65,
                      // decoration: BoxDecoration(
                      //     color: Color(0xff030303),
                      //     borderRadius: BorderRadius.circular(30)),
                      child: Visibility(
                        visible: !isTulum,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              "assets/images/paycool/paycool-with-caption.svg",
                              color: primaryColor,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                                FlutterI18n.translate(
                                    context, "paycoolCaption"),
                                textAlign: TextAlign.center,
                                style: headText4.copyWith(
                                    fontWeight: FontWeight.w400, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible: isTulum,
                      child: Image.asset(
                        "assets/images/tulum/TC-Word.png",
                        width: 230,
                      ),
                      // Text(
                      //   "TULUM WALLET",
                      //   style: TextStyle(
                      //       color: tulumYellow,
                      //       fontSize: 30,
                      //       fontWeight: FontWeight.bold),
                      // )
                    ),
                    UIHelper.verticalSpaceMedium,
                    isTulum
                        ? Image.asset(
                            "assets/images/tulum/2DCoin.png",
                            width: 230,
                          )
                        : Image.asset("assets/images/paycool/Crypto5.png"),
                    UIHelper.verticalSpaceMedium,

                    model.isDeleting
                        ? Text(
                            FlutterI18n.translate(context, "deletingWallet"),
                            style: Theme.of(context).textTheme.bodyText1,
                          )
                        : Container(),
                    !model.isBusy && model.errorMessage.isNotEmpty
                        ? Text(
                            model.errorMessage,
                            style: Theme.of(context).textTheme.bodyText1,
                          )
                        : Container(),
                    // Button Container
                    model.isBusy
                        ? Shimmer.fromColors(
                            baseColor: primaryColor,
                            highlightColor: white,
                            child: Center(
                              child: Text(
                                '${FlutterI18n.translate(context, "checkingExistingWallet")}...',
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ),
                          )
                        : model.isWallet
                            ? Shimmer.fromColors(
                                baseColor: primaryColor,
                                highlightColor: white,
                                child: Center(
                                  child: Text(
                                    '${FlutterI18n.translate(context, "restoringWallet")}...',
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                ),
                              )
                            : Container(
                                child: Column(
                                  children: [
                                    !model.hasAuthenticated &&
                                            !model.isBusy &&
                                            model.storageService
                                                .hasInAppBiometricAuthEnabled &&
                                            model.storageService
                                                .hasPhoneProtectionEnabled
                                        ? ElevatedButton(
                                            style: ButtonStyle(
                                                shape:
                                                    MaterialStateProperty.all(
                                                  const StadiumBorder(
                                                      side: BorderSide(
                                                          color: Colors
                                                              .transparent,
                                                          width: 2)),
                                                ),
                                                elevation:
                                                    MaterialStateProperty.all(
                                                        5)),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Padding(
                                                  padding:
                                                      EdgeInsets.only(right: 4),
                                                  child: Icon(
                                                    Icons.lock_open_outlined,
                                                    color: white,
                                                    size: 18,
                                                  ),
                                                ),
                                                Text(
                                                    FlutterI18n.translate(
                                                        context, "unlock"),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline4),
                                              ],
                                            ),
                                            onPressed: () {
                                              model.checkExistingWallet();
                                            },
                                          )
                                        : Container(),
                                    !model.storageService
                                                .hasInAppBiometricAuthEnabled ||
                                            !model.storageService
                                                .hasPhoneProtectionEnabled
                                        ? model.storageService.hasPrivacyConsent
                                            ? Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              right: 5),
                                                      child: ElevatedButton(
                                                        style: ButtonStyle(
                                                          padding: MaterialStateProperty
                                                              .all(const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      15,
                                                                  vertical:
                                                                      15)),
                                                          elevation:
                                                              MaterialStateProperty
                                                                  .all(5),
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all(white),
                                                          shape:
                                                              MaterialStateProperty
                                                                  .all(
                                                            const StadiumBorder(
                                                                side: BorderSide(
                                                                    color:
                                                                        primaryColor,
                                                                    width: 1)),
                                                          ),
                                                        ),
                                                        child: Text(
                                                            FlutterI18n.translate(
                                                                context,
                                                                "createWallet"),
                                                            style: headText5
                                                                .copyWith(
                                                                    color:
                                                                        primaryColor)),
                                                        onPressed: () {
                                                          if (!model.isBusy) {
                                                            model
                                                                .importCreateNav(
                                                                    'create');
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: ElevatedButton(
                                                      style: ButtonStyle(
                                                          padding: MaterialStateProperty.all(
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      15,
                                                                  vertical:
                                                                      15)),
                                                          elevation:
                                                              MaterialStateProperty
                                                                  .all(5),
                                                          shape:
                                                              MaterialStateProperty
                                                                  .all(
                                                            const StadiumBorder(
                                                                side: BorderSide(
                                                                    color:
                                                                        primaryColor,
                                                                    width: 2)),
                                                          ),
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all(isTulum
                                                                      ? tulumYellow
                                                                      : primaryColor)),
                                                      child: Text(
                                                        FlutterI18n.translate(
                                                            context,
                                                            "importWallet"),
                                                        style:
                                                            headText5.copyWith(
                                                                color: isTulum
                                                                    ? tulumColor
                                                                    : white),
                                                      ),
                                                      onPressed: () {
                                                        if (!model.isBusy) {
                                                          model.importCreateNav(
                                                              'import');
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                  // TextButton(
                                                  //   child: Text('click'),
                                                  //   onPressed: () => model
                                                  //       .coreWalletDatabaseService
                                                  //       .insert(CoreWalletModel()),
                                                  // )
                                                ],
                                              )
                                            : Container(
                                                child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    FlutterI18n.translate(
                                                        context,
                                                        "askPrivacyConsent"),
                                                    style: headText5.copyWith(
                                                        color: black),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    child: Text(
                                                      FlutterI18n.translate(
                                                          context,
                                                          "userDataUsage"),
                                                      style: headText5,
                                                    ),
                                                  ),
                                                  UIHelper.verticalSpaceSmall,
                                                  ElevatedButton(
                                                      style: ButtonStyle(
                                                          padding: MaterialStateProperty
                                                              .all(const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      25,
                                                                  vertical:
                                                                      15)),
                                                          elevation:
                                                              MaterialStateProperty
                                                                  .all(10),
                                                          shape:
                                                              MaterialStateProperty
                                                                  .all(
                                                            const StadiumBorder(
                                                                side: BorderSide(
                                                                    color:
                                                                        primaryColor,
                                                                    width: 2)),
                                                          ),
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all(
                                                                      primaryColor)),
                                                      child: Text(
                                                        FlutterI18n.translate(
                                                            context,
                                                            "privacyPolicy"),
                                                        style:
                                                            headText5.copyWith(
                                                                color: white),
                                                      ),
                                                      onPressed: () => model
                                                          .showPrivacyConsentWidget()),
                                                ],
                                              ))
                                        : Container(),
                                  ],
                                ),
                              ),
                  ],
                ),
              ),
              UIHelper.verticalSpaceSmall,
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 30),
                  padding: const EdgeInsets.only(top: 30),
                  child: DropdownButtonHideUnderline(
                    child: Container(
                      color: const Color(0xaaffffff),
                      child: DropdownButton(
                          iconEnabledColor: primaryColor,
                          iconSize: 26,
                          hint: Text(
                            FlutterI18n.translate(
                                context, "changeWalletLanguage"),
                            textAlign: TextAlign.center,
                            style: headText5,
                          ),
                          value: model.selectedLanguage,
                          onChanged: (newValue) {
                            model.changeWalletLanguage(newValue);
                          },
                          items: [
                            DropdownMenuItem(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/images/flags/en.png",
                                    width: 20,
                                    height: 20,
                                  ),
                                  const SizedBox(width: 15),
                                  Text("English",
                                      textAlign: TextAlign.center,
                                      style: headText6),
                                ],
                              ),
                              value: model.languages['en'],
                            ),
                            DropdownMenuItem(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/images/flags/zh.png",
                                    width: 20,
                                    height: 20,
                                  ),
                                  const SizedBox(width: 15),
                                  Text("简体中文",
                                      textAlign: TextAlign.center,
                                      style: headText6),
                                ],
                              ),
                              value: model.languages['zh'],
                            ),
                            DropdownMenuItem(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/images/flags/es.webp",
                                    width: 20,
                                    height: 20,
                                  ),
                                  const SizedBox(width: 15),
                                  Text("Español",
                                      textAlign: TextAlign.center,
                                      style: headText6),
                                ],
                              ),
                              value: model.languages['es'],
                            ),
                          ]),
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
