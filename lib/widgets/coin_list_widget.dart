import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/shared/ui_helpers.dart';

class CoinListWidget extends StatefulWidget {
  const CoinListWidget({super.key});

  @override
  State<CoinListWidget> createState() => _CoinListWidgetState();
}

class _CoinListWidgetState extends State<CoinListWidget>
    with SingleTickerProviderStateMixin {
  TabController? tabController;

  final searchController = TextEditingController();

  @override
  void initState() {
    tabController = TabController(length: 5, vsync: this);
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
    return Scaffold(
      appBar: customAppBarWithIcon(
        title: FlutterI18n.translate(context, "coinList"),
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 20,
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: size.width,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(),
                    child: Icon(
                      Icons.search,
                      color: Colors.grey,
                      size: 18,
                    ),
                  ),
                  contentPadding: EdgeInsets.zero,
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
              ),
            ),
            TabBar(
              controller: tabController,
              labelColor: primaryColor,
              unselectedLabelColor: grey,
              indicatorColor: primaryColor,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: EdgeInsets.all(10),
              indicatorWeight: 3,
              labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              tabs: const [
                Tab(
                  text: "All",
                ),
                Tab(
                  text: "FAB",
                ),
                Tab(
                  text: "BNB",
                ),
                Tab(
                  text: "ETH",
                ),
                Tab(
                  text: "KANBAN",
                )
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        getRecords(size, "BTC"),
                        getRecords(size, "EYH"),
                        getRecords(size, "FAB"),
                        getRecords(size, "EXC"),
                        getRecords(size, "BNB"),
                        getRecords(size, "DUSD"),
                        getRecords(size, "USDT"),
                        getRecords(size, "BTC"),
                        getRecords(size, "BTC"),
                        getRecords(size, "BTC"),
                        getRecords(size, "BTC"),
                        getRecords(size, "BTC"),
                        getRecords(size, "BTC"),
                        getRecords(size, "BTC"),
                        getRecords(size, "BTC"),
                        getRecords(size, "BTC"),
                        getRecords(size, "BTC"),
                        getRecords(size, "BTC"),
                        getRecords(size, "BTC"),
                      ],
                    ),
                  ),
                  Center(child: Text("No Data")),
                  Center(child: Text("No Data")),
                  Center(child: Text("No Data")),
                  Center(child: Text("No Data"))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getRecords(Size size, String name) {
    return SizedBox(
      width: size.width,
      height: size.height * 0.1,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: Colors.grey[200]),
            child: Icon(
              Icons.arrow_upward,
              color: Colors.black,
            ),
          ),
          UIHelper.horizontalSpaceSmall,
          Text(
            name,
            style: TextStyle(color: Colors.black),
          ),
          Expanded(child: SizedBox()),
          Text(
            "10.008",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
