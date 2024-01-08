import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/shared/ui_helpers.dart';

class ServerErrorWidget extends StatelessWidget {
  const ServerErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: [
        UIHelper.verticalSpaceLarge,
        Text(
          FlutterI18n.translate(context, "serverError"),
          style: headText2.copyWith(color: red),
        ),
        const Divider(
          height: 2,
          thickness: 0.2,
        ),
        Text(
          FlutterI18n.translate(context, "pleaseTryAgainLater"),
          style: headText4,
        ),
      ],
    ));
  }
}
