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
import 'dart:io';
import 'dart:ui';
import 'package:device_info/device_info.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:overlay_support/overlay_support.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/colors.dart';
import '../constants/custom_styles.dart';
import '../environments/environment.dart';
import '../logger.dart';
import '../models/shared/pair_decimal_config_model.dart';
import '../service_locator.dart';
import '../shared/ui_helpers.dart';
import '../utils/string_util.dart';
import 'api_service.dart';
import 'db/core_wallet_database_service.dart';
import 'db/decimal_config_database_service.dart';
import 'db/token_list_database_service.dart';
import 'local_storage_service.dart';

class SharedService {
  late BuildContext context;
  final log = getLogger('SharedService');
  final storageService = locator<LocalStorageService>();
  NavigationService navigationService = locator<NavigationService>();

  final tokenListDatabaseService = locator<TokenListDatabaseService>();
  DecimalConfigDatabaseService decimalConfigDatabaseService =
      locator<DecimalConfigDatabaseService>();
  final coreWalletDatabaseService = locator<CoreWalletDatabaseService>();

  navigateWithAnimation(Widget viewToNavigate) => Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              viewToNavigate,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = const Offset(0.0, 1.0);
            var end = Offset.zero;
            var curve = Curves.easeInOut;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );

  storeDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceId = '';
    if (Platform.isAndroid) {
      var androidInfo = await deviceInfo.androidInfo;
      log.w("androidInfo $androidInfo");
      deviceId = androidInfo.id.toString();
    } else if (Platform.isIOS) {
      var iosInfo = await deviceInfo.iosInfo;
      log.w("iosInfo $iosInfo");
      deviceId = iosInfo.identifierForVendor.toString();
    }
    String dId = deviceId;
    if (deviceId.length > 32) {
      dId = deviceId.substring(0, 32);
    }
    storageService.deviceId = dId;
  }

/*--------------------------------------------------------------------------
                  Show Simple Notification
------------------------------------------------------------------------- */
  sharedSimpleNotification(String content,
      {String subtitle = '', bool isError = true}) {
    return showSimpleNotification(
        Text(firstCharToUppercase(content),
            textAlign: subtitle.isEmpty ? TextAlign.center : TextAlign.start,
            style: headText3.copyWith(
                color: isError ? red : green, fontWeight: FontWeight.w500)),
        position: NotificationPosition.top,
        background: white,
        duration: const Duration(seconds: 3),
        slideDismissDirection: DismissDirection.startToEnd,
        subtitle: Text(subtitle,
            style: headText5.copyWith(
                color: isError ? red : green, fontWeight: FontWeight.w400)));
  }

/*--------------------------------------------------------------------------
                        getPairDecimalConfig
------------------------------------------------------------------------- */

  Future<PairDecimalConfig> getSinglePairDecimalConfig(String pairName,
      {String base = ''}) async {
    PairDecimalConfig singlePairDecimalConfig = PairDecimalConfig();
    log.i('tickername $pairName -- endswith usdt ${pairName.endsWith('USDT')}');

    // if (pairName == 'BTC' || pairName == 'ETH' || pairName == 'EXG')
    //   base = 'USDT';
    // else
    if ((pairName == 'BTC' || pairName == 'ETH' || pairName == 'EXG') ||
        !pairName.endsWith('USDT') &&
            !pairName.endsWith('DUSD') &&
            !pairName.endsWith('BTC') &&
            !pairName.endsWith('ETH') &&
            !pairName.endsWith("EXG")) base = 'USDT';

    if (pairName == 'USDT' || pairName == 'DUSD') {
      return singlePairDecimalConfig =
          PairDecimalConfig(name: pairName, priceDecimal: 2, qtyDecimal: 2);
    } else {
      log.i('base $base');
      await getAllPairDecimalConfig().then((res) {
        singlePairDecimalConfig =
            res.firstWhere((element) => element.name == pairName + base);
        log.i(
            'returning result $singlePairDecimalConfig -- name $pairName -- base $base');

        // if firstWhere fails
        if (singlePairDecimalConfig != null) {
          log.w(
              'single pair decimal config for $pairName result ${singlePairDecimalConfig.toJson()}');
          return singlePairDecimalConfig;
        } else {
          log.i('single pair config using for loop');
          for (PairDecimalConfig pair in res) {
            if (pair.name == pairName) {
              singlePairDecimalConfig = PairDecimalConfig(
                  priceDecimal: pair.priceDecimal, qtyDecimal: pair.qtyDecimal);
            }
          }
        }
      }).catchError((err) {
        log.e('getSinglePairDecimalConfig CATCH $err');
      });
    }
    return singlePairDecimalConfig;
  }

