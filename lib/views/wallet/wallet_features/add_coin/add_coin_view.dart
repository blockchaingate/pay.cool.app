import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/models/wallet/add_coin_model.dart';
import 'package:paycool/services/api_service.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/wallet/wallet_features/add_coin/all_coins_list_view.dart';
import 'package:paycool/widgets/shimmer_layouts/shimmer_layout.dart';

class AddCoinView extends StatefulWidget {
  const AddCoinView({super.key});

  @override
  State<AddCoinView> createState() => _AddCoinViewState();
}

class _AddCoinViewState extends State<AddCoinView>
    with SingleTickerProviderStateMixin {
  TextEditingController searchController = TextEditingController();
  TabController? _tabController;
  bool isLoading = false;

  List<AddCoinModel> coinList = [];
  List<AddCoinModel> hotCoinList = [];

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    getCoinList();
    super.initState();
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  Future<void> getCoinList() async {
    Future.wait([
      ApiService().getHomePageCoinList(context),
      ApiService().getHotCoinList(context),
    ]).then((value) {
      setState(() {
        coinList = value[0]!;
        hotCoinList = value[1]!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: bgGrey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: bgGrey,
        leadingWidth: size.width * 0.1,
        centerTitle: true,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 20,
            ),
          ),
        ),
        title: Container(
          height: 50,
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
                hintText: FlutterI18n.translate(context, "enterTheCoinName"),
                contentPadding: EdgeInsets.only(left: 10),
                hintStyle: TextStyle(
                  color: grey,
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: white),
            style: TextStyle(
              color: black,
              fontSize: 14,
            ),
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: size.width,
              height: 50,
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return AllCoinsListView(coinList);
                    },
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      FlutterI18n.translate(context, "homePageCoinList"),
                      style: TextStyle(
                        color: black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: black, size: 20),
                  ],
                ),
              ),
            ),
            UIHelper.verticalSpaceSmall,
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: primaryColor,
                    unselectedLabelColor: grey,
                    indicatorColor: primaryColor,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorWeight: 3,
                    labelPadding: EdgeInsets.symmetric(horizontal: 5),
                    indicatorPadding:
                        EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    tabs: [
                      Tab(
                        text: FlutterI18n.translate(context, "hot"),
                      ),
                      Tab(
                        text: FlutterI18n.translate(context, "my"),
                      ),
                    ],
                  ),
                ),
                Expanded(flex: 6, child: SizedBox())
              ],
            ),
            Expanded(
              child: isLoading || coinList.isEmpty
                  ? const ShimmerLayout(
                      layoutType: 'walletDashboard',
                      count: 12,
                    )
                  : TabBarView(
                      controller: _tabController,
                      physics: AlwaysScrollableScrollPhysics(),
                      children: [
                        buildListView(hotCoinList),
                        buildListView(coinList),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildListView(List<AddCoinModel> coinList) {
    return RawScrollbar(
      thumbColor: black,
      thickness: 2,
      child: ListView.builder(
        itemCount: coinList.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 30,
                  width: 30,
                  child: CachedNetworkImage(
                    imageUrl: coinList[index].token!.image!,
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
                UIHelper.horizontalSpaceSmall,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coinList[index].token!.name!,
                      style: TextStyle(
                        color: black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    UIHelper.verticalSpaceSmall,
                    Text(
                      "${coinList[index].id!.substring(0, 6)}...${coinList[index].id!.substring(coinList[index].id!.length - 4)}",
                      style: TextStyle(
                        color: grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Expanded(child: SizedBox()),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "100,000.00",
                      style: TextStyle(
                        color: black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    UIHelper.verticalSpaceSmall,
                    Text(
                      FlutterI18n.translate(context, "balance"),
                      style: TextStyle(
                        color: grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                UIHelper.horizontalSpaceMedium,
                IconButton(
                  onPressed: () {
                    print(coinList[index].token!.chain);
                  },
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: black,
                    size: 24,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
