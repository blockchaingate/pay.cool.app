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

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/models/wallet/wallet.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/utils/number_util.dart';
import 'package:paycool/views/wallet/wallet_features/send/send_viewmodel.dart';
import 'package:paycool/widgets/wallet/decimal_limit_widget.dart';
import 'package:stacked/stacked.dart';

class SendWalletView extends StatelessWidget {
  final WalletInfo walletInfo;
  const SendWalletView({Key? key, required this.walletInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String tickerName = '';
    walletInfo.tickerName == 'USDTX'
        ? tickerName = 'USDT(TRC20)'
        : tickerName = walletInfo.tickerName!;
    String tokenType = walletInfo.tokenType!;
    return ViewModelBuilder<SendViewModel>.reactive(
        viewModelBuilder: () => SendViewModel(),
        onViewModelReady: (model) {
          model.context = context;
          model.walletInfo = walletInfo;
          model.initState();
        },
        builder: (context, model, child) => Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: customAppBarWithTitleNB(
                  '${FlutterI18n.translate(context, "send")} ${model.specialTickerName}'),
              body: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: SingleChildScrollView(
                  // to avoid using ListView without having any list childs to iterate and use column as its child now
                  child: Container(
                    margin: const EdgeInsets.all(10.0),
                    child: Column(
                      // I was using ListView here earlier to solve keyboard overflow error
                      children: <Widget>[
/*--------------------------------------------------------------------------------------------------------------------------------------------------------------

                                    Receiver's Wallet Address Container

--------------------------------------------------------------------------------------------------------------------------------------------------------------*/

                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          color: secondaryColor,
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Padding(
                                  padding: const EdgeInsets.only(bottom: 3.0),
                                  child: GestureDetector(
                                    child: TextField(
                                      maxLines: 1,
                                      controller: model
                                          .receiverWalletAddressTextController,
                                      onChanged: (value) =>
                                          model.checkDomain(value),
                                      decoration: InputDecoration(
                                          enabledBorder:
                                              const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: grey, width: 0.5)),
                                          suffixIcon: Container(
                                            margin: EdgeInsets.only(
                                              top: 2,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                model.receiverWalletAddressTextController
                                                        .text.isNotEmpty
                                                    ? IconButton(
                                                        icon: const Icon(
                                                            Icons.cancel),
                                                        onPressed: () {
                                                          model.clearAddress();
                                                        },
                                                        iconSize: 18,
                                                        color: white
                                                            .withAlpha(190),
                                                      )
                                                    : Container(),
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.content_paste),
                                                  onPressed: () async {
                                                    await model
                                                        .pasteClipBoardData();
                                                  },
                                                  iconSize: 22,
                                                  color: primaryColor,
                                                ),
                                              ],
                                            ),
                                          ),
                                          labelText:
                                              '${FlutterI18n.translate(context, "receiverWalletAddress")}, DNS',
                                          labelStyle: headText6),
                                      style: headText6,
                                    ),
                                  )),
                              model.busy(model.userTypedDomain)
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: SizedBox(
                                              width: 15,
                                              height: 15,
                                              child: model.sharedService
                                                  .loadingIndicator()),
                                        ),
                                      ],
                                    )
                                  : Container(),
                              model.userTypedDomain.isNotEmpty &&
                                      !model.busy(model.userTypedDomain)
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          model.userTypedDomain,
                                          style:
                                              headText6.copyWith(color: grey),
                                        ),
                                      ],
                                    )
                                  : Container(),
                              TextButton(
                                  style: ButtonStyle(
                                      padding: MaterialStateProperty.all(
                                          const EdgeInsets.all(10))),
                                  onPressed: () {
                                    model.scan();
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      const Padding(
                                          padding: EdgeInsets.only(right: 5),
                                          child: Icon(Icons.camera_enhance)),
                                      Text(
                                        FlutterI18n.translate(
                                            context, "scanBarCode"),
                                        style: headText5.copyWith(
                                            fontWeight: FontWeight.w400),
                                      )
                                    ],
                                  ))
                            ],
                          ),
                        ),

