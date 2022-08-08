import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../constants/colors.dart';
import 'shimmer_market_pairs_layout.dart';
import 'shimmer_market_trades_layouty.dart';
import 'shimmer_orderbook_layout.dart';
import 'shimmer_wallet_dashboard_layout.dart';

class ShimmerLayout extends StatelessWidget {
  final String layoutType;
  final int count;
  const ShimmerLayout({Key key, this.layoutType, this.count}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: ListView.builder(
            itemCount: count ?? 5,
            itemBuilder: (BuildContext context, int index) {
              Widget layout;

              if (layoutType == 'walletDashboard') {
                layout = Shimmer.fromColors(
                    child: const ShimmerWalletDashboardLayout(),
                    baseColor: Colors.grey,
                    highlightColor: Colors.white);
              } else if (layoutType == 'marketPairs') {
                layout = Shimmer.fromColors(
                    child: const ShimmerMarketPairsLayout(),
                    baseColor: Colors.grey,
                    highlightColor: Colors.white);
              } else if (layoutType == 'orderbook') {
                layout = Shimmer.fromColors(
                    child: const ShimmerOrderbookLayout(),
                    baseColor: grey.withAlpha(155),
                    highlightColor: Colors.white);
              } else if (layoutType == 'marketTrades') {
                layout = Shimmer.fromColors(
                    child: const ShimmerMarketTradesLayout(),
                    baseColor: Colors.grey,
                    highlightColor: Colors.white);
              }
              return layout;
            }));
  }
}
