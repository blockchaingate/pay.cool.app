import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/environments/environment_type.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/wallet/wallet_dashboard_viewmodel.dart';
import 'package:shimmer/shimmer.dart';

class TotalBalanceCardWidget extends StatelessWidget {
  const TotalBalanceCardWidget({Key? key, required this.model})
      : super(key: key);
  final WalletDashboardViewModel model;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        Positioned(
            bottom: 20,
            right: 30,
            left: 30,
            child: Card(
              elevation: model.elevation,
              color: isProduction ? secondaryColor : red.withAlpha(200),
              child: Container(
                width: 350,
                height: 90,
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                        flex: 1,
                        child: Image.asset(
                          'assets/images/wallet-page/dollar-sign.png',
                          width: 30,
                          height: 30,
                          color: iconBackgroundColor, // image background color
                          fit: BoxFit.contain,
                        )),
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(
                              FlutterI18n.translate(
                                  context, "totalWalletBalance"),
                              style: headText4),
                          model.isBusy
                              ? Shimmer.fromColors(
                                  baseColor: primaryColor,
                                  highlightColor: white,
                                  child: Text(
                                    '${model.totalUsdBalance} USD',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                )
                              : Text('${model.totalUsdBalance} USD',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                          fontWeight: FontWeight.w400,
                                          color: black)),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                          // child: Widget(),
                          ),
                    )
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

class TotalBalanceCardWidget2 extends StatelessWidget {
  const TotalBalanceCardWidget2({Key? key, required this.model})
      : super(key: key);
  final WalletDashboardViewModel model;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        Positioned(
            bottom: 20,
            right: 30,
            left: 30,
            child: Card(
              elevation: model.elevation,
              color: isProduction ? secondaryColor : red.withAlpha(200),
              child: Container(
                //duration: Duration(milliseconds: 250),
                width: 350,
                height: 90,
                //model.totalBalanceContainerWidth,
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    //Announcement Widget
                    Expanded(
                        flex: 1,
                        child:

                            // model.announceList == null ||
                            //         model.announceList.length < 1
                            //     ?
                            Container(
                                decoration: const BoxDecoration(
                                    color: iconBackgroundColor,
                                    shape: BoxShape.circle),
                                width: 30,
                                height: 30,
                                child: Icon(
                                  // Icons.local_gas_station,
                                  MdiIcons.finance,
                                  color: isProduction
                                      ? secondaryColor
                                      : red.withAlpha(200),
                                ))),
                    Expanded(
                      flex: 3,
                      child: model.isBusy
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                UIHelper.horizontalSpaceSmall,
                                Padding(
                                  padding: const EdgeInsets.only(right: 3.0),
                                  child: Text(
                                      FlutterI18n.translate(
                                          context, "totalExchangeBalance"),
                                      style: headText6),
                                ),
                                Shimmer.fromColors(
                                    baseColor: primaryColor,
                                    highlightColor: white,
                                    child: Text(
                                        '${model.totalExchangeBalance} USD',
                                        style: subText1)),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                UIHelper.horizontalSpaceSmall,
                                Padding(
                                  padding: const EdgeInsets.only(right: 3.0),
                                  child: Text(
                                      FlutterI18n.translate(
                                          context, "totalExchangeBalance"),
                                      style: headText4),
                                ),
                                Text('${model.totalExchangeBalance} USD',
                                    style: subText1),
                              ],
                            ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                          // child: Widget(),
                          ),
                    )
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

// class TotalBalanceCardWidget3 extends StatelessWidget {
//   const TotalBalanceCardWidget3({Key? key, required this.model})
//       : super(key: key);
//   final WalletDashboardViewModel model;

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       alignment: Alignment.center,
//       children: <Widget>[
//         Positioned(
//             bottom: 20,
//             right: 30,
//             left: 30,
//             child: Card(
//               elevation: model.elevation,
//               color: isProduction ? secondaryColor : red.withAlpha(200),
//               child: Container(
//                 width: 350,
//                 height: 90,
//                 alignment: Alignment.center,
//                 padding: const EdgeInsets.all(10),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     AddGasWithShowcaseWidget(model: model),
//                   ],
//                 ),
//               ),
//             )),
//       ],
//     );
//   }
// }
