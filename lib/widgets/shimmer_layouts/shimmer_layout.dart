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
  const ShimmerLayout(
      {super.key, required this.layoutType, required this.count});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: ListView.builder(
            itemCount: count,
            itemBuilder: (BuildContext context, int index) {
              Widget? layout;

              if (layoutType == 'walletDashboard') {
                layout = Shimmer.fromColors(
                    baseColor: Colors.grey,
                    highlightColor: Colors.white,
                    child: const ShimmerWalletDashboardLayout());
              } else if (layoutType == 'marketPairs') {
                layout = Shimmer.fromColors(
                    baseColor: Colors.grey,
                    highlightColor: Colors.white,
                    child: const ShimmerMarketPairsLayout());
              } else if (layoutType == 'orderbook') {
                layout = Shimmer.fromColors(
                    baseColor: grey.withAlpha(155),
                    highlightColor: Colors.white,
                    child: const ShimmerOrderbookLayout());
              } else if (layoutType == 'marketTrades') {
                layout = Shimmer.fromColors(
                    baseColor: Colors.grey,
                    highlightColor: Colors.white,
                    child: const ShimmerMarketTradesLayout());
              }
              return layout;
            }));
  }
}
