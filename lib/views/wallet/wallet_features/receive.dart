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

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/models/wallet/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/utils/fab_util.dart';
import 'package:share_plus/share_plus.dart';

class ReceiveWalletScreen extends StatefulWidget {
  final WalletInfo walletInfo;
  const ReceiveWalletScreen({Key? key, required this.walletInfo})
      : super(key: key);

  @override
  _ReceiveWalletScreenState createState() => _ReceiveWalletScreenState();
}

class _ReceiveWalletScreenState extends State<ReceiveWalletScreen> {
  String convertedToFabAddress = '';
  var fabUtils = FabUtils();
  @override
  void initState() {
    super.initState();
    // log.w(widget.walletInfo.toJson());
    // if (widget.walletInfo.tokenType == 'FAB') {
    //   convertedToFabAddress =
    //       fabUtils.exgToFabAddress(widget.walletInfo.address);
    //   log.w(
    //       'convertedToFabAddress from ${widget.walletInfo.address} to $convertedToFabAddress');
    // }
  }

  final log = getLogger('Receive');
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar:
          customAppBarWithTitleNB(FlutterI18n.translate(context, "receive")),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                width: double.infinity,
                height: 150,
                color: secondaryColor,
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                        convertedToFabAddress == ''
                            ? widget.walletInfo.address!
                            : convertedToFabAddress,
                        style: Theme.of(context).textTheme.bodyMedium),
                    SizedBox(
                      width: 200,
                      child: OutlinedButton(
                        style: outlinedButtonStyles2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Padding(
                              padding: EdgeInsets.only(right: 4.0),
                              child: Icon(
                                Icons.content_copy,
                                size: 16,
                              ),
                            ),
                            Text(
                              FlutterI18n.translate(context, "copyAddress"),
                              style: headText5.copyWith(
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                        onPressed: () {
                          copyAddress(context);
                        },
                      ),
                    )
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: 350,
                color: secondaryColor,
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                            border:
                                Border.all(width: 1.0, color: primaryColor)),
                        child: Center(
                          child: Container(
                            child: RepaintBoundary(
                              key: _globalKey,
                              child: QrImageView(
                                  backgroundColor: white,
                                  data: convertedToFabAddress == ''
                                      ? widget.walletInfo.address!
                                      : convertedToFabAddress,
                                  version: QrVersions.auto,
                                  size: 300,
                                  gapless: true,
                                  errorStateBuilder: (context, err) {
                                    return Container(
                                      child: Center(
                                        child: Text(
                                            FlutterI18n.translate(
                                                context, "somethingWentWrong"),
                                            textAlign: TextAlign.center),
                                      ),
                                    );
                                  }),
                            ),
                          ),
                        )),
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      child: ElevatedButton(
                          style: generalButtonStyle1,
                          child: Text(
                              FlutterI18n.translate(
                                  context, "saveAndShareQrCode"),
                              style: headText4.copyWith(
                                  color: secondaryColor,
                                  fontWeight: FontWeight.w400)),
                          onPressed: () {
                            String receiveFileName = 'qr-code.png';
                            getApplicationDocumentsDirectory().then((dir) {
                              String filePath = "${dir.path}/$receiveFileName";
                              File file = File(filePath);

                              Future.delayed(const Duration(milliseconds: 30),
                                  () {
                                _capturePng().then((byteData) {
                                  file.writeAsBytes(byteData!).then((onFile) {
                                    Share.share(onFile.path,
                                        subject: convertedToFabAddress == ''
                                            ? widget.walletInfo.address
                                            : convertedToFabAddress);
                                  });
                                });
                              });
                            });
                          }),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /*--------------------------------------------------------------------------------------------------------------------------------------------------------------

                                                        Copy Address Function

  --------------------------------------------------------------------------------------------------------------------------------------------------------------*/

  copyAddress(BuildContext context) {
    String address = convertedToFabAddress == ''
        ? widget.walletInfo.address!
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
