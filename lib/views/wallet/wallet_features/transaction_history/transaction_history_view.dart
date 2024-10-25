import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:pagination_widget/pagination_widget.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/models/wallet/wallet.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/wallet/wallet_features/transaction_history/transaction_history_card_widget.dart';
import 'package:paycool/views/wallet/wallet_features/transaction_history/transaction_history_viewmodel.dart';

import 'package:stacked/stacked.dart';

class TransactionHistoryView extends StatelessWidget {
  final WalletInfo walletInfo;
  const TransactionHistoryView({Key? key, required this.walletInfo})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double customFontSize = 12;
    return ViewModelBuilder<TransactionHistoryViewmodel>.reactive(
        viewModelBuilder: () =>
            TransactionHistoryViewmodel(tickerName: walletInfo.tickerName),
        onViewModelReady: (model) async {
          model.context = context;
          model.walletInfo = walletInfo;
        },
        builder: (context, model, child) => WillPopScope(
              onWillPop: () async {
                debugPrint('isDialogUp ${model.isDialogUp}');
                if (model.isDialogUp) {
                  Navigator.of(context, rootNavigator: true).pop();
                  model.isDialogUp = false;
                  debugPrint('isDialogUp in if ${model.isDialogUp}');
                } else {
                  Navigator.of(context).pop();
                }

                return Future.value(false);
              },
              child: Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: black,
                      ),
                      onPressed: () => Navigator.of(context).pop()),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      icon: const Icon(
                        Icons.refresh,
                        color: primaryColor,
                      ),
                      onPressed: () => model.reloadTransactions(),
                    )
                  ],
                  title: Text(
                      FlutterI18n.translate(context, "transactionHistory"),
                      style: headText3.copyWith(color: black)),
                  backgroundColor: secondaryColor,
                ),
                body: !model.dataReady || model.isBusy
                    ? SizedBox(
                        width: double.infinity,
                        height: 300,
                        child: model.sharedService
                            .loadingIndicator(isCustomWidthHeight: true))
                    : model.transactionsToDisplay.isEmpty
                        ? Container(
                            margin: const EdgeInsets.only(top: 20),
                            child: const Center(
                                child: Icon(Icons.insert_drive_file,
                                    color: white)))
                        : Container(
                            padding: const EdgeInsets.all(4.0),
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: Column(
                              children: <Widget>[
                                //  IconButton(icon:Icon(Icons.ac_unit,color:colors.white),onPressed: ()=> model.test(),),

                                Row(
                                  children: [
                                    UIHelper.horizontalSpaceSmall,
                                    Text(
                                        FlutterI18n.translate(
                                            context, "action"),
                                        style: subText2),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                          FlutterI18n.translate(
                                              context, "date"),
                                          textAlign: TextAlign.center,
                                          style: subText2),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                          FlutterI18n.translate(
                                              context, "quantity"),
                                          textAlign: TextAlign.center,
                                          style: subText2),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                          FlutterI18n.translate(
                                              context, "status"),
                                          textAlign: TextAlign.center,
                                          style: subText2),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                          FlutterI18n.translate(
                                              context, "details"),
                                          textAlign: TextAlign.center,
                                          style: subText2),
                                    ),
                                  ],
                                ),
                                model.isBusy
                                    ? const CircularProgressIndicator()
                                    : Expanded(
                                        child: ListView.builder(
                                            scrollDirection: Axis.vertical,
                                            shrinkWrap: true,
                                            itemCount: model
                                                .transactionsToDisplay.length,
                                            itemBuilder: (context, index) {
                                              return TxHisotryCardWidget(
                                                  customFontSize:
                                                      customFontSize,
                                                  transaction: model
                                                          .transactionsToDisplay[
                                                      index],
                                                  model: model);
                                            }),
                                      ),
                              ],
                            )),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                floatingActionButton: model.paginationModel.pages.isEmpty
                    ? Container()
                    : PaginationWidget(
                        pageCallback: model.getPaginationTransactions,
                        paginationModel: model.paginationModel,
                      ),
              ),
            ));
  }
}
