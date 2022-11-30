import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/utils/number_util.dart';
import 'package:paycool/views/paycool_club/club_dashboard_model.dart';

import '../../service_locator.dart';
import '../../services/local_storage_service.dart';

class ClubRewardsView extends StatelessWidget {
  final ClubRewardsArgs clubRewardsArgs;
  const ClubRewardsView({Key key, this.clubRewardsArgs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var storageService = locator<LocalStorageService>();

    return Scaffold(
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
        child: clubRewardsArgs.summary.first.totalReward.first.coin == null
            ? Center(
                child: Image.asset(
                  "assets/images/img/rewards.png",
                  width: 25,
                  height: 25,
                ),
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
                            itemCount: clubRewardsArgs.summary.length,
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const Divider(
                                      height: 15,
                                    ),
                            itemBuilder: (BuildContext context, int index) {
                              String memberType() {
                                if (clubRewardsArgs.summary[index].status ==
                                    0) {
                                  return FlutterI18n.translate(
                                      context, "noPartner");
                                } else if (clubRewardsArgs
                                        .summary[index].status ==
                                    1) {
                                  return FlutterI18n.translate(
                                      context, "basicPartner");
                                } else if (clubRewardsArgs
                                        .summary[index].status ==
                                    2) {
                                  return FlutterI18n.translate(
                                      context, "beginnerPartner");
                                } else if (clubRewardsArgs
                                        .summary[index].status ==
                                    3) {
                                  return FlutterI18n.translate(
                                      context, "intermediatePartner");
                                } else if (clubRewardsArgs
                                        .summary[index].status ==
                                    4) {
                                  return FlutterI18n.translate(
                                      context, "advancedPartner");
                                } else {
                                  return FlutterI18n.translate(
                                      context, "noPartner");
                                }
                              }

                              return Container(
                                margin: const EdgeInsets.all(5.0),
                                padding: const EdgeInsets.all(10.0),
                                decoration:
                                    roundedBoxDecoration(color: secondaryColor),
                                child: ListTile(
                                  onTap: () => showRewardDistributionDialog(
                                      context, index),
                                  horizontalTitleGap: 0,
                                  leading: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 50,
                                        margin:
                                            const EdgeInsets.only(right: 10),
                                        child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              memberType(),
                                              style: headText5.copyWith(
                                                  color: primaryColor,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                      ),
                                    ],
                                  ),
                                  title: Text(
                                    storageService.language == "en"
                                        ? clubRewardsArgs
                                            .summary[index].project.en
                                        : clubRewardsArgs
                                            .summary[index].project.sc,
                                    style: headText4,
                                  ),
                                  subtitle: Container(
                                    margin: EdgeInsets.all(4),
                                    color: white,
                                    height: 70,
                                    child: ListView.builder(
                                        itemCount: clubRewardsArgs
                                            .summary[index].totalReward.length,
                                        itemBuilder: ((context, j) {
                                          var selectedPrice = clubRewardsArgs
                                                  .rewardTokenPriceMap[
                                              clubRewardsArgs.summary[index]
                                                  .totalReward[j].coin];
                                          return clubRewardsArgs.summary[index]
                                                      .totalReward[j].coin ==
                                                  null
                                              ? Container()
                                              : Row(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 4.0),
                                                      child: Text(
                                                        clubRewardsArgs
                                                            .summary[index]
                                                            .totalReward[j]
                                                            .coin,
                                                        style: headText6,
                                                      ),
                                                    ),
                                                    UIHelper
                                                        .horizontalSpaceSmall,
                                                    Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          // AMOUNT
                                                          clubRewardsArgs
                                                                  .summary[
                                                                      index]
                                                                  .totalReward[
                                                                      j]
                                                                  .coin
                                                                  .contains('-')
                                                              ? Text(
                                                                  '\$${NumberUtil.rawStringToDecimal(clubRewardsArgs.summary[index].totalReward[j].amount.toString())}',
                                                                  maxLines: 2,
                                                                  style: headText6.copyWith(
                                                                      color:
                                                                          green,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                )
                                                              : Text(
                                                                  NumberUtil.decimalLimiter(
                                                                          clubRewardsArgs
                                                                              .summary[index]
                                                                              .totalReward[j]
                                                                              .amount,
                                                                          decimalPrecision: 18)
                                                                      .toString(),
                                                                  style: headText6.copyWith(
                                                                      color:
                                                                          green,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                          // USD VALUE
                                                          clubRewardsArgs
                                                                  .summary[
                                                                      index]
                                                                  .totalReward[
                                                                      j]
                                                                  .coin
                                                                  .contains('-')
                                                              ? Text(
                                                                  '\$${NumberUtil.decimalLimiter(NumberUtil.rawStringToDecimal(clubRewardsArgs.summary[index].totalReward[j].amount.toString()) * selectedPrice)}',
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: headText6.copyWith(
                                                                      color:
                                                                          green,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                )
                                                              : Text(
                                                                  '\$${NumberUtil.decimalLimiter(clubRewardsArgs.summary[index].totalReward[j].amount * selectedPrice)}',
                                                                  maxLines: 2,
                                                                  style: headText6.copyWith(
                                                                      color:
                                                                          green,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                        ])
                                                  ],
                                                );
                                        })),
                                  ),
                                  trailing: clubRewardsArgs.summary[index]
                                              .rewardDistribution ==
                                          null
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [])
                                      : Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            UIHelper.horizontalSpaceSmall,
                                            Text(
                                              FlutterI18n.translate(
                                                  context, "details"),
                                              style: headText5.copyWith(
                                                  color: primaryColor,
                                                  decoration:
                                                      TextDecoration.underline),
                                            )
                                          ],
                                        ),
                                ),
                              );
                            }))
                  ],
                ),
              ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: model.paginationModel.pages.isEmpty
      //     ? Container()
      //     : PaginationWidget(
      //         pageCallback: model.getPaginationRewards,
      //         paginationModel: model.paginationModel,
      //       ),
    );
  }

  showRewardDistributionDialog(BuildContext context, index) {
    List<String> rewardTypes = [
      FlutterI18n.translate(context, "gap"),
      FlutterI18n.translate(context, "marketing"),
      FlutterI18n.translate(context, "leadership"),
      FlutterI18n.translate(context, "global"),
      FlutterI18n.translate(context, "merchant"),
      FlutterI18n.translate(context, "merchantReferral"),
      FlutterI18n.translate(context, "merchantNode"),
    ];
    showModalBottomSheet(
        //isScrollControlled: true,
        enableDrag: true,
        backgroundColor: Colors.transparent,
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 150),
        context: context,
        builder: (BuildContext context) {
          rewardsCoinWithAmount(String title, List<SummaryReward> rewards) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    title,
                    style: headText4.copyWith(color: black),
                  ),
                ),
                rewards.isEmpty
                    ? Container()
                    : Expanded(
                        flex: 4,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var m = 0; m < rewards.length; m++)
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      rewards[m].coin ?? '',
                                      textAlign: TextAlign.right,
                                      style: headText5,
                                    ),
                                    UIHelper.horizontalSpaceSmall,
                                    Expanded(
                                      child: Text(
                                        rewards[m].amount.toString(),
                                        textAlign: TextAlign.right,
                                        style: headText5,
                                        maxLines: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            UIHelper.verticalSpaceSmall,
                          ],
                        ),
                      ),
              ],
            );
          }

          return Container(
              decoration:
                  roundedTopLeftRightBoxDecoration(color: secondaryColor),
              child: Container(
                margin: const EdgeInsets.all(15),
                child: ListView(children: [
                  UIHelper.verticalSpaceMedium,
                  clubRewardsArgs.summary[index].rewardDistribution.gap == null
                      ? rewardsCoinWithAmount(
                          FlutterI18n.translate(context, "gap"), [])
                      : rewardsCoinWithAmount(
                          FlutterI18n.translate(context, "gap"),
                          clubRewardsArgs
                              .summary[index].rewardDistribution.gap),

                  // Leadership
                  UIHelper.verticalSpaceSmall,
                  UIHelper.divider,
                  UIHelper.verticalSpaceSmall,
                  clubRewardsArgs
                              .summary[index].rewardDistribution.leadership ==
                          null
                      ? rewardsCoinWithAmount(
                          FlutterI18n.translate(context, "leadership"), [])
                      : rewardsCoinWithAmount(
                          FlutterI18n.translate(context, "leadership"),
                          clubRewardsArgs
                              .summary[index].rewardDistribution.leadership),

                  // Marketing
                  UIHelper.verticalSpaceSmall,
                  UIHelper.divider,
                  UIHelper.verticalSpaceSmall,
                  clubRewardsArgs.summary[index].rewardDistribution.marketing ==
                          null
                      ? rewardsCoinWithAmount(
                          FlutterI18n.translate(context, "marketing"), [])
                      : rewardsCoinWithAmount(
                          FlutterI18n.translate(context, "marketing"),
                          clubRewardsArgs
                              .summary[index].rewardDistribution.marketing),
                  // Global
                  UIHelper.verticalSpaceSmall,
                  UIHelper.divider,
                  UIHelper.verticalSpaceSmall,
                  clubRewardsArgs.summary[index].rewardDistribution.global ==
                          null
                      ? rewardsCoinWithAmount(
                          FlutterI18n.translate(context, "global"), [])
                      : rewardsCoinWithAmount(
                          FlutterI18n.translate(context, "global"),
                          clubRewardsArgs
                              .summary[index].rewardDistribution.global),

                  // Merchant
                  UIHelper.verticalSpaceSmall,
                  UIHelper.divider,
                  UIHelper.verticalSpaceSmall,
                  clubRewardsArgs.summary[index].rewardDistribution.merchant ==
                          null
                      ? rewardsCoinWithAmount(
                          FlutterI18n.translate(context, "merchant"), [])
                      : rewardsCoinWithAmount(
                          FlutterI18n.translate(context, "merchant"),
                          clubRewardsArgs
                              .summary[index].rewardDistribution.merchant),

                  // Merchant Referral
                  UIHelper.verticalSpaceSmall,
                  UIHelper.divider,
                  UIHelper.verticalSpaceSmall,
                  clubRewardsArgs.summary[index].rewardDistribution
                              .merchantReferral ==
                          null
                      ? rewardsCoinWithAmount(
                          FlutterI18n.translate(context, "merchantReferral"),
                          [])
                      : rewardsCoinWithAmount(
                          FlutterI18n.translate(context, "merchantReferral"),
                          clubRewardsArgs.summary[index].rewardDistribution
                              .merchantReferral),

                  // Merchant Node
                  UIHelper.verticalSpaceSmall,
                  UIHelper.divider,
                  UIHelper.verticalSpaceSmall,
                  clubRewardsArgs
                              .summary[index].rewardDistribution.merchantNode ==
                          null
                      ? rewardsCoinWithAmount(
                          FlutterI18n.translate(context, "merchantNode"), [])
                      : rewardsCoinWithAmount(
                          FlutterI18n.translate(context, "merchantNode"),
                          clubRewardsArgs
                              .summary[index].rewardDistribution.merchantNode),
                ]),
              ));
        });
  }
}
