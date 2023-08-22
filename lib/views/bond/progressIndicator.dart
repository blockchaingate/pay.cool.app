import 'package:flutter/material.dart';

class CustomIndicator {
  static Widget indicator() {
    return SizedBox(
      height: 150,
      width: 150,
      child: Image.asset(
        'assets/animations/loading.gif',
        fit: BoxFit.fill,
      ),
    );
  }
}
