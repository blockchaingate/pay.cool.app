import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pagination_widget/pagination_widget.dart';
import 'package:paycool/utils/paycool_util.dart';
import 'package:paycool/utils/string_util.dart';
import 'package:paycool/views/paycool_club/referral/referral_model.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/constants/route_names.dart';

import 'package:stacked/stacked.dart';
import 'package:paycool/views/paycool_club/referral/referral_viewmodel.dart';

class PaycoolReferralDetailsView extends StatelessWidget {
  final ReferalRoute referalRoute;
  const PaycoolReferralDetailsView({super.key, required this.referalRoute});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ReferralViewmodel>.reactive(
      viewModelBuilder: () => ReferralViewmodel(),
      onViewModelReady: (ReferralViewmodel model) {
        model.context = context;
        model.referalRoute = referalRoute;
        model.init();
      },
      builder: (context, model, _) => Scaffold(
          appBar: customAppBarWithTitleNB(
              '${model.referalRoute.address != null ? StringUtils.showPartialData(data: model.referalRoute.address) : PaycoolUtil.localizedProjectData(model.referalRoute.project!)} - ${FlutterI18n.translate(context, "referrals")}',
              subTitle: referalRoute.address == null
                  ? ''
                  : PaycoolUtil.localizedProjectData(referalRoute.project!)),
          body: model.isBusy
              ? SizedBox(
                  height: 500,
                  child: Center(
                      child: model.sharedService.loadingIndicator(
                          isCustomWidthHeight: true, width: 40, height: 40)))
              : model.referalRoute.referrals == null ||
                      model.referalRoute.referrals!.isEmpty
                  ? SizedBox(
                      height: 400,
                      child: Center(
                        child: Text(
                            FlutterI18n.translate(context, "noReferralsYet"),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    )
                  : referralMethod(model),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: model.paginationModel.pages.isEmpty
              ? Container()
              : PaginationWidget(
                  paginationModel: model.paginationModel,
                  pageCallback: model.getPaginationRewards,
                )),
    );
  }

  Container referralMethod(ReferralViewmodel model) {
    return Container(
      decoration: const BoxDecoration(
        color: white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: model.referalRoute.referrals!.length,
              itemBuilder: (BuildContext context, int index) {
                int i = index + 1;
                return Container(
                  decoration: BoxDecoration(
                      border: Border(
                    bottom: BorderSide(color: grey.withAlpha(40)),
                  )),
                  child: ListTile(
                    onTap: () {
                      model.navigationService.navigateTo(
                          referralDetailsViewRoute,
                          arguments: ReferalRoute(
                              project: model.referalRoute.project,
                              address: model
                                  .referalRoute.referrals![index].userAddress));
                    },
                    leading: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        model.paginationModel.pageNumber > 1
                            ? '${model.paginationModel.pageNumber - 1}${i.toString()}'
                            : '$i ',
                        style: headText5.copyWith(
                            color: black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          model.referalRoute.referrals![index].count!.isNotEmpty
                              ? Container(
                                  //  color: primaryColor.withAlpha(120),
                                  padding: const EdgeInsets.all(2.0),
                                  child: Column(children: [
                                    if (model.referalRoute.project!.en ==
                                        'Paycool') ...[
                                      if (model.referalRoute.referrals![index]
                                              .status ==
                                          1) ...[
                                        Text(
                                            ' ${FlutterI18n.translate(context, "member")}',
                                            style: headText6.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: black)),
                                      ] else ...[
                                        Text(
                                            ' ${FlutterI18n.translate(context, "vipMember")}',
                                            style: headText6.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: black)),
                                      ]
                                    ] else ...[
                                      if (model.referalRoute.referrals![index]
                                              .status ==
                                          -1) ...[
                                        Text(
                                            ' ${FlutterI18n.translate(context, "noPartner")}',
                                            style: headText6.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: black)),
                                      ] else if (model.referalRoute
                                              .referrals![index].status ==
                                          0) ...[
                                        Text(
                                            ' ${FlutterI18n.translate(context, "noPartner")}',
                                            style: headText6.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: black)),
                                      ] else if (model.referalRoute
                                              .referrals![index].status ==
                                          1) ...[
                                        Text(
                                            ' ${FlutterI18n.translate(context, "basicPartner")}',
                                            style: headText6.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: black)),
                                      ] else if (model.referalRoute
                                              .referrals![index].status ==
                                          2) ...[
                                        Text(
                                            ' ${FlutterI18n.translate(context, "juniorPartner")}',
                                            style: headText6.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: black)),
                                      ] else if (model.referalRoute
                                              .referrals![index].status ==
                                          3) ...[
                                        Text(
                                            ' ${FlutterI18n.translate(context, "seniorPartner")}',
                                            style: headText6.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: black)),
                                      ] else if (model.referalRoute
                                              .referrals![index].status ==
                                          4) ...[
                                        Text(
                                            ' ${FlutterI18n.translate(context, "executivePartner")}',
                                            style: headText6.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: black)),
                                      ]
                                    ],
                                  ]),
                                )
                              : Container(),
                          // id
                          Row(
                            children: [
                              // Padding(
                              //   padding: const EdgeInsets.only(
                              //       right: 2.0),
                              //   child: Text(
                              //       FlutterI18n.translate(
                              //               context, "id") +
                              //           ':',
                              //       style: headText5.copyWith(
                              //           fontWeight:
                              //               FontWeight.bold,
                              //           color: black)),
                              // ),
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 3.0),
                                  child: Text(
                                    model.referalRoute.referrals![index]
                                        .userAddress!,
                                    style: headText5.copyWith(
                                      decoration: TextDecoration.underline,
                                      color: primaryColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Text(
                              '${FlutterI18n.translate(context, "referralCount")} ${model.referalRoute.referrals![index].count}',
                              style: headText5.copyWith(color: black)),
                        ],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CupertinoButton(
                            child: const Icon(
                              FontAwesomeIcons.copy,
                              //  CupertinoIcons.,
                              color: primaryColor,
                              size: 14,
                            ),
                            onPressed: () {
                              model.sharedService.copyAddress(
                                  context,
                                  model.referalRoute.referrals![index]
                                      .userAddress)();
                            }),
                        CupertinoButton(
                            child: const Icon(
                              FontAwesomeIcons.qrcode,
                              //  CupertinoIcons.,
                              color: primaryColor,
                              size: 14,
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DisplayQrCode(model
                                          .referalRoute
                                          .referrals![index]
                                          .userAddress!)));
                            }),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DisplayQrCode extends StatelessWidget {
  const DisplayQrCode(this.qr);

  final String qr;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('${FlutterI18n.translate(context, "id")}: ',
                style: headText5.copyWith(
                    fontWeight: FontWeight.bold, color: secondaryColor)),
            Flexible(
              child: Text(
                qr,
                style: headText5.copyWith(color: secondaryColor),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        child: Center(
          child: QrImageView(
              data: qr,
              version: QrVersions.auto,
              size: 200.0,
              foregroundColor: black),
        ),
      ),
    );
  }
}
