import 'package:flutter/material.dart';

callSMessage(BuildContext context, String text, {int duration = 3}) {
  var snackBar = SnackBar(
    content: Text(text),
    duration: Duration(seconds: duration),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
