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

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/constants/ui_var.dart';
import 'package:paycool/models/bond/vm/me_model.dart';
import 'package:paycool/models/wallet/wallet_balance.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/bond/buyBond/bond_symbol_view.dart';
import 'package:paycool/views/bond/login/login_view.dart';
import 'package:paycool/views/bond/register/bond_register_view.dart';
import 'package:paycool/views/bond/txHistory/bond_history_view.dart';
import 'package:paycool/views/wallet/wallet_dashboard_viewmodel.dart';
import 'package:paycool/views/wallet/wallet_features/wallet_features_view.dart';
import 'package:paycool/widgets/bottom_nav.dart';
import 'package:paycool/widgets/shimmer_layouts/shimmer_layout.dart';
import 'package:paycool/widgets/wallet/add_gas/gas_balance_and_add_gas_button_widget.dart';
import 'package:paycool/widgets/wallet/coin_details_card_widget.dart';
import 'package:paycool/widgets/wallet/total_balance_card_widget.dart';
// import 'package:showcaseview/showcaseview.dart';
import 'package:stacked/stacked.dart';

class WalletDashboardView extends StatefulWidget {
  const WalletDashboardView({Key? key}) : super(key: key);

  @override
  State<WalletDashboardView> createState() => _WalletDashboardViewState();
}

