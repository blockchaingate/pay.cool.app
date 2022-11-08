/*
* Copyright (c) 2020 Exchangily LLC
*
* Licensed under Apache License v2.0
* You may obtain a copy of the License at
*
*      https://www.apache.org/licenses/LICENSE-2.0
*
*----------------------------------------------------------------------
* Author: ken.qiu@exchangily.com and barry_ruprai@exchangily.com
*----------------------------------------------------------------------
*/

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/models/wallet/wallet.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/utils/number_util.dart';
import 'package:paycool/utils/string_util.dart';
import 'package:paycool/views/wallet/wallet_features/move_to_exchange/move_to_exchange_viewmodel.dart';
import 'package:paycool/widgets/wallet/decimal_limit_widget.dart';

import 'package:stacked/stacked.dart';

// {"success":true,"data":{"transactionID":"7f9d1b3fad00afa85076d28d46fd3457f66300989086b95c73ed84e9b3906de8"}}
class MoveToExchangeView extends StatelessWidget {
  final WalletInfo walletInfo;
  const MoveToExchangeView({Key key, this.walletInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MoveToExchangeViewModel>.reactive(
      viewModelBuilder: () => MoveToExchangeViewModel(),
      onModelReady: (model) {
        model.context = context;
        model.walletInfo = walletInfo;
        model.initState();
      },
      builder: (context, model, child) => Scaffold(
        appBar: CupertinoNavigationBar(
          padding: const EdgeInsetsDirectional.only(start: 0),
          leading: CupertinoButton(
            padding: const EdgeInsets.all(0),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
          middle: Text(
            '${FlutterI18n.translate(context, "move")}  ${model.specialTicker}  ${FlutterI18n.translate(context, "toExchange")}',
            style: headText5,
          ),
          backgroundColor: const Color(0XFF1f2233),
        ),
        backgroundColor: const Color(0xFF1F2233),
        body: Container(
          padding: const EdgeInsets.all(10),
          child: ListView(
            // mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextField(
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  DecimalTextInputFormatter(
                      decimalRange: model.decimalLimit,
                      activatedNegativeValues: false)
                ],
                onChanged: (String amount) {
                  model.updateTransFee();
                },
                decoration: InputDecoration(
                  // suffix: RichText(
                  //   text: TextSpan(
                  //     recognizer: TapGestureRecognizer()
                  //       ..onTap = () {
                  //         model.fillMaxAmount();
                  //       },
                  //     text: FlutterI18n.translate(context, "maxAmount"),
                  //     style: Theme.of(context)
                  //         .textTheme
                  //         .bodyText1
                  //         .copyWith(color: primaryColor),
                  //   ),
                  // ),
                  suffix: DecimalLimitWidget(decimalLimit: model.decimalLimit),
                  enabledBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0XFF871fff), width: 1.0)),
                  hintText: FlutterI18n.translate(context, "enterAmount"),
                  hintStyle:
                      const TextStyle(fontSize: 14.0, color: Colors.grey),
                ),
                controller: model.amountController,
                style: headText5.copyWith(
                    fontWeight: FontWeight.w300,
                    color: model.isValidAmount ? white : red),
              ),
              UIHelper.verticalSpaceSmall,
              // Wallet Balance
              Row(
                children: <Widget>[
                  Text(
                      FlutterI18n.translate(context, "walletbalance") +
                          '  ${NumberUtil().truncateDoubleWithoutRouding(model.walletInfo.availableBalance, precision: model.decimalLimit).toString()}',
                      style: subText2),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 3,
                    ),
                    child: Text(model.specialTicker.toUpperCase(),
                        style: subText2),
                  )
                ],
              ),
              UIHelper.verticalSpaceSmall,

