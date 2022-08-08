import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/views/wallet/wallet_dashboard_viewmodel.dart';
//import 'package:showcaseview/showcaseview.dart';

class DepositWidget extends StatelessWidget {
  const DepositWidget({Key key, this.model, this.index, this.tickerName})
      : super(key: key);

  final WalletDashboardViewModel model;
  final int index;
  final String tickerName;

  @override
  Widget build(BuildContext context) {
    // model.showcaseEvent(context);
    return InkWell(
        child:
            // tickerName.toUpperCase() == 'FAB' &&
            //         (model.isShowCaseView || model.gasAmount < 0.0001) &&
            //         !model.isBusy
            //     ? Showcase(
            //         key: model.globalKeyTwo,
            //         descTextStyle: TextStyle(fontSize: 9, color: black),
            //         description: FlutterI18n.translate(
            //             context, "walletDashboardInstruction2"),
            //         child: buildPaddingDeposit(context),
            //       )
            //     :
            buildPaddingDeposit(context),
        onTap: () => model.routeWithWalletInfoArgs(
            model.wallets[index], DepositViewRoute));
  }

  Padding buildPaddingDeposit(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 8.0, right: 5.0, left: 2.0),
        child: Column(
          children: [
            Text(
              FlutterI18n.translate(context, "deposit"),
              style: subText2.copyWith(fontSize: 8),
            ),
            const Icon(Icons.arrow_downward, color: green, size: 16),
          ],
        ));
  }
}
