import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:pagination_widget/pagination_widget.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/utils/number_util.dart';
import 'package:paycool/utils/string_util.dart';
import 'package:paycool/widgets/shared/copy_clipboard_text_widget.dart';
import 'package:stacked/stacked.dart';

import 'package:paycool/views/paycool/rewards/paycool_rewards_viewmodel.dart';

class PayCoolRewardsView extends StatelessWidget {
  const PayCoolRewardsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PayCoolRewardsViewModel>.reactive(
      viewModelBuilder: () => PayCoolRewardsViewModel(),
      onViewModelReady: (model) async {
        model.context = context;
      },
      builder: (BuildContext context, PayCoolRewardsViewModel model, child) =>
          Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          backgroundColor: Colors.transparent,
          title: Text(
            FlutterI18n.translate(context, "rewards"),
            style: headText4.copyWith(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          automaticallyImplyLeading: true,
        ),
        body: Container(
          decoration: BoxDecoration(image: blurBackgroundImage()),
          child: model.isBusy
              ? model.sharedService.loadingIndicator()
              : model.paymentRewards.isEmpty
                  ? const Center(
                      child: Icon(Icons.money_off_csred_outlined, color: white),
                    )
                  : Container(
                      margin: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          UIHelper.verticalSpaceSmall,
                          Expanded(
                              child: ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: model.paymentRewards.length,
                                  separatorBuilder:
                                      (BuildContext context, int index) =>
                                          const Divider(
                                            height: 15,
                                          ),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                      margin: const EdgeInsets.all(5.0),
                                      padding: const EdgeInsets.all(10.0),
                                      decoration: roundedBoxDecoration(
                                          color: secondaryColor),
                                      child: ListTile(
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
                                                          .paymentRewards[index]
                                                          .dateCreated
                                                          .toString())
                                                      .split(' ')[0],
                                                  style: headText5.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  formatStringDateV2(model
                                                          .paymentRewards[index]
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
                                                '${model.paymentRewards[index].rewardCoin} ',
                                                style: headText5,
                                              ),
                                              Text(
                                                NumberUtil.decimalLimiter(
                                                        model
                                                            .paymentRewards[
                                                                index]
                                                            .rewardAmount!,
                                                        decimalPlaces: 6)
                                                    .toString(),
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: primaryColor,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            ],
                                          ),
                                          subtitle: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    FlutterI18n.translate(
                                                        context,
                                                        "transactionId"),
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: black,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5.0),
                                                      child: Text(
                                                        model
                                                            .paymentRewards[
                                                                index]
                                                            .txid
                                                            .toString(),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: black),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          trailing: CopyClipboardTextWidget(
                                              model.paymentRewards[index].txid
                                                  .toString())),
                                    );
                                  }))
                        ],
                      ),
                    ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: model.paginationModel.totalPages == 0
            ? Container()
            : PaginationWidget(
                pageCallback: model.getPaginationData,
                paginationModel: model.paginationModel,
              ),
      ),
    );
  }
}