// -------------- all pair ---------------------

  Future<List<PairDecimalConfig>> getAllPairDecimalConfig() async {
    ApiService apiService = locator<ApiService>();
    List<PairDecimalConfig> result = [];
    result = await decimalConfigDatabaseService.getAll();
    log.e('decimal configs length in db ${result.length}');
    if (result.isEmpty) {
      await apiService.getPairDecimalConfig().then((res) async {
        if (res.isEmpty) {
          return null;
        } else {
          result = res;
        }
      });
    }
    debugPrint('returning result');
    return result;
  }
/*---------------------------------------------------
      Get EXG address from wallet database
--------------------------------------------------- */

  Future<String> getExgAddressFromCoreWalletDatabase() async {
    return await coreWalletDatabaseService.getWalletAddressByTickerName('EXG');
  }
/*---------------------------------------------------
      Get FAB address from wallet database
--------------------------------------------------- */

  Future<String> getFabAddressFromCoreWalletDatabase() async {
    return await coreWalletDatabaseService.getWalletAddressByTickerName('FAB');
  }

  Future<String> getCoinAddressFromCoreWalletDatabase(String ticker) async {
    return await coreWalletDatabaseService.getWalletAddressByTickerName(ticker);
  }

/*---------------------------------------------------
      Get EXG Official address
--------------------------------------------------- */

  String getEXGOfficialAddress() {
    return environment['addresses']['exchangilyOfficial'][0]['address'];
  }

/*---------------------------------------------------
      Rounded gradient button box decoration
--------------------------------------------------- */

  Decoration circularGradientBoxDecoration() {
    return const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(25)),
      gradient: LinearGradient(
        colors: [Colors.redAccent, Colors.yellow],
        begin: FractionalOffset.topLeft,
        end: FractionalOffset.bottomRight,
      ),
    );
  }

  Decoration rectangularGradientBoxDecoration() {
    return const BoxDecoration(
      // borderRadius: BorderRadius.all(Radius.circular(25)),
      gradient: LinearGradient(
        colors: [Colors.redAccent, Colors.yellow],
        begin: FractionalOffset.topLeft,
        end: FractionalOffset.bottomRight,
      ),
    );
  }
/*---------------------------------------------------
            Launch link urls
--------------------------------------------------- */

  // launchURL(String url) async {
  //   log.i('launchURL $url');
  //   if (await canLaunch(url)) {
  //     await launch(url);
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }

/* ---------------------------------------------------
            Full screen Stack loading indicator
--------------------------------------------------- */

  Widget stackFullScreenLoadingIndicator() {
    return Container(
        height: UIHelper.getScreenFullHeight(context),
        width: UIHelper.getScreenFullWidth(context),
        color: Colors.transparent,
        child: loadingIndicator());
  }

/* ---------------------------------------------------
        Loading indicator platform specific
--------------------------------------------------- */
  Widget loadingIndicator(
      {double width = 30,
      double height = 30,
      bool isCustomWidthHeight = false,
      double strokeWidth = 5}) {
    if (!isCustomWidthHeight && Platform.isAndroid) {
      width = 20;
      height = 20;
    }
    return Center(
        child: Platform.isIOS
            ? Container(
                decoration: BoxDecoration(
                    color: grey.withAlpha(125),
                    borderRadius: const BorderRadius.all(Radius.circular(5))),
                width: width,
                height: height,
                child: const CupertinoActivityIndicator())
            : SizedBox(
                width: width,
                height: height,
                child: CircularProgressIndicator(
                  backgroundColor: primaryColor,
                  semanticsLabel: 'Loading',
                  strokeWidth: strokeWidth,
                  //  valueColor: AlwaysStoppedAnimation<Color>(secondaryColor)
                ),
              ));
  }

/* ---------------------------------------------------
                Get device ID
--------------------------------------------------- */
  // Future<String> getDeviceID() async {
  //   String deviceID = '';

  //   final deviceInfo = DeviceInfoPlugin();
  //   if (Platform.isAndroid) {
  //     AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  //     debugPrint('Running on ${androidInfo.model}');
  //     deviceID = androidInfo.deviceId;
  //   } else if (Platform.isIOS) {
  //     IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
  //     debugPrint('Running on ${iosInfo.utsname.machine}');
  //     deviceID = iosInfo.deviceId;
  //   }

  //   return deviceID;
  // }

