/*
* Copyright (c) 2020 Exchangily LLC
*
* Licensed under Apache License v2.0
* You may obtain a copy of the License at
*
*      https://www.apache.org/licenses/LICENSE-2.0
*
*----------------------------------------------------------------------
* Author: barry-ruprai@exchangily.com
*----------------------------------------------------------------------
*/

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/constants.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/models/wallet/wallet.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/utils/barcode_util.dart';
import 'package:paycool/utils/number_util.dart';
import 'package:paycool/views/wallet/wallet_features/send/send_viewmodel.dart';
import 'package:stacked/stacked.dart';

class SendWalletView extends StatefulWidget {
  final WalletInfo? walletInfo;
  const SendWalletView({super.key, this.walletInfo});

  @override
  State<SendWalletView> createState() => _SendWalletViewState();
}

class _SendWalletViewState extends State<SendWalletView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double aniheight = 0.0;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500), // Adjust the duration as needed
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ViewModelBuilder<SendViewModel>.reactive(
        viewModelBuilder: () => SendViewModel(),
        onViewModelReady: (model) {
          model.context = context;
          if (widget.walletInfo != null) {
            model.walletInfo = widget.walletInfo;
          }
          model.initState();
        },
        builder: (context, model, child) => GestureDetector(
              onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: bgGrey,
                appBar: customAppBarWithIcon(
                    title: FlutterI18n.translate(context, "send"),
                    leading: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.black,
                          size: 20,
                        )),
                    actions: [
                      IconButton(
                        onPressed: () async {
                          await BarcodeUtil()
                              .showScannerPopup(context)
                              .then((value) {
                            if (value != null) {
                              model.receiverWalletAddressTextController.text =
                                  value;
                            }
                          });
                        },
                        icon: Image.asset(
                          "assets/images/new-design/scan_icon.png",
                          scale: 2.7,
                        ),
                      )
                    ]),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
                floatingActionButton: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 50,
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: ElevatedButton.icon(
                          icon:
                              Icon(Icons.arrow_circle_up, color: Colors.white),
                          label: Text(FlutterI18n.translate(context, "send"),
                              style: TextStyle(color: Colors.white)),
                          onPressed: () async {
                            model.amount != Constants.decimalZero &&
                                    model.receiverWalletAddressTextController
                                        .text.isNotEmpty &&
                                    model.checkSendAmount &&
                                    model.amount.toDouble() <=
                                        model.walletInfo!.availableBalance!
                                ? await model
                                    .checkFields(context)
                                    .catchError((e) {
                                    debugPrint(e.toString());
                                  })
                                : null;
                          },
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: model.amount !=
                                          Constants.decimalZero &&
                                      model.receiverWalletAddressTextController
                                          .text.isNotEmpty &&
                                      model.checkSendAmount &&
                                      model.amount.toDouble() <=
                                          model.walletInfo!.availableBalance!
                                  ? buttonGreen
                                  : grey),
                        ),
                      ),
                    ),
                  ],
                ),
                body: Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${FlutterI18n.translate(context, "receiverWalletAddress")}, DNS',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: black),
                      ),
                      UIHelper.verticalSpaceSmall,
                      Container(
                        width: size.width,
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller:
                                    model.receiverWalletAddressTextController,
                                onChanged: (value) => model.checkDomain(value),
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: FlutterI18n.translate(
                                      context, "enterTheReceived"),
                                  hintStyle: TextStyle(
                                      fontSize: 16, color: textHintGrey),
                                  contentPadding: EdgeInsets.only(left: 10),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 50,
                              height: 50,
                              child: Center(
                                child: IconButton(
                                  onPressed: () async {
                                    await model.pasteClipBoardData();
                                  },
                                  icon: Image.asset(
                                    "assets/images/new-design/clipBoard_icon.png",
                                    scale: 2.2,
                                    color: textHintGrey,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      UIHelper.verticalSpaceMedium,
                      Text(
                        FlutterI18n.translate(context, "amount"),
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: black),
                      ),
                      UIHelper.verticalSpaceSmall,
                      Container(
                        width: size.width,
                        height: size.height * 0.1,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: model.sendAmountTextController,
                                inputFormatters: [
                                  DecimalTextInputFormatter(
                                      decimalRange: model.decimalLimit,
                                      activatedNegativeValues: false)
                                ],
                                onChanged: (String amount) {
                                  if (amount.isNotEmpty &&
                                      model.walletInfo != null) {
                                    model.amount =
                                        NumberUtil.convertStringToDecimal(
                                            amount);
                                    model.checkAmount();
                                  }
                                  setState(() {});
                                },
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                style: model.checkSendAmount &&
                                        model.amount.toDouble() <=
                                            model.walletInfo!.availableBalance!
                                    ? TextStyle(
                                        fontSize: 16, color: Colors.black)
                                    : TextStyle(
                                        fontSize: 16, color: Colors.red),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '0.00',
                                  hintStyle: TextStyle(
                                      fontSize: 16, color: textHintGrey),
                                  contentPadding: EdgeInsets.only(left: 10),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: SizedBox(
                                height: size.height * 0.08,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        model.goToCoinList(size).then((value) {
                                          setState(() {});
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          Text(
                                            model.walletInfo != null
                                                ? model.walletInfo!.tickerName!
                                                : FlutterI18n.translate(
                                                    context, "selectToken"),
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: black),
                                          ),
                                          Icon(Icons.arrow_drop_down,
                                              color: Colors.black, size: 18)
                                        ],
                                      ),
                                    ),
                                    model.walletInfo != null
                                        ? Text(
                                            "${FlutterI18n.translate(context, "balance")} ${model.walletInfo!.availableBalance!}${model.walletInfo!.tickerName}",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: textHintGrey),
                                          )
                                        : SizedBox()
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      UIHelper.verticalSpaceMedium,
                      Text(
                        FlutterI18n.translate(context, "gasFee"),
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: black),
                      ),
                      UIHelper.verticalSpaceSmall,
                      Container(
                        width: size.width,
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.only(right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Text(
                                    ' ${FlutterI18n.translate(context, "About")} ${NumberUtil.roundDouble(model.transFee, decimalPlaces: 6)}  ${model.feeUnit}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: black),
                                  ),
                                ),
                                model.tokenType.isNotEmpty
                                    ? Text(
                                        ' ${FlutterI18n.translate(context, "balance")} ${model.chainBalance} ${model.feeUnit}',
                                        style: TextStyle(
                                            fontSize: 10, color: grey),
                                      )
                                    : Container()
                              ],
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (aniheight == 0) {
                                    aniheight = 120;
                                  } else {
                                    aniheight = 0;
                                  }
                                });
                              },
                              child: Row(
                                children: [
                                  Text(
                                    FlutterI18n.translate(context, "advance"),
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: black),
                                  ),
                                  Icon(Icons.arrow_drop_down,
                                      color: Colors.black, size: 18)
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      UIHelper.verticalSpaceSmall,
                      AnimatedContainer(
                          duration: Duration(
                              milliseconds:
                                  500), // Adjust the duration as needed
                          height: aniheight,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Container(
                                  width: size.width,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    children: [
                                      Center(
                                        child: Text(
                                          FlutterI18n.translate(
                                              context, "gasPrice"),
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: textHintGrey),
                                        ),
                                      ),
                                      Expanded(
                                        child: TextField(
                                          controller:
                                              model.gasPriceTextController,
                                          onChanged: (value) {},
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black),
                                          textAlign: TextAlign.right,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "90",
                                            hintStyle: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black),
                                            contentPadding:
                                                EdgeInsets.only(left: 10),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 3,
                                ),
                                Container(
                                  width: size.width,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    children: [
                                      Center(
                                        child: Text(
                                          FlutterI18n.translate(
                                              context, "gasLimit"),
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: textHintGrey),
                                        ),
                                      ),
                                      Expanded(
                                        child: TextField(
                                          controller:
                                              model.gasLimitTextController,
                                          onChanged: (value) {},
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black),
                                          textAlign: TextAlign.right,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "21000",
                                            hintStyle: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black),
                                            contentPadding:
                                                EdgeInsets.only(left: 10),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                      UIHelper.verticalSpaceSmall,
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          child: model.txHash.isNotEmpty
                              ? Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    RichText(
                                      text: TextSpan(
                                          text: FlutterI18n.translate(
                                              context, "taphereToCopyTxId"),
                                          style: const TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                              color: primaryColor),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              model.copyAddress(context);
                                            }),
                                    ),
                                    UIHelper.verticalSpaceSmall,
                                    Text(
                                      model.txHash,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ],
                                )
                              : Center(
                                  child: Text(
                                  model.errorMessage,
                                  style: const TextStyle(color: red),
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
                                            .bodyMedium!
                                            .copyWith(
                                                decoration:
                                                    TextDecoration.underline),
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
                                        color: Colors.red, size: 18)
                                    : const Icon(Icons.arrow_drop_up,
                                        color: Colors.red, size: 18)
                              ],
                            )
                          : Container(),
                      model.isShowDetailsMessage
                          ? Center(
                              child: Text(model.serverError, style: headText6),
                            )
                          : Container(),
                      UIHelper.verticalSpaceSmall,
                    ],
                  ),
                ),
              ),
            ));
  }
}
