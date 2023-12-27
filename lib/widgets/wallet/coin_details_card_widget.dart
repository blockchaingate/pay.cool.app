import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:paycool/constants/api_routes.dart';
import 'package:paycool/constants/colors.dart';
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
    Size size = MediaQuery.of(context).size;
    String finalTickerName = '';
    String logoTicker = '';

    var specialTickerRes = WalletUtil.updateSpecialTokensTickerName(tickerName);
    finalTickerName = specialTickerRes['tickerName']!;
    logoTicker = specialTickerRes['logoTicker']!;
    if (model.hideSmallAmountCheck(wallets[index])) {
      return Container();
    } else {
      return Card(
        color: secondaryColor,
        elevation: 0,
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onDoubleTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          onTap: () {
            model.routeWithWalletInfoArgs(
                wallets[index], walletFeaturesViewRoute);
          },
          child: SizedBox(
            width: size.width * 0.9,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Logo
                SizedBox(
                  height: 50,
                  width: 50,
                  child: CachedNetworkImage(
                    imageUrl:
                        '$WalletCoinsLogoUrl${logoTicker.toLowerCase()}.png',
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 500),
                    fadeOutDuration: const Duration(milliseconds: 500),
                    fadeOutCurve: Curves.easeOut,
                    fadeInCurve: Curves.easeIn,
                    imageBuilder: (context, imageProvider) => FadeInImage(
                      placeholder: const AssetImage(
                          'assets/images/launcher/paycool-logo.png'),
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                UIHelper.horizontalSpaceMedium,

                // Tickername and available balance
                Expanded(
                  flex: 5,
                  child: SizedBox(
                    width: size.width * 0.4,
                    height: 50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text(
                          finalTickerName.toUpperCase(),
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          wallets[index].unlockedExchangeBalance!.isNegative
                              ? "0"
                              : NumberUtil.roundDouble(
                                      wallets[index].unlockedExchangeBalance!,
                                      decimalPlaces: 6)
                                  .toString(),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: textHintGrey),
                        ),
                      ],
                    ),
                  ),
                ),

                // Value USD and deposit - withdraw Container column
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    width: size.width * 0.3,
                    height: 50,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          wallets[index].balance!.isNegative
                              ? "0"
                              : NumberUtil.roundDouble(wallets[index].balance!,
                                      decimalPlaces: 6)
                                  .toString(),
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '\$',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: textHintGrey),
                            ),
                            Text(
                              wallets[index].usdValue!.usd!.isNegative
                                  ? "0"
                                  : NumberUtil.roundDouble(
                                          (!wallets[index].balance!.isNegative
                                                  ? wallets[index].balance
                                                  : 0.0)! *
                                              wallets[index].usdValue!.usd!,
                                          decimalPlaces: 2)
                                      .toString(),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: textHintGrey),
                            ),
                          ],
                        ),
                      ],
                    ),
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
