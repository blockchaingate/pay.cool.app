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
import 'package:paycool/models/wallet/provider_address_model.dart';
import 'package:paycool/models/wallet/wallet.dart';
import 'package:paycool/providers/app_state_provider.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class ReceiveWalletScreen extends StatefulWidget {
  final bool isMain;
  final WalletInfo? data;
  const ReceiveWalletScreen({super.key, this.data, this.isMain = false});

  @override
  _ReceiveWalletScreenState createState() => _ReceiveWalletScreenState();
}

class _ReceiveWalletScreenState extends State<ReceiveWalletScreen> {
  final walletService = locator<WalletService>();
  AppStateProvider appStateProvider = locator<AppStateProvider>();
  List<ProviderAddressModel> addressModelList = [];
  ProviderAddressModel? model;

  @override
  void initState() {
    appStateProvider = Provider.of<AppStateProvider>(context, listen: false);

    setWalletInfo();
    super.initState();
  }

  setWalletInfo() {
    if (widget.isMain) {
      addressModelList = appStateProvider.getProviderAddressList;
      model = appStateProvider.getProviderAddressList
          .where((element) => element.name == "FAB")
          .first;
    } else {
      model = ProviderAddressModel(
          name: widget.data!.name, address: widget.data!.address);
    }
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
            height: size.height > 750 ? size.height * 0.55 : size.height * 0.7,
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
                        data: model!.address!,
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
                  widget.isMain
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                FlutterI18n.translate(context, "walletAddress"),
                                style: TextStyle(
                                    color: textHintGrey,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            UIHelper.horizontalSpaceSmall,
                            DropdownButton(
                              underline: SizedBox(),
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: widget.isMain
                                    ? textHintGrey
                                    : Colors
                                        .black, // Change icon color based on widget.isMain
                              ),
                              onTap:
                                  () {}, // Disable onTap if widget.isMain is true
                              items: addressModelList.map((addressModel) {
                                return DropdownMenuItem(
                                  value: addressModel.name,
                                  child: Text(addressModel.name!),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  model = addressModelList
                                      .where((element) =>
                                          element.name == value.toString())
                                      .first;
                                });
                                // Handle onChanged event if needed
                              },
                              value: model!
                                  .name, // Set the initial value or the selected value
                              style: TextStyle(
                                color: widget.isMain
                                    ? textHintGrey
                                    : Colors
                                        .black, // Change text color based on widget.isMain
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          "${FlutterI18n.translate(context, "walletAddress")}: ${model!.name!}",
                          style: TextStyle(
                              color: textHintGrey,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                  UIHelper.verticalSpaceSmall,
                  FittedBox(
                    child: Text(model!.address!,
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
                    label: Text(
                      FlutterI18n.translate(context, "copyAddress"),
                      style: TextStyle(color: white),
                    ),
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
                    label: Text(
                      FlutterI18n.translate(context, "shareQRCode"),
                      style: TextStyle(color: white),
                    ),
                    onPressed: () {
                      String receiveFileName = 'qr-code.png';
                      getApplicationDocumentsDirectory().then((dir) {
                        String filePath = "${dir.path}/$receiveFileName";
                        File file = File(filePath);

                        Future.delayed(const Duration(milliseconds: 30), () {
                          _capturePng().then((byteData) {
                            file.writeAsBytes(byteData!).then((onFile) {
                              Share.shareXFiles([XFile(onFile.path)],
                                  subject: model!.address!);
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
    Clipboard.setData(ClipboardData(text: model!.address!));
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
