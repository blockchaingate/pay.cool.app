import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeUtil extends StatefulWidget {
  const BarcodeUtil({super.key});

  @override
  State<BarcodeUtil> createState() => _BarcodeUtilState();
}

class _BarcodeUtilState extends State<BarcodeUtil> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Stack(
          children: [
            MobileScanner(onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;

              debugPrint('Barcode found! ${barcodes[0].rawValue}');
              Navigator.pop(context, barcodes[0].rawValue);
            }),
            Center(
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.red,
                    width: 2.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
