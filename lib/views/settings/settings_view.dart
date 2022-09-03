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

import 'package:exchangily_ui/exchangily_ui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/views/settings/settings_viewmodel.dart';
import 'package:paycool/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SettingsViewmodel>.reactive(
      onModelReady: (model) async {
        model.context = context;
        await model.init();
      },
      viewModelBuilder: () => SettingsViewmodel(),
      builder: (context, model, _) => WillPopScope(
        onWillPop: () async {
          model.onBackButtonPressed();
          return Future(() => false);
        },
        child: Scaffold(
          // When the keyboard appears, the Flutter widgets resize to avoid that we use resizeToAvoidBottomInset: false
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            centerTitle: true,
            title: Text(FlutterI18n.translate(context, "settings"),
                style: headText3),
            backgroundColor: secondaryColor,
            leading: Container(),
          ),
          body: model.isBusy
              ? Center(child: model.sharedService.loadingIndicator())
              // : model.isShowCaseOnce == false
              //     ? ShowCaseWidget(
              //         onStart: (index, key) {
              //           debugPrint('onStart: $index, $key');
              //         },
              //         onComplete: (index, key) {
              //           debugPrint('onComplete: $index, $key');
              //         },
              //         onFinish: () async {
              //           // debugPrint('FINISH, set isShowCaseOnce to true as we have shown user the showcase dialogs');
              //           // await model.getStoredDataByKeys('isShowCaseOnce',
              //           //     isSetData: true, value: true);
              //         },
              //         // autoPlay: true,
              //         // autoPlayDelay: Duration(seconds: 3),
              //         // autoPlayLockEnable: true,
              //         builder: Builder(
              //           builder: (context) => SettingsWidget(model: model),
              //         ),
              //       )
              : SettingsContainer(model: model),
          bottomNavigationBar: BottomNavBar(count: 4),
        ),
      ),
    );
  }
}

class SettingsWidget extends StatelessWidget {
  final SettingsViewmodel model;
  const SettingsWidget({
    Key key,
    this.model,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GlobalKey _one = GlobalKey();
    GlobalKey _two = GlobalKey();
    model.one = _one;
    model.two = _two;
    debugPrint('isShow _SettingsWidgetState ${model.isShowCaseOnce}');
    model.showcaseEvent(context);
    // WidgetsBinding.instance
    //   .addPostFrameCallback((_) => widget.model.showcaseEvent(context));
    return SettingsContainer(
      model: model,
    );
  }
}

class SettingsContainer extends StatelessWidget {
  const SettingsContainer({Key key, this.model}) : super(key: key);

  final SettingsViewmodel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: ListView(
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // InkWell(
            //   child: Text(
            //     FlutterI18n.translate(context, "title"),
            //     style: TextStyle(color: Colors.amber),
            //   ),
            //   onTap: () {
            //     model.changeLanguage();
            //   },
            // ),

            InkWell(
              splashColor: primaryColor,
              child: Card(
                elevation: 4,
                child: Container(
                  alignment: Alignment.centerLeft,
                  color: walletCardColor,
                  padding: const EdgeInsets.all(20),
                  // height: 100,
                  child:
                      // !model.isShowCaseOnce
                      //     ? Showcase(
                      //         key: model.one,
                      //         description: 'Delete wallet from this device',
                      //         child: deleteWalletRow(context),
                      //       )
                      //     :
                      deleteWalletRow(context),
                ),
              ),
              onTap: () async {
                await model.deleteWallet();
              },
            ),
            InkWell(
              splashColor: primaryColor,
              child: Card(
                elevation: 5,
                child: showMnemonicContainer(context),
              ),
              onTap: () {
                model.displayMnemonic();
              },
            ),
            //  InkWell(
            //   splashColor: primaryColor,
            //   child: Card(
            //     elevation: 5,
            //     child:
            //        Text('Convert Decimal to hex')
            //   ),
            //   onTap: () {
            //     model.convertDecimalToHex();
            //   },
            // ),
            Visibility(
              visible: model.isVisible,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                    child: Text(
                  model.mnemonic,
                  style: Theme.of(context).textTheme.bodyText1,
                )),
              ),
            ),

