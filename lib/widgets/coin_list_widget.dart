// import 'package:flutter/material.dart';
// import 'package:flutter_i18n/flutter_i18n.dart';
// import 'package:paycool/constants/colors.dart';
// import 'package:paycool/constants/custom_styles.dart';
// import 'package:paycool/models/wallet/wallet_balance.dart';
// import 'package:paycool/providers/app_state_provider.dart';
// import 'package:paycool/shared/ui_helpers.dart';

// class CoinListWidget extends StatefulWidget {
//   const CoinListWidget({super.key});

//   @override
//   State<CoinListWidget> createState() => _CoinListWidgetState();
// }

// class _CoinListWidgetState extends State<CoinListWidget>
//     with SingleTickerProviderStateMixin {
//   TabController? tabController;

//   final searchController = TextEditingController();
//   final _appStateProvider = AppStateProvider();

//   List<WalletBalance> conList = [];

//   @override
//   void initState() {
//     tabController = TabController(length: 5, vsync: this);
//     tabController!.addListener(() {
//       _handleTabSelection();
//     });
//     getCoinList();
//     super.initState();
//   }

//   @override
//   dispose() {
//     tabController!.removeListener(_handleTabSelection);
//     tabController!.dispose();
//     super.dispose();
//   }

//   void _handleTabSelection() {}

//   Future<void> getCoinList() async {
//     conList = await _appStateProvider.getTokenList(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     return Scaffold(
//       appBar: customAppBarWithIcon(
//         title: FlutterI18n.translate(context, "coinList"),
//         leading: IconButton(
//             onPressed: () => Navigator.pop(context),
//             icon: Icon(
//               Icons.arrow_back_ios,
//               color: Colors.black,
//               size: 20,
//             )),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             Container(
//               width: size.width,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: Colors.grey[200],
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: TextField(
//                 controller: searchController,
//                 decoration: InputDecoration(
//                   hintText: "Search",
//                   prefixIcon: Padding(
//                     padding: const EdgeInsets.only(),
//                     child: Icon(
//                       Icons.search,
//                       color: Colors.grey,
//                       size: 18,
//                     ),
//                   ),
//                   contentPadding: EdgeInsets.zero,
//                   hintStyle: TextStyle(
//                     color: grey,
//                     fontSize: 14,
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: BorderSide.none,
//                   ),
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                 ),
//               ),
//             ),
//             TabBar(
//               controller: tabController,
//               labelColor: primaryColor,
//               unselectedLabelColor: grey,
//               indicatorColor: primaryColor,
//               indicatorSize: TabBarIndicatorSize.tab,
//               indicatorPadding: EdgeInsets.all(10),
//               indicatorWeight: 3,
//               labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//               tabs: const [
//                 Tab(
//                   text: "All",
//                 ),
//                 Tab(
//                   text: "FAB",
//                 ),
//                 Tab(
//                   text: "BNB",
//                 ),
//                 Tab(
//                   text: "ETH",
//                 ),
//                 Tab(
//                   text: "KANBAN",
//                 )
//               ],
//             ),
//             Expanded(
//               child: TabBarView(
//                 controller: tabController,
//                 physics: AlwaysScrollableScrollPhysics(),
//                 children: [
//                   SingleChildScrollView(
//                     child: Column(
//                       children: [
//                         getRecords(size, "BTC"),
//                         getRecords(size, "EYH"),
//                         getRecords(size, "FAB"),
//                         getRecords(size, "EXC"),
//                         getRecords(size, "BNB"),
//                         getRecords(size, "DUSD"),
//                         getRecords(size, "USDT"),
//                         getRecords(size, "BTC"),
//                         getRecords(size, "BTC"),
//                         getRecords(size, "BTC"),
//                         getRecords(size, "BTC"),
//                         getRecords(size, "BTC"),
//                         getRecords(size, "BTC"),
//                         getRecords(size, "BTC"),
//                         getRecords(size, "BTC"),
//                         getRecords(size, "BTC"),
//                         getRecords(size, "BTC"),
//                         getRecords(size, "BTC"),
//                         getRecords(size, "BTC"),
//                       ],
//                     ),
//                   ),
//                   Center(child: Text("No Data")),
//                   Center(child: Text("No Data")),
//                   Center(child: Text("No Data")),
//                   Center(child: Text("No Data"))
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget getRecords(Size size, String name) {
//     return SizedBox(
//       width: size.width,
//       height: size.height * 0.1,
//       child: Row(
//         children: [
//           Container(
//             width: 50,
//             height: 50,
//             decoration:
//                 BoxDecoration(shape: BoxShape.circle, color: Colors.grey[200]),
//             child: Icon(
//               Icons.arrow_upward,
//               color: Colors.black,
//             ),
//           ),
//           UIHelper.horizontalSpaceSmall,
//           Text(
//             name,
//             style: TextStyle(color: Colors.black),
//           ),
//           Expanded(child: SizedBox()),
//           Text(
//             "10.008",
//             style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//   }
// }

// bottom_sheet_content.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:paycool/constants/api_routes.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/models/wallet/wallet_balance.dart';
import 'package:paycool/shared/ui_helpers.dart';

Widget coinListBottomSheet(
    BuildContext context, Size size, List<WalletBalance> wallets) {
  final searchController = TextEditingController();

  return Container(
    height: size.height * 0.8,
    padding: EdgeInsets.all(20),
    child: Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
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
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      for (var i = 0; i < wallets.length; i++)
                        getRecords(context, size, wallets[i]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget getRecords(BuildContext context, Size size, WalletBalance wallet) {
  return InkWell(
    onTap: () {
      Navigator.pop(
          context,
          WalletBalance(
              coin: wallet.coin,
              balance: wallet.balance,
              tokenType: wallet.tokenType,
              usdValue: wallet.usdValue));
    },
    child: SizedBox(
      width: size.width,
      height: size.height * 0.1,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: Colors.grey[200]),
            child: CachedNetworkImage(
              imageUrl: '$WalletCoinsLogoUrl${wallet.coin!.toLowerCase()}.png',
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 500),
              fadeOutDuration: const Duration(milliseconds: 500),
              fadeOutCurve: Curves.easeOut,
              fadeInCurve: Curves.easeIn,
              imageBuilder: (context, imageProvider) => FadeInImage(
                placeholder:
                    const AssetImage('assets/images/launcher/paycool-logo.png'),
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          UIHelper.horizontalSpaceSmall,
          Text(
            wallet.coin!,
            style: TextStyle(color: Colors.black),
          ),
          Expanded(child: SizedBox()),
          Text(
            wallet.balance!.toString(),
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}
