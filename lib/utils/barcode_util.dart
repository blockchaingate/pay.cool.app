import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeUtil {
  Future<String?> showScannerPopup(BuildContext context) async {
    Completer<String?> completer = Completer<String?>();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return MobileScanner(onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          String scannedText = barcodes[0].rawValue!;
          Navigator.pop(context);
          completer.complete(scannedText);
        });
      },
    );

    return completer.future;
  }
}
