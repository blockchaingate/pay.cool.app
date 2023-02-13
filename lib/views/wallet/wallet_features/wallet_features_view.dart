/*
* Copyright (c) 2020 Exchangily LLC
*
* Licensed under Apache License v2.0
* You may obtain a copy of the License at
*
*      https://www.apache.org/licenses/LICENSE-2.0
*
*----------------------------------------------------------------------
* Author: barry-ruprai@exchangily.com, ken.qiu@exchangily.com
*----------------------------------------------------------------------
*/

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/constants/ui_var.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/models/wallet/wallet.dart';

import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/utils/number_util.dart';

import 'package:flutter/material.dart';
import 'package:paycool/views/wallet/wallet_features/wallet_features_viewmodel.dart';
import 'package:stacked/stacked.dart';

class WalletFeaturesView extends StatelessWidget {
  final WalletInfo walletInfo;
  WalletFeaturesView({Key? key, required this.walletInfo}) : super(key: key);
  final log = getLogger('WalletFeatures');

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<WalletFeaturesViewModel>.reactive(
      viewModelBuilder: () => WalletFeaturesViewModel(),
      onViewModelReady: (model) {
        model.walletInfo = walletInfo;
        model.context = context;
        model.init();
      },
      builder: (context, model, child) => Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: primaryColor,
          toolbarHeight: 2.0,
        ),
        key: key,
        body: ListView(
          children: <Widget>[
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (isPhone()) {
                  return Container(
                    height: 225,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(
                                'assets/images/paycool/walletBg8.jpg'),
                            fit: BoxFit.cover)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                    height: 225,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        gradient: LinearGradient(
                                            begin: FractionalOffset.topCenter,
                                            end: FractionalOffset.bottomCenter,
                                            colors: [
                                              secondaryColor.withOpacity(0.0),
                                              secondaryColor.withOpacity(0.4),
                                              secondaryColor
                                            ],
                                            stops: const [
                                              0.0,
                                              0.5,
                                              1.0
                                            ]))),
                              ),
                              Align(
                                  alignment: Alignment.topLeft,
                                  child: IconButton(
                                      icon: const Icon(
                                        Icons.arrow_back,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        model.navigationService
                                            .navigateTo('/dashboard');
                                      })),
                              Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: model.isFavorite
                                      ? const Icon(Icons.star,
                                          color: white, size: 20)
                                      : const Icon(Icons.star_border_outlined,
                                          color: white, size: 22),
                                  onPressed: () =>
                                      model.updateFavWalletCoinsList(
                                          model.walletInfo.tickerName!),
                                ),
                              ),
                              Positioned(
                                  bottom: 10,
                                  left: 0,
                                  right: 0,
                                  child: headerContainer(context, model))
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return headerContainer(context, model);
                }
              },
            ),
            Container(
              color: secondaryColor,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  UIHelper.horizontalSpaceMedium,
                  SizedBox(
                    height: model.containerHeight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            child: _featuresCard(context, 0, model),
                          ),
                        ),
                        Expanded(
                          child: Container(
                              child: _featuresCard(context, 1, model)),
                        )
                      ],
                    ),
                  ),
                  model.walletInfo.tickerName == 'Maticm'
                      ? Container()
                      : SizedBox(
                          height: model.containerHeight,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    child: _featuresCard(context, 2, model),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: _featuresCard(context, 3, model),
                                  ),
                                ),
                              ]),
                        ),

                  SizedBox(
                    height: model.containerHeight,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          model.errDepositItem != null
                              ? Expanded(
                                  child: Container(
                                    child: _featuresCard(context, 4, model),
                                  ),
                                )
                              : Container(),
                          walletInfo.tickerName == 'FAB'
                              ? Expanded(
                                  child: _featuresCard(context, 5, model),
                                )
                              : Container(),
                        ]),
                  ),

                  // UIHelper.horizontalSpaceSmall,
                  // Transaction History Column
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 0.0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 3.0, vertical: 8.0),
                    child: Material(
                      borderRadius: BorderRadius.circular(5),
                      color: secondaryColor,
                      elevation: model.elevation,
                      child: InkWell(
                        splashColor: primaryColor.withAlpha(30),
                        onTap: () {
                          var route = model.features[6].route;
                          Navigator.pushNamed(context, route,
                              arguments: walletInfo);
                        },
                        child: Container(
                          height: 45,
                          padding: const EdgeInsets.symmetric(
                              vertical: 9, horizontal: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                  decoration: BoxDecoration(
                                      color: walletCardColor,
                                      borderRadius: BorderRadius.circular(50),
                                      boxShadow: [
                                        BoxShadow(
                                            color: model.features[6].shadowColor
                                                .withOpacity(0.2),
                                            offset: Offset(0, 2),
                                            blurRadius: 10,
                                            spreadRadius: 3)
                                      ]),
                                  child: Icon(
                                    model.features[6].icon,
                                    size: 18,
                                    color: white,
                                  )),
                              Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Text(
                                  model.features[6].name,
                                  style: subText1,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),

        // bottomNavigationBar: BottomNavBar(count: 0),
      ),
    );
  }

  //coin name and balance card
  Widget headerContainer(BuildContext context, WalletFeaturesViewModel model) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 25),
        height: 160,
        alignment: const FractionalOffset(0.0, 2.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 5),
              child: Row(
                children: <Widget>[
                  Text(model.specialTicker, style: headText5),
                  const Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 17,
                      color: white,
                    ),
                  ),
                  Text(walletInfo.name ?? '', style: subText1)
                ],
              ),
            ),
            Expanded(
              child: Stack(
                clipBehavior: Clip.antiAlias,
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  Positioned(
                    //   bottom: -15,
                    child: _buildTotalBalanceCard(context, model, walletInfo),
                  )
                ],
              ),
            )
          ],
        ));
  }

  // Build Total Balance Card

  Widget _buildTotalBalanceCard(
      context, WalletFeaturesViewModel model, walletInfo) {
    String message = FlutterI18n.translate(context, "sameBalanceNote");
    String nativeTicker = model.specialTicker.split('(')[0];
    return Card(
        elevation: model.elevation,
        color: secondaryColor,
        child: Container(
          padding: const EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: Text(
                        //  '${model.specialTicker} ' +
                        FlutterI18n.translate(context, "totalBalance"),
                        style: subText1.copyWith(color: buyPrice),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: InkWell(
                        onTap: () async {
                          await model.refreshBalance();
                        },
                        child: model.isBusy
                            ? SizedBox(
                                height: 20,
                                child: model.sharedService.loadingIndicator())
                            : const Center(
                                child: Icon(
                                  Icons.refresh,
                                  color: black,
                                  size: 18,
                                ),
                              ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        '${NumberUtil().truncateDoubleWithoutRouding(model.walletInfo.usdValue!).toString()} USD',
                        textAlign: TextAlign.right,
                        style: subText1.copyWith(color: buyPrice),
                      ),
                    )
                  ],
                ),
              ),
              UIHelper.verticalSpaceSmall,
              // Middle column row containes wallet balance and in exchnage text
              Container(
                color: primaryColor.withAlpha(27),
                padding:
                    const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                        //  '${model.specialTicker} '.toUpperCase() +
                        FlutterI18n.translate(context, "walletbalance"),
                        style: subText1),
                    Text(
                        '${NumberUtil().truncateDoubleWithoutRouding(model.walletInfo.availableBalance!, precision: model.decimalLimit).toString()} ${model.specialTicker}',
                        style: headText5),
                  ],
                ),
              ),
              // Middle column row contains unconfirmed balance
              model.walletInfo.tickerName == 'FAB'
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5.0, vertical: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                              //  '${model.specialTicker} '.toUpperCase() +
                              FlutterI18n.translate(
                                  context, "unConfirmedBalance"),
                              style: subText1),
                          Text(
                              '${NumberUtil().truncateDoubleWithoutRouding(model.unconfirmedBalance, precision: model.decimalLimit).toString()} ${model.specialTicker}',
                              style: headText5),
                        ],
                      ),
                    )
                  : Container(),
              // Last column row contains wallet balance and exchange balance
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: Text(
                          '${FlutterI18n.translate(context, "inExchange")} ${model.specialTicker.contains('(') ? '\n$message $nativeTicker' : ''}',
                          style: subText1),
                    ),
                    Expanded(
                        flex: 4,
                        child: Text(
                            NumberUtil()
                                .truncateDoubleWithoutRouding(
                                    model.walletInfo.inExchange!,
                                    precision: model.decimalLimit)
                                .toString(),
                            textAlign: TextAlign.right,
                            style: subText1)),
                  ],
                ),
              )
            ],
          ),
        ));
  }

  // Features Card

  Widget _featuresCard(context, index, WalletFeaturesViewModel model) => Card(
        color: secondaryColor,
        elevation: model.elevation,
        child: InkWell(
          splashColor: primaryColor.withAlpha(30),
          onTap: (model.features[index].route != null &&
                  model.features[index].route != '')
              ? () {
                  var route = model.features[index].route;
                  Navigator.pushNamed(context, '/$route',
                      arguments: model.walletInfo);
                }
              : null,
          child: Container(
            // color: model.features[index].shadowColor.withOpacity(0.2),
            // padding: EdgeInsets.symmetric(vertical: 5, horizontal: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                        color:
                            model.features[index].shadowColor.withOpacity(1.0),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                              color: model.features[index].shadowColor
                                  .withOpacity(0.2),
                              offset: Offset(0, 9),
                              blurRadius: 10,
                              spreadRadius: 3)
                        ]),
                    child: Center(
                      child: Image.asset(
                        "assets/images/paycool/${model.iconImg[index]}",
                        width: 40,
                        height: 40,
                      ),
                    )
                    // Icon(
                    //   model.features[index].icon,
                    //   size: 40,
                    //   color: white,
                    // )
                    ),
                Text(
                  model.features[index].name,
                  style: subText1,
                )
              ],
            ),
          ),
        ),
      );
}
