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
  const WalletFeaturesView({Key? key}) : super(key: key);

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
                  icon: Icon(Icons.arrow_circle_up),
                  label: Text(
                    FlutterI18n.translate(context, "send"),
                  ),
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
                  icon: Icon(Icons.arrow_circle_down),
                  label: Text(
                    FlutterI18n.translate(context, "receive"),
                  ),
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
                  icon: Icon(Icons.swap_horizontal_circle_outlined),
                  label: Text(
                    FlutterI18n.translate(context, "transfer"),
                  ),
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

  // Expanded(
  //   child: ListView(
  //     children: <Widget>[
  //       LayoutBuilder(
  //         builder:
  //             (BuildContext context, BoxConstraints constraints) {
  //           if (isPhone()) {
  //             return Container(
  //               height: 225,
  //               decoration: const BoxDecoration(
  //                   image: DecorationImage(
  //                       image: AssetImage(
  //                           'assets/images/paycool/walletBg8.jpg'),
  //                       fit: BoxFit.cover)),
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                 children: <Widget>[
  //                   SizedBox(
  //                     width: MediaQuery.of(context).size.width,
  //                     child: Stack(
  //                       children: [
  //                         Align(
  //                           alignment: Alignment.topCenter,
  //                           child: Container(
  //                               height: 225,
  //                               decoration: BoxDecoration(
  //                                   color: Colors.white,
  //                                   gradient: LinearGradient(
  //                                       begin: FractionalOffset
  //                                           .topCenter,
  //                                       end: FractionalOffset
  //                                           .bottomCenter,
  //                                       colors: [
  //                                         secondaryColor
  //                                             .withOpacity(0.0),
  //                                         secondaryColor
  //                                             .withOpacity(0.4),
  //                                         secondaryColor
  //                                       ],
  //                                       stops: const [
  //                                         0.0,
  //                                         0.5,
  //                                         1.0
  //                                       ]))),
  //                         ),
  //                         Align(
  //                             alignment: Alignment.topLeft,
  //                             child: IconButton(
  //                                 icon: const Icon(
  //                                   Icons.arrow_back,
  //                                   color: Colors.white,
  //                                 ),
  //                                 onPressed: () {
  //                                   model.navigationService
  //                                       .navigateTo('/dashboard');
  //                                 })),
  //                         Align(
  //                           alignment: Alignment.topRight,
  //                           child: IconButton(
  //                             padding: EdgeInsets.zero,
  //                             icon: model.isFavorite
  //                                 ? const Icon(Icons.star,
  //                                     color: white, size: 20)
  //                                 : const Icon(
  //                                     Icons.star_border_outlined,
  //                                     color: white,
  //                                     size: 22),
  //                             onPressed: () => model
  //                                 .updateFavWalletCoinsList(model
  //                                     .walletInfo!.tickerName!),
  //                           ),
  //                         ),
  //                         Positioned(
  //                             bottom: 10,
  //                             left: 0,
  //                             right: 0,
  //                             child:
  //                                 headerContainer(context, model))
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             );
  //           } else {
  //             return Container(
  //                 margin: EdgeInsets.only(top: 10),
  //                 child: headerContainer(context, model));
  //           }
  //         },
  //       ),
  //       Container(
  //         color: secondaryColor,
  //         padding: const EdgeInsets.symmetric(
  //             vertical: 10, horizontal: 25),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //           children: <Widget>[
  //             UIHelper.horizontalSpaceMedium,
  //             SizedBox(
  //               height: model.containerHeight,
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 mainAxisSize: MainAxisSize.max,
  //                 children: <Widget>[
  //                   Expanded(
  //                     child: Container(
  //                       child: _featuresCard(context, 0, model),
  //                     ),
  //                   ),
  //                   Expanded(
  //                     child: Container(
  //                         child: _featuresCard(context, 1, model)),
  //                   )
  //                 ],
  //               ),
  //             ),
  //             model.walletInfo!.tickerName == 'Maticm'
  //                 ? Container()
  //                 : SizedBox(
  //                     height: model.containerHeight,
  //                     child: Row(
  //                         mainAxisAlignment:
  //                             MainAxisAlignment.spaceBetween,
  //                         children: <Widget>[
  //                           Expanded(
  //                             child: Container(
  //                               child: _featuresCard(
  //                                   context, 2, model),
  //                             ),
  //                           ),
  //                           Expanded(
  //                             child: Container(
  //                               child: _featuresCard(
  //                                   context, 3, model),
  //                             ),
  //                           ),
  //                         ]),
  //                   ),

  //             SizedBox(
  //               height: model.containerHeight,
  //               child: Row(
  //                   mainAxisAlignment:
  //                       MainAxisAlignment.spaceBetween,
  //                   children: <Widget>[
  //                     model.errDepositItem != null
  //                         ? Expanded(
  //                             child: Container(
  //                               child: _featuresCard(
  //                                   context, 4, model),
  //                             ),
  //                           )
  //                         : Container(),
  //                     model.walletInfo!.tickerName == 'FAB'
  //                         ? Expanded(
  //                             child:
  //                                 _featuresCard(context, 5, model),
  //                           )
  //                         : Container(),
  //                   ]),
  //             ),

  //             // UIHelper.horizontalSpaceSmall,
  //             // Transaction History Column
  //             Container(
  //               margin: const EdgeInsets.symmetric(horizontal: 0.0),
  //               padding: const EdgeInsets.symmetric(
  //                   horizontal: 3.0, vertical: 8.0),
  //               child: Material(
  //                 borderRadius: BorderRadius.circular(5),
  //                 color: secondaryColor,
  //                 elevation: model.elevation,
  //                 child: InkWell(
  //                   splashColor: primaryColor.withAlpha(30),
  //                   onTap: () {
  //                     var route = model.features[6].route;
  //                     Navigator.pushNamed(context, route,
  //                         arguments: model.walletInfo!);
  //                   },
  //                   child: Container(
  //                     height: 45,
  //                     padding: const EdgeInsets.symmetric(
  //                         vertical: 9, horizontal: 6),
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: <Widget>[
  //                         Container(
  //                             decoration: BoxDecoration(
  //                                 color: walletCardColor,
  //                                 borderRadius:
  //                                     BorderRadius.circular(50),
  //                                 boxShadow: [
  //                                   BoxShadow(
  //                                       color: model
  //                                           .features[6].shadowColor
  //                                           .withOpacity(0.2),
  //                                       offset: const Offset(0, 2),
  //                                       blurRadius: 10,
  //                                       spreadRadius: 3)
  //                                 ]),
  //                             child: Icon(
  //                               model.features[6].icon,
  //                               size: 18,
  //                               color: white,
  //                             )),
  //                         Padding(
  //                           padding:
  //                               const EdgeInsets.only(left: 4.0),
  //                           child: Text(
  //                             model.features[6].name,
  //                             style: subText1,
  //                           ),
  //                         )
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   ),
  // ),

  // //coin name and balance card
  // Widget headerContainer(BuildContext context, WalletFeaturesViewModel model) {
  //   return Container(
  //       padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 25),
  //       height: 160,
  //       alignment: const FractionalOffset(0.0, 2.0),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //         children: <Widget>[
  //           Container(
  //             padding: const EdgeInsets.only(left: 5),
  //             child: Row(
  //               children: <Widget>[
  //                 Text(model.specialTicker!, style: headText5),
  //                 const Padding(
  //                   padding: EdgeInsets.all(2.0),
  //                   child: Icon(
  //                     Icons.arrow_forward,
  //                     size: 17,
  //                     color: white,
  //                   ),
  //                 ),
  //                 Text(model.walletInfo!.name ?? '', style: subText1)
  //               ],
  //             ),
  //           ),
  //           Expanded(
  //             child: Stack(
  //               clipBehavior: Clip.antiAlias,
  //               alignment: Alignment.bottomCenter,
  //               children: <Widget>[
  //                 Positioned(
  //                   //   bottom: -15,
  //                   child: _buildTotalBalanceCard(
  //                       context, model, model.walletInfo!),
  //                 )
  //               ],
  //             ),
  //           )
  //         ],
  //       ));
  // }

  // // Build Total Balance Card
  // Widget _buildTotalBalanceCard(
  //     context, WalletFeaturesViewModel model, walletInfo) {
  //   String message = FlutterI18n.translate(context, "sameBalanceNote");
  //   String nativeTicker = model.specialTicker!.split('(')[0];
  //   return Card(
  //       elevation: model.elevation,
  //       color: secondaryColor,
  //       child: Container(
  //         padding: const EdgeInsets.all(5),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //           children: <Widget>[
  //             Container(
  //               padding:
  //                   const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                 children: <Widget>[
  //                   Expanded(
  //                     flex: 4,
  //                     child: Text(
  //                       //  '${model.specialTicker} ' +
  //                       FlutterI18n.translate(context, "totalBalance"),
  //                       style: subText1.copyWith(color: buyPrice),
  //                     ),
  //                   ),
  //                   Expanded(
  //                     flex: 2,
  //                     child: InkWell(
  //                       onTap: () async {
  //                         await model.refreshBalance();
  //                       },
  //                       child: model.isBusy
  //                           ? SizedBox(
  //                               height: 20,
  //                               child: model.sharedService.loadingIndicator(
  //                                   isCustomWidthHeight: true,
  //                                   width: 15,
  //                                   height: 15))
  //                           : const Center(
  //                               child: Icon(
  //                                 Icons.refresh,
  //                                 color: black,
  //                                 size: 18,
  //                               ),
  //                             ),
  //                     ),
  //                   ),
  //                   Expanded(
  //                     flex: 4,
  //                     child: Text(
  //                       '${NumberUtil.roundDouble(model.walletInfo!.usdValue!).toString()} USD',
  //                       textAlign: TextAlign.right,
  //                       style: subText1.copyWith(color: buyPrice),
  //                     ),
  //                   )
  //                 ],
  //               ),
  //             ),
  //             UIHelper.verticalSpaceSmall,
  //             // Middle column row containes wallet balance and in exchnage text
  //             Container(
  //               color: primaryColor.withAlpha(27),
  //               padding:
  //                   const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: <Widget>[
  //                   Text(
  //                       //  '${model.specialTicker} '.toUpperCase() +
  //                       FlutterI18n.translate(context, "walletbalance"),
  //                       style: subText1),
  //                   Text(
  //                       '${NumberUtil.roundDouble(model.walletInfo!.availableBalance!, decimalPlaces: model.decimalLimit).toString()} ${model.specialTicker}',
  //                       style: headText5),
  //                 ],
  //               ),
  //             ),
  //             // Middle column row contains unconfirmed balance
  //             model.walletInfo!.tickerName == 'FAB'
  //                 ? Container(
  //                     padding: const EdgeInsets.symmetric(
  //                         horizontal: 5.0, vertical: 5.0),
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                       children: <Widget>[
  //                         Text(
  //                             //  '${model.specialTicker} '.toUpperCase() +
  //                             FlutterI18n.translate(
  //                                 context, "unConfirmedBalance"),
  //                             style: subText1),
  //                         Text(
  //                             '${NumberUtil.roundDouble(model.unconfirmedBalance, decimalPlaces: model.decimalLimit).toString()} ${model.specialTicker}',
  //                             style: headText5),
  //                       ],
  //                     ),
  //                   )
  //                 : Container(),
  //             // Last column row contains wallet balance and exchange balance
  //             Container(
  //               padding:
  //                   const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: <Widget>[
  //                   Expanded(
  //                     flex: 4,
  //                     child: Text(
  //                         '${FlutterI18n.translate(context, "inExchange")} ${model.specialTicker!.contains('(') ? '\n$message $nativeTicker' : ''}',
  //                         style: subText1),
  //                   ),
  //                   Expanded(
  //                       flex: 4,
  //                       child: Text(
  //                           NumberUtil.roundDouble(
  //                                   model.walletInfo!.inExchange!,
  //                                   decimalPlaces: model.decimalLimit)
  //                               .toString(),
  //                           textAlign: TextAlign.right,
  //                           style: subText1)),
  //                 ],
  //               ),
  //             )
  //           ],
  //         ),
  //       ));
  // }

  // // Features Card
  // Widget _featuresCard(context, index, WalletFeaturesViewModel model) => Card(
  //       color: secondaryColor,
  //       elevation: model.elevation,
  //       child: InkWell(
  //         splashColor: primaryColor.withAlpha(30),
  //         onTap: (model.features[index].route != '')
  //             ? () {
  //                 var route = model.features[index].route;
  //                 Navigator.pushNamed(context, '/$route',
  //                     arguments: model.walletInfo!);
  //               }
  //             : null,
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //           children: <Widget>[
  //             Container(
  //                 width: 60,
  //                 height: 60,
  //                 decoration: BoxDecoration(
  //                     color: model.features[index].shadowColor.withOpacity(1.0),
  //                     borderRadius: BorderRadius.circular(50),
  //                     boxShadow: [
  //                       BoxShadow(
  //                           color: model.features[index].shadowColor
  //                               .withOpacity(0.2),
  //                           offset: const Offset(0, 9),
  //                           blurRadius: 10,
  //                           spreadRadius: 3)
  //                     ]),
  //                 child: Center(
  //                   child: Image.asset(
  //                     "assets/images/paycool/${model.iconImg[index]}",
  //                     width: 40,
  //                     height: 40,
  //                   ),
  //                 )),
  //             Text(
  //               model.features[index].name,
  //               style: subText1,
  //             )
  //           ],
  //         ),
  //       ),
  //     );
}
