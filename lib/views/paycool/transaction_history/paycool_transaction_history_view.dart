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
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: true,
          centerTitle: true,
          title: Text(
            FlutterI18n.translate(context, "transactionHistory"),
            style: headText3.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(image: blurBackgroundImage()),
          child: model.isBusy && !model.isProcessingAction
              ? model.sharedService.loadingIndicator()
              : model.transactions.isEmpty
                  ? const Center(
                      child:
                          Icon(Icons.history_toggle_off_rounded, color: white),
                    )
                  : Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          UIHelper.verticalSpaceSmall,
                          // Container(
                          //   padding: const EdgeInsets.symmetric(
                          //       horizontal: 2.0, vertical: 10),
                          //   decoration: roundedTopLeftRightBoxDecoration(
                          //       color: secondaryColor),
                          //   child: Row(
                          //     mainAxisSize: MainAxisSize.min,
                          //     children: [
                          //       UIHelper.horizontalSpaceMedium,
                          //       Expanded(
                          //         flex: 2,
                          //         child: Text(
                          //             FlutterI18n.translate(context, "date")),
                          //       ),
                          //       Expanded(
                          //         flex: 2,
                          //         child: Text(
                          //             FlutterI18n.translate(context, "coin")),
                          //       ),
                          //       Expanded(
                          //         flex: 2,
                          //         child: Text(
                          //             FlutterI18n.translate(context, "amount")),
                          //       ),
                          //       Expanded(
                          //         flex: 2,
                          //         child: Text(
                          //             FlutterI18n.translate(context, "status")),
                          //       )
                          //     ],
                          //   ),
                          // ),
                          Expanded(
                            child: ListView.builder(
                                itemCount: model.transactions.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () => model.showRefundButton(
                                        model.transactions[index].id),
                                    child: Container(
                                      margin: const EdgeInsets.all(5.0),
                                      padding: const EdgeInsets.all(10.0),
                                      decoration: roundedBoxDecoration(
                                          color: secondaryColor),
                                      child: ListTile(
                                        title: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              model.transactions[index]
                                                      .tickerName +
                                                  ' ',
                                              style: headText5,
                                            ),
                                            Text(
                                              NumberUtil.decimalLimiter(
                                                      model.transactions[index]
                                                          .totalTransactionAmount,
                                                      decimalPrecision: 6)
                                                  .toString(),
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: primaryColor,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                FlutterI18n.translate(
                                                    context, "txId"),
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5.0),
                                                  child: Text(
                                                    model.transactions[index]
                                                        .txid,
                                                    maxLines: 2,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        trailing: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              formatStringDateV2(model
                                                      .transactions[index]
                                                      .dateCreated)
                                                  .split(' ')[0],
                                              style: headText4,
                                            ),
                                            Text(
                                              formatStringDateV2(model
                                                      .transactions[index]
                                                      .dateCreated)
                                                  .split(' ')[1],
                                              style: headText5,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          )
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}
