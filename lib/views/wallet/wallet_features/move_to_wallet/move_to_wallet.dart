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

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/models/wallet/wallet.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/utils/number_util.dart';
import 'package:paycool/views/wallet/wallet_features/move_to_wallet/move_to_wallet_viewmodel.dart';
import 'package:paycool/widgets/wallet/decimal_limit_widget.dart';
import 'package:stacked/stacked.dart';

import 'package:flutter/gestures.dart';

class MoveToWalletView extends StatelessWidget {
  final WalletInfo walletInfo;
  const MoveToWalletView({Key key, this.walletInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MoveToWalletViewmodel>.reactive(
      viewModelBuilder: () => MoveToWalletViewmodel(),
      onModelReady: (model) {
        model.context = context;
        model.walletInfo = walletInfo;
        model.initState();
      },
      builder: (context, model, child) => WillPopScope(
        onWillPop: () async {
          debugPrint('is Alert ${model.isAlert}');
          if (model.isAlert) {
            Navigator.of(context, rootNavigator: true).pop();
            model.isAlert = false;
            debugPrint('i Alert in if ${model.isAlert}');
          } else {
            Navigator.of(context).pop();
          }

          return Future.value(false);
        },
        child: Scaffold(
          appBar: customAppBarWithTitleNB(
              '${FlutterI18n.translate(context, "move")}  ${model.specialTicker}  ${FlutterI18n.translate(context, "toWallet")}'),
          body: SingleChildScrollView(
            child: Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    TextField(
                        onChanged: (String amount) {
                          model.updateTransFee();
                        },
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          DecimalTextInputFormatter(
                              decimalRange: model.token.decimal,
                              activatedNegativeValues: false)
                        ],
                        decoration: InputDecoration(
                            suffix: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                        FlutterI18n.translate(
                                                context, "minimumAmount") +
                                            ': ',
                                        style: headText6),
                                    Text(
                                        model.token.minWithdraw == null
                                            ? FlutterI18n.translate(
                                                context, "loading")
                                            : model.token.minWithdraw
                                                .toString(),
                                        style: headText6),
                                  ],
                                ),
                                DecimalLimitWidget(
                                    decimalLimit: model.token.decimal)
                              ],
                            ),
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: primaryColor, width: 1.0)),
                            enabledBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: black, width: 1.0)),
                            hintText:
                                FlutterI18n.translate(context, "enterAmount"),
                            hintStyle: headText5.copyWith(
                                fontWeight: FontWeight.w300)),
                        controller: model.amountController,
                        style: headText5.copyWith(fontWeight: FontWeight.w300)),
                    UIHelper.verticalSpaceSmall,
                    // Exchange bal
                    Row(
                      children: <Widget>[
                        Text(
                            FlutterI18n.translate(context, "inExchange") +
                                ' ${NumberUtil().truncateDoubleWithoutRouding(model.walletInfo.inExchange, precision: 6).toString()}',
                            style: subText2),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 3,
                          ),
                          child: walletInfo.tickerName == 'USDTX'
                              ? Text('USDT'.toUpperCase(), style: subText2)
                              : Text(model.specialTicker.toUpperCase(),
                                  style: subText2),
                        ),
                        model.isWithdrawChoice
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.info_outline,
                                      color: primaryColor,
                                      size: 16,
                                    ),
                                    onPressed: () =>
                                        model.showInfoDialog(false)),
                              )
                            : Container()
                      ],
                    ),

                    UIHelper.verticalSpaceSmall,
                    // Kanban Gas Fee
                    // walletInfo.tickerName == 'TRX' ||
                    //         walletInfo.tickerName == 'USDTX' ||
                    //         model.isShowTrxTsWalletBalance
                    //     ? Container(
                    //         padding: EdgeInsets.only(top: 10, bottom: 0),
                    //         alignment: Alignment.topLeft,
                    //         child: walletInfo.tickerName == 'TRX'
                    //             ? Text(
                    //                 '${FlutterI18n.translate(context, "gasFee")}: 1 TRX',
                    //                 textAlign: TextAlign.left,
                    //                 style:
                    //                     headText6)
                    //             : Text(
                    //                 '${FlutterI18n.translate(context, "gasFee")}: 15 TRX',
                    //                 textAlign: TextAlign.left,
                    //                 style: headText6),
                    //       )
                    //     : Container(),
                    //
                    // // withdraw choice radio
                    model.isWithdrawChoice
                        ? Container(child: model.radioChoiceRow(context))
                        : Container(),
                    model.isWithdrawChoice
                        ? UIHelper.verticalSpaceMedium
                        : Container(),
