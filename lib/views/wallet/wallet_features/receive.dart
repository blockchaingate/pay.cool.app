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

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/models/wallet/wallet.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/utils/fab_util.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class ReceiveWalletScreen extends StatefulWidget {
  final WalletInfo? data;
  const ReceiveWalletScreen({Key? key, this.data}) : super(key: key);

  @override
  _ReceiveWalletScreenState createState() => _ReceiveWalletScreenState();
}

class _ReceiveWalletScreenState extends State<ReceiveWalletScreen> {
  final walletService = locator<WalletService>();
  String convertedToFabAddress = '';
  WalletInfo? walletInfo;
  var fabUtils = FabUtils();
  @override
  void initState() {
    setWalletInfo();
    super.initState();
  }

  setWalletInfo() async {
    if (widget.data == null) {
      walletInfo = walletService.walletInfoDetails;
    } else {
      walletInfo = widget.data;
    }

    print("------------------");
    print(walletInfo!.address);

    setState(() {});
  }

  final log = getLogger('Receive');
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: bgGrey,
      appBar: customAppBarWithIcon(
        title: FlutterI18n.translate(context, "receive"),
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 20,
            )),
      ),
      body: Column(
        children: [
          Container(
            width: size.width,
            height: size.height * 0.55,
            margin: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  RepaintBoundary(
                    key: _globalKey,
                    child: QrImageView(
                        backgroundColor: white,
                        data: convertedToFabAddress == ''
                            ? walletInfo!.address ?? "dasdad!"
                            : convertedToFabAddress,
                        version: QrVersions.auto,
                        gapless: true,
                        errorStateBuilder: (context, err) {
                          return Center(
                            child: Text(
                                FlutterI18n.translate(
                                    context, "somethingWentWrong"),
                                textAlign: TextAlign.center),
                          );
                        }),
                  ),
                  UIHelper.verticalSpaceMedium,
                  Text("Wallet Address",
                      style: TextStyle(
                          color: textHintGrey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  UIHelper.verticalSpaceSmall,
                  FittedBox(
                    child: Text(
                        convertedToFabAddress == ''
                            ? walletInfo!.address ?? "dsada!"
                            : convertedToFabAddress,
                        style: TextStyle(
                            color: black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  height: 50,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: ElevatedButton.icon(
                    icon: Image.asset(
                      "assets/images/new-design/copy_icon.png",
                      scale: 2.7,
                    ),
                    label: Text("Copy Address"),
                    onPressed: () {
                      copyAddress(context);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: buttonGreen,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  height: 50,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: ElevatedButton.icon(
                    icon: Image.asset(
                      "assets/images/new-design/share_icon.png",
                      scale: 2.7,
                    ),
                    label: Text("Share QR Code"),
                    onPressed: () {
                      String receiveFileName = 'qr-code.png';
                      getApplicationDocumentsDirectory().then((dir) {
                        String filePath = "${dir.path}/$receiveFileName";
                        File file = File(filePath);

                        Future.delayed(const Duration(milliseconds: 30), () {
                          _capturePng().then((byteData) {
                            file.writeAsBytes(byteData!).then((onFile) {
                              Share.shareXFiles([XFile(onFile.path)],
                                  subject: convertedToFabAddress == ''
                                      ? walletInfo!.address
                                      : convertedToFabAddress);
                            });
                          });
                        });
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: buttonPurple,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /*--------------------------------------------------------------------------------------------------------------------------------------------------------------

                                                        Copy Address Function

  --------------------------------------------------------------------------------------------------------------------------------------------------------------*/

  copyAddress(BuildContext context) {
    String address = convertedToFabAddress == ''
        ? walletInfo!.address!
        : convertedToFabAddress;
    log.w(address);
    Clipboard.setData(ClipboardData(text: address));
    showSimpleNotification(
        Text(
          FlutterI18n.translate(context, "addressCopied"),
          style: const TextStyle(color: white, fontWeight: FontWeight.bold),
        ),
        background: primaryColor,
        position: NotificationPosition.bottom);
  }

  /*--------------------------------------------------------------------------------------------------------------------------------------------------------------

                                                        Save and Share PNG

  --------------------------------------------------------------------------------------------------------------------------------------------------------------*/

  Future<Uint8List?> _capturePng() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
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
