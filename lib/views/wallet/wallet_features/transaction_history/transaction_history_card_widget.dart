//import 'package:auto_size_text/auto_size_text.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/models/wallet/transaction_history.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/utils/number_util.dart';
import 'package:paycool/utils/string_util.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paycool/views/wallet/wallet_features/transaction_history/transaction_history_viewmodel.dart';

class TxHisotryCardWidget extends StatelessWidget {
  final TransactionHistoryViewmodel model;
  const TxHisotryCardWidget({
    required this.model,
    Key? key,
    required this.transaction,
    required this.customFontSize,
  }) : super(key: key);

  final TransactionHistory transaction;
  final double customFontSize;

  @override
  Widget build(BuildContext context) {
    transaction.tickerName = model.updateTickers(transaction.tickerName);

    return Card(
        elevation: 4,
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            color: secondaryColor,
            child: Row(children: <Widget>[
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 4),
                        child: Padding(
                          padding: transaction.tickerName.length > 3
                              ? const EdgeInsets.only(left: 0.0)
                              : const EdgeInsets.only(left: 5.0),
                          child: transaction.tickerName.contains('(')
                              ? Column(
                                  children: [
                                    Text(transaction.tickerName.split('(')[0],
                                        style: headText6),
                                    Text(
                                        transaction.tickerName
                                            .split('(')[1]
                                            .substring(
                                                0,
                                                transaction.tickerName
                                                        .split('(')[1]
                                                        .length -
                                                    1),
                                        style: subText2),
                                  ],
                                )
                              : Text(transaction.tickerName, style: subText2),
                        ),
                      ),

                      // icon
                      transaction.tag.toUpperCase() == model.send.toUpperCase()
                          ? const Padding(
                              padding: EdgeInsets.only(left: 13.0),
                              child: Icon(
                                FontAwesomeIcons.arrowRight,
                                size: 11,
                                color: sellPrice,
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Icon(
                                Icons.arrow_downward,
                                size: 16,
                                color: transaction.tag.toUpperCase() ==
                                        model.deposit.toUpperCase()
                                    ? buyPrice
                                    : sellPrice,
                              ),
                            ),

                      if (transaction.tag.toUpperCase() ==
                          model.withdraw.toUpperCase())
                        Padding(
                          padding: const EdgeInsets.only(left: 3.0),
                          child: Text(
                            FlutterI18n.translate(context, "withdraw"),
                            style: subText2,
                            textAlign: TextAlign.center,
                          ),
                        )
                      else if (transaction.tag.toUpperCase() ==
                          model.send.toUpperCase())
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Text(
                            FlutterI18n.translate(context, "send"),
                            style: subText2,
                            textAlign: TextAlign.center,
                          ),
                        )
                      else if (transaction.tag.toUpperCase() ==
                          model.deposit.toUpperCase())
                        Padding(
                          padding: model.isChinese
                              ? const EdgeInsets.only(left: 7.0)
                              : const EdgeInsets.only(left: 3.0),
                          child: Text(
                            FlutterI18n.translate(context, "deposit"),
                            style: subText2,
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ]),
              ),
// UIHelper.horizontalSpaceSmall,
              // DATE
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      '${transaction.date.split(" ")[0].split("-")[1]}-${transaction.date.split(" ")[0].split("-")[2]}-${transaction.date.split(" ")[0].split("-")[0]}',
                      style: headText5.copyWith(fontWeight: FontWeight.w400),
                      minFontSize: 8,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Time
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        transaction.tag == model.send
                            ? transaction.date.split(" ")[1].split(".")[0]
                            : transaction.date.split(" ")[1],
                        style: subText2.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              UIHelper.horizontalSpaceSmall,
              // Quantity
              Expanded(
                flex: 2,
                child: Container(
                  alignment: Alignment.center,
                  child: AutoSizeText(
                    NumberUtil.roundDouble(transaction.quantity!,
                            decimalPlaces: model.decimalLimit)
                        .toString(),
                    textAlign: TextAlign.right,
                    style: headText5.copyWith(fontWeight: FontWeight.w400),
                    minFontSize: 8,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              UIHelper.horizontalSpaceSmall,
              // Status
              transaction.tag != model.send
                  ? Expanded(
                      flex: 1,
                      child: Container(
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                            // If deposit is success in both Ticker chain and kanabn chain then show completed
                            if (transaction.tag.toUpperCase() ==
                                    model.deposit.toUpperCase() &&
                                transaction.tickerChainTxStatus ==
                                    model.success &&
                                transaction.kanbanTxStatus == model.success)
                              Expanded(
                                child: AutoSizeText(
                                  firstCharToUppercase(FlutterI18n.translate(
                                      context, "completed")),
                                  style: TextStyle(
                                      fontSize: customFontSize,
                                      color: buyPrice),
                                  minFontSize: 8,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )

                            // If deposit is success in only Ticker chain and not in kanban chain then show sent
                            else if (transaction.tag.toUpperCase() ==
                                    model.deposit.toUpperCase() &&
                                transaction.tickerChainTxStatus ==
                                    model.success &&
                                transaction.kanbanTxStatus == model.success)
                              Text(
                                  firstCharToUppercase(
                                      FlutterI18n.translate(context, "sent")),
                                  style: TextStyle(
                                      fontSize: customFontSize,
                                      color: buyPrice))
                            // depsoit pending if ticker chain staus is pending
                            else if (transaction.tag.toUpperCase() ==
                                    model.deposit.toUpperCase() &&
                                transaction.tickerChainTxStatus ==
                                    model.pending)
                              Text(
                                  firstCharToUppercase(FlutterI18n.translate(
                                      context, "pending")),
                                  style: TextStyle(
                                      fontSize: customFontSize, color: black))
                            // depsoit pending if kanban chain staus is pending
                            else if (transaction.tag.toUpperCase() ==
                                    model.deposit.toUpperCase() &&
                                transaction.kanbanTxStatus == model.pending)
                              Text(
                                  firstCharToUppercase(FlutterI18n.translate(
                                      context, "pending")),
                                  style: TextStyle(
                                      fontSize: customFontSize, color: black))
                            else if (transaction.tag.toUpperCase() ==
                                    model.deposit.toUpperCase() &&
                                (transaction.kanbanTxStatus == model.rejected ||
                                    transaction.tickerChainTxStatus ==
                                        model.rejected ||
                                    model.rejected.contains(
                                        transaction.tickerChainTxStatus!)))
                              RichText(
                                text: TextSpan(
                                    text: FlutterI18n.translate(
                                        context, "redeposit"),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        decoration: TextDecoration.underline,
                                        color: red),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        model.navigationService.navigateTo(
                                            RedepositViewRoute,
                                            arguments: model.walletInfo);
                                      }),
                              ) // if withdraw status is success on kanban but null on ticker chain then display sent
                            else if (transaction.tag.toUpperCase() ==
                                    model.withdraw.toUpperCase() &&
                                transaction.kanbanTxStatus == model.success &&
                                transaction.tickerChainTxId == '')
                              Text(
                                  firstCharToUppercase(
                                      FlutterI18n.translate(context, "sent")),
                                  style: TextStyle(
                                      fontSize: customFontSize,
                                      color:
                                          buyPrice)) // if withdraw status is success on kanban but null on ticker chain then display sent
                            else if (transaction.tag.toUpperCase() ==
                                    model.withdraw.toUpperCase() &&
                                transaction.kanbanTxStatus == model.success &&
                                transaction.tickerChainTxStatus!
                                    .startsWith('sent'))
                              Expanded(
                                child: AutoSizeText(
                                  firstCharToUppercase(FlutterI18n.translate(
                                      context, "completed")),
                                  style: TextStyle(
                                      fontSize: customFontSize,
                                      color: buyPrice),
                                  minFontSize: 8,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                          ])))
                  : Expanded(
                      flex: 1,
                      child: Container(
                          child: Text(
                              firstCharToUppercase(
                                FlutterI18n.translate(context, "sent"),
                              ),
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: customFontSize, color: buyPrice))),
                    ),
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.more, color: black, size: 14),
                      onPressed: () {
                        debugPrint('tx histoy ${transaction.toJson()}');
                        model.showTxDetailDialog(transaction);
                      }),
                ),
              )
            ])));
  }
}