/* ---------------------------------------------------
                Get app version Code
--------------------------------------------------- */

  Future<Map<String, String>> getLocalAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String versionName = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    Map<String, String> versionInfo = {
      "name": versionName,
      "buildNumber": buildNumber
    };
    return versionInfo;
  }

/*-------------------------------------------------------------------------------------
                          getCurrentRouteName
-------------------------------------------------------------------------------------*/

  String getCurrentRouteName(BuildContext context) {
    String routeName = '';
    routeName = ModalRoute.of(context)!.settings.name!;
    debugPrint('$routeName in bottom Nav');
    return routeName;
  }

/*-------------------------------------------------------------------------------------
                          Physical Back Button pressed
-------------------------------------------------------------------------------------*/

  onBackButtonPressed(String route) async {
    navigationService.navigateTo(route);
  }

  Future<void> launchInBrowser(Uri url) async {
    debugPrint('url $url');
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }

  Future<bool?> closeApp() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            elevation: 20,
            backgroundColor: walletCardColor.withOpacity(0.85),
            titleTextStyle: headText5.copyWith(fontWeight: FontWeight.bold),
            contentTextStyle: const TextStyle(color: white),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                // add here cupertino widget to check in these small widgets first then the entire app
                '${FlutterI18n.translate(context, "closeTheApp")}?',
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
            actions: <Widget>[
              UIHelper.verticalSpaceSmall,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                        elevation: MaterialStateProperty.all(5.0),
                        backgroundColor:
                            MaterialStateProperty.all(secondaryColor),
                        shape: buttonRoundShape(secondaryColor)),
                    child: Text(
                      FlutterI18n.translate(context, "no"),
                      style: headText5,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  UIHelper.horizontalSpaceMedium,
                  ElevatedButton(
                    style: ButtonStyle(
                        elevation: MaterialStateProperty.all(5.0),
                        backgroundColor:
                            MaterialStateProperty.all(primaryColor),
                        shape: buttonRoundShape(primaryColor)),
                    child: Text(FlutterI18n.translate(context, "yes"),
                        style: const TextStyle(color: white, fontSize: 12)),
                    onPressed: () {
                      SystemChannels.platform
                          .invokeMethod('SystemNavigator.pop');
                    },
                  ),
                  UIHelper.verticalSpaceSmall,
                ],
              ),
            ],
          );
        });
  }

