import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:paycool/constants/api_routes.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/models/wallet/provider_address_model.dart';
import 'package:paycool/models/wallet/wallet_balance.dart';
import 'package:paycool/shared/ui_helpers.dart';

var chainList = ["FAB", "ETH", "BTC", "LTC", "DOGE", "BCH", "TRX"];
int currentChainIndex = 0;

Widget chainListWidget(
    BuildContext context,
    Size size,
    List<WalletBalance> wallets,
    List<ProviderAddressModel> providerAddressList) {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return Container(
        height: size.height * 0.7,
        color: Colors.white,
        padding: EdgeInsets.only(top: 5),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.close,
                    color: black,
                    size: 28,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Row(
                children: [
                  Container(
                    color: Colors.grey[200],
                    width: size.width * 0.15,
                    child: ListView.builder(
                        itemCount: chainList.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                currentChainIndex = index;
                              });
                            },
                            child: Column(
                              children: [
                                Container(
                                  height: size.width * 0.15,
                                  padding: const EdgeInsets.all(10),
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
                                UIHelper.verticalSpaceSmall,
                              ],
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        UIHelper.verticalSpaceMedium,
                        getRecords(context, size, wallets, providerAddressList),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget getRecords(BuildContext context, Size size, List<WalletBalance> wallets,
    List<ProviderAddressModel> providerAddressList) {
  var currentWallet = wallets
      .where((element) => element.coin == chainList[currentChainIndex])
      .first;

  var currentProviderAddress = providerAddressList
      .where((element) => element.name == chainList[currentChainIndex])
      .first;

  return InkWell(
    onTap: () {
      Navigator.pop(context, currentChainIndex);
    },
    child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "${currentProviderAddress.address!.substring(0, 6)}...${currentProviderAddress.address!.substring(currentProviderAddress.address!.length - 4)}",
          style: TextStyle(
              color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500),
        ),
        Text(
          currentWallet.balance! > 0 ? "\$ ${currentWallet.balance!}" : "0.0",
          softWrap: true,
          style: TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}
