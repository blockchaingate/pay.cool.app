import 'package:flutter/material.dart';

callSMessage(BuildContext context, String text, {int duration = 3}) {
  var snackBar = SnackBar(
    content: Text(text),
    duration: Duration(seconds: duration),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

String makeShort(String str) {
  if (double.parse(str) <= 0) {
    return "0.0";
  }
  if (str.length >= 12) {
    return str.substring(0, 12);
  } else {
    return str;
  }
}