/*-------------------------------------------------------------------------------------
                          Alert dialog
-------------------------------------------------------------------------------------*/
  alertDialog(String title, String message,
      {BuildContext? contexte,
      bool isWarning = false,
      String? path,
      dynamic arguments,
      bool isCopyTxId = false,
      bool isDismissible = true,
      bool isUpdate = false,
      bool isLater = false,
      bool isWebsite = false,
      String? stringData}) async {
    bool checkBoxValue = false;
    showDialog(
        barrierDismissible: isDismissible,
        context: context ?? contexte!,
        builder: (context) {
          return AlertDialog(
            titlePadding: const EdgeInsets.all(0),
            actionsPadding: const EdgeInsets.all(0),
            elevation: 5,
            backgroundColor: secondaryColor,
            title: title == ""
                ? Container()
                : Container(
                    alignment: Alignment.center,
                    color: primaryColor.withOpacity(0.1),
                    padding: const EdgeInsets.all(10),
                    child: Text(title),
                  ),
            titleTextStyle: headText5,
            contentTextStyle: const TextStyle(color: grey),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            content: Visibility(
              visible: message != '',
              child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    UIHelper.verticalSpaceMedium,
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 6.0),
                      child: Text(
                          // add here cupertino widget to check in these small widgets first then the entire app
                          message,
                          textAlign: TextAlign.left,
                          style: headText5),
                    ),
                    // Do not show checkbox and text does not require to show on all dialogs
                    Visibility(
                      visible: isWarning,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Checkbox(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              value: checkBoxValue,
                              activeColor: primaryColor,
                              onChanged: (bool? value) async {
                                setState(() => checkBoxValue = value!);

                                /// user click on do not show which is negative means false
                                /// so to make it work it needs to be opposite of the orginal value
                                storageService.isNoticeDialogDisplay =
                                    !checkBoxValue;
                              }),
                          Text(
                            FlutterI18n.translate(
                                context, "doNotShowTheseWarnings"),
                            style: headText6,
                          ),
                        ],
                      ),
                    ),
                    // SizedBox(height: 10),
                  ],
                );
              }),
            ),
            // actions: [],
            actions: <Widget>[
              isCopyTxId
                  ?
                  //  RaisedButton(
                  //     child:
                  //         Text(FlutterI18n.translate(context, "taphereToCopyTxId"),style:headText5),
                  //     onPressed: () {
                  //       Clipboard.setData(new ClipboardData(text: message));
                  //     })
                  Center(
                      child: RichText(
                        text: TextSpan(
                            text: FlutterI18n.translate(
                                context, "taphereToCopyTxId"),
                            style: const TextStyle(
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                                color: primaryColor),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                //  Clipboard.setData(ClipboardData(text: message));
                                copyAddress(context, message);
                              }),
                      ),
                    )
                  : Container(),
              isDismissible
                  ? Container(
                      margin: const EdgeInsetsDirectional.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(red),
                              padding:
                                  MaterialStateProperty.all<EdgeInsetsGeometry>(
                                      const EdgeInsets.all(0)),
                            ),
                            child: Text(
                              isLater
                                  ? FlutterI18n.translate(context, "later")
                                  : FlutterI18n.translate(context, "close"),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                            onPressed: () {
                              if (path == '' || path == null) {
                                Navigator.of(context).pop(false);
                              } else {
                                debugPrint('PATH $path');
                                Navigator.of(context).pop(false);
                                navigationService.navigateTo(path,
                                    arguments: arguments);
                              }
                            },
                          ),
                          UIHelper.horizontalSpaceSmall,
                          isWebsite
                              ? TextButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(primaryColor),
                                    padding: MaterialStateProperty.all(
                                        const EdgeInsets.all(5)),
                                  ),
                                  onPressed: () {
                                    // launchURL(stringData);
                                    Navigator.of(context).pop(false);
                                  },
                                  child: Center(
                                    child: Text(
                                      FlutterI18n.translate(context, "website"),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                )
                              : Container(),
                          UIHelper.horizontalSpaceSmall,
                          isUpdate
                              ? TextButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(green),
                                    padding: MaterialStateProperty.all(
                                        const EdgeInsets.all(5)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      FlutterI18n.translate(
                                          context, "updateNow"),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                  onPressed: () {
                                    // LaunchReview.launch(
                                    //     androidAppId: "com.exchangily.wallet",
                                    //     iOSAppId: "com.exchangily.app",
                                    //     writeReview: false);
                                    // Navigator.of(context).pop(false);
                                  },
                                )
                              : Container(),
                        ],
                      ),
                    )
                  : Container(),
            ],
          );
        });
  }

  // Language
  checkLanguage() {
    String lang = '';

    lang = storageService.language;
    if (lang == '') {
      debugPrint('language empty');
    } else {
      Navigator.pushNamed(context, '/walletSetup');
    }
  }

  /* ---------------------------------------------------
                Flushbar Notification bar
    -------------------------------------------------- */

  void showInfoFlushbar(String title, String message, IconData iconData,
      Color leftBarColor, BuildContext context) {
    showSimpleNotification(
        Text(title, style: headText4.copyWith(color: secondaryColor)),
        background: primaryColor,
        subtitle: Text(message, style: headText5),
        position: NotificationPosition.bottom);
  }

/* ---------------------------------------------------
                Copy Address
--------------------------------------------------- */

  copyAddress(context, text, {textColor = white}) {
    Clipboard.setData(ClipboardData(text: text));
    showSimpleNotification(
        Text(
          FlutterI18n.translate(context, "addressCopied"),
          textAlign: TextAlign.center,
          style: TextStyle(color: textColor, fontSize: 13),
        ),
        background: primaryColor,
        position: NotificationPosition.bottom);
  }

/* ---------------------------------------------------
                paste dat
--------------------------------------------------- */

  pasteData() async {
    return await Clipboard.getData(Clipboard.kTextPlain);
  }

  Future<String> pasteClipboardData() async {
    var res = await Clipboard.getData(Clipboard.kTextPlain);
    return res!.text!;
  }
  /*--------------------------------------------------------------------------------------------------------------------------------------------------------------
                  Save and Share PNG
  --------------------------------------------------------------------------------------------------------------------------------------------------------------*/

  Future<Uint8List?> capturePng({GlobalKey? globalKey}) async {
    try {
      RenderRepaintBoundary boundary = globalKey!.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      return pngBytes;
    } catch (e) {
      return null;
    }
  }
}
