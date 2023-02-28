import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/api_routes.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/models/wallet/wallet_balance.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/utils/number_util.dart';
import 'package:paycool/utils/wallet/wallet_util.dart';
import 'package:paycool/views/wallet/wallet_dashboard_viewmodel.dart';
import 'package:stacked/stacked.dart';

class CoinDetailsCardWidget extends StackedView<WalletDashboardViewModel> {
  final String tickerName;
  final int index;
  final List<WalletBalance> wallets;

  final BuildContext context;

  const CoinDetailsCardWidget(
      {required this.tickerName,
      required this.index,
      required this.wallets,
      required this.context});
  @override
  WalletDashboardViewModel viewModelBuilder(BuildContext context) =>
      WalletDashboardViewModel(context: context);
  @override
  Widget builder(
      BuildContext context, WalletDashboardViewModel model, Widget? child) {
    var walletUtils = WalletUtil();
    String finalTickerName = '';
    String logoTicker = '';

    var specialTickerRes =
        walletUtils.updateSpecialTokensTickerNameForTxHistory(tickerName);
    finalTickerName = specialTickerRes['tickerName']!;
    logoTicker = specialTickerRes['logoTicker']!;
    if (model.hideSmallAmountCheck(wallets[index])) {
      return Container();
    } else {
      return Card(
        color: secondaryColor,
        elevation: 4,
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onDoubleTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          onTap: () {
            model.routeWithWalletInfoArgs(
                wallets[index], walletFeaturesViewRoute);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                UIHelper.horizontalSpaceSmall,
                // Card logo container
                Container(
                    padding: const EdgeInsets.all(8),
                    // decoration: BoxDecoration(
                    //     color: walletCardColor,
                    //     borderRadius: BorderRadius.circular(50),
                    //     boxShadow: const [
                    //       BoxShadow(
                    //           color: fabLogoColor,
                    //           offset: Offset(1.0, 5.0),
                    //           blurRadius: 10.0,
                    //           spreadRadius: 1.0),
                    //     ]),
                    child: Image.network(
                        '$WalletCoinsLogoUrl${logoTicker.toLowerCase()}.png'),
                    //asset('assets/images/wallet-page/$tickerName.png'),
                    width: 35,
                    height: 35),
                UIHelper.horizontalSpaceSmall,
                // Tickername available locked and inexchange column
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        finalTickerName.toUpperCase(),
                        style: headText3,
                      ),
                      // Available Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 5.0),
                            child: Text(
                                FlutterI18n.translate(context, "available"),
                                style: headText6),
                          ),
                          Expanded(
                            child: Text(
                                wallets[index].balance!.isNegative
                                    ? FlutterI18n.translate(
                                        context, "unavailable")
                                    : NumberUtil()
                                        .truncateDoubleWithoutRouding(
                                            wallets[index].balance!,
                                            precision: 6)
                                        .toString(),
                                style: headText6),
                          ),
                        ],
                      ),
                      // Locked Row
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 2.0, right: 5.0, bottom: 2.0),
                            child: Text(
                                FlutterI18n.translate(context, "locked"),
                                style: headText6.copyWith(color: red)),
                          ),
                          Expanded(
                            child: Text(
                                wallets[index].lockBalance!.isNegative
                                    ? FlutterI18n.translate(
                                        context, "unavailable")
                                    : NumberUtil()
                                        .truncateDoubleWithoutRouding(
                                            wallets[index].lockBalance!,
                                            precision: 6)
                                        .toString(),
                                style: headText6.copyWith(color: red)),
                          )
                        ],
                      ),
                      // Inexchange Row
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 5.0),
                            child: Text(
                                FlutterI18n.translate(context, "inExchange"),
                                textAlign: TextAlign.center,
                                style: headText6),
                          ),
                          Expanded(
                            child: Text(
                                wallets[index]
                                        .unlockedExchangeBalance!
                                        .isNegative
                                    ? FlutterI18n.translate(
                                        context, "unavailable")
                                    : NumberUtil()
                                        .truncateDoubleWithoutRouding(
                                            wallets[index]
                                                .unlockedExchangeBalance!,
                                            precision: 6)
                                        .toString(),
                                style: headText6),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Value USD and deposit - withdraw Container column
                Expanded(
                  flex: 2,
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          UIHelper.horizontalSpaceSmall,
                          const Text('\$', style: TextStyle(color: green)),
                          Expanded(
                            child: Text(
                              wallets[index].usdValue!.usd!.isNegative
                                  ? FlutterI18n.translate(
                                      context, "unavailable")
                                  : NumberUtil()
                                      .truncateDoubleWithoutRouding(
                                          (!wallets[index].balance!.isNegative
                                                  ? wallets[index].balance
                                                  : 0.0)! *
                                              wallets[index].usdValue!.usd!,
                                          precision: 2)
                                      .toString(),
                              style: const TextStyle(color: green),
                            ),
                          )
                        ],
                      ),

                      // Deposit and Withdraw Container Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          InkWell(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Column(
                                  children: [
                                    Text(
                                      FlutterI18n.translate(context, "deposit"),
                                      style: subText2.copyWith(fontSize: 8),
                                    ),
                                    const Icon(
                                      Icons.arrow_downward,
                                      color: green,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                model.routeWithWalletInfoArgs(
                                    wallets[index], DepositViewRoute);
                              }),
                          // DepositWidget(
                          //     model: model,
                          //     index: index,
                          //     tickerName: finalTickerName),
                          const Divider(
                            endIndent: 5,
                          ),
                          InkWell(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Column(
                                  children: [
                                    Text(
                                      FlutterI18n.translate(
                                          context, "withdraw"),
                                      style: subText2.copyWith(fontSize: 8),
                                    ),
                                    const Icon(
                                      Icons.arrow_upward,
                                      color: red,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                model.routeWithWalletInfoArgs(
                                    wallets[index], WithdrawViewRoute);
                              }),
                        ],
                      ),
                      wallets[index].coin == 'FAB' &&
                              wallets[index].unconfirmedBalance != 0
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0, vertical: 5.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                          //  '${model.specialTicker} '.toUpperCase() +
                                          FlutterI18n.translate(
                                              context, "unConfirmedBalance"),
                                          style:
                                              subText2.copyWith(color: yellow)),
                                      Text(
                                          '${NumberUtil().truncateDoubleWithoutRouding(wallets[index].unconfirmedBalance!, precision: 8)}  FAB',
                                          textAlign: TextAlign.start,
                                          style:
                                              subText2.copyWith(color: yellow)),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
