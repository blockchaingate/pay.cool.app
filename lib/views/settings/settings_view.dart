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
import 'package:flutter/gestures.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:kyc/kyc.dart';
import 'package:paycool/constants/api_routes.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/environments/environment_type.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/settings/settings_viewmodel.dart';
import 'package:paycool/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SettingsViewmodel>.reactive(
      onViewModelReady: (model) async {
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
          extendBodyBehindAppBar: true,
          // When the keyboard appears, the Flutter widgets resize to avoid that we use resizeToAvoidBottomInset: false
          resizeToAvoidBottomInset: false,

          appBar: customAppBarWithTitleNB(
              FlutterI18n.translate(context, "settings")),
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
    Key? key,
    required this.model,
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
  const SettingsContainer({Key? key, required this.model}) : super(key: key);

  final SettingsViewmodel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(image: blurBackgroundImage()),
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
              child: Container(
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
              onTap: () async {
                await model.deleteWallet();
              },
            ),
            UIHelper.divider,
            InkWell(
              splashColor: primaryColor,
              child: showMnemonicContainer(context),
              onTap: () {
                model.displayMnemonic();
              },
            ),
            UIHelper.divider,
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
                  style: headText6,
                )),
              ),
            ),

            Center(
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
                                textAlign: TextAlign.center, style: headText6),
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
                                textAlign: TextAlign.center, style: headText6),
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
                                textAlign: TextAlign.center, style: headText6),
                          ],
                        ),
                      ),
                    ]),
              ),
            ),
            UIHelper.divider,
            // Showcase club dashboard
            Container(
              padding: const EdgeInsets.all(15),
              child: Row(
                //  crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(left: 5.0, right: 8.0),
                    child: Icon(Icons.account_balance_wallet,
                        color: black, size: 18),
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
            ),
            UIHelper.divider,
            // Showcase ON/OFF
            Container(
              padding: const EdgeInsets.all(15),
              child: Row(
                //  crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(left: 5.0, right: 8.0),
                    child: Icon(Icons.qr_code, color: black, size: 18),
                  ),
                  Expanded(
                    child: Text(
                        FlutterI18n.translate(context, "autoStartPaycoolScan"),
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
            ),
            UIHelper.divider,
            // Card(
            //     elevation: 5,
            //     color: secondaryColor,
            //     child: Container(
            //       padding: const EdgeInsets.all(10),
            //       child: Row(
            //         //  crossAxisAlignment: CrossAxisAlignment.start,
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: <Widget>[
            //           const Padding(
            //             padding: EdgeInsets.only(left: 5.0, right: 8.0),
            //             child:
            //                 Icon(Icons.insert_comment, color: white, size: 18),
            //           ),
            //           Expanded(
            //             child: Text(
            //                 FlutterI18n.translate(
            //                     context, "settingsShowcaseInstructions"),
            //                 style: headText5,
            //                 textAlign: TextAlign.left),
            //           ),
            //           SizedBox(
            //             height: 20,
            //             child: Switch(
            //                 inactiveThumbColor: grey,
            //                 activeTrackColor: white,
            //                 activeColor: primaryColor,
            //                 inactiveTrackColor: white,
            //                 value: model.isShowCaseOnce,
            //                 onChanged: (value) {
            //                   model.setIsShowcase(value);
            //                 }),
            //           ),
            //           // ),
            //         ],
            //       ),
            //     )),

            // Biometric authentication toggle
            // Card(
            //     elevation: 5,
            //     color: secondaryColor,
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
            //         color: secondaryColor,
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

            Container(
              padding: const EdgeInsets.all(15),
              child: Row(
                //  crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(left: 5.0, right: 8.0),
                    child: Icon(Icons.storage, color: black, size: 18),
                  ),
                  // Add column here and add text box that shows which node is current
                  Expanded(
                    child: Text(FlutterI18n.translate(context, "useAsiaNode"),
                        style: headText5, textAlign: TextAlign.left),
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
            ),
            Container(
              padding: const EdgeInsets.all(15),
              child: Row(
                //  crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Material(
                      borderRadius: BorderRadius.circular(30.0),
                      elevation: 5,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  //  KycData(
                                  //   kycService: KycBaseService(),
                                  //   progress: 1.0 / 9.0,
                                  //   isProd: isProduction,
                                  //   xAccessToken: ValueNotifier<String?>(null),
                                  //   child:
                                  KycView(
                                onFormSubmit: (KycModel kycModel) async {
                                  try {
                                    final kycService =
                                        locator<KycBaseService>();

                                    var sig = await model.walletService
                                        .signKycData(kycModel, context);

                                    String url = isProduction
                                        ? KycConstants.prodBaseUrl
                                        : KycConstants.testBaseUrl;
                                    final res;

                                    if (sig.isNotEmpty) {
                                      res = await kycService.submitKycData(
                                          url, kycModel.setSignature(sig));
                                    } else {
                                      res = {
                                        'success': false,
                                        'error': 'Failed to sign data'
                                      };
                                    }
                                    return res;
                                  } catch (e) {
                                    debugPrint('CATCH error $e');
                                  }
                                },
                                // ),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30.0),
                            gradient: LinearGradient(
                              colors: [
                                primaryColor,
                                primaryColor.withAlpha(900),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_user,
                                  color: Colors.white), // Icon related to KYC
                              SizedBox(
                                  width: 8.0), // Space between icon and text
                              Text(
                                FlutterI18n.translate(
                                  context,
                                  model.kycCompleted
                                      ? "Check KYC Status"
                                      : "Start KYC Process",
                                ),
                                style: headText5.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                  // ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(5),
              child: Center(
                child: Text(model.errorMessage,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: Colors.red)),
              ),
            ),
            UIHelper.verticalSpaceLarge,
            Center(
              child: RichText(
                text: TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      model.sharedService.launchInBrowser(Uri.parse(
                          '$paycoolWebsiteUrl${model.storageService.langCodeSC}/privacy'));
                    },
                  text: FlutterI18n.translate(context, "privacyPolicy"),
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                ),
              ),
            ),
            UIHelper.verticalSpaceLarge,
            // Version Code
            SizedBox(
              height: 40,
              child: Center(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'v ${model.versionName}.${model.buildNumber}',
                    style: headText6.copyWith(color: black),
                  ),
                  if (!isProduction)
                    const Text(' Debug', style: TextStyle(color: Colors.white))
                ],
              )),
            ),
          ]),
    );
  }

  Container showMnemonicContainer(BuildContext context) {
    return Container(
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
