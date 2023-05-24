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
    GlobalKey one = GlobalKey();
    GlobalKey two = GlobalKey();
    model.one = one;
    model.two = two;
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
            UIHelper.verticalSpaceLarge,
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
                      for (var language in model.languages.entries)
                        DropdownMenuItem(
                          value: language.value,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                KycUtil.generateflag(
                                    isoCode: model.languageWithIsoCode[
                                            language.key] ??
                                        ""),
                                style: const TextStyle(color: black),
                              ),
                              UIHelper.horizontalSpaceSmall,
                              Text(language.value,
                                  textAlign: TextAlign.center,
                                  style: headText6),
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
                          model.kycStarted
                              ? showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Center(
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.8,
                                        height: 230,
                                        decoration:
                                            roundedBoxDecoration(color: white),
                                        child: Stack(
                                          children: [
                                            SingleChildScrollView(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  UIHelper.verticalSpaceLarge,
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        FlutterI18n.translate(
                                                            context, "status"),
                                                        style: headText3,
                                                      ),
                                                      UIHelper
                                                          .horizontalSpaceMedium,
                                                      Text(
                                                        model.kycCheckResult
                                                                    .kyc!.status
                                                                    .toString() ==
                                                                '0'
                                                            ? 'KYC Started'
                                                            : 'KYC Approved',
                                                        style: headText4,
                                                      )
                                                    ],
                                                  ),
                                                  UIHelper.verticalSpaceMedium,
                                                  UIHelper.divider,
                                                  UIHelper.verticalSpaceMedium,
                                                  Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            FlutterI18n
                                                                .translate(
                                                                    context,
                                                                    "step"),
                                                            style: headText3,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 4.0),
                                                            child: Text(
                                                              model.kycCheckResult.kyc!
                                                                          .step ==
                                                                      -1
                                                                  ? '0'
                                                                  : model
                                                                      .kycCheckResult
                                                                      .kyc!
                                                                      .step
                                                                      .toString(),
                                                              style: headText3,
                                                            ),
                                                          ),
                                                          UIHelper
                                                              .horizontalSpaceMedium,
                                                          Text(
                                                            FlutterI18n.translate(
                                                                context,
                                                                'kycStep${model.kycCheckResult.kyc!.step.toString()}'),
                                                            style: headText4,
                                                          ),
                                                        ],
                                                      ),
                                                      UIHelper
                                                          .verticalSpaceSmall,
                                                      model.kycCheckResult.kyc!
                                                                  .step ==
                                                              7
                                                          ? Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              decoration:
                                                                  roundedBoxDecoration(
                                                                      color:
                                                                          primaryColor),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Text(
                                                                  FlutterI18n
                                                                      .translate(
                                                                          context,
                                                                          "waitingForApproval"),
                                                                  style: headText5
                                                                      .copyWith(
                                                                          color:
                                                                              white),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ),
                                                            )
                                                          : TextButton(
                                                              onPressed:
                                                                  () async {
                                                                model.setBusy(
                                                                    true);
                                                                try {
                                                                  final kycService =
                                                                      locator<
                                                                          KycBaseService>();
                                                                  final kycNavigationService =
                                                                      locator<
                                                                          KycNavigationService>();

                                                                  var data =
                                                                      'action=login';

                                                                  var sig = await model
                                                                      .walletService
                                                                      .signKycData(
                                                                          data,
                                                                          context);

                                                                  String url = isProduction
                                                                      ? KycConstants
                                                                          .prodBaseUrl
                                                                      : KycConstants
                                                                          .testBaseUrl;

                                                                  Map<String,
                                                                          dynamic>
                                                                      res = {};
                                                                  if (sig
                                                                      .isNotEmpty) {
                                                                    res = await kycService
                                                                        .login(
                                                                            url,
                                                                            sig);
                                                                    debugPrint(
                                                                        'login res $res');
                                                                    model.setBusy(
                                                                        false);
                                                                    if (res[
                                                                        'success']) {
                                                                      var token =
                                                                          res['data']['data']
                                                                              [
                                                                              'token'];

                                                                      kycService
                                                                          .updateXAccessToken(
                                                                              token);

                                                                      kycNavigationService.navigateToStep(
                                                                          context,
                                                                          model
                                                                              .kycCheckResult
                                                                              .kyc!
                                                                              .step);
                                                                    } else {
                                                                      model.setBusy(
                                                                          false);
                                                                      model.sharedService.sharedSimpleNotification(
                                                                          FlutterI18n.translate(
                                                                              context,
                                                                              'loginFailed'),
                                                                          isError:
                                                                              true);
                                                                    }
                                                                  } else {
                                                                    model.setBusy(
                                                                        false);
                                                                    res = {
                                                                      'success':
                                                                          false,
                                                                      'error':
                                                                          'Failed to sign data'
                                                                    };
                                                                  }
                                                                } catch (e) {
                                                                  debugPrint(
                                                                      'CATCH error $e');
                                                                  model.setBusy(
                                                                      false);
                                                                }
                                                              },
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Text(
                                                                    FlutterI18n.translate(
                                                                        context,
                                                                        "continue"),
                                                                    style: const TextStyle(
                                                                        letterSpacing:
                                                                            1.1),
                                                                  ),
                                                                  UIHelper
                                                                      .horizontalSpaceSmall,
                                                                  const Icon(
                                                                    Icons
                                                                        .double_arrow_rounded,
                                                                    size: 18,
                                                                  ),
                                                                ],
                                                              )),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                            if (model.isBusy)
                                              Center(
                                                child: Container(
                                                  decoration:
                                                      roundedBoxDecoration(
                                                          color:
                                                              black.withOpacity(
                                                                  0.5)),
                                                  child: const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  })
                              : Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => KycView(
                                      kycPrimaryColor: primaryColor,
                                      onFormSubmit: (KycModel kycModel) async {
                                        try {
                                          final kycService =
                                              locator<KycBaseService>();
                                          var data =
                                              'email=${kycModel.email}&first_name=${kycModel.firstName}&last_name=${kycModel.lastName}';

                                          var sig = await model.walletService
                                              .signKycData(data, context);

                                          String url = isProduction
                                              ? KycConstants.prodBaseUrl
                                              : KycConstants.testBaseUrl;
                                          final Map<String, dynamic> res;

                                          if (sig.isNotEmpty) {
                                            res =
                                                await kycService.submitKycData(
                                                    url,
                                                    kycModel.setSignature(sig));
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
                          padding: const EdgeInsets.all(8),
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
                              const Icon(Icons.verified_user,
                                  color: Colors.white), // Icon related to KYC
                              const SizedBox(
                                  width: 8.0), // Space between icon and text
                              model.busy(model.kycStarted)
                                  ? Text(
                                      FlutterI18n.translate(context, "loading"),
                                      style: headText5,
                                    )
                                  : Text(
                                      FlutterI18n.translate(
                                          context,
                                          model.kycStarted
                                              ? "checkKycStatus"
                                              : "startKycProcess"),
                                      style: headText5.copyWith(
                                          color: Colors.white),
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
                    const Text(' Debug', style: TextStyle(color: grey))
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
            ? Text('${FlutterI18n.translate(context, "deleteWallet")}...')
            : Text(
                FlutterI18n.translate(context, "deleteWallet"),
                textAlign: TextAlign.center,
                style: headText5,
              ),
      ],
    );
  }
}
