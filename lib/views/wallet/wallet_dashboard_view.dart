/*
* Copyright (c) 2020 Exchangily LLC
*
* Licensed under Apache License v2.0
* You may obtain a copy of the License at
*
*      https://www.apache.org/licenses/LICENSE-2.0
*
*----------------------------------------------------------------------
* Author: barry-ruprai@exchangily.com
*----------------------------------------------------------------------
*/

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/models/wallet/wallet_balance.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/wallet/wallet_dashboard_viewmodel.dart';
import 'package:paycool/widgets/bottom_nav.dart';
import 'package:paycool/widgets/shared/will_pop_scope.dart';
import 'package:paycool/widgets/shimmer_layouts/shimmer_layout.dart';
import 'package:paycool/widgets/wallet/coin_details_card_widget.dart';
import 'package:paycool/widgets/wallet/wallet_card_widget.dart';
import 'package:stacked/stacked.dart';

class WalletDashboardView extends StatefulWidget {
  const WalletDashboardView({super.key});

  @override
  State<WalletDashboardView> createState() => _WalletDashboardViewState();
}

class _WalletDashboardViewState extends State<WalletDashboardView>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  WalletDashboardViewModel? newModel;
  final PageController _pageController = PageController(initialPage: 1);

  bool isKeyboardOpen = false;

  @override
  initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  dispose() {
    _tabController!.dispose();
    _pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<ScaffoldState>();
    Size size = MediaQuery.of(context).size;

    MediaQuery.of(context).viewInsets.bottom == 0.0
        ? isKeyboardOpen = false
        : isKeyboardOpen = true;

    return ViewModelBuilder<WalletDashboardViewModel>.reactive(
        onViewModelReady: (model) async {
          model.context = context;
          await model.init();
          model.refreshIndicator.complete();
          model.refreshIndicator = Completer<void>();
        },
        viewModelBuilder: () => WalletDashboardViewModel(),
        builder: (context, WalletDashboardViewModel model, child) {
          return PopScope(
            canPop: false,
            onPopInvoked: (x) async {
              return WillPopScopeWidget().onWillPop(context);
            },
            child: GestureDetector(
              onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
              child: Scaffold(
                backgroundColor: white,
                key: key,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  systemOverlayStyle: SystemUiOverlayStyle.dark,
                  leading: InkWell(
                    onTap: () async {
                      if (!model.isBusy) {
                        model.goToChainList(size);
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/new-design/menu_icon.png",
                          scale: 2.7,
                        ),
                        UIHelper.horizontalSpaceSmall,
                        Text(
                          FlutterI18n.translate(context, "chain"),
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        )
                      ],
                    ),
                  ),
                  leadingWidth: (size.width * 0.3),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: InkWell(
                        onTap: () {
                          model.navigationService.navigateTo(
                            WalletConnectViewRoute,
                          );
                        },
                        child: Image.asset(
                          "assets/images/new-design/wc_icon.png",
                          scale: 2.7,
                        ),
                      ),
                    ),
                  ],
                ),
                body: Builder(
                    builder: (context) => mainWidgets(size, model, context)),
                bottomNavigationBar: BottomNavBar(count: 1),
                floatingActionButton: !isKeyboardOpen
                    ? FloatingActionButton(
                        onPressed: () {
                          model.navigationService.navigateTo(PayCoolViewRoute);
                        },
                        backgroundColor: Colors.transparent,
                        child: Image.asset(
                          "assets/images/new-design/pay_cool_icon.png",
                          fit: BoxFit.cover,
                        ),
                      )
                    : null,
                extendBody: true,
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
              ),
            ),
          );
        });
  }

  Widget mainWidgets(
      Size size, WalletDashboardViewModel model, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: <Widget>[
          WalletCardWidget(model),
          SizedBox(
              width: size.width,
              height:
                  size.height > 750 ? size.height * 0.05 : size.height * 0.06,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: model.chainList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        model.updateTabSelection(index);
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          model.selectedTabIndex == index
                              ? buttonPurple
                              : Colors.grey,
                        ),
                      ),
                      child: Text(
                        model.chainList[index],
                        style: TextStyle(color: white),
                      ),
                    ),
                  );
                },
              )),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: TabBar(
                  dividerHeight: 0,
                  controller: _tabController,
                  labelColor: primaryColor,
                  unselectedLabelColor: grey,
                  indicatorColor: primaryColor,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorWeight: 3,
                  labelPadding: EdgeInsets.symmetric(horizontal: 5),
                  labelStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  indicatorPadding:
                      EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  tabs: [
                    Tab(
                      text: FlutterI18n.translate(context, "token"),
                    ),
                    Tab(
                      text: FlutterI18n.translate(context, "nft"),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: size.width * 0.45,
                      height: size.height * 0.045,
                      child: TextField(
                        key: model.formKey,
                        controller: model.searchCoinTextController,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: FlutterI18n.translate(context, "search"),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(),
                            child: Icon(
                              Icons.search,
                              color: Colors.grey,
                              size: 18,
                            ),
                          ),
                          contentPadding:
                              EdgeInsets.zero, // Adjust vertical padding
                          hintStyle: TextStyle(
                            color: grey,
                            fontSize: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                        onChanged: (value) {
                          model.searchCoinsByTickerName(value);
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          Expanded(
            child: model.isBusy ||
                    model.busy(model.isHideSmallAssetsButton) ||
                    model.busy(model.selectedTabIndex)
                ? const ShimmerLayout(
                    layoutType: 'walletDashboard',
                    count: 9,
                  )
                : TabBarView(
                    controller: _tabController,
                    physics: AlwaysScrollableScrollPhysics(),
                    children: [
                      RefreshIndicator(
                          onRefresh: () async {
                            model.refreshBalancesV2();
                          },
                          child: buildListView(model)),
                      Center(
                        child:
                            Text(FlutterI18n.translate(context, "comingSoon")),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  ListView buildListView(WalletDashboardViewModel model) {
    List<WalletBalance> newList = [];

    switch (model.selectedTabIndex) {
      case 0:
        newList = model.wallets;
        break;
      case 6:
        newList = model.getFavCoins();
        break;
      default:
        newList =
            model.getSortedWalletList(model.chainList[model.selectedTabIndex]);
        break;
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: newList.length,
      itemBuilder: (BuildContext context, int index) {
        var tickerName = newList[index].coin!.toLowerCase();
        var usdBalance = (!newList[index].balance!.isNegative
                ? newList[index].balance
                : 0.0)! *
            newList[index].usdValue!.usd!;
        return Visibility(
          // Default visible widget will be visible when usdVal is greater than equals to 0 and isHideSmallAmountAssets is false
          visible: usdBalance >= 0 && !model.isHideSmallAssetsButton,
          // Secondary visible widget will be visible when usdVal is not equals to 0 and isHideSmallAmountAssets is true
          replacement: Visibility(
              visible: model.selectedTabIndex == 6
                  ? true
                  : model.isHideSmallAssetsButton && usdBalance != 0,
              child: CoinDetailsCardWidget(
                tickerName: tickerName,
                index: index,
                wallets: newList,
                context: context,
              )),
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: CoinDetailsCardWidget(
              tickerName: tickerName,
              index: index,
              wallets: newList,
              context: context,
            ),
          ),
        );
      },
    );
  }
}