              Container(
                child: Column(
                  children: [
                    walletInfo.tickerName == 'TRX' ||
                            walletInfo.tickerName == 'USDTX'
                        ? Container(
                            padding: const EdgeInsets.only(top: 10, bottom: 0),
                            alignment: Alignment.topLeft,
                            child: walletInfo.tickerName == 'TRX'
                                ? Text(
                                    '${FlutterI18n.translate(context, "gasFee")}: 1 TRX',
                                    textAlign: TextAlign.left,
                                    style: headText6)
                                : Text(
                                    '${FlutterI18n.translate(context, "gasFee")}: 15 TRX',
                                    textAlign: TextAlign.left,
                                    style: headText6),
                          )
                        : Row(
                            children: <Widget>[
                              Text(FlutterI18n.translate(context, "gasFee"),
                                  style: headText6),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left:
                                        5), // padding left to keep some space from the text
                                child: Text(
                                    '${NumberUtil().truncateDoubleWithoutRouding(model.transFee, precision: 4).toString()} ${model.feeUnit}',
                                    style: headText6),
                              )
                            ],
                          ),
                    UIHelper.verticalSpaceSmall,
                    // Kanaban Gas Fee Row
                    Row(
                      children: <Widget>[
                        Text(FlutterI18n.translate(context, "kanbanGasFee"),
                            style: headText6),
                        Padding(
                          padding: const EdgeInsets.only(
                              left:
                                  5), // padding left to keep some space from the text
                          child: Text(
                              '${NumberUtil().truncateDoubleWithoutRouding(model.kanbanTransFee, precision: 4).toString()} GAS',
                              style: headText6),
                        )
                      ],
                    ),
                  ],
                ),
              ),

              // Switch Row
              Row(
                children: <Widget>[
                  Text(FlutterI18n.translate(context, "advance"),
                      style: headText6),
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
              // Transaction Fee Advance
              Visibility(
                  visible: model.transFeeAdvance,
                  child: Column(
                    children: <Widget>[
                      Visibility(
                          visible: (model.coinName == 'ETH' ||
                              model.tokenType == 'ETH' ||
                              model.tokenType == 'FAB'),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: Text(
                                    FlutterI18n.translate(context, "gasPrice"),
                                    style: headText5.copyWith(
                                        fontWeight: FontWeight.w300)),
                              ),
                              Expanded(
                                  flex: 5,
                                  child: TextField(
                                      controller: model.gasPriceTextController,
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
                                          hintStyle: headText5.copyWith(
                                              fontWeight: FontWeight.w300)),
                                      style: headText5.copyWith(
                                          fontWeight: FontWeight.w300)))
                            ],
                          )),
                      Visibility(
                          visible: (model.coinName == 'ETH' ||
                              model.tokenType == 'ETH' ||
                              model.tokenType == 'FAB'),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                  flex: 3,
                                  child: Text(
                                    FlutterI18n.translate(context, "gasLimit"),
                                    style: headText5.copyWith(
                                        fontWeight: FontWeight.w300),
                                  )),
                              Expanded(
                                  flex: 5,
                                  child: TextField(
                                      controller: model.gasLimitTextController,
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
                                          hintStyle: headText5.copyWith(
                                              fontWeight: FontWeight.w300)),
                                      style: headText5.copyWith(
                                          fontWeight: FontWeight.w300)))
                            ],
                          )),
                      Visibility(
                          visible: (model.coinName == 'BTC' ||
                              model.coinName == 'FAB' ||
                              model.tokenType == 'FAB'),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: Text(
                                  FlutterI18n.translate(
                                      context, "satoshisPerByte"),
                                  style: headText5.copyWith(
                                      fontWeight: FontWeight.w300),
                                ),
                              ),
                              Expanded(
                                  flex: 5,
                                  child: TextField(
                                    controller:
                                        model.satoshisPerByteTextController,
                                    onChanged: (String amount) {
                                      model.updateTransFee();
                                    },
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true), // numnber keyboard
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
                                        hintStyle: headText5.copyWith(
                                            fontWeight: FontWeight.w300)),
                                    style: const TextStyle(
                                        color: grey, fontSize: 16),
                                  ))
                            ],
                          )),
                      Row(
                        children: <Widget>[
                          Expanded(
                              flex: 3,
                              child: Text(
                                FlutterI18n.translate(
                                    context, "kanbanGasPrice"),
                                style: headText5.copyWith(
                                    fontWeight: FontWeight.w300),
                              )),
                          Expanded(
                              flex: 5,
                              child: TextField(
                                  controller:
                                      model.kanbanGasPriceTextController,
                                  onChanged: (String amount) {
                                    model.updateTransFee();
                                  },
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true), // numnber keyboard
                                  decoration: InputDecoration(
                                      focusedBorder: const UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: primaryColor)),
                                      enabledBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(color: grey)),
                                      hintText: '0.00000',
                                      hintStyle: headText5.copyWith(
                                          fontWeight: FontWeight.w300)),
                                  style: headText5.copyWith(
                                      fontWeight: FontWeight.w300)))
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 3,
                            child: Text(
                                FlutterI18n.translate(
                                    context, "kanbanGasLimit"),
                                style: headText5.copyWith(
                                    fontWeight: FontWeight.w300)),
                          ),
                          Expanded(
                              flex: 5,
                              child: TextField(
                                controller: model.kanbanGasLimitTextController,
                                onChanged: (String amount) {
                                  model.updateTransFee();
                                },
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true), // numnber keyboard
                                decoration: InputDecoration(
                                    focusedBorder: const UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: primaryColor)),
                                    enabledBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(color: grey)),
                                    hintText: '0.00000',
                                    hintStyle: headText5.copyWith(
                                        fontWeight: FontWeight.w300)),
                                style: headText5.copyWith(
                                    fontWeight: FontWeight.w300),
                              ))
                        ],
                      )
                    ],
                  )),
              UIHelper.verticalSpaceSmall,
              // Success/Error container
              Container(
                  child: Visibility(
                      visible: model.message.isNotEmpty,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(model.message),
                          UIHelper.verticalSpaceSmall,
                          RichText(
                            text: TextSpan(
                                text: FlutterI18n.translate(
                                    context, "taphereToCopyTxId"),
                                style: const TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: primaryColor),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    debugPrint('1');
                                    debugPrint(model.message.toString());
                                    debugPrint('2');
                                    model
                                        .copyAndShowNotification(model.message);
                                  }),
                          ),
                          UIHelper.verticalSpaceSmall,
                        ],
                      ))),
              UIHelper.verticalSpaceSmall,
              model.isShowErrorDetailsButton
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: RichText(
                            text: TextSpan(
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .copyWith(
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.w400),
                                text:
                                    '${FlutterI18n.translate(context, "error")} ${FlutterI18n.translate(context, "details")}',
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    model.showDetailsMessageToggle();
                                  }),
                          ),
                        ),
                        !model.isShowDetailsMessage
                            ? const Icon(Icons.arrow_drop_down,
                                color: Colors.red, size: 20)
                            : const Icon(Icons.arrow_drop_up,
                                color: Colors.red, size: 20)
                      ],
                    )
                  : Container(),

              model.isShowDetailsMessage
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(firstCharToUppercase(model.serverError),
                            style: headText5),
                      ),
                    )
                  : Container(),
              UIHelper.verticalSpaceSmall,
              // Confirm Button
              ElevatedButton(
                style: generalButtonStyle1,
                onPressed: () {
                  if (model.isValidAmount && model.amount != 0.0) {
                    model.checkPass();
                  }
                },
                child: model.isBusy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                        ))
                    : Text(FlutterI18n.translate(context, "confirm"),
                        style: headText4.copyWith(
                            color: model.isValidAmount && model.amount != 0.0
                                ? white
                                : grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
