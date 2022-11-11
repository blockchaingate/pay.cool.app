import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/shared/ui_helpers.dart';
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
          appBar: AppBar(
            leading: Container(
              margin: const EdgeInsets.only(
                  right: 12, left: 9, top: 12, bottom: 10),
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: IconButton(
                  onPressed: (() => model.navigationService.goBack()),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: black,
                    size: 20,
                  )),
            ),
            backgroundColor: Colors.transparent,
            centerTitle: true,
            title: Text(FlutterI18n.translate(context, "referrals"),
                style: headText4.copyWith(fontWeight: FontWeight.bold)),
          ),
          body: model.isBusy
              ? SizedBox(
                  height: 500,
                  child: Center(child: model.sharedService.loadingIndicator()))
              : model.children == null || model.children.isEmpty
                  ? SizedBox(
                      height: 400,
                      child: Center(
                        child: Text(
                            FlutterI18n.translate(context, "noReferralsYet")),
                      ),
                    )
                  : Container(
                      decoration: const BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(20),
                            topRight: Radius.circular(20)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: model.children.length,
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
                                      if (model.downlineReferralCount > 0) {
                                        model.navigationService.navigateTo(
                                            PayCoolClubReferralViewRoute,
                                            arguments:
                                                model.children[index].id);
                                      }
                                    },
                                    leading: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        i.toString() + ' ',
                                        style: headText5.copyWith(color: black),
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
                                          model
                                                  .children[index]
                                                  .smartContractAddress
                                                  .isNotEmpty
                                              ? Container(
                                                  color: const Color.fromARGB(
                                                      255, 218, 146, 52),
                                                  padding:
                                                      const EdgeInsets.all(3.0),
                                                  child: Column(
                                                    children: [
                                                      if (model.children[index]
                                                              .status ==
                                                          0) ...[
                                                        Text(
                                                            ' ${FlutterI18n.translate(context, "primaryPartner")}',
                                                            style: headText6
                                                                .copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color:
                                                                        black)),
                                                      ] else if (model
                                                              .children[index]
                                                              .status ==
                                                          1) ...[
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
                                                              .children[index]
                                                              .status ==
                                                          2) ...[
                                                        Text(
                                                            ' ${FlutterI18n.translate(context, "intermediatePartner")}',
                                                            style: headText6
                                                                .copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color:
                                                                        black)),
                                                      ] else if (model
                                                              .children[index]
                                                              .status ==
                                                          3) ...[
                                                        Text(
                                                            ' ${FlutterI18n.translate(context, "seniorPartner")}',
                                                            style: headText6
                                                                .copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color:
                                                                        black)),
                                                      ]
                                                    ],
                                                  ),
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
                                                child: Text(
                                                  model.children[index]
                                                      .userAddress,
                                                  style: headText5.copyWith(
                                                      color: grey),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                ),
                                              ),
                                            ],
                                          ),

                                          Text(
                                              FlutterI18n.translate(context,
                                                      "referralCount") +
                                                  ' ' +
                                                  model.downlineReferralCount
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
                                                  model.children[index].id)();
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
                                                              .children[index]
                                                              .id)));
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
            Text(FlutterI18n.translate(context, "id") + ':',
                style: headText5.copyWith(fontWeight: FontWeight.bold)),
            Flexible(
              child: Text(
                qr,
                style: headText5.copyWith(color: primaryColor),
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
              foregroundColor: Colors.white),
        ),
      ),
    );
  }
}