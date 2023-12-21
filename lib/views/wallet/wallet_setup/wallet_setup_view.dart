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
import 'package:paycool/views/wallet/wallet_setup/wallet_setup_viewmodel.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stacked/stacked.dart';

class WalletSetupView extends StatelessWidget {
  const WalletSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ViewModelBuilder<WalletSetupViewmodel>.reactive(
      viewModelBuilder: () => WalletSetupViewmodel(),
      onViewModelReady: (WalletSetupViewmodel model) async {
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
              Container(
                width: size.width,
                height: size.height,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(
                          "assets/images/new-design/first_page_bg.png"),
                      fit: BoxFit.cover),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    model.isDeleting
                        ? Text(
                            FlutterI18n.translate(context, "deletingWallet"),
                            style: Theme.of(context).textTheme.bodyLarge,
                          )
                        : SizedBox(),
                    !model.isBusy && model.errorMessage.isNotEmpty
                        ? Text(
                            model.errorMessage,
                            style: Theme.of(context).textTheme.bodyLarge,
                          )
                        : SizedBox(),
                    model.isBusy
                        ? Shimmer.fromColors(
                            baseColor: primaryColor,
                            highlightColor: white,
                            child: Center(
                              child: Text(
                                '${FlutterI18n.translate(context, "checkingExistingWallet")}...',
                                style: Theme.of(context).textTheme.bodyLarge,
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
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  Image.asset(
                                    "assets/images/new-design/first_page_image.png",
                                    alignment: Alignment.topCenter,
                                    height: size.height * 0.5,
                                    width: size.width * 0.8,
                                  ),
                                  !model.hasAuthenticated &&
                                          !model.isBusy &&
                                          model.storageService
                                              .hasInAppBiometricAuthEnabled &&
                                          model.storageService
                                              .hasPhoneProtectionEnabled
                                      ? ElevatedButton(
                                          style: ButtonStyle(
                                              shape: MaterialStateProperty.all(
                                                const StadiumBorder(
                                                    side: BorderSide(
                                                        color:
                                                            Colors.transparent,
                                                        width: 2)),
                                              ),
                                              elevation:
                                                  MaterialStateProperty.all(5)),
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
                                                      .headlineMedium),
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
                                          ? Column(
                                              children: <Widget>[
                                                Container(
                                                  width: size.width * 0.8,
                                                  height: 40,
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: 10),
                                                  child: ElevatedButton.icon(
                                                    icon: Icon(Icons.add_circle,
                                                        color: white, size: 24),
                                                    label: Text(
                                                      FlutterI18n.translate(
                                                          context,
                                                          "createWallet"),
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                    onPressed: () {
                                                      if (!model.isBusy) {
                                                        model.importCreateNav(
                                                            'create');
                                                      }
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      backgroundColor:
                                                          buttonPurple,
                                                    ),
                                                  ),
                                                ),
                                                UIHelper.verticalSpaceSmall,
                                                Container(
                                                  width: size.width * 0.8,
                                                  height: 40,
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: 10),
                                                  child: ElevatedButton.icon(
                                                    icon: Icon(
                                                        Icons.arrow_circle_down,
                                                        color: buttonPurple,
                                                        size: 24),
                                                    label: Text(
                                                      FlutterI18n.translate(
                                                          context,
                                                          "importWallet"),
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: buttonPurple,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                    onPressed: () {
                                                      if (!model.isBusy) {
                                                        model.importCreateNav(
                                                            'import');
                                                      }
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      backgroundColor:
                                                          Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  FlutterI18n.translate(context,
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
                                                Container(
                                                  width: size.width * 0.8,
                                                  height: 40,
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: 10),
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      model
                                                          .showPrivacyConsentWidget();
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      backgroundColor:
                                                          buttonPurple,
                                                    ),
                                                    child: Text(
                                                      FlutterI18n.translate(
                                                          context,
                                                          "privacyPolicy"),
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                      : Container(),
                                ],
                              ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: DropdownButtonHideUnderline(
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
                          model.changeWalletLanguage(newValue.toString());
                        },
                        items: [
                          DropdownMenuItem(
                            value: model.languages['en'],
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
                          ),
                          DropdownMenuItem(
                            value: model.languages['zh'],
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
                          ),
                          DropdownMenuItem(
                            value: model.languages['es'],
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
                          ),
                        ]),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Image.asset(
                    "assets/images/new-design/payCool_logo.png",
                    scale: 2.5,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
