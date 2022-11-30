import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/widgets/pagination/pagination_widget.dart';

import 'package:stacked/stacked.dart';
import 'package:paycool/views/paycool_club/referral/paycool_referral_viewmodel.dart';

class PaycoolReferralView extends StatelessWidget {
  final String address;
  const PaycoolReferralView({Key key, this.address}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PaycoolReferralViewmodel>.reactive(
      viewModelBuilder: () => PaycoolReferralViewmodel(),
      onModelReady: (PaycoolReferralViewmodel model) {
        model.address = address ?? '';
        model.context = context;
        model.init();
      },
      builder: (context, model, _) => Scaffold(
          appBar: customAppBarWithTitleNB(
              FlutterI18n.translate(context, "referrals")),
          body: model.isBusy
              ? SizedBox(
                  height: 500,
                  child: Center(child: model.sharedService.loadingIndicator()))
              : model.referrals == null || model.referrals.isEmpty
                  ? SizedBox(
                      height: 400,
                      child: Center(
                        child: Text(
                            FlutterI18n.translate(context, "noReferralsYet"),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    )
                  : Container(
                      decoration: const BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: model.referrals.length,
                              itemBuilder: (BuildContext context, int index) {
                                int i = index + 1;
                                return Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                    bottom:
                                        BorderSide(color: grey.withAlpha(40)),
                                  )),
                                  child: ListTile(
                                    onTap: () {
                                      if (int.parse(
                                              model.referrals[index].count) >
                                          0) {
                                        model.navigationService.navigateTo(
                                            PayCoolClubReferralViewRoute,
                                            arguments: model
                                                .referrals[index].userAddress);
                                      }
                                    },
                                    leading: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        i.toString() + ' ',
                                        style: headText5.copyWith(
                                            color: black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    title: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          model.referrals[index].count
                                                  .isNotEmpty
                                              ? Container(
                                                  color: primaryColor
                                                      .withAlpha(120),
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: Column(children: [
                                                    if (model.referrals[index]
                                                            .status ==
                                                        -1) ...[
                                                      Text(
                                                          ' ${FlutterI18n.translate(context, "noPartner")}',
                                                          style: headText6
                                                              .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      black)),
                                                    ] else if (model
                                                            .referrals[index]
                                                            .status ==
                                                        0) ...[
                                                      Text(
                                                          ' ${FlutterI18n.translate(context, "noPartner")}',
                                                          style: headText6
                                                              .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      black)),
                                                    ] else if (model
                                                            .referrals[index]
                                                            .status ==
                                                        1) ...[
                                                      Text(
                                                          ' ${FlutterI18n.translate(context, "basicPartner")}',
                                                          style: headText6
                                                              .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      black)),
                                                    ] else if (model
                                                            .referrals[index]
                                                            .status ==
                                                        2) ...[
                                                      Text(
                                                          ' ${FlutterI18n.translate(context, "juniorPartner")}',
                                                          style: headText6
                                                              .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      black)),
                                                    ] else if (model
                                                            .referrals[index]
                                                            .status ==
                                                        3) ...[
                                                      Text(
                                                          ' ${FlutterI18n.translate(context, "sophomorePartner")}',
                                                          style: headText6
                                                              .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      black)),
                                                    ] else if (model
                                                            .referrals[index]
                                                            .status ==
                                                        4) ...[
                                                      Text(
                                                          ' ${FlutterI18n.translate(context, "executivePartner")}',
                                                          style: headText6
                                                              .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      black)),
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
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 4),
                                                  child: Text(
                                                    model.referrals[index]
                                                        .userAddress,
                                                    style: headText5.copyWith(
                                                      decoration: TextDecoration
                                                          .underline,
                                                      color: primaryColor,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          Text(
                                              FlutterI18n.translate(context,
                                                      "referralCount") +
                                                  ' ' +
                                                  model.referrals[index].count
                                                      .toString(),
                                              style: headText5.copyWith(
                                                  color: black)),
                                        ],
                                      ),
                                    ),
                                    trailing: Container(
                                        child: Row(
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
                                                  model.referrals[index]
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
                                                      builder: (context) =>
                                                          DisplayQrCode(model
                                                              .referrals[index]
                                                              .userAddress)));
                                            }),
                                      ],
                                    )),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: model.paginationModel.pages.isEmpty
              ? Container()
              : PaginationWidget(
                  pageCallback: model.getPaginationRewards,
                  paginationModel: model.paginationModel,
                )),
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
            Text(FlutterI18n.translate(context, "id") + ': ',
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
          child: QrImage(
              data: qr,
              version: QrVersions.auto,
              size: 200.0,
              foregroundColor: black),
        ),
      ),
    );
  }
}
