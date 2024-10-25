import 'dart:convert';
import 'dart:math';
import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:paycool/constants/constants.dart';
import 'package:paycool/logger.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';

import 'package:paycool/utils/string_validator.dart';

class NumberUtil {
  int? maxDecimalDigits;
  final log = getLogger('NumberUtil');

  static BigInt hexToBigInt(String hex) {
    if (hex.startsWith('0x')) {
      hex = hex.substring(2);
    }
    return BigInt.parse('0x$hex');
  }

  static checkRegexAmount(Decimal amount) =>
      RegexValidator(Constants.regexPattern.toString())
          .isValid(amount.toString());

  // Decode a BigInt from bytes in big-endian encoding.
  static BigInt decodeBigIntV1(List<int> bytes) {
    BigInt result = BigInt.from(0);
    for (int i = 0; i < bytes.length; i++) {
      result += BigInt.from(bytes[bytes.length - i - 1]) << (8 * i);
    }
    return result;
  }

  static final _byteMask = BigInt.from(0xff);

  /// Encode a BigInt into bytes using big-endian encoding.
  static Uint8List encodeBigIntV1(BigInt number) {
    // Not handling negative numbers. Decide how you want to do that.
    int size = (number.bitLength + 7) >> 3;
    var result = Uint8List(size);
    for (int i = 0; i < size; i++) {
      result[size - i - 1] = (number & _byteMask).toInt();
      number = number >> 8;
    }
    return result;
  }

  static Decimal rawStringToDecimal(String raw, {int? decimalPrecision = 18}) {
    if (raw.isNotEmpty) {
      Decimal amount = Decimal.parse(raw.toString());
      var x = Decimal.fromInt((pow(10, decimalPrecision!)).toInt());
      Decimal result = (amount / x).toDecimal();

      return result;
    } else {
      return Decimal.zero;
    }
  }

  static Decimal roundDecimal(Decimal value, int decimalPlaces) {
    Decimal multiplier = Decimal.parse(pow(10, decimalPlaces).toString());
    Decimal roundedValue = ((value * multiplier).truncate() / multiplier)
        .toDecimal(scaleOnInfinitePrecision: decimalPlaces);
    return roundedValue;
  }

  static double roundDouble(double value, {int decimalPlaces = 2}) {
    if (value != 0) {
      Decimal decimalValue = Decimal.parse(value.toString());

      return roundDecimal(decimalValue, decimalPlaces).toDouble();
    } else {
      return value;
    }
  }

  /// Breaks at precision 19
  static Decimal decimalLimiter(Decimal input, {int decimalPlaces = 2}) {
    var finalRes = Constants.decimalZero;

    if (input != Constants.decimalZero) {
      finalRes = roundDecimal(input, decimalPlaces);
    }

    debugPrint('finalRes $finalRes');
    return finalRes;
  }

// create a function fixed32Chars that takes a string and a key length as parameters and returns a string with hex characters instead of '0' for better security

  static String fixed32CharsV2(String input, int keyLength) {
    if (input.length < 32) {
      int diff = 32 - keyLength;
      for (var i = 0; i < diff; i++) {
        input += '0'; // generate a random hex character
      }
    }
    return input;
  }

  static String fixed32Chars(String input, int keyLength) {
    if (input.length < 32) {
      int diff = 32 - keyLength;

      //TODO: add hex character instead of '0' for better security
      for (var i = 0; i < diff; i++) {
        input += '0';
      }
    }
    return input;
  }

  static Decimal convertStringToDecimal(String value) {
    return Decimal.parse(value);
  }

  static double truncateDoubleWithoutRouding(double input,
      {int precision = 2}) {
    double res = 0.0;
    bool isInputContainsE = input.toString().contains('e');
    if (!input.isNaN && !isInputContainsE) {
      String decimalPart = input.toString().split('.')[1];
      // if (input.toString().contains('.')) {
      // indexOf gives 2 if balance is 54.321299421
      // as . is after 2 decimal digits
      // we add precision for example 6
      // 2+ 6 = 8
      // 54.32129
      // we add +1 as we need 6 precisions
      // 2+6+1 = 9
      // 54.321299
      if (decimalPart.length > precision) {
        res = double.parse(
            '$input'.substring(0, '$input'.indexOf('.') + precision + 1));
      } else {
        // String tail = '';
        // for (var i = 0; i < precision - decimalPart.length; i++) {
        //   tail += '0';
        // }
        // String concat = '$input' + tail;
        // res = double.parse(concat);
        // log.e('res $res');
        res = input;
      }
    }
    return res;
  }

/*---------------------------------------------------
                Round down
--------------------------------------------------- */

