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
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:bs58check/bs58check.dart' as Base58;
/*
toBitInt(num, [zeroLength]) {
  var numString = num.toString();
  var numStringArray = numString.split('.');
  zeroLength ??= 18;
  var val = '';
  if (numStringArray != null) {
    val = numStringArray[0];
    if (numStringArray.length == 2) {
      zeroLength -= numStringArray[1].length;
      val += numStringArray[1];
    }
  }

  var valInt = int.parse(val);
  val = valInt.toString();
  for (var i = 0; i < zeroLength; i++) {
    val += '0';
  }

  return val;
}
*/

// extension ExtendedText on Widget {
//   addContainer(){
//     return Container(
//       padding: const EdgeInsets.all(16),
//       margin: const EdgeInsets.all(16),
//       color: Colors.yellow,
//       child: this,
//     );
//   }
// }
class StringUtils {
  static String hexToAscii(String hexInput) {
    var bytes = hexToBytes(hexInput);
    var res = ascii.decode(bytes);
    debugPrint('String util- hex to ascii res $res');
    return res;
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

hexToUint8List(String source) {
  return Uint8List.fromList(HEX.decode(source));
}

hexToBytes(String source) {
  return HEX.decode(source);
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
      s = beforeDecimal + '.' + afterDecimal.substring(0, 8);

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