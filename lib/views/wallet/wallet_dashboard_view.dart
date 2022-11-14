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

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/constants/ui_var.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/wallet/wallet_dashboard_viewmodel.dart';
import 'package:paycool/views/wallet/wallet_features/wallet_features_view.dart';
import 'package:paycool/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paycool/widgets/shimmer_layouts/shimmer_layout.dart';
import 'package:paycool/widgets/wallet/add_gas/gas_balance_and_add_gas_button_widget.dart';
import 'package:paycool/widgets/wallet/coin_details_card_widget.dart';
import 'package:paycool/widgets/wallet/total_balance_card_widget.dart';
// import 'package:showcaseview/showcaseview.dart';
import 'package:stacked/stacked.dart';

class WalletDashboardView extends StatelessWidget {
  const WalletDashboardView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // GlobalKey _one = GlobalKey(debugLabel: "one");
    // GlobalKey _two = GlobalKey(debugLabel: "two");
    final key = GlobalKey<ScaffoldState>();

    // RefreshController _refreshController =
    //     RefreshController(initialRefresh: false);
    return ViewModelBuilder<WalletDashboardViewModel>.reactive(
        viewModelBuilder: () => WalletDashboardViewModel(),
        onModelReady: (model) async {
          model.context = context;
          // model.globalKeyOne = _one;
          // model.globalKeyTwo = _two;
          // model.refreshController = _refreshController;
          await model.init();
        },
        // onDispose: () {
        //   _refreshController.dispose();
        //   debugPrint('_refreshController disposed in wallet dashboard view');
        // },
        builder: (context, WalletDashboardViewModel model, child) {
          // var connectionStatus = Provider.of<ConnectivityStatus>(context);
          // if (connectionStatus == ConnectivityStatus.Offline)
          //   return NetworkStausView();
          // else
          return WillPopScope(
            onWillPop: () {
              model.onBackButtonPressed();
              return Future(() => false);
            },
            child: Scaffold(
              key: key,
              appBar: customAppBar(),
              body: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child:
                    //  ShowCaseWidget(
                    //   onStart: (index, key) {
                    //     debugPrint('onStart: $index, $key');
                    //   },
                    //   onComplete: (index, key) {
                    //     debugPrint('onComplete: $index, $key');
                    //   },
                    //   onFinish: () {
                    //     model.storageService.isShowCaseView = false;

                    //     model.updateShowCaseViewStatus();
                    //   },
                    //   builder:
                    Builder(
                        // ignore: missing_return
                        builder: (context) => mainWidgets(model, context)),
                // ),
              ),
              bottomNavigationBar: BottomNavBar(count: 1),
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

        /*------------------------------------------------------------------------------
                                        Build Wallet List Container
        -------------------------------------------------------------------------------*/
        //   !Platform.isAndroid
        //      ?
        Expanded(
          child: LayoutBuilder(
              builder: (BuildContext ctx, BoxConstraints constraints) {
            if (constraints.maxWidth < largeSize) {
              return coinList(model, ctx);
              // return tester();
            } else {
              if (model.rightWalletInfo == null && model.wallets != null) {
                model.assignDefaultWalletForIos();
              }
              return Row(
                children: [
                  SizedBox(
                      width: 300,
                      height: double.infinity,
                      child: coinList(model, ctx)),
                  Expanded(
                    child: model.wallets == null ||
                            model.rightWalletInfo == null
                        ? Container()
                        : WalletFeaturesView(walletInfo: model.rightWalletInfo),
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
      decoration: const BoxDecoration(image: DecorationImage(image: AssetImage(
          // 'assets/images/wallet-page/background.png'
          // 'assets/images/img/starMainBg2.jpg',
          // 'assets/images/paycool/Liquid1.jpg'
          'assets/images/paycool/walletBg8.jpg'), fit: BoxFit.cover)),
      child: Stack(children: <Widget>[
        Container(
            // height: 350.0,
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

        Container(
            child: Swiper(
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return TotalBalanceCardWidget(model: model);
            } else {
              return TotalBalanceCardWidget2(model: model);
            }

            // return TotalBalanceCardWidget(
            //   logo: logoWidget,
            //   title: titleWidget,
            // );
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
        )),

        //Refresh BalancesV2
        Positioned(
            top: 15,
            right: 5,
            child: IconButton(
                onPressed: () {
                  // if (model.currentTabSelection == 0)
                  model.refreshBalancesV2();
                  // else
                  //   model.getBalanceForSelectedCustomTokens();
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
                              height: 20,
                              child: OutlinedButton.icon(
                                  style: ButtonStyle(
                                      padding: MaterialStateProperty.all(
                                          const EdgeInsets.all(0))),
                                  onPressed: model.getFreeFab,
                                  icon: const Icon(
                                    Icons.add,
                                    size: 14,
                                    color: primaryColor,
                                  ),
                                  label: Text(
                                    FlutterI18n.translate(context, "getFree") +
                                        ' FAB',
                                    style: headText5.copyWith(
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
          margin: const EdgeInsets.only(left: 8.0),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
                  child: Container(
                    margin: const EdgeInsets.only(top: 5),
                    height: 30,
                    child: TextField(
                      enabled:
                          model.isShowFavCoins || model.isHideSmallAssetsButton
                              ? false
                              : true,
                      decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: primaryColor, width: 1),
                          ),
                          // helperText: 'Search',
                          // helperStyle:
                          //     Theme.of(context).textTheme.bodyText1,
                          suffixIcon: Icon(Icons.search, color: white)),
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
            ? Container(
                child: TextButton(
                child: Text(FlutterI18n.translate(context, "updateWallet")),
                onPressed: () => model.updateWallet(),
              ))
            : Container(),
      ],
    );
  }

  Widget coinList(WalletDashboardViewModel model, BuildContext context) {
    var top = 0.0;
    return DefaultTabController(
        length: 2,
        initialIndex: model.currentTabSelection,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              // MediaQuery.of(context).size.width < largeSize
              //     ? SliverAppBar(
              //         elevation: 0,
              //         backgroundColor: secondaryColor,
              //         expandedHeight: 180.0,
              //         floating: false,
              //         pinned: true,
              //         leading: Container(),
              //         flexibleSpace: LayoutBuilder(builder:
              //             (BuildContext context, BoxConstraints constraints) {
              //           // debugPrint('constraints=' + constraints.toString());
              //           top = constraints.biggest.height;
              //           return FlexibleSpaceBar(
              //             centerTitle: true,
              //             titlePadding: EdgeInsets.all(0),
              //             title: AnimatedOpacity(
              //               duration: Duration(milliseconds: 50),
              //               opacity: top ==
              //                       MediaQuery.of(context).padding.top +
              //                           kToolbarHeight
              //                   ? 1.0
              //                   : 0.0,
              //               child: TotalBalanceWidget(model: model),
              //             ),
              //             background: topWidget(model, context),
              //           );
              //         }))
              //     : SliverToBoxAdapter(),
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

                        onTap: (int tabIndex) {
                          model.updateTabSelection(tabIndex);
                        },
                        labelColor: primaryColor,
                        unselectedLabelColor: grey,
                        indicatorColor: primaryColor,
                        indicatorSize: TabBarIndicatorSize.tab,
                        tabs: const [
                          Tab(
                            icon: Icon(
                              FontAwesomeIcons.coins,
                              // color: white,
                              size: 16,
                            ),
                            iconMargin: EdgeInsets.only(bottom: 3),
                            // child: Text(
                            //     model.walletInfoCopy.length.toString(),
                            //     style: TextStyle(fontSize: 10, color: grey))
                          ),
                          Tab(
                            icon: Icon(Icons.star,
                                // color: primaryColor,
                                size: 18),
                            iconMargin: EdgeInsets.only(bottom: 3),
                            // child: Text(
                            //     model.favWalletInfoList.length.toString(),
                            //     style: TextStyle(fontSize: 10, color: grey)),
                          )
                        ]),
                  ))
            ];
          },
          body: TabBarView(
            //  physics: ClampingScrollPhysics(),
            children: [
              // All coins tab
              model.isBusy || model.busy(model.isHideSmallAssetsButton)
                  ? const ShimmerLayout(
                      layoutType: 'walletDashboard',
                      count: 9,
                    )
                  :
                  //Center(child: Text(model.isBusy.toString())),

                  buildListView(model),

              FavTab(),
            ],
          ),
        ));
  }

  ListView buildListView(WalletDashboardViewModel model) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 0),
      shrinkWrap: true,
      itemCount: model.wallets.length,
      itemBuilder: (BuildContext context, int index) {
        var tickerName = model.wallets[index].coin.toLowerCase();
        var usdBalance = (!model.wallets[index].balance.isNegative
                ? model.wallets[index].balance
                : 0.0) *
            model.wallets[index].usdValue.usd;
        return Visibility(
          // Default visible widget will be visible when usdVal is greater than equals to 0 and isHideSmallAmountAssets is false
          visible: usdBalance >= 0 && !model.isHideSmallAssetsButton,
          child: CoinDetailsCardWidget(
            tickerName: tickerName,
            index: index,
            wallets: model.wallets,
            context: context,
          ),
          // Secondary visible widget will be visible when usdVal is not equals to 0 and isHideSmallAmountAssets is true
          replacement: Visibility(
              visible: model.isHideSmallAssetsButton && usdBalance != 0,
              child: CoinDetailsCardWidget(
                tickerName: tickerName,
                index: index,
                wallets: model.wallets,
                context: context,
              )),
        );
      },
    );
  }
}
// FAB TAB

class FavTab extends ViewModelBuilderWidget<WalletDashboardViewModel> {
  @override
  void onViewModelReady(WalletDashboardViewModel model) async {
    await model.buildFavCoinListV1();
  }

  @override
  Widget builder(
      BuildContext context, WalletDashboardViewModel model, Widget child) {
    debugPrint('fav list length before');
    debugPrint(model.favWallets.length.toString());
    return model.busy(model.favWallets)
        ? model.sharedService.loadingIndicator()
        : Container(
            child: model.favWallets.isEmpty || model.favWallets == null
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
                          model.favWallets[index].coin.toLowerCase();
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
      WalletDashboardViewModel();
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
      child: _tabBar,
      color: secondaryColor,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
