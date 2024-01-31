import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeUtil extends ChangeNotifier {
  Future<String?> showScannerPopup(BuildContext context) async {
    Completer<String?> completer = Completer<String?>();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext contexta) {
        return MobileScanner(onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          String scannedText = barcodes[0].rawValue!;
          Navigator.pop(contexta);
          completer.complete(scannedText);
        });
      },
    );

    String? result = await completer.future;
    completer = Completer<String?>();
    notifyListeners();
    return result;
  }
}
