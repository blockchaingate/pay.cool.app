import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paycool/constants/api_routes.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/utils/exaddr.dart';
import 'package:paycool/utils/string_util.dart';
import 'package:paycool/views/multisig/transactions/history_queue_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'multisig_dashboard_viewmodel.dart';

class MultisigDashboardView extends StatelessWidget {
  final String txid;
  const MultisigDashboardView({Key? key, required this.txid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MultisigDashboardViewModel>.reactive(
      viewModelBuilder: () =>
          MultisigDashboardViewModel(context: context, txid: txid),
      onViewModelReady: (model) => model.init(),
      builder: (
        BuildContext context,
        MultisigDashboardViewModel model,
        Widget? child,
      ) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  UIHelper.verticalSpaceMedium,

                  UIHelper.verticalSpaceMedium,
                  // wallet name and switch wallet arrow
                  DropdownButton(
                      underline: const SizedBox.shrink(),
                      elevation: 15,
                      isExpanded: false,
                      icon: const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.arrow_drop_down,
                          color: black,
                        ),
                      ),
                      iconEnabledColor: primaryColor,
                      iconDisabledColor:
                          model.multisigWallets.isEmpty ? secondaryColor : grey,
                      iconSize: 30,
                      value: model.txid,
                      onChanged: (newValue) {
                        model.getWalletByTxid(value: newValue.toString());
                      },
                      items: model.multisigWallets.map(
                        (wallet) {
                          return DropdownMenuItem(
                            value: wallet.txid,
                            child: Container(
                              color: secondaryColor,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  customText(
                                      text: wallet.name.toString(),
                                      textAlign: TextAlign.center,
                                      letterSpace: 1.2,
                                      style: headText4.copyWith(
                                          fontWeight: FontWeight.bold)),
                                  Container(
                                    width: 5,
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ).toList()),
                  // chain name
                  UIHelper.verticalSpaceMedium,
                  Container(
                    alignment: Alignment.centerLeft,
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: roundedBoxDecoration(
                        color: Colors.grey[200]!, radius: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.multisigWallet.chain.toString(),
                          style:
                              headText5.copyWith(fontWeight: FontWeight.bold),
                        ),
                        UIHelper.verticalSpaceSmall,
                        // wallet address and copy button,qr code and exchangily tx on blockchain button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  StringUtils.showPartialAddress(
                                      address: toKbpayAddress(model.fabUtils
                                          .exgToFabAddress(model
                                              .multisigWallet.address
                                              .toString()))),
                                  style: headText5.copyWith(
                                      fontWeight: FontWeight.bold),
                                ),
                                UIHelper.horizontalSpaceSmall,
                                InkWell(
                                  onTap: () {
                                    model.sharedService.copyAddress(
                                        context,
                                        toKbpayAddress(model.fabUtils
                                            .exgToFabAddress(model
                                                .multisigWallet.address!)));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: const Icon(
                                      Icons.copy,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {},
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: const Icon(
                                      Icons.qr_code,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () {},
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: const Icon(
                                  Icons.open_in_browser_outlined,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // transaction history and transaction queue button
                  UIHelper.verticalSpaceLarge,
                  Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      gradient: LinearGradient(
                        colors: const [Colors.blue, Colors.green],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: ListTile(
                      textColor: black,
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.history,
                            color: white,
                          ),
                        ],
                      ),
                      title: const Text('Transactions'),
                      titleTextStyle:
                          headText4.copyWith(fontWeight: FontWeight.bold),
                      subtitle: const Text('History - Queue'),
                      subtitleTextStyle: headText5,
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: white,
                      ),
                      onTap: () => model.navigationService
                          .navigateWithTransition(
                              HistoryQueueView(
                                  address:
                                      model.multisigWallet.address.toString()),
                              transitionStyle: Transition.downToUp),
                    ),
                  ),

                  UIHelper.verticalSpaceMedium,
                  Container(
                      padding: EdgeInsets.all(10),
                      width: double.infinity,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          customText(text: 'Assets'),
                          IconButton(
                            icon: Icon(
                              Icons.refresh,
                              color: primaryColor,
                            ),
                            onPressed: () {
                              model.getBalance();
                            },
                          )
                        ],
                      )),

                  // asset balance and asset name

                  Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: roundedBoxDecoration(
                        color: Colors.grey[100]!, radius: 10),
                    child: Column(children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            flex: 2,
                            child: customText(
                                text: 'Name',
                                style: headText5.copyWith(
                                    fontWeight: FontWeight.bold)),
                          ),
                          Expanded(
                            flex: 2,
                            child: customText(
                                text: 'Balance',
                                style: headText5.copyWith(
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      )
                    ]),
                  ),

                  Container(
                    child: model.busy(model.multisigBalance)
                        ? Column(
                            children: [
                              UIHelper.verticalSpaceLarge,
                              model.sharedService.loadingIndicator(),
                            ],
                          )
                        : Column(
                            children: [
                              UIHelper.verticalSpaceMedium,
                              InkWell(
                                onTap: () => model.navigateToTransferView(-1),
                                child: Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(bottom: 5),
                                  decoration: roundedBoxDecoration(
                                      color: Colors.grey[200]!, radius: 10),
                                  padding: const EdgeInsets.only(
                                      left: 10, bottom: 20.0, top: 20),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        width: 30,
                                        height: 30,
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              WalletCoinsLogoUrl + 'fab.png',
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
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  FadeInImage(
                                            placeholder: const AssetImage(
                                                'assets/images/launcher/paycool-logo.png'),
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                          flex: 2,
                                          child: Text('Kanban',
                                              style: headText5.copyWith())),
                                      Expanded(
                                          flex: 2,
                                          child: Text(
                                              model.multisigBalance.native
                                                  .toString(),
                                              style: headText5.copyWith()))
                                    ],
                                  ),
                                ),
                              ),
                              ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount:
                                      model.multisigBalance.tokens!.ids!.length,
                                  shrinkWrap: true,
                                  itemBuilder: ((context, index) {
                                    return InkWell(
                                      onTap: () =>
                                          model.navigateToTransferView(index),
                                      child: Container(
                                        alignment: Alignment.center,
                                        margin: EdgeInsets.only(bottom: 5),
                                        decoration: roundedBoxDecoration(
                                            color: Colors.grey[200]!,
                                            radius: 10),
                                        padding: const EdgeInsets.only(
                                            left: 10, bottom: 20.0, top: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              //asset('assets/images/wallet-page/$tickerName.png'),
                                              width: 30,
                                              height: 30,
                                              // decoration: BoxDecoration(
                                              //     color: walletCardColor,
                                              //     borderRadius: BorderRadius.circular(50),
                                              //     boxShadow: const [
                                              //       BoxShadow(
                                              //           color: fabLogoColor,
                                              //           offset: Offset(1.0, 5.0),
                                              //           blurRadius: 10.0,
                                              //           spreadRadius: 1.0),
                                              //     ]),

                                              // Todo Error handling when image not found or url not found
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    '$WalletCoinsLogoUrl${model.multisigBalance.tokens!.tickers![index].toLowerCase()}.png',
                                                placeholder: (context, url) =>
                                                    const CircularProgressIndicator(),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Icon(Icons.error),
                                                fit: BoxFit.cover,
                                                fadeInDuration: const Duration(
                                                    milliseconds: 500),
                                                fadeOutDuration: const Duration(
                                                    milliseconds: 500),
                                                fadeOutCurve: Curves.easeOut,
                                                fadeInCurve: Curves.easeIn,
                                                imageBuilder:
                                                    (context, imageProvider) =>
                                                        FadeInImage(
                                                  placeholder: const AssetImage(
                                                      'assets/images/launcher/paycool-logo.png'),
                                                  image: imageProvider,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                                flex: 2,
                                                child: Text(
                                                    model
                                                        .multisigBalance
                                                        .tokens!
                                                        .tickers![index],
                                                    style:
                                                        headText5.copyWith())),
                                            Expanded(
                                                flex: 2,
                                                child: Text(
                                                    model
                                                        .multisigBalance
                                                        .tokens!
                                                        .balances![index]
                                                        .toString(),
                                                    style:
                                                        headText5.copyWith()))
                                          ],
                                        ),
                                      ),
                                    );
                                  })),
                            ],
                          ),
                  ),
                  UIHelper.verticalSpaceMedium,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
