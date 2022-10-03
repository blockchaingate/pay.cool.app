import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/environments/environment.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/utils/abi_util.dart';
import 'package:paycool/utils/barcode_util.dart';
import 'package:paycool/views/paycool_club/paycool_club_service.dart';

class GenerateCustomQrCodeView extends StatefulWidget {
  const GenerateCustomQrCodeView({Key key}) : super(key: key);

  @override
  _GenerateCustomQrCodeViewState createState() =>
      _GenerateCustomQrCodeViewState();
}

class _GenerateCustomQrCodeViewState extends State<GenerateCustomQrCodeView> {
  final sharedService = locator<SharedService>();
  final log = getLogger('GenerateCustomQrCodeView');
  @override
  void dispose() {
    referralNode.dispose();
    referralController.dispose();
    super.dispose();
  }

  final FocusNode referralNode = FocusNode();
  var data;
  bool isValid = false;
  bool isBusy = false;
  TextEditingController referralController = TextEditingController();
  final clubService = locator<PayCoolClubService>();
  final GlobalKey _globalKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: true,
          centerTitle: true,
          title: Text(
            FlutterI18n.translate(context, "generateQrCode"),
            style: headText4,
          )),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                FlutterI18n.translate(context, "scanOrPasteReferralCodeBelow"),
                style: subText2,
              ),
              UIHelper.verticalSpaceSmall,
              TextField(
                controller: referralController,
                style: const TextStyle(color: white, height: 2.5),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                  prefixIconConstraints:
                      const BoxConstraints(maxHeight: 30, minHeight: 25),
                  suffixIconConstraints:
                      const BoxConstraints(maxHeight: 30, minHeight: 25),
                  suffixIcon: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.paste,
                      size: 19,
                      color: white,
                    ),
                    onPressed: () => pasteClipBoardData(),
                  ),
                  prefixIcon: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.camera_alt_outlined,
                        color: primaryColor,
                      ),
                      onPressed: () => scanBarCode()),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor, width: 1.0),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: white, width: 1.0),
                  ),
                ),
                onChanged: (value) async {
                  await clubService.isValidReferralCode(value).then((value) {
                    setState(() {
                      isValid = value;
                    });
                  });
                  if (isValid) generateCustomQrCode(value);
                },
              ),
              UIHelper.divider,
              UIHelper.verticalSpaceMedium,
              referralController.text.isNotEmpty && !isValid
                  ? Center(
                      child: Text(FlutterI18n.translate(
                          context, "invalidReferralCode")),
                    )
                  : Container(),
              referralController.text.isEmpty && !isValid
                  ? Container()
                  : referralController.text.isNotEmpty && !isValid
                      ? Container()
                      : isBusy
                          ? sharedService.loadingIndicator()
                          : Container(
                              width: 250,
                              height: 250,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1.0, color: primaryColor)),
                              child: Center(
                                child: Container(
                                  child: RepaintBoundary(
                                    key: _globalKey,
                                    child: QrImage(
                                        backgroundColor: white,
                                        data: jsonEncode(data),
                                        version: QrVersions.auto,
                                        size: 300,
                                        gapless: true,
                                        errorStateBuilder: (context, err) {
                                          return Container(
                                            child: Center(
                                              child: Text(
                                                  FlutterI18n.translate(context,
                                                      "somethingWentWrong"),
                                                  textAlign: TextAlign.center),
                                            ),
                                          );
                                        }),
                                  ),
                                ),
                              )),
            ]),
      ),
    );
  }

  void showBasicSnackbar(String title) {
    showSimpleNotification(
      Center(child: Text(title, style: headText6)),
    );
  }

  generateCustomQrCode(String refAddress) async {
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      isBusy = true;
    });
    log.w('refAddress $refAddress');
    int dusdCoinType = 131074;
    String fabAddress =
        await sharedService.getFabAddressFromCoreWalletDatabase();
    var paycoolSmartContractAddress = environment['addresses']['smartContract']
        ['PaycoolSmartContractAddress'];
    var abiHex = getPayCoolClubFuncABI(
        dusdCoinType, fabAddress, referralController.text);
    var holder = {
      'name': 'Pay.cool Defi Management',
      'to': paycoolSmartContractAddress,
      'data': abiHex
    };
    log.w('data $holder');
    setState(() {
      data = holder;
    });
    setState(() {
      isBusy = false;
    });
    // Container(
    //     margin: EdgeInsets.only(top: 10.0),
    //     width: 250,
    //     height: 250,
    //     child: Center(
    //       child: Container(
    //         child: RepaintBoundary(
    //           key: _globalKey,
    //           child: QrImage(
    //               backgroundColor: white,
    //               data: jsonEncode(data),
    //               version: QrVersions.auto,
    //               size: 300,
    //               gapless: true,
    //               errorStateBuilder: (context, err) {
    //                 return Container(
    //                   child: Center(
    //                     child: Text(
    //                         FlutterI18n.translate(context, "somethingWentWrong"),
    //                         textAlign: TextAlign.center),
    //                   ),
    //                 );
    //               }),
    //         ),
    //       ),
    //     ));
  }

  pasteClipBoardData() async {
    FocusScope.of(context).requestFocus(FocusNode());
    ClipboardData holder = await Clipboard.getData(Clipboard.kTextPlain);
    if (holder != null) {
      setState(() {
        referralController.text = '';
        referralController.text = holder.text;
        log.i('paste data ${referralController.text}');
      });
    }
    await clubService.isValidReferralCode(holder.text).then((value) {
      setState(() {
        isValid = value;
        log.w('isValid paste $isValid');
      });
    });
    if (isValid) generateCustomQrCode(holder.text);
  }

/*--------------------------------------------------------
                      Barcode Scan
--------------------------------------------------------*/
  scanBarCode() async {
    FocusScope.of(context).requestFocus(FocusNode());
    try {
      String barcode = '';

      var result = await BarcodeUtils().scanQR(context);
      barcode = result;
      debugPrint("Barcode Res: $result ");
      setState(() {
        referralController.text = barcode;
      });

      await clubService.isValidReferralCode(barcode).then((value) {
        setState(() {
          isValid = value;
          log.w('isValid scan barcode $isValid');
        });
      });
      if (isValid) generateCustomQrCode(barcode);
    } on PlatformException catch (e) {
      debugPrint("Barcode PlatformException : ${e.toString()} ");

      if (e.code == "PERMISSION_NOT_GRANTED") {
        sharedService.alertDialog(
            '', FlutterI18n.translate(context, "userAccessDenied"),
            isWarning: false);
        // receiverWalletAddressTextController.text =
        //     FlutterI18n.translate(context, "userAccessDenied");
      } else {
        sharedService.alertDialog(
            '', FlutterI18n.translate(context, "unknownError"),
            isWarning: false);
        // receiverWalletAddressTextController.text =
        //     '${FlutterI18n.translate(context, "unknownError")}: $e';
      }
    } on FormatException {
      log.i("Barcode FormatException : ");

      // sharedService.alertDialog(FlutterI18n.translate(context, "scanCancelled"),FlutterI18n.translate(context, "scanCancelled")
      //     AppLocalizations.of(context).userReturnedByPressingBackButton,
      //     isWarning: false);
    } catch (e) {
      log.i("Barcode error : ");
      log.i(e.toString());

      sharedService.alertDialog(
          '', FlutterI18n.translate(context, "unknownError"),
          isWarning: false);
      // receiverWalletAddressTextController.text =
      //     '${FlutterI18n.translate(context, "unknownError")}: $e';
    }
  }
}
