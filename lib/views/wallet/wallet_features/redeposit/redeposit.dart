/*
* Copyright (c) 2020 Exchangily LLC
*
* Licensed under Apache License v2.0
* You may obtain a copy of the License at
*
*      https://www.apache.org/licenses/LICENSE-2.0
*
*----------------------------------------------------------------------
* Author: ken.qiu@exchangily.com
*----------------------------------------------------------------------
*/

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/models/wallet/wallet.dart';

import 'package:paycool/shared/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:paycool/utils/number_util.dart';
import 'package:paycool/views/wallet/wallet_features/redeposit/redeposit_viewmodel.dart';
import 'package:stacked/stacked.dart';

// {"success":true,"data":{"transactionID":"7f9d1b3fad00afa85076d28d46fd3457f66300989086b95c73ed84e9b3906de8"}}
class RedepositView extends StatelessWidget {
  final WalletInfo walletInfo;

  const RedepositView({Key? key, required this.walletInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<RedepositViewModel>.reactive(
      onViewModelReady: (model) {
        model.context = context;
        model.walletInfo = walletInfo;
      },
      viewModelBuilder: () => RedepositViewModel(),
      builder: (BuildContext context, model, child) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            '${FlutterI18n.translate(context, "redeposit")}  ${walletInfo.tickerName}  ${FlutterI18n.translate(context, "toExchange")}',
            style: headText4,
          ),
          // backgroundColor: const Color(0XFF1f2233),
        ),
        //  backgroundColor: const Color(0xFF1F2233),
        body: Container(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: <Widget>[
              model.isBusy
                  ? model.sharedService.loadingIndicator()
                  : Container(
                      color: grey.withOpacity(.2),
                      child: Column(
                        children: model.errDepositList
                            .map((data) => RadioListTile(
                                  dense: true,
                                  title: Row(
                                    children: <Widget>[
                                      Text(
                                          FlutterI18n.translate(
                                              context, "amount"),
                                          style: headText4),
                                      UIHelper.horizontalSpaceSmall,
                                      Text(
                                        NumberUtil.rawStringToDecimal(
                                                data["amount"].toString())
                                            .toDouble()
                                            .toString(),
                                        style: headText4,
                                      ),
                                    ],
                                  ),
                                  value: data['transactionID'].toString(),
                                  groupValue: model.errDepositTransactionID,
                                  onChanged: (val) {
                                    model.setBusy(true);
                                    model.errDepositTransactionID =
                                        val.toString();
                                    debugPrint(
                                        'valllll=${model.errDepositTransactionID}');
                                    model.setBusy(false);
                                  },
                                ))
                            .toList(),
                      ),
                    ),
              UIHelper.verticalSpaceSmall,
              Container(
                padding: const EdgeInsets.only(left: 20.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          '${FlutterI18n.translate(context, "walletbalance")} ${walletInfo.availableBalance}',
                          style: headText5,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          child: Text(
                            walletInfo.tickerName!.toUpperCase(),
                            style: headText5,
                          ),
                        )
                      ],
                    ),
                    UIHelper.verticalSpaceSmall,
                    Row(
                      children: <Widget>[
                        Text(FlutterI18n.translate(context, "kanbanGasFee"),
                            style: headText5),
                        UIHelper.horizontalSpaceSmall,
                        Text(
                          '${model.kanbanTransFee}',
                          style: headText5,
                        )
                      ],
                    ),
                    // Switch Row
                    Row(
                      children: <Widget>[
                        Text(FlutterI18n.translate(context, "advance"),
                            style: headText5),
                        Switch(
                          value: model.transFeeAdvance,
                          inactiveTrackColor: grey,
                          dragStartBehavior: DragStartBehavior.start,
                          activeColor: primaryColor,
                          onChanged: (bool isOn) {
                            model.setBusy(true);
                            model.transFeeAdvance = isOn;
                            model.setBusy(false);
                          },
                        )
                      ],
                    ),
                    Visibility(
                        visible: model.transFeeAdvance,
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                      FlutterI18n.translate(
                                          context, "kanbanGasPrice"),
                                      style: headText6),
                                ),
                                Expanded(
                                    flex: 5,
                                    child: TextField(
                                      controller:
                                          model.kanbanGasPriceTextController,
                                      onChanged: (String amount) {
                                        model.updateTransFee();
                                      },
                                      keyboardType: TextInputType
                                          .number, // numnber keyboard
                                      decoration: InputDecoration(
                                          focusedBorder:
                                              const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: primaryColor)),
                                          enabledBorder:
                                              const UnderlineInputBorder(
                                                  borderSide:
                                                      BorderSide(color: grey)),
                                          hintText: '0.00000',
                                          hintStyle: headText5),
                                      style: const TextStyle(
                                          color: grey, fontSize: 12),
                                    ))
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                      FlutterI18n.translate(
                                          context, "kanbanGasLimit"),
                                      style: headText6),
                                ),
                                Expanded(
                                    flex: 5,
                                    child: TextField(
                                      controller:
                                          model.kanbanGasLimitTextController,
                                      onChanged: (String amount) {
                                        model.updateTransFee();
                                      },
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal:
                                                  true), // numnber keyboard
                                      decoration: InputDecoration(
                                          focusedBorder:
                                              const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: primaryColor)),
                                          enabledBorder:
                                              const UnderlineInputBorder(
                                                  borderSide:
                                                      BorderSide(color: grey)),
                                          hintText: '0.00000',
                                          hintStyle: headText5),
                                      style: const TextStyle(
                                          color: grey, fontSize: 12),
                                    ))
                              ],
                            )
                          ],
                        ))
                  ],
                ),
              ),
              model.errorMessage.isNotEmpty
                  ? Center(child: Text(model.errorMessage))
                  : Container(),
              UIHelper.verticalSpaceSmall,
              MaterialButton(
                padding: const EdgeInsets.all(15),
                color: primaryColor,
                textColor: Colors.white,
                onPressed: () {
                  model.checkPass();
                },
                child: Text(
                  FlutterI18n.translate(context, "confirm"),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
