import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:pagination_widget/pagination_widget.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/utils/number_util.dart';
import 'package:paycool/utils/string_util.dart';
import 'package:paycool/views/paycool/transaction_history/paycool_transaction_history_viewmodel.dart';
import 'package:paycool/widgets/shared/copy_clipboard_text_widget.dart';
import 'package:stacked/stacked.dart';

class PayCoolTransactionHistoryView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PayCoolTransactionHistoryViewModel>.reactive(
      onViewModelReady: (model) async {
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
                      child: ListView.builder(
                          itemCount: model.transactions.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onDoubleTap: () => model.showRefundButton(
                                  model.transactions[index].id.toString()),
                              child: Container(
                                margin: const EdgeInsets.all(5.0),
                                padding: const EdgeInsets.all(10.0),
                                decoration:
                                    roundedBoxDecoration(color: secondaryColor),
                                child: Stack(children: [
                                  ListTile(
                                      leading: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              formatStringDateV2(model
                                                      .transactions[index]
                                                      .dateCreated
                                                      .toString())
                                                  .split(' ')[0],
                                              style: headText5.copyWith(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              formatStringDateV2(model
                                                      .transactions[index]
                                                      .dateCreated
                                                      .toString())
                                                  .split(' ')[1],
                                              style: headText5,
                                            ),
                                          ],
                                        ),
                                      ),
                                      title: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '${model.transactions[index].tickerName} ',
                                            style: headText5,
                                          ),
                                          Text(
                                            NumberUtil.decimalLimiter(
                                                    model.transactions[index]
                                                        .totalTransactionAmount!,
                                                    decimalPlaces: 6)
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
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  FlutterI18n.translate(
                                                      context, "orderId"),
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 5.0),
                                                    child: Text(
                                                      StringUtils.showPartialAddress(
                                                              address: model
                                                                  .transactions[
                                                                      index]
                                                                  .id)
                                                          .toString(),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: black,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // refund button
                                            // model.isShowRefundButton &&
                                            //         (model
                                            //                 .transactions[
                                            //                     index]
                                            //                 .id ==
                                            //             model
                                            //                 .selectedTxOrderId)
                                            //     ?

                                            // : Container()
                                          ],
                                        ),
                                      ),
                                      trailing: CopyClipboardTextWidget(model
                                          .transactions[index].id
                                          .toString())),
                                  model.isShowRefundButton &&
                                          (model.transactions[index].id ==
                                              model.selectedTxOrderId)
                                      ? Positioned(
                                          right: Platform.isIOS ? 5 : 10,
                                          bottom: 20,
                                          child: AnimatedContainer(
                                            curve:
                                                Curves.fastLinearToSlowEaseIn,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                5,
                                            height: model.isShowRefundButton &&
                                                    (model.transactions[index]
                                                            .id ==
                                                        model.selectedTxOrderId)
                                                ? 50.0
                                                : 0.0,
                                            duration: const Duration(
                                                milliseconds: 500),
                                            child: model.transactions[index]
                                                    .refunds!.isNotEmpty
                                                ? Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 10.0),
                                                    alignment: Alignment.center,
                                                    decoration:
                                                        roundedBoxDecoration(),
                                                    child: customText(
                                                        textAlign:
                                                            TextAlign.center,
                                                        text: model
                                                                    .transactions[
                                                                        index]
                                                                    .refunds!
                                                                    .first
                                                                    .txid !=
                                                                null
                                                            ? FlutterI18n
                                                                .translate(
                                                                    context,
                                                                    "Refunded")
                                                            : FlutterI18n.translate(
                                                                context,
                                                                "Refund Requested"),
                                                        color: secondaryColor,
                                                        isBold: true),
                                                  )
                                                : Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      top: 15.0,
                                                    ),
                                                    child: ElevatedButton(
                                                        style:
                                                            generalButtonStyle(
                                                                primaryColor),
                                                        onPressed: () =>
                                                            model.refund(
                                                                model
                                                                    .transactions[
                                                                        index]
                                                                    .id
                                                                    .toString(),
                                                                model
                                                                    .transactions[
                                                                        index]
                                                                    .address
                                                                    .toString()),
                                                        child: Text(FlutterI18n
                                                            .translate(context,
                                                                "Refund"))),
                                                  ),
                                          ),
                                        )
                                      : Container()
                                ]),
                              ),
                            );
                          }),
                    ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: model.paginationModel.pages.isEmpty
            ? Container()
            : PaginationWidget(
                pageCallback: model.getPaginationRewards,
                paginationModel: model.paginationModel,
              ),
      ),
    );
  }
}
