import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
//import 'package:qr_code_scanner/qr_code_scanner.dart';

class BarcodeUtils {
  Future<ScanResult> scanBarcode(BuildContext context) async {
    ScanResult scanResult;
    var options = ScanOptions(strings: {
      "cancel": FlutterI18n.translate(context, "cancel"),
      "flash_on": FlutterI18n.translate(context, "flashOn"),
      "flash_off": FlutterI18n.translate(context, "flashOff"),
    });

    scanResult = await BarcodeScanner.scan(options: options);
    // await BarcodeUtils().scanQR(context);
    debugPrint(
        'BarcodeUtils : scanBarcode ${scanResult.rawContent.toString()}');
    return scanResult;
  }

  Future scanQRV2(BuildContext context) async {
    // Barcode barcodeScanRes;
    // QRViewController controller;
    // try {
    //   controller.scannedDataStream.listen((scanData) {
    //     barcodeScanRes = scanData;
    //   });
    //   debugPrint(barcodeScanRes);
    // } on PlatformException {
    //   barcodeScanRes = Barcode(
    //       'PlatformException Failed to get platform version.',
    //       BarcodeFormat.aztec, []);
    // }
    // return barcodeScanRes;
  }

  Future scanQR(BuildContext context) async {
    String barcodeScanRes;
    // try {
    //   barcodeScanRes = await FlutterBarcodeScanner.scanBarcode('#ff6666',
    //       FlutterI18n.translate(context, "cancel"), true, ScanMode.BARCODE);
    //   debugPrint(barcodeScanRes);
    // } on PlatformException {
    //   barcodeScanRes = 'PlatformException Failed to get platform version.';
    // }
    return barcodeScanRes;
  }
}