// withdraw fee
                    Row(
                      children: <Widget>[
                        Text(
                            FlutterI18n.translate(context, "withdraw") +
                                ' ' +
                                FlutterI18n.translate(context, "fee"),
                            style: headText6),
                        UIHelper.horizontalSpaceSmall,
                        Padding(
                          padding: const EdgeInsets.only(
                              left:
                                  5), // padding left to keep some space from the text
                          child: model.isBusy
                              ? const Text('..')
                              : Text(
                                  '${model.token.feeWithdraw} ${model.specialTicker.contains('(') ? model.specialTicker.split('(')[0] : model.specialTicker}',
                                  style: headText6),
                        )
                      ],
                    ),
                    UIHelper.verticalSpaceSmall,
                    // kanban gas fee
                    Row(
                      children: <Widget>[
                        Text(FlutterI18n.translate(context, "kanbanGasFee"),
                            style: headText6),
                        UIHelper.horizontalSpaceSmall,
                        Padding(
                          padding: const EdgeInsets.only(
                              left:
                                  5), // padding left to keep some space from the text
                          child: Text(
                              '${model.kanbanTransFee.toStringAsFixed(4)} GAS',
                              style: headText6),
                        )
                      ],
                    ),
                    // Switch Row
                    UIHelper.verticalSpaceSmall,
                    Row(
                      children: <Widget>[
                        Text(FlutterI18n.translate(context, "advance"),
                            style: headText6),
                        SizedBox(
                          height: 15,
                          child: Switch(
                            value: model.transFeeAdvance,
                            inactiveTrackColor: grey,
                            dragStartBehavior: DragStartBehavior.start,
                            activeColor: primaryColor,
                            onChanged: (bool isOn) {
                              model.setBusy(true);
                              model.transFeeAdvance = isOn;
                              model.setBusy(false);
                            },
                          ),
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
                                      style: headText5.copyWith(
                                          fontWeight: FontWeight.w300)),
                                ),
                                Expanded(
                                    flex: 5,
                                    child: Padding(
                                        padding:
                                            const EdgeInsets.fromLTRB(
                                                20, 0, 0, 0),
                                        child: TextField(
                                            controller: model
                                                .kanbanGasPriceTextController,
                                            onChanged: (String amount) {
                                              model.updateTransFee();
                                            },
                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                                    decimal:
                                                        true), // numnber keyboard
                                            decoration: InputDecoration(
                                                focusedBorder: const UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: primaryColor)),
                                                enabledBorder:
                                                    const UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: grey)),
                                                hintText: '0.00000',
                                                hintStyle: headText5.copyWith(
                                                    fontWeight:
                                                        FontWeight.w300)),
                                            style: headText5.copyWith(
                                                fontWeight: FontWeight.w300))))
                              ],
                            ),
                            // Kanban Gas Limit

                            Row(
                              children: <Widget>[
                                Expanded(
                                    flex: 3,
                                    child: Text(
                                      FlutterI18n.translate(
                                          context, "kanbanGasLimit"),
                                      style: headText5.copyWith(
                                          fontWeight: FontWeight.w300),
                                    )),
                                Expanded(
                                    flex: 5,
                                    child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 0, 0, 0),
                                        child: TextField(
                                            controller: model
                                                .kanbanGasLimitTextController,
                                            onChanged: (String amount) {
                                              model.updateTransFee();
                                            },
                                            keyboardType: TextInputType
                                                .number, // numnber keyboard
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
                                                fontWeight: FontWeight.w300)))),
                              ],
                            ),
                            UIHelper.verticalSpaceSmall,
                          ],
                        )),

                    UIHelper.verticalSpaceSmall,

                    // TS wallet balance show
                    // Expanded(
                    //   child: Column(
                    //     children: [
                    //       Container(
                    //           child: Row(
                    //         mainAxisAlignment:
                    //             MainAxisAlignment.center,
                    //         children: [
                    //           Text(
                    //             'TS ${FlutterI18n.translate(context, "wallet")}',
                    //             style: Theme.of(context)
                    //                 .textTheme
                    //                 .subText2,
                    //           ),
                    //           Text(
                    //             '${FlutterI18n.translate(context, "balance")}: ',
                    //             style: Theme.of(context)
                    //                 .textTheme
                    //                 .subText2,
                    //           ),
                    //           model.isWithdrawChoice
                    //               ? SizedBox(
                    //                   width: 20,
                    //                   height: 20,
                    //                   child: IconButton(
                    //                       padding: EdgeInsets.zero,
                    //                       icon: Icon(
                    //                         Icons.info_outline,
                    //                         color: primaryColor,
                    //                         size: 16,
                    //                       ),
                    //                       onPressed: () =>
                    //                           model.showInfoDialog(
                    //                               true)),
                    //                 )
                    //               : Container()
                    //         ],
                    //       )),

                    //       // show ts wallet balance for tron chain
                    //       model.walletInfo.tickerName == 'USDT' ||
                    //               model.walletInfo.tickerName ==
                    //                   'USDTX'
                    //           ? Container(
                    //               margin:
                    //                   EdgeInsets.only(left: 5.0),
                    //               child: model.trxTsWalletBalance !=
                    //                           null &&
                    //                       model.ethChainBalance !=
                    //                           null
                    //                   ? model
                    //                           .isShowTrxTsWalletBalance
                    //                       ? Text(
                    //                           model
                    //                               .trxTsWalletBalance
                    //                               .toString(),
                    //                           maxLines: 2,
                    //                           style:headText6,
                    //                         )
                    //                       : Text(
                    //                           model.ethChainBalance
                    //                               .toString(),
                    //                           maxLines: 2,
                    //                           style:headText6,
                    //                         )
                    //                   : Container(
                    //                       child: Text(
                    //                           AppLocalizations.of(context)
                    //                               .loading)))
                    //           : Container(
                    //               margin:
                    //                   EdgeInsets.only(left: 5.0),
                    //               child: model.fabChainBalance !=
                    //                           null &&
                    //                       model.ethChainBalance !=
                    //                           null
                    //                   ? model.isShowFabChainBalance
                    //                       ? Text(
                    //                           model.fabChainBalance
                    //                               .toString(),
                    //                           maxLines: 2,
                    //                           style:headText6,
                    //                         )
                    //                       : Text(
                    //                           model.ethChainBalance
                    //                               .toString(),
                    //                           maxLines: 2,
                    //                           style:headText6,
                    //                         )
                    //                   : Container(
                    //                       child: Text(
                    //                           AppLocalizations.of(context)
                    //                               .loading))),
                    //     ],
                    //   ),
                    // ),

                    // Success/Error container
                    Container(
                        child: Visibility(
                            visible: model.message.isNotEmpty,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(model.message ?? ''),
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
                                          model.copyAndShowNotificatio(
                                              model.message);
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
                    // Confirm Button
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 25,
                      child: MaterialButton(
                        padding: const EdgeInsets.all(15),
                        color: primaryColor,
                        textColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35.0),
                        ),
                        onPressed: () {
                          model.isWithdrawChoice
                              ? model.popupToConfirmWithdrawSelection()
                              : model.checkPass();
                        },
                        child: model.isBusy
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1,
                                ))
                            : Text(FlutterI18n.translate(context, "confirm"),
                                style: Theme.of(context).textTheme.button),
                      ),
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
