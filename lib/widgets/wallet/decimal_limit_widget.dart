import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/custom_styles.dart';

class DecimalLimitWidget extends StatelessWidget {
  final int decimalLimit;
  const DecimalLimitWidget({Key key, this.decimalLimit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(FlutterI18n.translate(context, "decimalLimit") + ': ',
              style: headText6),
          Text(decimalLimit.toString(), style: headText6),
        ],
      ),
    );
  }
}
