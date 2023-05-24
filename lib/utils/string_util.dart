/*
* Copyright (c) 2020 Exchangily LLC
*
* Licensed under Apache License v2.0
* You may obtain a copy of the License at
*
*      https://www.apache.org/licenses/LICENSE-2.0
*
*----------------------------------------------------------------------
* Author: ken.qiu@exchangily.com & barry-ruprai@exchangily.com
*----------------------------------------------------------------------
*/

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:bs58check/bs58check.dart' as Base58;

class StringUtils {
  static final Random _random = Random.secure();

  static String stringToHexUsingUint8List(String input) {
    Uint8List uint8List = Uint8List.fromList(input.codeUnits);
    return uint8List.map((c) => c.toRadixString(16).padLeft(2, '0')).join();
  }

  static String stringToHex(String input) {
    return input.codeUnits
        .map((c) => c.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  static String createCryptoRandomString([int length = 64]) {
    var val = List<int>.generate(length, (index) => _random.nextInt(256));
    return base64Url.encode(val);
  }

  static String generateRandomHexString() {
    Random random = Random.secure();
    List<int> values = List.generate(32, (index) => random.nextInt(256));
    String hexString =
        values.map((value) => value.toRadixString(16).padLeft(2, '0')).join();
    return hexString;
  }

  static String hexToAscii(String hexInput) {
    var bytes = hexToBytes(hexInput);
    var res = ascii.decode(bytes);
    debugPrint('String util- hex to ascii res $res');
    return res;
  }

  static String showPartialAddress(
      {String? address, int startLimit = 6, int endLimit = 6}) {
    return '${address!.substring(0, startLimit)}...${address.substring(address.length - endLimit)}';
  }

  static List<int> hexToBytes(String source) {
    return HEX.decode(source);
  }

  static String localDateFromMilliseconds(int milliseconds,
      {bool removeLast4Chars = false}) {
    var date =
        DateTime.fromMillisecondsSinceEpoch(milliseconds * 1000).toLocal();
    debugPrint('dateFromMilliseconds string ${date.toString().length}');
    String finalDate = '';
    removeLast4Chars
        ? finalDate = date.toString().substring(0, date.toString().length - 4)
        : finalDate = date.toString();
    debugPrint('dateFromMilliseconds string ${finalDate.toString()}');
    return finalDate;
  }
}

String getLast64CharAbiHex(String abiHex) {
  int hexLength = abiHex.length;
  int start = hexLength - 64;
  return abiHex.substring(start, hexLength);
}

sliceAbiHex(abiHex) {
  String abiHexString = abiHex;
  String first10Char = abiHexString.substring(0, 10);
  List<String> slice64CharsList = [];
  debugPrint('First abiHex 10 char $first10Char');
  int condition = ((abiHexString.length - first10Char.length) / 64).round();
  debugPrint('CONDITION $condition');
  for (var i = 0; i < condition; i++) {
    String t = abiHexString.substring(10);
    int start = i * 64;
    int end = (i * 64) + 64;
    String res = t.substring(start, end);
    debugPrint('$i - - $res');
    slice64CharsList.add(res);
    //  debugPrint('list $slice64CharsList');
  }
}

String firstCharToUppercase(String value) {
  String formattedString = value[0].toUpperCase() + value.substring(1);
  return formattedString;
}

hex2Buffer(hexString) {
  List<int> buffer = [];
  for (var i = 0; i < hexString.length; i += 2) {
    var val = (int.parse(hexString[i], radix: 16) << 4) |
        int.parse(hexString[i + 1], radix: 16);
    buffer.add(val);
  }
  return buffer;
}

trimHexPrefix(String str) {
  if (str.startsWith('0x')) {
    str = str.substring(2);
  }
  return str.trim();
}

number2Buffer(numVal) {
  List<int> buffer = [];
  var neg = (numVal < 0);
  numVal = numVal.abs();
  while (numVal > 0) {
    buffer.add(numVal & 0xff);

    numVal = numVal >> 8;
  }

  var top = buffer[buffer.length - 1];
  if (top & 0x80 != 0) {
    buffer.add(neg ? 0x80 : 0x00);
  } else if (neg) {
    buffer.add(top | 0x80);
  }
  debugPrint('string_util number2Buffer $buffer');
  return buffer;
}
/*----------------------------------------------------------------------
                    Convert fab to hex
----------------------------------------------------------------------*/

String convertFabAddressToHex(String fabAddress) {
  var decoded = Base58.decode(fabAddress);
  String hexString = HEX.encode(decoded);
  return hexString;
}

stringToUint8List(String s) {
  List<int> list = utf8.encode(s);
  return Uint8List.fromList(list);
}

uint8ListToHex(Uint8List list) {
  return HEX.encode(list);
}

hexToUint8List(String hexSource) {
  return Uint8List.fromList(HEX.decode(hexSource));
}

hexToBytes(String hexSource) {
  return HEX.decode(hexSource);
}

/*
bigIntString2Double(bigInt) {
  return (Decimal.parse(bigInt.toString()) / Decimal.parse('1000000000000000000')).toDouble();
}
*/
fixLength(String str, int length) {
  var retStr = '';
  int len = str.length;
  int len2 = length - len;
  if (len2 > 0) {
    for (int i = 0; i < len2; i++) {
      retStr += '0';
    }
    retStr += str;
    return retStr;
  } else if (len2 < 0) {
    return str.substring(0, length - 1);
  } else {
    return str;
  }
}

doubleAdd(double d1, double d2) {
  var d = Decimal.parse(d1.toString()) + Decimal.parse(d2.toString());
  return d.toDouble();
}

bigNumToDouble(BigInt bigNum, {int decimalLength = 8}) {
  var dec =
      Decimal.parse(bigNum.toString()) / Decimal.parse('1000000000000000000');
  if (dec.toDouble() > 999999) {
    return double.parse(dec.toDouble().toStringAsFixed(8));
  }
  var str = dec.toString();
  var s = str;
  var d = dec.toDouble();
  if (str.contains('.')) {
    var beforeDecimal = str.split('.')[0];
    var afterDecimal = str.split('.')[1];
    if (afterDecimal.length > decimalLength) {
      s = '$beforeDecimal.${afterDecimal.substring(0, 8)}';

      d = double.parse(s);
    }
  }
  return d;
}

/*----------------------------------------------------------------------
                Format Date and time string
----------------------------------------------------------------------*/
String formatStringDate(String date) {
  String wholeDate = date;
  var dateToFormat = DateTime.parse(wholeDate);
  String formattedDate = DateFormat('MM/dd/yyyy').format(dateToFormat);
  String formattedTime = DateFormat('kk:mm:ss').format(dateToFormat);
  formattedDate = '$formattedDate\n' '$formattedTime';
  return formattedDate;
}

String formatStringDateV2(String date) {
  String wholeDate = date;
  var dateToFormat = DateTime.parse(wholeDate);
  String formattedDate = DateFormat('MM-dd-yyyy').format(dateToFormat);
  String formattedTime = DateFormat('kk:mm:ss').format(dateToFormat);
  formattedDate = '$formattedDate $formattedTime';
  return formattedDate;
}

String extractTimeFromDate(String date) {
  String wholeDate = date;
  var dateToFormat = DateTime.parse(wholeDate);
  String formattedTime = DateFormat.ms().format(dateToFormat);

  return formattedTime;
}

String formatStringDateV3(String date) {
  String wholeDate = date;
  var dateToFormat = DateTime.parse(wholeDate);
  String formattedDate = DateFormat('MM-dd-yyyy').format(dateToFormat);

  return formattedDate;
}

String formatStringDateWithMonth(String date) {
  String wholeDate = date;
  var dateToFormat = DateTime.parse(wholeDate);
  String formattedDate = DateFormat('MM/dd/yyyy').format(dateToFormat);
  String formattedTime = DateFormat('kk:mm:ss').format(dateToFormat);
  formattedDate = '$formattedDate\n' '$formattedTime';
  return formattedDate;
}

DateTime dateFromMilliseconds(int milliseconds) {
  var date = DateTime.fromMillisecondsSinceEpoch(milliseconds * 1000);
  var formattedDate = date.toUtc();
  debugPrint('dateFromMilliseconds: $formattedDate');
  return formattedDate;
}
