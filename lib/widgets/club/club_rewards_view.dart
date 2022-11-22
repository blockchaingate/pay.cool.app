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
  final List<Summary> rewardsSummary;
  const ClubRewardsView({Key key, this.rewardsSummary}) : super(key: key);

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
        child: rewardsSummary.first.totalReward.first.coin == null
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
                            itemCount: rewardsSummary.length,
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const Divider(
                                      height: 15,
                                    ),
                            itemBuilder: (BuildContext context, int index) {
                              String memberType() {
                                if (rewardsSummary[index].status == 0) {
                                  return FlutterI18n.translate(
                                      context, "basicPartner");
                                } else if (rewardsSummary[index].status == 1) {
                                  return FlutterI18n.translate(
                                      context, "juniorPartner");
                                } else if (rewardsSummary[index].status == 2) {
                                  return FlutterI18n.translate(
                                      context, "seniorPartner");
                                } else if (rewardsSummary[index].status == 3) {
                                  return FlutterI18n.translate(
                                      context, "executivePartner");
                                } else {
                                  return FlutterI18n.translate(
                                      context, "notJoinedProject");
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
                                        ? rewardsSummary[index].project.en
                                        : rewardsSummary[index].project.sc,
                                    style: headText4,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      for (var j = 0;
                                          j <
                                              rewardsSummary[index]
                                                  .totalReward
                                                  .length;
                                          j++)
                                        rewardsSummary[index]
                                                    .totalReward[j]
                                                    .coin ==
                                                null
                                            ? Container()
                                            : Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4.0),
                                                child: Text(
                                                    rewardsSummary[index]
                                                            .totalReward[j]
                                                            .coin +
                                                        ' ' +
                                                        NumberUtil.decimalLimiter(
                                                                rewardsSummary[
                                                                        index]
                                                                    .totalReward[
                                                                        j]
                                                                    .amount,
                                                                decimalPrecision:
                                                                    18)
                                                            .toString(),
                                                    style: headText5),
                                              ),
                                    ],
                                  ),
                                  // trailing:

                                  //     Row(
                                  //   mainAxisSize: MainAxisSize.min,
                                  //   children: [
                                  //     UIHelper.horizontalSpaceSmall,
                                  //     Text(
                                  //       FlutterI18n.translate(
                                  //           context, "details"),
                                  //       style: headText5.copyWith(
                                  //           color: primaryColor,
                                  //           decoration:
                                  //               TextDecoration.underline),
                                  //     )
                                  //   ],
                                  // ),
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
                UIHelper.horizontalSpaceMedium,
                rewards.isEmpty
                    ? Container()
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var m = 0; m < rewards.length; m++)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  rewards[m].coin,
                                  textAlign: TextAlign.right,
                                  style: headText5,
                                ),
                                Text(
                                  rewards[m].amount.toString(),
                                  textAlign: TextAlign.right,
                                  style: headText5,
                                ),
                              ],
                            ),
                        ],
                      ),
              ],
            );
          }

          return Container(
              decoration:
                  roundedTopLeftRightBoxDecoration(color: secondaryColor),
              child: Container(
                margin: const EdgeInsets.all(15),
                child: Column(children: [
                  UIHelper.verticalSpaceMedium,
                  Expanded(
                    child: ListView.separated(
                        shrinkWrap: true,
                        separatorBuilder: (context, _) => UIHelper.divider,
                        itemCount: 7,
                        itemBuilder: (BuildContext context, int j) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                rewardsSummary[index].rewardDistribution.gap ==
                                        null
                                    ? Container(
                                        child: rewardsCoinWithAmount(
                                            FlutterI18n.translate(
                                                context, "gap"),
                                            []),
                                      )
                                    : rewardsCoinWithAmount(
                                        FlutterI18n.translate(context, "gap"),
                                        rewardsSummary[index]
                                            .rewardDistribution
                                            .gap),
                                // rewardsSummary[index]
                                //             .rewardDistribution
                                //             .leadership ==
                                //         null
                                //     ? Container()
                                //     : Expanded(
                                //         flex: 5,
                                //         child: rewardsCoinWithAmount(
                                //             rewardsSummary[index]
                                //                 .rewardDistribution
                                //                 .leadership),
                                //       )
                              ],
                            ),
                          );
                        }),
                  ),
                ]),
              ));
        });
  }
}
