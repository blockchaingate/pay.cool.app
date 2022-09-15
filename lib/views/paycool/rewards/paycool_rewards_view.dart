import 'package:exchangily_core/exchangily_core.dart';
import 'package:exchangily_ui/exchangily_ui.dart';
import 'package:flutter/material.dart';
import 'package:pagination_widget/pagination_widget.dart';
import 'package:paycool/constants/paycool_styles.dart';
import 'package:paycool/views/paycool/rewards/paycool_rewards_viewmodel.dart';

class PayCoolRewardsView extends StatelessWidget {
  const PayCoolRewardsView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PayCoolRewardsViewModel>.reactive(
      viewModelBuilder: () => PayCoolRewardsViewModel(),
      onModelReady: (model) async {
        model.context = context;
        model.init();
      },
      builder: (BuildContext context, PayCoolRewardsViewModel model, child) =>
          Scaffold(
        appBar: AppBar(
          title: Text(
            FlutterI18n.translate(context, "myRewardDetails"),
            style: headText4.copyWith(fontWeight: FontWeight.w500),
          ),
          centerTitle: true,
          automaticallyImplyLeading: true,
        ),
        body: model.isBusy
            ? model.sharedService.loadingIndicator()
            : model.rewards.isEmpty
                ? const Center(
                    child: Icon(Icons.money_off_csred_outlined, color: white),
                  )
                : Container(
                    // color: Colors.cyan,
                    margin: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        UIHelper.verticalSpaceSmall,
                        Expanded(
                            child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: model.rewards.length,
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        const Divider(
                                          height: 15,
                                        ),
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                    color: PaycoolColors.secondaryColor,
                                    child: Column(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              10,
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: PaycoolColors.primaryColor
                                                .withOpacity(0.3),
                                            // borderRadius:
                                            //     BorderRadius.only(
                                            //         topLeft: Radius
                                            //             .circular(20),
                                            //         topRight:
                                            //             Radius.circular(
                                            //                 20))
                                          ),
                                          child: Text(
                                            model.rewards[index]
                                                .releaseDateTimeString(),
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              10,
                                          // margin: EdgeInsets.only(top: 20),
                                          color: PaycoolColors.walletCardColor,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    top: 20),
                                                height: 50,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    for (var i = 0;
                                                        i <
                                                            model
                                                                .rewards[index]
                                                                .coinType
                                                                .length;
                                                        i++)
                                                      Column(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(3.0),
                                                            // reward amount currency coin
                                                            child: Text(
                                                              Constants
                                                                  .coinTypeWithTicker[model
                                                                      .rewards[
                                                                          index]
                                                                      .coinType[i]]
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                  fontSize: 14,
                                                                  color: white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                          // rewards amount
                                                          Text(
                                                            NumberUtil.rawStringToDecimal(
                                                                    model
                                                                        .rewards[
                                                                            index]
                                                                        .amount[i],
                                                                    decimalPrecision: 6)
                                                                .toString(),
                                                            style: const TextStyle(
                                                                fontSize: 14,
                                                                color: PaycoolColors
                                                                    .primaryColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )
                                                        ],
                                                      )
                                                  ],
                                                ),
                                              ),
                                              //
                                              Text(
                                                FlutterI18n.translate(
                                                    context, "TransactionId"),
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: Text(
                                                  model.rewards[index].txids[0],
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: white,
                                                  ),
                                                ),
                                              ),
                                              TextButton(
                                                // padding:
                                                //     EdgeInsets.all(0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    model.isShowAllTxIds &&
                                                            model.selectedTxId ==
                                                                model
                                                                    .rewards[
                                                                        index]
                                                                    .txids[0]
                                                        ? const Icon(
                                                            Icons
                                                                .keyboard_arrow_up_outlined,
                                                            color: white)
                                                        : const Icon(
                                                            Icons.expand_more,
                                                            color: white,
                                                          ),
                                                    Text(
                                                      model.isShowAllTxIds &&
                                                              model.selectedTxId ==
                                                                  model
                                                                      .rewards[
                                                                          index]
                                                                      .txids[0]
                                                          ? 'Hide Txids'
                                                          : 'Show all Txid\'s',
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.blueAccent,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                                onPressed: () =>
                                                    model.showAllTxIds(model
                                                        .rewards[index]
                                                        .txids[0]),
                                              ),
                                              if (model.isShowAllTxIds &&
                                                  model.selectedTxId ==
                                                      model.rewards[index]
                                                          .txids[0])
                                                for (var j = 0;
                                                    j <
                                                        model.rewards[index]
                                                            .txids.length;
                                                    j++)
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        children: [
                                                          const Icon(
                                                              Icons
                                                                  .arrow_forward_outlined,
                                                              size: 14,
                                                              color: PaycoolColors
                                                                  .primaryColor),
                                                          Expanded(
                                                            child: Text(
                                                              model
                                                                  .rewards[
                                                                      index]
                                                                  .txids[j],
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 10,
                                                                color: grey,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      )),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }))
                      ],
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