  double roundDownLastDigit(double input) {
    log.w('roundDownLastDigit input val $input');
    double finalBalance = 0.0;
    int roundDown = 0;
    String balanceToString = input.toString();
    String beforeDecimalBalance = balanceToString.split(".")[0];
    String afterDecimalBalance = balanceToString.split(".")[1];
    String lastDecimalDigit =
        afterDecimalBalance.substring(afterDecimalBalance.length - 1);
    String secondLastDecimalDigit =
        afterDecimalBalance.substring(0, afterDecimalBalance.length - 1);
    if (lastDecimalDigit != '0') {
      roundDown = int.parse(lastDecimalDigit) - 1;
    }
    String res = '$beforeDecimalBalance.$secondLastDecimalDigit$roundDown';
    finalBalance = double.parse(res);

    log.w('roundDownLastDigit res $finalBalance');
    return finalBalance;
  }

  intToHex(source) {
    return source.toRadixString(16);
  }

  static int hexToInt(String hex) {
    return int.parse(hex, radix: 16);
  }

  static double hexToDouble(String hex) {
    return int.parse(hex, radix: 16) / 1e18;
  }

  double truncateDouble(double val, int places) {
    num mod = pow(10.0, places);
    return ((val * mod).round().toDouble() / mod);
  }

// Parse double
  double parsedDouble(value) {
    double res = 0.0;

    if (value != null) res = double.parse(value.toString());
    return res;
  }

// To Big Int
  static toBigInt(amount, [decimalLength]) {
    var numString = amount.toString();
    var numStringArray = numString.split('.');
    decimalLength ??= 18;
    var val = '';

    val = numStringArray[0];
    if (numStringArray.length == 2) {
      var decimalPart = numStringArray[1];
      if (decimalPart.length > decimalLength) {
        debugPrint('decimalPart before: $decimalPart');
        debugPrint('decimalLength: $decimalLength');
        decimalPart = decimalPart.substring(0, decimalLength);
        debugPrint('decimalPart after: $decimalPart');
      }
      decimalLength -= decimalPart.length;
      val += decimalPart;
    }

    var valInt = int.parse(val);
    val = valInt.toString();
    if (decimalLength > 0) {
      for (var i = 0; i < decimalLength; i++) {
        val += '0';
      }
    }

    debugPrint('toBigInt value: $val');
    return val;
  }

// pass value to format with decimal digits needed
  static String currencyFormat(double value, int decimalDigits) {
    String holder = '';
    holder =
        NumberFormat.simpleCurrency(decimalDigits: decimalDigits).format(value);
    holder = holder.substring(1);
    return holder;
  }

// Time Format
  timeFormatted(timeStamp) {
    var time = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
    return '${addZeroInFrontForSingleDigit(time.hour.toString())}:${addZeroInFrontForSingleDigit(time.minute.toString())}:${addZeroInFrontForSingleDigit(time.second.toString())}';
  }

  String addZeroInFrontForSingleDigit(String value) {
    String holder = '';
    if (value.length == 1) {
      holder = '0$value';
    } else {
      holder = value;
    }

    return holder;
  }

  // check decimal places more than 6
  checkDecimal(double value) {
    String valueToString = value.toString();
  }

  // md5 hashing a random number
  String md5RandomString() {
    final randomNumber = Random().nextDouble();
    final randomBytes = utf8.encode(randomNumber.toString());
    final randomString = md5.convert(randomBytes).toString();
    return randomString;
  }

// sha1 hashing a random number
  String sha1RandomString() {
    final randomNumber = Random().nextDouble();
    final randomBytes = utf8.encode(randomNumber.toString());
    final randomString = sha1.convert(randomBytes).toString();
    return randomString;
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  final log = getLogger('DecimalTextInputFormatter');
  DecimalTextInputFormatter({int? decimalRange, bool? activatedNegativeValues})
      : assert(decimalRange == null || decimalRange >= 0,
            'DecimalTextInputFormatter declaretion error') {
    String dp = (decimalRange != null && decimalRange > 0)
        ? "([.][0-9]{0,$decimalRange}){0,1}"
        : "";
    String num = "[0-9]*$dp";

    if (activatedNegativeValues!) {
      _exp = RegExp("^((((-){0,1})|((-){0,1}[0-9]$num))){0,1}\$");
    } else {
      _exp = RegExp("^($num){0,1}\$");
    }
  }
  late RegExp _exp;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (_exp.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}
