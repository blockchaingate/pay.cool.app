import 'package:flutter/material.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/shared/ui_helpers.dart';

class ShimmerMarketTradesLayout extends StatelessWidget {
  const ShimmerMarketTradesLayout({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = 20;
    double width = 50;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              height: height,
              width: width - 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1),
                color: primaryColor.withAlpha(155),
              ),
            ),
          ),
          UIHelper.horizontalSpaceSmall,
        ],
      ),
    );
  }
}