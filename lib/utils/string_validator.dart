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

import 'package:flutter/services.dart';

abstract class StringValidator {
  // need to define your own class
  bool isValid(String value);
}

class RegexValidator implements StringValidator {
  RegexValidator(this.regexSource);
  final String regexSource;

  @override
  bool isValid(String value) {
    try {
      final regex = RegExp(regexSource);
      final matches = regex.allMatches(value);
      for (Match match in matches) {
        if (match.start == 0 && match.end == value.length) {
          return true;
        }
      }
      return false;
    } catch (err) {
      assert(false, err.toString());
      return true;
    }
  }
}

class ValidatorInputFormatter implements TextInputFormatter {
  final StringValidator editingValidator;
  ValidatorInputFormatter(this.editingValidator);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final oldValueValid = editingValidator.isValid(oldValue.text);
    final newValueValid = editingValidator.isValid(newValue.text);
    if (oldValueValid && !newValueValid) {
      return oldValue;
    }
    return newValue;
  }
}

bool validateEmail(String email) {
  // Regular expression pattern for email validation
  const pattern = r'^[\w-]+(\.[\w-]+)*@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,7}$';
  final regExp = RegExp(pattern);

  // Check if the email matches the pattern
  return regExp.hasMatch(email);
}

bool validatePassword(String param) {
  RegExp pattern = RegExp(
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[`~!@#\$%\^&*\(\)-_\+\=\{\[\}\]]).{8,}$');
  bool hasSpecialCharacters = param.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  return pattern.hasMatch(param) && hasSpecialCharacters;
}
