/*
* Copyright (c) 2020 Exchangily LLC
*
* Licensed under Apache License v2.0
* You may obtain a copy of the License at
*
*      https://www.apache.org/licenses/LICENSE-2.0
*
*----------------------------------------------------------------------
* Author: barry-ruprai@exchangily.com
*----------------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paycool/constants/colors.dart';

class VerifyMnemonicWalletView extends StatelessWidget {
  final List<TextEditingController> mnemonicTextController;
  final String? validationMessage;
  final int? count;

  // ignore: use_key_in_widget_constructors
  const VerifyMnemonicWalletView(
      {required this.mnemonicTextController,
      this.validationMessage,
      this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
              child: GridView.extent(
                  maxCrossAxisExtent: 125,
                  padding: const EdgeInsets.all(2),
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 10,
                  shrinkWrap: true,
                  childAspectRatio: 2,
                  children: _buildTextGrid(count!, mnemonicTextController))),
        ],
      ),
    );
  }

  List<Container> _buildTextGrid(int count, controller) =>
      List.generate(count, (i) {
        var hintMnemonicWordNumber = i + 1;
        // FocusNode focusNode = FocusNode();
        controller.add(TextEditingController());
        return Container(
            child: TextField(
          inputFormatters: [
            LowerCaseTextFormatter(),
            FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]")),
          ],
          // textCapitalization: TextCapitalization.none,

          style: const TextStyle(
              color: grey, fontSize: 14, fontWeight: FontWeight.bold),
          controller: controller[i], cursorColor: black, //focusNode: focusNode,
          autocorrect: true,
          decoration: InputDecoration(
            fillColor: secondaryColor,
            filled: true,
            hintText:
                // focusNode.hasFocus && focusNode.hasFocus != null
                //     ? ' '
                //     :
                '$hintMnemonicWordNumber',
            hintStyle: const TextStyle(color: primaryColor),
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: primaryColor, width: 1.5),
                borderRadius: BorderRadius.circular(30.0)),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: grey, width: 1),
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
        ));
      });
}

class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}