class _WalletDashboardViewState extends State<WalletDashboardView>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  late WalletDashboardViewModel newModel;
  final PageController _pageController = PageController(initialPage: 1);

  @override
  initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController!.addListener(() {
      _handleTabSelection();
    });
  }

  @override
  dispose() {
    _tabController!.removeListener(_handleTabSelection);
    _tabController!.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    debugPrint('is busy 0 ${newModel.isBusy}');
    newModel.updateTabSelection(_tabController!.index);
    debugPrint('is busy 2 ${newModel.isBusy}');
  }

  @override
  Widget build(BuildContext context) {
    // GlobalKey _one = GlobalKey(debugLabel: "one");
    // GlobalKey _two = GlobalKey(debugLabel: "two");
    final key1 = GlobalKey<ScaffoldState>();
    final key = GlobalKey<ScaffoldState>();

    Size size = MediaQuery.of(context).size;

    // RefreshController _refreshController =
    //     RefreshController(initialRefresh: false);
    return ViewModelBuilder<WalletDashboardViewModel>.reactive(
        viewModelBuilder: () => WalletDashboardViewModel(context: context),
        disposeViewModel: true,
        onViewModelReady: (model) async {
          newModel = model;

          model.sharedService.context = context;
          model.init();
        },
        builder: (context, WalletDashboardViewModel model, child) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: WillPopScope(
              onWillPop: () {
                model.onBackButtonPressed();
                return Future(() => false);
              },
              child: PageView(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                children: [
                  Scaffold(
                    key: key1,
                    body: GestureDetector(
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      child: Builder(
                          builder: (context) => bondPage(model, context)),
                      // ),
                    ),
                  ),
                  Scaffold(
                    key: key,
                    appBar: PreferredSize(
                      preferredSize: const Size.fromHeight(140),
                      child: InkWell(
                        onTap: () {
                          _pageController.animateToPage(0,
                              duration: Duration(seconds: 2),
                              curve: Curves.easeInOut);
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                                opacity: 0.8,
                                image: AssetImage("assets/images/bondBg.jpeg"),
                                fit: BoxFit.cover),
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.white,
                                width: 2.0,
                              ),
                            ),
                          ),
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: size.height * 0.05,
                              ),
                              SizedBox(
                                  width: 50,
                                  child: Image.asset(
                                      "assets/images/salvador.png")),
                              SizedBox(
                                child: Text(
                                  "EI SALVADOR",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(
                                child: Text(
                                  FlutterI18n.translate(
                                      context, "nationalBondSale"),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    body: GestureDetector(
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      child: Builder(
                          builder: (context) => mainWidgets(model, context)),
                      // ),
                    ),
                    bottomNavigationBar: BottomNavBar(count: 1),
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget mainWidgets(WalletDashboardViewModel model, BuildContext context) {
    return Column(
      children: <Widget>[
        LayoutBuilder(builder: (BuildContext ctx, BoxConstraints constraints) {
          if (constraints.maxWidth < largeSize) {
            return Container(
              height: MediaQuery.of(context).padding.top,
            );
          } else {
            return Column(
              children: <Widget>[
                topWidget(model, context),
                amountAndGas(model, context),
              ],
            );
          }
        }),
        //   !Platform.isAndroid
        //      ?
        Expanded(
          child: LayoutBuilder(
              builder: (BuildContext ctx, BoxConstraints constraints) {
            if (constraints.maxWidth < largeSize) {
              return coinList(model, ctx);
            } else {
              if (model.rightWalletInfo == null ||
                  model.rightWalletInfo!.address!.isEmpty) {
                model.updateRightWallet();
              }
              return Row(
                children: [
                  SizedBox(
                      width: 300,
                      height: double.infinity,
                      child: coinList(model, ctx)),
                  Expanded(
                    child: model.rightWalletInfo == null ||
                            model.rightWalletInfo!.address!.isEmpty
                        ? Container()
                        : WalletFeaturesView(),
                  )
                ],
              );
            }
          }),
        ),
      ],
    );
  }

/*-------------------------------------------------------------------------------------
                Build Background, Logo Container with balance card
-------------------------------------------------------------------------------------*/
  Widget topWidget(WalletDashboardViewModel model, BuildContext context) {
    return Container(
      height: 180,
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/paycool/walletBg8.jpg'),
              fit: BoxFit.cover)),
      child: Stack(children: <Widget>[
        Container(
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

        Positioned(
          top: 30,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  FlutterI18n.translate(context, "myWallet"),
                  style: const TextStyle(
                      fontSize: 23,
                      color: white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'WorkSans-Thin'),
                ),
              )
            ],
          ),
        ),

        Swiper(
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return TotalBalanceCardWidget(model: model);
            } else {
              return TotalBalanceCardWidget2(model: model);
            }
          },
          itemCount: 2,
          itemWidth: 500,
          itemHeight: 180.0,
          layout: SwiperLayout.TINDER,
          pagination: const SwiperPagination(
            margin: EdgeInsets.fromLTRB(5, 10, 5, 0),
            builder: DotSwiperPaginationBuilder(
              color: Color(0xccffffff),
            ),
          ),
          autoplay: true,
          autoplayDelay: 7000,
        ),

        //Refresh BalancesV2
        Positioned(
            top: 15,
            right: 5,
            child: IconButton(
                onPressed: () {
                  model.refreshBalancesV2();
                },
                icon: model.isBusy
                    ? Container(
                        margin: const EdgeInsets.only(left: 3.0),
                        child: model.sharedService.loadingIndicator(),
                      )
                    : const Icon(
                        Icons.refresh,
                        color: Color(0xbbffffff),
                        size: 22,
                      ))),
      ]),
    );
  }

  /*-----------------------------------------------------------------
                            Hide Small Amount Row
  -----------------------------------------------------------------*/
  Widget amountAndGas(WalletDashboardViewModel model, BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(right: 10, top: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                width: 130,
                margin:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        model.isShowFavCoins
                            ? debugPrint('...')
                            : model.hideSmallAmountAssets();
                      },
                      child: Row(
                        children: <Widget>[
                          !model.isHideSmallAssetsButton
                              ? const Icon(
                                  Icons.money_off,
                                  semanticLabel: 'Show all Amount Assets',
                                  color: primaryColor,
                                )
                              : Icon(
                                  Icons.attach_money,
                                  semanticLabel: 'Hide Small Amount Assets',
                                  color: model.isShowFavCoins
                                      ? grey
                                      : primaryColor,
                                ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(left: 5),
                              child: Text(
                                !model.isHideSmallAssetsButton
                                    ? FlutterI18n.translate(
                                        context, "hideSmallAmountAssets")
                                    : FlutterI18n.translate(
                                        context, "showSmallAmountAssets"),
                                style: model.isShowFavCoins
                                    ? headText5.copyWith(
                                        wordSpacing: 1.25, color: grey)
                                    : headText5.copyWith(wordSpacing: 1.25),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    model.isBusy
                        ? Container()
                        : GasBalanceAndAddGasButtonWidget(
                            gasAmount: model.gasAmount),
                    !model.isFreeFabNotUsed
                        ? Container()
                        : Container(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(30)),
                            child: SizedBox(
                              width: 120,
                              height: 22,
                              child: OutlinedButton.icon(
                                  style: ButtonStyle(
                                      padding: MaterialStateProperty.all(
                                          const EdgeInsets.all(0))),
                                  onPressed: model.getFreeFab,
                                  icon: const Icon(
                                    Icons.add,
                                    size: 14,
                                    color: white,
                                  ),
                                  label: Text(
                                    '${FlutterI18n.translate(context, "getFree")} FAB',
                                    style: headText5.copyWith(
                                        color: secondaryColor,
                                        fontWeight: FontWeight.w400),
                                  )),
                            )),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.only(left: 8.0),
          width: MediaQuery.of(context).size.width / 2,
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
                  child: Container(
                    margin: const EdgeInsets.only(top: 5),
                    height: 30,
                    child: TextField(
                      style: headText5,
                      enabled:
                          model.isShowFavCoins || model.isHideSmallAssetsButton
                              ? false
                              : true,
                      decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: primaryColor, width: 0.5),
                          ),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: primaryColor)),
                          // helperText: 'Search',
                          // helperStyle:
                          //     Theme.of(context).textTheme.bodyText1,
                          suffixIcon: Icon(
                            Icons.search,
                            color: primaryColor,
                            size: 18,
                          )),
                      controller: model.searchCoinTextController,
                      onChanged: (String value) {
                        model.isShowFavCoins
                            ? model.searchFavCoinsByTickerName(value)
                            : model.searchCoinsByTickerName(value);
                      },
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        UIHelper.verticalSpaceSmall,
        model.isUpdateWallet
            ? TextButton(
                child: Text(FlutterI18n.translate(context, "updateWallet")),
                onPressed: () => model.updateWallet(),
              )
            : Container(),
      ],
    );
  }

  Widget coinList(WalletDashboardViewModel model, BuildContext context) {
    // var top = 0.0;
    return DefaultTabController(
        length: 6,
        initialIndex: model.selectedTabIndex,
        child: NestedScrollView(
          controller: model.walletsScrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              MediaQuery.of(context).size.width < largeSize
                  ? SliverToBoxAdapter(
                      child: SizedBox(
                          // color: Colors.lightBlue,
                          height: 180,
                          width: MediaQuery.of(context).size.width,
                          child: topWidget(model, context)),
                    )
                  : const SliverToBoxAdapter(),
              SliverToBoxAdapter(
                  child: MediaQuery.of(context).size.width < largeSize
                      ? amountAndGas(model, context)
                      : Container()),
              SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                        // labelPadding: EdgeInsets.only(bottom: 14, top: 14),
                        controller: _tabController,
                        onTap: (int tabIndex) {
                          model.updateTabSelection(tabIndex);
                        },
                        isScrollable: isPhone() ? false : true,
                        labelColor: primaryColor,
                        unselectedLabelColor: grey,
                        indicatorColor: primaryColor,
                        indicatorSize: TabBarIndicatorSize.tab,
                        tabs: const [
                          Tab(
                            text: "All",
                            iconMargin: EdgeInsets.only(bottom: 3),
                          ),
                          Tab(
                            text: "FAB",
                            iconMargin: EdgeInsets.only(bottom: 3),
                          ),
                          Tab(
                            text: "ETH",
                            iconMargin: EdgeInsets.only(bottom: 3),
                          ),
                          Tab(
                            text: "TRX",
                            iconMargin: EdgeInsets.only(bottom: 3),
                          ),
                          Tab(
                            text: "BNB",
                            iconMargin: EdgeInsets.only(bottom: 3),
                          ),
                          Tab(
                            icon: Icon(Icons.star, size: 18),
                            iconMargin: EdgeInsets.only(bottom: 3),
                          ),
                        ]),
                  ))
            ];
          },
          body: model.isBusy ||
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
                    // All coins tab
                    //Center(child: Text(model.isBusy.toString())),
                    buildListView(model),
                    buildListView(model),
                    buildListView(model),
                    buildListView(model),
                    buildListView(model),

                    FavTab(),
                  ],
                ),
        ));
  }

  ListView buildListView(WalletDashboardViewModel model) {
    List<WalletBalance> newList = [];

    if (model.selectedTabIndex == 0) {
      newList = model.wallets;
    } else if (model.selectedTabIndex == 1) {
      newList = model.fabWalletTokens;
    } else if (model.selectedTabIndex == 2) {
      newList = model.ethWalletTokens;
    } else if (model.selectedTabIndex == 3) {
      newList = model.trxWalletTokens;
    } else if (model.selectedTabIndex == 4) {
      newList = model.bnbWalletTokens;
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 0),
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
              visible: model.isHideSmallAssetsButton && usdBalance != 0,
              child: CoinDetailsCardWidget(
                tickerName: tickerName,
                index: index,
                wallets: newList,
                context: context,
              )),
          child: CoinDetailsCardWidget(
            tickerName: tickerName,
            index: index,
            wallets: newList,
            context: context,
          ),
        );
      },
    );
  }

  Widget bondPage(WalletDashboardViewModel model, BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/images/bgImage.png"), fit: BoxFit.cover),
      ),
      child: Column(
        children: [
          model.bondMeVm.email == null
              ? SizedBox(
                  height: size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/salvador.png",
                        height: 100,
                      ),
                      UIHelper.verticalSpaceMedium,
                      Text(
                        FlutterI18n.translate(context, "elSalvadorDigital"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      UIHelper.verticalSpaceLarge,
                      Text(
                        FlutterI18n.translate(context, "youHaveAccount"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w200,
                            color: Colors.white),
                      ),
                      UIHelper.verticalSpaceSmall,
                      Container(
                        width: size.width * 0.9,
                        height: 45,
                        decoration: BoxDecoration(
                          gradient: buttoGradient,
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const BondLoginView()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: Text(
                            FlutterI18n.translate(context, "login"),
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      UIHelper.verticalSpaceSmall,
                      Text(
                        FlutterI18n.translate(context, "dontHaveAnAccount"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w200,
                            color: Colors.white),
                      ),
                      UIHelper.verticalSpaceSmall,
                      Container(
                        width: size.width * 0.9,
                        height: 45,
                        decoration: BoxDecoration(
                          gradient: buttoGradient,
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const BondRegisterView()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: Text(
                            FlutterI18n.translate(context, "register"),
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    UIHelper.verticalSpaceLarge,
                    SizedBox(
                      width: size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            alignment: Alignment.topRight,
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      elevation: 10,
                                      titleTextStyle: headText5.copyWith(
                                          fontWeight: FontWeight.bold),
                                      contentTextStyle:
                                          const TextStyle(color: white),
                                      content: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          FlutterI18n.translate(
                                              context, "doYouLogout"),
                                          style: const TextStyle(fontSize: 14),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      actions: <Widget>[
                                        UIHelper.verticalSpaceSmall,
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                gradient: buttoGradient,
                                                borderRadius:
                                                    BorderRadius.circular(40.0),
                                              ),
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  shadowColor:
                                                      Colors.transparent,
                                                ),
                                                child: Text(
                                                  FlutterI18n.translate(
                                                      context, "no"),
                                                  style: headText5,
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(false);
                                                },
                                              ),
                                            ),
                                            UIHelper.horizontalSpaceMedium,
                                            Container(
                                              decoration: BoxDecoration(
                                                gradient: buttoGradient,
                                                borderRadius:
                                                    BorderRadius.circular(40.0),
                                              ),
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  shadowColor:
                                                      Colors.transparent,
                                                ),
                                                child: Text(
                                                    FlutterI18n.translate(
                                                        context, "yes"),
                                                    style: const TextStyle(
                                                        color: white,
                                                        fontSize: 12)),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  LocalStorageService()
                                                      .clearToken();
                                                  model.bondMeVm =
                                                      BondMeModel();
                                                  setState(() {});
                                                },
                                              ),
                                            ),
                                            UIHelper.verticalSpaceSmall,
                                          ],
                                        ),
                                      ],
                                    );
                                  });
                            },
                            icon: Icon(Icons.logout),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: IconButton(
                              alignment: Alignment.topRight,
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const BondHistoryView()));
                              },
                              icon: Icon(Icons.history),
                            ),
                          ),
                        ],
                      ),
                    ),
                    UIHelper.verticalSpaceLarge,
                    Image.asset(
                      "assets/images/salvador.png",
                      height: 100,
                    ),
                    UIHelper.verticalSpaceLarge,
                    Text(
                      "El Salvador",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    UIHelper.verticalSpaceSmall,
                    Text(
                      FlutterI18n.translate(context, "nationalBondSale"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    UIHelper.verticalSpaceLarge,
                    Container(
                      width: size.width * 0.8,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: buttoGradient,
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      BondSembolView(model.bondMeVm)));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(
                          FlutterI18n.translate(context, "buyNow"),
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // UIHelper.verticalSpaceMedium,
                    // model.bondMeVm.kycLevel != null &&
                    //         model.bondMeVm.kycLevel! < 2
                    //     ? Container(
                    //         width: size.width * 0.9,
                    //         height: 45,
                    //         decoration: BoxDecoration(
                    //           gradient: buttoGradient,
                    //           borderRadius: BorderRadius.circular(40.0),
                    //         ),
                    //         child: ElevatedButton(
                    //           onPressed: () {
                    //             print(" kyc");
                    //           },
                    //           style: ElevatedButton.styleFrom(
                    //             backgroundColor: Colors.transparent,
                    //             shadowColor: Colors.transparent,
                    //           ),
                    //           child: Text(
                    //             ' KYC',
                    //             style: TextStyle(
                    //               fontSize: 16.0,
                    //               fontWeight: FontWeight.bold,
                    //             ),
                    //           ),
                    //         ),
                    //       )
                    //     : SizedBox()
                  ],
                )
        ],
      ),
    );
  }
}
// FAB TAB

class FavTab extends StackedView<WalletDashboardViewModel> {
  @override
  void onViewModelReady(WalletDashboardViewModel model) async {
    await model.buildFavCoinListV1();
  }

  @override
  Widget builder(
    BuildContext context,
    WalletDashboardViewModel model,
    Widget? child,
  ) {
    debugPrint('fav list length before');
    debugPrint(model.favWallets.length.toString());
    return model.busy(model.favWallets)
        ? model.sharedService.loadingIndicator()
        : Container(
            child: model.favWallets.isEmpty
                ? Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/paycool/box.png",
                        width: 40,
                        height: 40,
                      ),
                    ],
                  ))
                : ListView.builder(
                    controller: model.walletsScrollController,
                    shrinkWrap: true,
                    itemCount: model.favWallets.length,
                    itemBuilder: (BuildContext context, int index) {
                      var tickerName =
                          model.favWallets[index].coin!.toLowerCase();
                      return CoinDetailsCardWidget(
                        tickerName: tickerName,
                        index: index,
                        wallets: model.favWallets,
                        context: context,
                      );
                    }),
          );
  }

  @override
  WalletDashboardViewModel viewModelBuilder(BuildContext context) =>
      WalletDashboardViewModel(context: context);
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: secondaryColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
