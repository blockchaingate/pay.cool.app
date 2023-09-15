import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/utils/exaddr.dart';
import 'package:paycool/utils/string_util.dart';
import 'package:stacked/stacked.dart';

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                          onPressed: () {},
                          child: Row(
                            children: [
                              Text('Transaction History'),
                              UIHelper.horizontalSpaceSmall,
                              Icon(
                                Icons.history,
                                size: 18,
                              )
                            ],
                          )),
                      ElevatedButton(
                          onPressed: () {},
                          child: Row(
                            children: [
                              Text('Transaction Queue'),
                              UIHelper.horizontalSpaceSmall,
                              Icon(
                                Icons.queue,
                                size: 18,
                              )
                            ],
                          )),
                    ],
                  ),
                  UIHelper.verticalSpaceMedium,
                  Container(
                      alignment: Alignment.centerLeft,
                      child: customText(text: 'Assets')),
                  UIHelper.verticalSpaceMedium,

                  // asset balance and asset name

                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                          )
                        ],
                      )
                    ]),
                  ),

                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: model.busy(model.exchangeBalances)
                        ? Column(
                            children: [
                              UIHelper.verticalSpaceLarge,
                              model.sharedService.loadingIndicator(),
                            ],
                          )
                        : model.exchangeBalances.isEmpty
                            ? Container(
                                height: 100,
                                alignment: Alignment.bottomCenter,
                                margin: EdgeInsets.symmetric(vertical: 40),
                                child: Icon(
                                  Icons.hourglass_empty_outlined,
                                  color: black,
                                  size: 32,
                                ),
                              )
                            : ListView.builder(
                                itemCount: model.exchangeBalances.length,
                                shrinkWrap: true,
                                itemBuilder: ((context, index) {
                                  return InkWell(
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 2,
                                            child: Text(model
                                                .exchangeBalances[index]
                                                .ticker)),
                                        Expanded(
                                            flex: 2,
                                            child: Text(model
                                                .exchangeBalances[index]
                                                .unlockedAmount
                                                .toString()))
                                      ],
                                    ),
                                  );
                                })),
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
