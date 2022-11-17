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
                              return Container(
                                margin: const EdgeInsets.all(5.0),
                                padding: const EdgeInsets.all(10.0),
                                decoration:
                                    roundedBoxDecoration(color: secondaryColor),
                                child: ListTile(
                                  onTap: () => showRewardDistributionDialog(
                                      context, index),
                                  horizontalTitleGap: 0,
                                  leading: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: const Icon(
                                          Icons.monetization_on_outlined,
                                          color: black,
                                          size: 18,
                                        ),
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
                                        Text(
                                            rewardsSummary[index]
                                                    .totalReward[j]
                                                    .coin +
                                                ' ' +
                                                NumberUtil.decimalLimiter(
                                                        rewardsSummary[index]
                                                            .totalReward[j]
                                                            .amount,
                                                        decimalPrecision: 18)
                                                    .toString(),
                                            style: headText5),
                                    ],
                                  ),
                                  trailing: rewardsSummary[index]
                                              .rewardDistribution
                                              .gap ==
                                          null
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [])
                                      : Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            UIHelper.horizontalSpaceSmall,
                                            Text(
                                              'Rewards distribution details',
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
          return Container(
              decoration:
                  roundedTopLeftRightBoxDecoration(color: secondaryColor),
              child: Container(
                margin: EdgeInsets.all(15),
                child: Column(children: [
                  UIHelper.verticalSpaceMedium,
                  Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Text(
                            'Type',
                            style: headText3.copyWith(color: primaryColor),
                          )),
                      Expanded(
                          flex: 2,
                          child: Text(
                            'FAB',
                            style: headText3.copyWith(color: primaryColor),
                            textAlign: TextAlign.right,
                          )),
                      Expanded(
                          flex: 2,
                          child: Text(
                            'FET',
                            style: headText3.copyWith(color: primaryColor),
                            textAlign: TextAlign.right,
                          )),
                    ],
                  ),
                  UIHelper.verticalSpaceSmall,
                  UIHelper.divider,
                  UIHelper.verticalSpaceSmall,
                  Expanded(
                    child: ListView.separated(
                        shrinkWrap: true,
                        separatorBuilder: (context, _) => UIHelper.divider,
                        itemCount: 7,
                        itemBuilder: (BuildContext context, int j) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    rewardTypes[j],
                                    style: headText4.copyWith(color: black),
                                  ),
                                ),
                                for (var m = 0;
                                    m <
                                        rewardsSummary[index]
                                            .rewardDistribution
                                            .gap
                                            .length;
                                    m++)
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      rewardsSummary[index]
                                          .rewardDistribution
                                          .gap[m]
                                          .amount
                                          .toString(),
                                      textAlign: TextAlign.right,
                                      style: headText5,
                                    ),
                                  ),
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
