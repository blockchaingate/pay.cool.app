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

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/environments/environment_type.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/utils/number_util.dart';
import "package:flutter/material.dart";
import 'package:paycool/constants/colors.dart';

class GasBalanceAndAddGasButtonWidget extends StatelessWidget {
  final double gasAmount;
  const GasBalanceAndAddGasButtonWidget({Key? key, required this.gasAmount})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Container(
                  decoration: const BoxDecoration(
                      color: iconBackgroundColor, shape: BoxShape.circle),
                  width: 26,
                  height: 26,
                  child: Icon(
                    Icons.local_gas_station,
                    size: 20,
                    color: isProduction ? secondaryColor : red.withAlpha(200),
                  )),
            ),
            UIHelper.horizontalSpaceSmall,
            Text(
              "${FlutterI18n.translate(context, "gas")}: ${NumberUtil.roundDouble(gasAmount, decimalPlaces: 6)}",
              style: headText5.copyWith(wordSpacing: 1.25),
            ),
            UIHelper.horizontalSpaceSmall,
            MaterialButton(
              minWidth: 70.0,
              height: 24,
              color: primaryColor,
              padding: const EdgeInsets.all(0),
              onPressed: () {
                Navigator.pushNamed(context, AddGasViewRoute);
              },
              child: Text(
                FlutterI18n.translate(context, "addGas"),
                style: headText6.copyWith(color: secondaryColor),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
