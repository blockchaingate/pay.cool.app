import 'package:flutter/material.dart';

class KeyboardClose extends StatelessWidget {
  const KeyboardClose({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SizedBox(
        height: 50,
        width: 75,
        child: Icon(Icons.keyboard_hide),
      ),
    );
  }
}
