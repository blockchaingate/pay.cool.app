import 'package:flutter/material.dart';

callSMessage(BuildContext context, String text, {int duration = 3}) {
  var snackBar = SnackBar(
    content: Text(text),
    duration: Duration(seconds: duration),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

String makeShort(double str) {
  if (str <= 0) {
    return "0.0";
  } else {
    return str.toStringAsFixed(2);
  }
}
