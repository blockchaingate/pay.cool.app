import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/utils/number_util.dart';
import 'package:paycool/utils/string_util.dart';
import 'package:paycool/views/paycool/transaction_history/paycool_transaction_history_viewmodel.dart';
import 'package:stacked/stacked.dart';

class PayCoolTransactionHistoryView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PayCoolTransactionHistoryViewModel>.reactive(
      onModelReady: (model) async {
        model.context = context;
      },
      viewModelBuilder: () => PayCoolTransactionHistoryViewModel(),
      builder: (BuildContext context, PayCoolTransactionHistoryViewModel model,
              child) =>
          Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          centerTitle: true,
          title: Text(
            FlutterI18n.translate(context, "transactionHistory"),
            style: headText4.copyWith(fontWeight: FontWeight.w400),
          ),
        ),
        body: model.isBusy && !model.isProcessingAction
            ? model.sharedService.loadingIndicator()
            : model.transactions.isEmpty
                ? const Center(
                    child: Icon(Icons.history_toggle_off_rounded, color: white),
                  )
                : Container(
                    margin: const EdgeInsets.only(
                      top: 5,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        UIHelper.verticalSpaceSmall,
                        Theme(
                          data: ThemeData(
                              textTheme: const TextTheme(
                                  bodyText1: TextStyle(color: white))),
                          child: Row(
                            children: [
                              UIHelper.horizontalSpaceMedium,
                              Expanded(
                                flex: 2,
                                child: Text(
                                    FlutterI18n.translate(context, "date")),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                    FlutterI18n.translate(context, "coin")),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                    FlutterI18n.translate(context, "amount")),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                    FlutterI18n.translate(context, "status")),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: Theme(
                            data: ThemeData(
                                textTheme: const TextTheme(
                                    bodyText2: TextStyle(color: white))),
                            child: ListView.builder(
                                itemCount: model.transactions.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () => model.showRefundButton(
                                        model.transactions[index].id),
                                    child: Card(
                                      color: walletCardColor,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          UIHelper.verticalSpaceSmall,
                                          Row(
                                            children: [
                                              UIHelper.horizontalSpaceSmall,
                                              Expanded(
                                                flex: 2,
                                                child: Text(formatStringDate(
                                                    model.transactions[index]
                                                        .dateCreated)),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text((model
                                                    .transactions[index]
                                                    .tickerName)),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(NumberUtil()
                                                    .truncateDoubleWithoutRouding(
                                                        model
                                                            .transactions[index]
                                                            .totalTransactionAmount,
                                                        precision: 6)
                                                    .toString()),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(model
                                                            .transactions[index]
                                                            .status ==
                                                        0
                                                    ? 'Refunded'
                                                    : model.transactions[index]
                                                                .status ==
                                                            1
                                                        ? 'Valid'
                                                        : 'Requested Refund'),
                                              )
                                            ],
                                          ),
                                          UIHelper.verticalSpaceSmall,
                                          // show refund button
                                          //  model.isShowRefundButton &&
                                          model.selectedTxOrderId ==
                                                  model.transactions[index].id
                                              ? Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    if (model
                                                            .transactions[index]
                                                            .status ==
                                                        2)
                                                      ElevatedButton(
                                                          style: ButtonStyle(
                                                              backgroundColor:
                                                                  MaterialStateProperty
                                                                      .all(
                                                                          sellPrice)),
                                                          onPressed: () {
                                                            if (!model
                                                                .isProcessingAction) {
                                                              model.txAction(
                                                                  model
                                                                      .transactions[
                                                                          index]
                                                                      .id,
                                                                  model
                                                                      .transactions[
                                                                          index]
                                                                      .address,
                                                                  isCancel:
                                                                      true);
                                                            }
                                                            debugPrint(model
                                                                .isProcessingAction
                                                                .toString());
                                                          },
                                                          child: Text(model
                                                                      .isBusy &&
                                                                  model.selectedTxOrderId ==
                                                                      model
                                                                          .transactions[
                                                                              index]
                                                                          .id &&
                                                                  model
                                                                      .isProcessingAction
                                                              ? 'Processing'
                                                              : 'Cancel refund request')),
                                                    UIHelper
                                                        .horizontalSpaceSmall,
                                                    if (model
                                                            .transactions[index]
                                                            .status ==
                                                        1)
                                                      ElevatedButton(
                                                          style: ButtonStyle(
                                                              backgroundColor:
                                                                  MaterialStateProperty
                                                                      .all(
                                                                          yellow)),
                                                          onPressed: () {
                                                            if (!model
                                                                .isProcessingAction) {
                                                              model.txAction(
                                                                  model
                                                                      .transactions[
                                                                          index]
                                                                      .id,
                                                                  model
                                                                      .transactions[
                                                                          index]
                                                                      .address);
                                                            }
                                                            debugPrint(model
                                                                .isProcessingAction
                                                                .toString());
                                                          },
                                                          child: Text(
                                                            model.isBusy &&
                                                                    model.selectedTxOrderId ==
                                                                        model
                                                                            .transactions[
                                                                                index]
                                                                            .id &&
                                                                    model
                                                                        .isProcessingAction
                                                                ? 'Processing'
                                                                : 'Request Refund',
                                                            style: const TextStyle(
                                                                color:
                                                                    secondaryColor),
                                                          )),
                                                  ],
                                                )
                                              : Container(),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        )
                      ],
                    ),
                  ),
      ),
    );
  }
}