            Card(
              elevation: 5,
              color: walletCardColor,
              child: Center(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                      iconEnabledColor: primaryColor,
                      iconSize: 26,
                      hint: Text(
                        FlutterI18n.translate(context, "changeWalletLanguage"),
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
                                "assets/images/img/flagEn.png",
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
                                "assets/images/img/flagChina.png",
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
                      ]),
                ),
              ),
            ),

            // Showcase club dashboard
            Card(
                elevation: 5,
                color: walletCardColor,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    //  crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.only(left: 5.0, right: 8.0),
                        child: Icon(Icons.account_balance_wallet,
                            color: white, size: 18),
                      ),
                      Expanded(
                        child: Text(
                            FlutterI18n.translate(context, "showPaycoolClub"),
                            style: headText5,
                            textAlign: TextAlign.left),
                      ),
                      SizedBox(
                        height: 20,
                        child: Switch(
                            inactiveThumbColor: grey,
                            activeTrackColor: white,
                            activeColor: primaryColor,
                            inactiveTrackColor: white,
                            value: model.isShowPaycoolClub,
                            onChanged: (value) {
                              model.setShowPaycoolClub(value);
                            }),
                      ),
                      // ),
                    ],
                  ),
                )),

            // Showcase ON/OFF
            Card(
                elevation: 5,
                color: walletCardColor,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    //  crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.only(left: 5.0, right: 8.0),
                        child: Icon(Icons.qr_code, color: white, size: 18),
                      ),
                      Expanded(
                        child: Text(
                            FlutterI18n.translate(
                                context, "autoStartPaycoolScan"),
                            //FlutterI18n.translate(context, "autoStartPaycoolScan"),
                            style: headText5,
                            textAlign: TextAlign.left),
                      ),
                      SizedBox(
                        height: 20,
                        child: Switch(
                            inactiveThumbColor: grey,
                            activeTrackColor: white,
                            activeColor: primaryColor,
                            inactiveTrackColor: white,
                            value: model.isAutoStartPaycoolScan,
                            onChanged: (value) {
                              model.setAutoScanPaycool(value);
                            }),
                      ),
                      // ),
                    ],
                  ),
                )),
            Card(
                elevation: 5,
                color: walletCardColor,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    //  crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.only(left: 5.0, right: 8.0),
                        child:
                            Icon(Icons.insert_comment, color: white, size: 18),
                      ),
                      Expanded(
                        child: Text(
                            FlutterI18n.translate(
                                context, "settingsShowcaseInstructions"),
                            style: headText5,
                            textAlign: TextAlign.left),
                      ),
                      SizedBox(
                        height: 20,
                        child: Switch(
                            inactiveThumbColor: grey,
                            activeTrackColor: white,
                            activeColor: primaryColor,
                            inactiveTrackColor: white,
                            value: model.isShowCaseOnce,
                            onChanged: (value) {
                              model.setIsShowcase(value);
                            }),
                      ),
                      // ),
                    ],
                  ),
                )),

            // Biometric authentication toggle
            // Card(
            //     elevation: 5,
            //     color: walletCardColor,
            //     child: Container(
            //       padding: EdgeInsets.all(10),
            //       child: Row(
            //         //  crossAxisAlignment: CrossAxisAlignment.start,
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: <Widget>[
            //           Padding(
            //             padding: const EdgeInsets.only(left: 5.0, right: 8.0),
            //             child:
            //                 Icon(Icons.security_sharp, color: white, size: 18),
            //           ),
            //           Expanded(
            //             child: Text(
            //                 FlutterI18n.translate(
            //                     context, "enableBiometricAuthentication"),
            //                 style: Theme.of(context).textTheme.headline5,
            //                 textAlign: TextAlign.left),
            //           ),
            //           SizedBox(
            //             height: 20,
            //             child: Switch(
            //                 inactiveThumbColor: grey,
            //                 activeTrackColor: white,
            //                 activeColor: primaryColor,
            //                 inactiveTrackColor: white,
            //                 value: model
            //                     .storageService.hasInAppBiometricAuthEnabled,
            //                 onChanged: (value) {
            //                   model.setBiometricAuth();
            //                 }),
            //           ),
            //           // ),
            //         ],
            //       ),
            //     )),

            // // lock app now
            // // only shows when user enabled the auth
            // // and biometric or pin/password is activated
            // model.storageService.hasInAppBiometricAuthEnabled &&
            //         model.storageService.hasPhoneProtectionEnabled
            //     ? Card(
            //         elevation: 5,
            //         color: walletCardColor,
            //         child: Container(
            //           padding: EdgeInsets.all(10),
            //           child: Row(
            //             //  crossAxisAlignment: CrossAxisAlignment.start,
            //             mainAxisAlignment: MainAxisAlignment.center,
            //             children: <Widget>[
            //               Padding(
            //                 padding:
            //                     const EdgeInsets.only(left: 5.0, right: 8.0),
            //                 child: Icon(Icons.lock_outline_rounded,
            //                     color: white, size: 18),
            //               ),
            //               Expanded(
            //                 child: Text(
            //                     FlutterI18n.translate(context, "lockAppNow"),
            //                     style: Theme.of(context).textTheme.headline5,
            //                     textAlign: TextAlign.left),
            //               ),
            //               SizedBox(
            //                 height: 20,
            //                 child: Switch(
            //                     inactiveThumbColor: grey,
            //                     activeTrackColor: white,
            //                     activeColor: primaryColor,
            //                     inactiveTrackColor: white,
            //                     value: model.lockAppNow,
            //                     onChanged: (value) {
            //                       model.setLockAppNowValue();
            //                     }),
            //               ),
            //               // ),
            //             ],
            //           ),
            //         ))
            //     : Container(),
// Server url change
            // Card(
            //   child: FlatButton(
            //       onPressed: () => model.reloadApp(),
            //       child: Text('Reload app')),
            // ),
            Card(
                elevation: 5,
                color: walletCardColor,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    //  crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.only(left: 5.0, right: 8.0),
                        child: Icon(Icons.storage, color: white, size: 18),
                      ),
                      // Add column here and add text box that shows which node is current
                      Expanded(
                        child: Text(
                            FlutterI18n.translate(context, "useAsiaNode"),
                            style: headText5,
                            textAlign: TextAlign.left),
                      ),
                      SizedBox(
                        height: 20,
                        child: Switch(
                            inactiveThumbColor: grey,
                            activeTrackColor: white,
                            activeColor: primaryColor,
                            inactiveTrackColor: white,
                            value: model.storageService.isHKServer,
                            onChanged: (value) {
                              model.changeBaseAppUrl();
                            }),
                      ),
                      // ),
                    ],
                  ),
                )),

            //Card(child: Container(child: Text(model.test))),
            // Version Code
            Card(
              elevation: 5,
              child: Container(
                color: primaryColor,
                width: 200,
                height: 40,
                child: Center(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'v ${model.versionName}.${model.buildNumber}',
                      style: headText6,
                    ),
                    if (!model.environmentService.kReleaseMode)
                      const Text(' Debug',
                          style: TextStyle(color: Colors.white))
                  ],
                )),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(5),
              child: Center(
                child: Text(model.errorMessage,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(color: Colors.red)),
              ),
            ),
          ]),
    );
  }

  Container showMnemonicContainer(BuildContext context) {
    return Container(
      color: walletCardColor,
      padding: const EdgeInsets.all(20),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
          padding: const EdgeInsets.only(right: 3.0),
          child: Icon(
            !model.isVisible ? Icons.enhanced_encryption : Icons.remove_red_eye,
            color: primaryColor,
            size: 18,
          ),
        ),
        Text(
          !model.isVisible
              ? FlutterI18n.translate(context, "displayMnemonic")
              : FlutterI18n.translate(context, "hideMnemonic"),
          textAlign: TextAlign.center,
          style: headText5,
        ),
      ]),
    );
  }

  Row deleteWalletRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 3.0),
          child: Icon(
            Icons.delete,
            color: sellPrice,
            size: 18,
          ),
        ),
        model.isDeleting
            ? Text(FlutterI18n.translate(context, "deleteWallet") + '...')
            : Text(
                FlutterI18n.translate(context, "deleteWallet"),
                textAlign: TextAlign.center,
                style: headText5,
              ),
      ],
    );
  }
}