/*--------------------------------------------------------------------------------------------------------------------------------------------------------------

                                    Send Amount And Available Balance Container

--------------------------------------------------------------------------------------------------------------------------------------------------------------*/
                        Container(
                            color: secondaryColor,
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                TextField(
                                  inputFormatters: [
                                    DecimalTextInputFormatter(
                                        decimalRange: model.decimalLimit,
                                        activatedNegativeValues: false)
                                  ],
                                  // change paste text color
                                  controller: model.sendAmountTextController,
                                  onChanged: (String amount) {
                                    model.amount =
                                        NumberUtil.convertStringToDecimal(
                                            amount);

                                    model.checkAmount();
                                  },

                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true), // numnber keyboard
                                  decoration: InputDecoration(
                                      suffix: DecimalLimitWidget(
                                          decimalLimit: model.decimalLimit),
                                      focusedBorder: const UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: primaryColor)),
                                      enabledBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: grey, width: 0.5)),
                                      hintText: '0.00000',
                                      hintStyle: const TextStyle(
                                          fontSize: 14, color: grey)),
                                  style: model.checkSendAmount &&
                                          model.amount.toDouble() <=
                                              walletInfo.availableBalance!
                                      ? const TextStyle(
                                          color: grey, fontSize: 14)
                                      : const TextStyle(
                                          color: red, fontSize: 14),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            '${FlutterI18n.translate(context, "walletbalance")}  ${NumberUtil.customRoundNumber(model.walletInfo.availableBalance!, decimalPlaces: model.singlePairDecimalConfig.qtyDecimal)} ',
                                            style: headText6.copyWith(
                                                fontWeight: FontWeight.w400),
                                          ),
                                          Text(
                                            model.specialTickerName
                                                .toUpperCase(),
                                            style: headText6,
                                          )
                                        ],
                                      ),
                                      // RichText(
                                      //   text: TextSpan(
                                      //     recognizer: TapGestureRecognizer()
                                      //       ..onTap = () {
                                      //         model.fillMaxAmount();
                                      //       },
                                      //     text: FlutterI18n.translate(context, "t"))
                                      //         .maxAmount,
                                      //     style: Theme.of(context)
                                      //         .textTheme
                                      //         .bodyText1
                                      //         .copyWith(color: primaryColor),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                )
                              ],
                            )),
