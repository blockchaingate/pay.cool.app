import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paycool/views/paycool_club/purchased_package_history/purchased_package_history_viewmodel.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/widgets/pagination/pagination_widget.dart';

import 'package:stacked/stacked.dart';

class PurchasedPackageView extends StatelessWidget {
  const PurchasedPackageView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PurchasedPackageViewmodel>.reactive(
      viewModelBuilder: () => PurchasedPackageViewmodel(),
      onViewModelReady: (PurchasedPackageViewmodel model) {
        model.context = context;
        model.init();
      },
      builder: (context, model, _) => Scaffold(
          appBar: customAppBarWithTitleNB(
              FlutterI18n.translate(context, "purchasedPackages")),
          body: model.isBusy
              ? SizedBox(
                  height: 500,
                  child: Center(child: model.sharedService.loadingIndicator()))
              : model.purchasedPackages.isEmpty
                  ? SizedBox(
                      height: 400,
                      child: Center(
                        child: Image.asset(
                          'assets/images/paycool/box.png',
                          color: red,
                          width: 50,
                        ),
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
                              itemCount: model.purchasedPackages.length,
                              itemBuilder: (BuildContext context, int index) {
                                int i = index + 1;
                                return Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                    bottom:
                                        BorderSide(color: grey.withAlpha(40)),
                                  )),
                                  child: ListTile(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 8),
                                    onTap: () {},
                                    leading: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            model.purchasedPackages[index].date
                                                .toString(),
                                            style: headText5.copyWith(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          // if (model.purchasedPackages[index]
                                          //         .project.status ==
                                          //     0) ...[
                                          //   Text(
                                          //       ' ${FlutterI18n.translate(context, "noPartner")}',
                                          //       style: headText6.copyWith(
                                          //           fontWeight: FontWeight.bold,
                                          //           color: black)),
                                          // ] else if (model
                                          //         .purchasedPackages[index]
                                          //         .project
                                          //         .status ==
                                          //     1) ...[
                                          //   Text(
                                          //       ' ${FlutterI18n.translate(context, "basicPartner")}',
                                          //       style: headText6.copyWith(
                                          //           fontWeight: FontWeight.bold,
                                          //           color: black)),
                                          // ] else if (model
                                          //         .purchasedPackages[index]
                                          //         .project
                                          //         .status ==
                                          //     2) ...[
                                          //   Text(
                                          //       ' ${FlutterI18n.translate(context, "juniorPartner")}',
                                          //       style: headText6.copyWith(
                                          //           fontWeight: FontWeight.bold,
                                          //           color: black)),
                                          // ] else if (model
                                          //         .purchasedPackages[index]
                                          //         .project
                                          //         .status ==
                                          //     3) ...[
                                          //   Text(
                                          //       ' ${FlutterI18n.translate(context, "seniorPartner")}',
                                          //       style: headText6.copyWith(
                                          //           fontWeight: FontWeight.bold,
                                          //           color: black)),
                                          // ] else if (model
                                          //         .purchasedPackages[index]
                                          //         .project
                                          //         .status ==
                                          //     4) ...[
                                          //   Text(
                                          //       ' ${FlutterI18n.translate(context, "executivePartner")}',
                                          //       style: headText6.copyWith(
                                          //           fontWeight: FontWeight.bold,
                                          //           color: black)),
                                          // ]
                                        ],
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
                                          model.purchasedPackages[index].txid!
                                                  .isNotEmpty
                                              ? Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 5.0),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        model.storageService
                                                                    .language ==
                                                                'en'
                                                            ? model
                                                                .purchasedPackages[
                                                                    index]
                                                                .project!
                                                                .name!
                                                                .en
                                                                .toString()
                                                            : model
                                                                .purchasedPackages[
                                                                    index]
                                                                .project!
                                                                .name!
                                                                .sc
                                                                .toString(),
                                                        style: headText4,
                                                      ),
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
                                                  model.purchasedPackages[index]
                                                      .txid
                                                      .toString(),
                                                  style: headText5.copyWith(
                                                      color: grey),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    trailing: Container(
                                        margin: EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              model.purchasedPackages[index]
                                                  .amount
                                                  .toString(),
                                              style: headText5,
                                            ),
                                            Text(
                                              model.purchasedPackages[index]
                                                  .paidCoinTicker
                                                  .toString(),
                                              style: headText6,
                                            )
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
