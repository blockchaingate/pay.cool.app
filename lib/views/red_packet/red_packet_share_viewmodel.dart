import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'dart:typed_data';

import '../../services/local_dialog_service.dart';

class RedPacketShareViewModel extends BaseViewModel {
  final log = getLogger('RedPacketShareViewModel');
  late String gcode;
  LocalDialogService dialogService = locator<LocalDialogService>();
  final GlobalKey captureKey = GlobalKey();
  bool showCopy = true;

  void init(context, giftCode) {
    gcode = giftCode;
  }

  void setSendOrReceive(bool value) {
    notifyListeners();
  }

  //copy gift code to clipboard
  void copyGiftCode(BuildContext context) {
    String copytext =
        "Pay.cool APP red packet. Enter the code in Pay.cool to get the red packet. Gift code: $gcode.";

    Clipboard.setData(ClipboardData(text: copytext));

    dialogService.showBasicDialog(
        title: 'Copy Gift Code',
        description: 'Gift code copied to clipboard.',
        buttonTitle: 'OK');
  }

  Future<Uint8List> captureWidgetAsImage(GlobalKey key) async {
    try {
      RenderRepaintBoundary boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(
          pixelRatio: 3.0); // You can adjust the pixelRatio as needed
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List uint8List = byteData!.buffer.asUint8List();
      return uint8List;
    } catch (e) {
      print('Error capturing widget as image: $e');
      return Uint8List(0);
    }
  }

  //save image to gallery
  void saveImageToGallery(BuildContext context) async {
    showCopy = false;
    Uint8List imageBytes = await captureWidgetAsImage(captureKey);
    showCopy = true;
    img.Image? image = img.decodeImage(imageBytes);
    img.Image? resizedImage = img.copyResize(image!,
        width: MediaQuery.of(context).size.width.toInt());
    Uint8List resizedImageBytes = img.encodePng(resizedImage!);

    //save image to gallery
    // final result = await ImageGallerySaver.saveImage(
    //     Uint8List.fromList(resizedImageBytes),
    //     quality: 60,
    //     name: "red_packet_$gcode");

    // print('RedPacketShareViewModel saveImageToGallery result: $result');

    // dialogService.showBasicDialog(
    //     title: 'Save Image',
    //     description: 'Image saved to gallery.',
    //     buttonTitle: 'OK');

    //save image to gallery
    final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(resizedImageBytes),
        quality: 100,
        name: "red_packet_$gcode");

    print('RedPacketShareViewModel saveImageToGallery result: $result');

    dialogService.showBasicDialog(
        title: 'Save Image',
        description: 'Image saved to gallery.',
        buttonTitle: 'OK');
  }

  //share image to social media
  void shareImageToSocialMedia(BuildContext context) async {
    showCopy = false;

    Uint8List imageBytes = await captureWidgetAsImage(captureKey);

    showCopy = true;

    //share image to social media
    // final ByteData bytes = ByteData.view(imageBytes.buffer);
    await Share.shareXFiles(
        [XFile.fromData(imageBytes, name: 'red_packet_$gcode.png')],
        text:
            'Pay.cool APP red packet. Enter the code in Pay.cool to get the red packet. Gift code: $gcode.');
  }
}