/*--------------------------------------------------------------------------------------------------------------------------------------------------------------

                                    Gas fee and Advance Switch Container

--------------------------------------------------------------------------------------------------------------------------------------------------------------*/
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: <Widget>[
                              model.isTrx()
                                  ? Container(
                                      padding: const EdgeInsets.only(
                                          top: 10, bottom: 0),
                                      alignment: Alignment.topLeft,
                                      child: walletInfo.tickerName == 'TRX'
                                          ? Text(
                                              '${FlutterI18n.translate(context, "gasFee")}: ${model.trxGasValueTextController.text} TRX',
                                              textAlign: TextAlign.left,
                                              style: headText6)
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    '${FlutterI18n.translate(context, "gasFee")}:  ${model.trxGasValueTextController.text} TRX',
                                                    textAlign: TextAlign.left,
                                                    style: headText6),
                                                Text(
                                                    'TRX'
                                                    '${FlutterI18n.translate(context, "balance")}: ${model.chainBalance} TRX',
                                                    textAlign: TextAlign.left,
                                                    style: headText6),
                                              ],
                                            ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.only(
                                          top: 15, bottom: 10),
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            FlutterI18n.translate(
                                                context, "gasFee"),
                                            style: headText5.copyWith(
                                                fontWeight: FontWeight.w400),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left:
                                                    5), // padding left to keep some space from the text
                                            child: model.isBusy
                                                ? SizedBox(
                                                    width: 16,
                                                    height: 16,
                                                    child: Theme.of(context)
                                                                .platform ==
                                                            TargetPlatform.iOS
                                                        ? const CupertinoActivityIndicator()
                                                        : const CircularProgressIndicator(
                                                            strokeWidth: 0.75,
                                                          ))
                                                : Text(
                                                    '${NumberUtil.customRoundNumber(model.transFee, decimalPlaces: 6)}  ${model.feeUnit}',
                                                    style: headText6.copyWith(
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                          )
                                        ],
                                      ),
                                    ),
                              // Switch Row Advance
                              Row(
                                children: <Widget>[
                                  Text(
                                    FlutterI18n.translate(context, "advance"),
                                    style: headText5.copyWith(
                                        fontWeight: FontWeight.w400),
                                  ),
                                  Switch(
                                    value: model.transFeeAdvance,
                                    inactiveTrackColor: grey,
                                    dragStartBehavior: DragStartBehavior.start,
                                    activeColor: primaryColor,
                                    onChanged: (bool value) {
                                      model.transFeeAdvance = value;
                                      model.notifyListeners();
                                    },
                                  )
                                ],
                              ),

                              model.isTrx()
                                  ? Visibility(
                                      visible: model.transFeeAdvance,
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                              flex: 3,
                                              child: Text(
                                                'TRX ${FlutterI18n.translate(context, "gasFee")}',
                                                style: headText5.copyWith(
                                                    fontWeight:
                                                        FontWeight.w300),
                                              )),
                                          Expanded(
                                              flex: 5,
                                              child: TextField(
                                                  controller: model
                                                      .trxGasValueTextController,
                                                  onChanged: (String amount) {
                                                    if (amount.isNotEmpty) {
                                                      model.trxGasValueTextController
                                                              .text =
                                                          amount.toString();
                                                      model.notifyListeners();
                                                    }
                                                  },
                                                  keyboardType: const TextInputType
                                                          .numberWithOptions(
                                                      decimal:
                                                          true), // numnber keyboard
                                                  decoration: InputDecoration(
                                                      focusedBorder:
                                                          const UnderlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color:
                                                                      primaryColor)),
                                                      enabledBorder:
                                                          const UnderlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: grey)),
                                                      hintText: '0.00000',
                                                      hintStyle: headText5.copyWith(
                                                          fontWeight:
                                                              FontWeight.w300)),
                                                  style: headText5.copyWith(
                                                      fontWeight:
                                                          FontWeight.w300)))
                                        ],
                                      ),
                                    )
                                  : Visibility(
                                      visible: model.transFeeAdvance,
                                      child: Column(
                                        children: <Widget>[
                                          Visibility(
                                              visible:
                                                  (model.specialTickerName ==
                                                          'ETH' ||
                                                      tokenType == 'ETH' ||
                                                      model.tokenType ==
                                                          'POLYGON' ||
                                                      tokenType == 'FAB'),
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                        FlutterI18n.translate(
                                                            context,
                                                            "gasPrice"),
                                                        style:
                                                            headText6.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400)),
                                                  ),
                                                  Expanded(
                                                      flex: 6,
                                                      child: TextField(
                                                          controller: model
                                                              .gasPriceTextController,
                                                          onChanged:
                                                              (String amount) {
                                                            model
                                                                .updateTransFee();
                                                          },
                                                          keyboardType:
                                                              const TextInputType.numberWithOptions(
                                                                  decimal:
                                                                      true),
                                                          decoration: InputDecoration(
                                                              focusedBorder: const UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              primaryColor)),
                                                              enabledBorder: const UnderlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      width:
                                                                          0.5,
                                                                      color:
                                                                          grey)),
                                                              hintText:
                                                                  '0.00000',
                                                              hintStyle: headText6.copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400)),
                                                          style: headText6.copyWith(
                                                              fontWeight:
                                                                  FontWeight.w400)))
                                                ],
                                              )),
                                          Visibility(
                                              visible:
                                                  (model.specialTickerName ==
                                                          'ETH' ||
                                                      model.tokenType ==
                                                          'POLYGON' ||
                                                      tokenType == 'ETH' ||
                                                      tokenType == 'FAB'),
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                        FlutterI18n.translate(
                                                            context,
                                                            "gasLimit"),
                                                        style:
                                                            headText6.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400)),
                                                  ),
                                                  Expanded(
                                                      flex: 6,
                                                      child: TextField(
                                                        controller: model
                                                            .gasLimitTextController,
                                                        onChanged:
                                                            (String amount) {
                                                          model
                                                              .updateTransFee();
                                                        },
                                                        keyboardType:
                                                            const TextInputType
                                                                    .numberWithOptions(
                                                                decimal: true),
                                                        decoration: InputDecoration(
                                                            focusedBorder:
                                                                const UnderlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                            color:
                                                                                primaryColor)),
                                                            enabledBorder: const UnderlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                        width:
                                                                            0.5,
                                                                        color:
                                                                            grey)),
                                                            hintText: '0.00000',
                                                            hintStyle: headText6
                                                                .copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400)),
                                                        style:
                                                            headText6.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                      ))
                                                ],
                                              )),
                                          Visibility(
                                              visible:
                                                  (model.specialTickerName ==
                                                          'BTC' ||
                                                      model.specialTickerName ==
                                                          'FAB' ||
                                                      tokenType == 'FAB'),
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                        FlutterI18n.translate(
                                                            context,
                                                            "satoshisPerByte"),
                                                        style: headText6),
                                                  ),
                                                  //  UIHelper.horizontalSpaceLarge,
                                                  Expanded(
                                                      flex: 6,
                                                      child: TextField(
                                                        controller: model
                                                            .satoshisPerByteTextController,
                                                        onChanged:
                                                            (String amount) {
                                                          model
                                                              .updateTransFee();
                                                        },
                                                        keyboardType:
                                                            const TextInputType
                                                                    .numberWithOptions(
                                                                decimal: true),
                                                        decoration: InputDecoration(
                                                            focusedBorder:
                                                                const UnderlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                            color:
                                                                                primaryColor)),
                                                            enabledBorder:
                                                                const UnderlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                            color:
                                                                                grey)),
                                                            hintText: '0.00000',
                                                            hintStyle: headText6
                                                                .copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400)),
                                                        style:
                                                            headText6.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300),
                                                      ))
                                                ],
                                              ))
                                        ],
                                      ))
                            ],
                          ),
                        ),

                        UIHelper.verticalSpaceSmall,
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            child: model.txHash.isNotEmpty
                                ? Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                        // show error details
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
                                child:
                                    Text(model.serverError, style: headText6),
                              )
                            : Container(),
                        UIHelper.verticalSpaceSmall,

                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: generalButtonStyle1,
                                onPressed: () {
                                  model.checkFields(context);
                                },
                                child: model.isBusy
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: model.sharedService
                                            .loadingIndicator())
                                    : Text(
                                        FlutterI18n.translate(context, "send"),
                                        style: headText4.copyWith(
                                            color: secondaryColor)),
                              ),
                            ),
                          ],
                        ),

                        UIHelper.verticalSpaceMedium
                      ],
                    ),
                  ),
                ),
              ),
            ));
  }
}
