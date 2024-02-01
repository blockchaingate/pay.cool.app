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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/api_routes.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/wallet/wallet_features/wallet_features_viewmodel.dart';
import 'package:stacked/stacked.dart';

class WalletFeaturesView extends StatefulWidget {
  const WalletFeaturesView({super.key});

  @override
  State<WalletFeaturesView> createState() => _WalletFeaturesViewState();
}

class _WalletFeaturesViewState extends State<WalletFeaturesView>
    with TickerProviderStateMixin {
  final log = getLogger('WalletFeatures');
  TabController? tabController;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    tabController!.addListener(() {
      _handleTabSelection();
    });
    super.initState();
  }

  @override
  dispose() {
    tabController!.removeListener(_handleTabSelection);
    tabController!.dispose();
    super.dispose();
  }

  void _handleTabSelection() {}

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ViewModelBuilder<WalletFeaturesViewModel>.reactive(
      viewModelBuilder: () => WalletFeaturesViewModel(),
      onViewModelReady: (model) {
        model.context = context;
        model.init();
      },
      builder: (context, model, child) => Scaffold(
        backgroundColor: white,
        appBar: customAppBarWithIcon(
          title: model.walletInfo!.tickerName,
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
                size: 20,
              )),
          actions: [
            IconButton(
              onPressed: () {
                model.updateFavWalletCoinsList(model.walletInfo!.tickerName!);
              },
              icon: model.isFavorite
                  ? const Icon(Icons.star, color: Colors.black87, size: 20)
                  : const Icon(Icons.star_border_outlined,
                      color: Colors.black87, size: 22),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                width: 60,
                height: 60,
                child: CachedNetworkImage(
                  imageUrl:
                      '$WalletCoinsLogoUrl${model.walletInfo!.tickerName!.toLowerCase()}.png',
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
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
              Text(
                "${model.walletInfo!.availableBalance} ${model.walletInfo!.tickerName}",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              UIHelper.verticalSpaceSmall,
              Text(
                "\$ ${model.walletInfo!.usdValue}",
                style: TextStyle(color: Colors.black26, fontSize: 12),
              ),
              UIHelper.verticalSpaceSmall,
              Container(
                width: size.width,
                height: size.height * 0.1,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            "${FlutterI18n.translate(context, "wallet")} ${FlutterI18n.translate(context, "balance")}",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 12)),
                        Text(
                            "${model.walletInfo!.availableBalance} ${model.walletInfo!.tickerName}",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 12)),
                      ],
                    ),
                    UIHelper.verticalSpaceSmall,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            "Exchangily ${FlutterI18n.translate(context, "balance")}",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 12)),
                        Text(
                            "${model.walletInfo!.inExchange} ${model.walletInfo!.tickerName}",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TabBar(
                      dividerHeight: 0,
                      controller: tabController,
                      labelColor: primaryColor,
                      unselectedLabelColor: grey,
                      indicatorColor: primaryColor,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorPadding: EdgeInsets.fromLTRB(35, 0, 35, 10),
                      indicatorWeight: 3,
                      labelStyle:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      tabs: [
                        Tab(
                          text: FlutterI18n.translate(context, "record"),
                        ),
                        Tab(
                          text: FlutterI18n.translate(context, "overview"),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: SizedBox(),
                  )
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  physics: AlwaysScrollableScrollPhysics(),
                  children: [
                    SingleChildScrollView(
                        child: model.transactionHistory != null
                            ? Column(
                                children: [
                                  for (var i = 0;
                                      i <
                                          model.transactionHistory!.history
                                              .length;
                                      i++)
                                    model.getRecords(size, i),
                                ],
                              )
                            : SizedBox()),
                    Center(
                      child: Text(
                        FlutterI18n.translate(context, "noData"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 1,
              child: Container(
                height: 50,
                margin: EdgeInsets.symmetric(horizontal: 5),
                child: ElevatedButton.icon(
                  icon: Icon(Icons.arrow_circle_up,
                      color: Colors.white, size: 20),
                  label: Text(FlutterI18n.translate(context, "send"),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      )),
                  onPressed: () {
                    var route = model.features[1].route;
                    Navigator.pushNamed(context, '/$route',
                        arguments: model.walletInfo!);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: buttonGreen,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                height: 50,
                margin: EdgeInsets.symmetric(horizontal: 5),
                child: ElevatedButton.icon(
                  icon: Icon(Icons.arrow_circle_down,
                      color: Colors.white, size: 20),
                  label: Text(FlutterI18n.translate(context, "receive"),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      )),
                  onPressed: () {
                    var route = model.features[0].route;
                    Navigator.pushNamed(context, '/$route',
                        arguments: model.walletInfo!);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: buttonPurple,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                height: 50,
                margin: EdgeInsets.symmetric(horizontal: 5),
                child: ElevatedButton.icon(
                  icon: Icon(Icons.swap_horizontal_circle_outlined,
                      size: 20, color: Colors.white),
                  label: Text(FlutterI18n.translate(context, "transfer"),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      )),
                  onPressed: () {
                    Navigator.pushNamed(context, '/transfer',
                        arguments: model.walletInfo!);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: buttonOrange,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
