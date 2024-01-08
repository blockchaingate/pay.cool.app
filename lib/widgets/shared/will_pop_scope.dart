import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:paycool/providers/app_state_provider.dart';
import 'package:provider/provider.dart';

class WillPopScopeWidget {
  Future<void> onWillPop(BuildContext context) async {
    AppStateProvider provider =
        Provider.of<AppStateProvider>(context, listen: false);
    if (provider.getDoubleBackToExitPressedOnce) {
      exit(0);
    }
    _showToast(context, 'Click again to exit');
    provider.setDoubleBackToExitPressedOnce(true);

    Timer(Duration(seconds: 3), () {
      provider.setDoubleBackToExitPressedOnce(false);
    });
  }

  void _showToast(BuildContext context, String message) async {
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (BuildContext context) => Positioned(
        bottom: MediaQuery.of(context).size.height * 0.15,
        left: MediaQuery.of(context).size.width * 0.3,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              message,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    await Future.delayed(Duration(seconds: 3));
    overlayEntry.remove();
  }
}
