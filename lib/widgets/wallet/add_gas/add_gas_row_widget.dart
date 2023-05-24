import 'package:flutter/material.dart';
import 'package:paycool/views/wallet/wallet_dashboard_viewmodel.dart';
import 'package:paycool/widgets/wallet/add_gas/gas_balance_and_add_gas_button_widget.dart';
//import 'package:showcaseview/showcaseview.dart';

class AddGasWithShowcaseWidget extends StatelessWidget {
  const AddGasWithShowcaseWidget({Key? key, required this.model})
      : super(key: key);
  final WalletDashboardViewModel model;
  @override
  Widget build(BuildContext context) {
    var begin = const Offset(0.0, 1.0);
    var end = Offset.zero;
    var tween = Tween(begin: begin, end: end);
    //  if (model.isShowCaseView && model.gasAmount < 0.0001 && !model.isBusy) {
    //   model.showcaseEvent(context);
    // }
    return
        //  model.isShowCaseView || model.gasAmount < 0.0001
        //     ? SafeArea(
        //         child: Column(
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           mainAxisSize: MainAxisSize.min,
        //           children: [
        //             Showcase(
        //               key: model.globalKeyOne,
        //               //  titleTextStyle:TextStyle(decoration:T ),
        //               title: FlutterI18n.translate(context, "note") + ':',
        //               description: FlutterI18n.translate(
        //                   context, "walletDashboardInstruction1"),
        //               child: TweenAnimationBuilder(
        //                   duration: const Duration(milliseconds: 500),
        //                   tween: tween,
        //                   builder: (_, Offset offset, __) {
        //                     return Container(
        //                         child: (GasBalanceAndAddGasButtonWidget(
        //                             gasAmount: model.gasAmount)));
        //                   }),
        //             ),
        //           ],
        //         ),
        //       )
        //  :
        GasBalanceAndAddGasButtonWidget(gasAmount: model.gasAmount);
  }
}
