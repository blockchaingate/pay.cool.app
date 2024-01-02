import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:paycool/constants/api_routes.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/models/wallet/wallet_balance.dart';
import 'package:paycool/shared/ui_helpers.dart';

var chainList = ["FAB", "BTC", "ETH", "USDT", "BNB", "TRX", "BUSD", "USDC"];
int currentChainIndex = 0;

Widget chainListWidget(
    BuildContext context, Size size, List<WalletBalance> wallets) {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 3),
        blendMode: BlendMode.darken,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          height: size.height * 0.7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(),
                    // IconButton(
                    //   onPressed: () {
                    //     Navigator.pop(context);
                    //   },
                    //   icon: ImageIcon(
                    //     AssetImage("assets/images/new-design/setting_icon.png"),
                    //     color: black,
                    //     size: 36,
                    //   ),
                    // ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        color: black,
                        size: 36,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      color: Colors.grey[200],
                      width: size.width * 0.2,
                      height: size.height * 0.8,
                      child: ListView.builder(
                          itemCount: chainList.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  currentChainIndex = index;
                                });
                              },
                              child: Container(
                                width: size.width * 0.2,
                                height: size.width * 0.2,
                                padding: EdgeInsets.all(15),
                                color: index == currentChainIndex
                                    ? white
                                    : Colors.grey[200],
                                child: CachedNetworkImage(
                                  imageUrl:
                                      '$WalletCoinsLogoUrl${chainList[index].toLowerCase()}.png',
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                  fit: BoxFit.cover,
                                  fadeInDuration:
                                      const Duration(milliseconds: 500),
                                  fadeOutDuration:
                                      const Duration(milliseconds: 500),
                                  fadeOutCurve: Curves.easeOut,
                                  fadeInCurve: Curves.easeIn,
                                  imageBuilder: (context, imageProvider) =>
                                      FadeInImage(
                                    placeholder: const AssetImage(
                                        'assets/images/launcher/paycool-logo.png'),
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                    UIHelper.horizontalSpaceSmall,
                    SizedBox(
                      width: size.width * 0.7,
                      height: size.height * 0.8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${chainList[currentChainIndex]} chain",
                            style: TextStyle(
                                color: black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          getRecords(context, size, wallets),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget getRecords(
    BuildContext context, Size size, List<WalletBalance> wallets) {
  var currentWallet = wallets
      .where((element) => element.coin == chainList[currentChainIndex])
      .first;

  return InkWell(
    onTap: () {
      Navigator.pop(context, currentChainIndex);
    },
    child: SizedBox(
      width: size.width,
      height: size.height * 0.1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "0xgtfr....hy65",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              // Text(
              //   "Wallet 1",
              //   style: TextStyle(
              //       color: Colors.black45,
              //       fontSize: 14,
              //       fontWeight: FontWeight.w600),
              // ),
            ],
          ),
          Text(
            "\$ ${currentWallet.balance!}",
            style: TextStyle(
                color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}
