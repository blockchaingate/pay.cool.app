import 'package:decimal/decimal.dart';
import 'package:exchangily_ui/exchangily_ui.dart' show kTextField;
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/multisig/dashboard/multisig_balance_model.dart';
import 'package:paycool/views/multisig/multisig_wallet_model.dart';
import 'package:stacked/stacked.dart';

import 'mutlisig_transfer_viewmodel.dart';

class MultisigTransferView extends StatelessWidget {
  final MultisigBalanceModel multisigBalance;
  final MultisigWalletModel multisigWallet;

  const MultisigTransferView(
      {Key? key, required this.multisigBalance, required this.multisigWallet})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MultisigTransferViewModel>.reactive(
      viewModelBuilder: () => MultisigTransferViewModel(),
      onViewModelReady: (viewModel) =>
          viewModel.init(multisigBalance.tokens!.tickers![0]),
      builder: (
        BuildContext context,
        MultisigTransferViewModel model,
        Widget? child,
      ) {
        return Scaffold(
            appBar: AppBar(
                centerTitle: true,
                title: Column(
                  children: [
                    Text(
                      FlutterI18n.translate(context, 'transfer'),
                      style: headText4.copyWith(color: Colors.white),
                    ),
                    Text(multisigBalance.tokens!.tickers![0])
                  ],
                )),
            body: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  kTextField(
                    controller: model.toController,
                    hintText: FlutterI18n.translate(context, 'address'),
                    labelText:
                        FlutterI18n.translate(context, 'receiverAddress'),
                    labelStyle: headText5.copyWith(color: grey),
                    cursorColor: green,
                    cursorHeight: 14,
                    fillColor: Colors.transparent,
                    suffixWidget: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.paste,
                            color: black,
                          ),
                          onPressed: () {
                            model.onPaste();
                          },
                        ),
                        // IconButton(
                        //   icon: Icon(
                        //     Icons.qr_code_scanner,
                        //     color: black,
                        //   ),
                        //   onPressed: () {
                        //     model.sharedService.sca(context);
                        //   },
                        // ),
                      ],
                    ),
                    leadingWidget: Icon(
                      Icons.abc,
                      color: black,
                    ),
                    isDense: true,
                    focusBorderColor: grey,
                  ),
                  UIHelper.verticalSpaceMedium,
                  kTextField(
                    controller: model.amountController,
                    hintText: '123',
                    labelText: FlutterI18n.translate(context, 'enterAmount'),
                    labelStyle: headText5.copyWith(color: grey),
                    cursorColor: green,
                    cursorHeight: 14,
                    fillColor: Colors.transparent,
                    leadingWidget: Icon(
                      Icons.numbers,
                      color: black,
                    ),
                    suffixWidget: Container(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            FlutterI18n.translate(context, 'balance'),
                            style: headText5.copyWith(color: grey),
                          ),
                          UIHelper.horizontalSpaceSmall,
                          Text(
                            multisigBalance.tokens!.balances![0],
                            style: headText5.copyWith(color: black),
                          ),
                        ],
                      ),
                    ),
                    isDense: true,
                    focusBorderColor: grey,
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: model.isBusy
                        ? model.sharedService.loadingIndicator()
                        : ElevatedButton.icon(
                            style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                    const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5)),
                                backgroundColor:
                                    MaterialStateProperty.all(primaryColor)),
                            icon: Icon(
                              Icons.send,
                              size: 18,
                            ),
                            onPressed: () {
                              var balance = Decimal.parse(
                                  multisigBalance.tokens!.balances![0]);
                              var textAmount = model.amountController.text;
                              if (textAmount.isEmpty) {
                                textAmount = '0';
                              }
                              var amount = Decimal.parse(textAmount);
                              if (model.toController.text.isEmpty) {
                                model.sharedService.sharedSimpleNotification(
                                  FlutterI18n.translate(
                                      context, 'enterAddress'),
                                );
                                return;
                              }
                              if (model.amountController.text.isEmpty ||
                                  model.amountController.text == '0') {
                                model.sharedService.sharedSimpleNotification(
                                  FlutterI18n.translate(context, 'enterAmount'),
                                );
                                return;
                              }

                              if (amount > balance) {
                                model.sharedService.sharedSimpleNotification(
                                  FlutterI18n.translate(
                                      context, 'insufficientBalance'),
                                );
                                return;
                              }
                              if (!model.isBusy)
                                model.transfer(multisigBalance.tokens!,
                                    multisigWallet, context);
                            },
                            label: Text(
                              FlutterI18n.translate(context, 'transfer'),
                              style: headText5.copyWith(color: white),
                            ),
                          ),
                  ),
                  UIHelper.verticalSpaceMedium,
                ],
              ),
            ));
      },
    );
  }
}
