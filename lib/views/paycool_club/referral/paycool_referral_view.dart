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
            centerTitle: true,
            title: Text(FlutterI18n.translate(context, "referrals"),
                style: headText4),
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
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: model.children.length,
                            itemBuilder: (BuildContext context, int index) {
                              int i = index + 1;
                              return InkWell(
                                onTap: () {
                                  if (model.children[index]
                                          .downlineReferralCount >
                                      0) {
                                    model.navigationService.navigateTo(
                                        PayCoolClubReferralViewRoute,
                                        arguments: model.children[index].id);
                                  }
                                },
                                child: Card(
                                  elevation: 2,
                                  color: walletCardColor,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        UIHelper.horizontalSpaceSmall,
                                        // Padding(
                                        //   padding: const EdgeInsets.all(8.0),
                                        //   child: Text(
                                        //     i.toString() + ') ',
                                        //     style: headText5,
                                        //   ),
                                        // ),
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              model
                                                      .children[index]
                                                      .smartContractAdd
                                                      .isNotEmpty
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 8.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Icon(Icons.star,
                                                              color: yellow,
                                                              size: 18),
                                                          Text(
                                                              ' ${FlutterI18n.translate(context, "vipMember")}',
                                                              style: headText4),
                                                        ],
                                                      ),
                                                    )
                                                  : Container(),
                                              // id
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 2.0),
                                                    child: Text(
                                                        FlutterI18n.translate(
                                                                context, "id") +
                                                            ':',
                                                        style:
                                                            headText5.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                  ),
                                                  Flexible(
                                                    child: Text(
                                                      model.children[index].id,
                                                      style: headText5.copyWith(
                                                          color: primaryColor),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                    ),
                                                  ),
                                                  CupertinoButton(
                                                      child: const Icon(
                                                        FontAwesomeIcons.copy,
                                                        //  CupertinoIcons.,
                                                        color: primaryColor,
                                                        size: 14,
                                                      ),
                                                      onPressed: () {
                                                        model.sharedService
                                                            .copyAddress(
                                                                context,
                                                                model
                                                                    .children[
                                                                        index]
                                                                    .id)();
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
                                                                        .children[
                                                                            index]
                                                                        .id)));
                                                      }),
                                                ],
                                              ),
                                              // UIHelper.verticalSpaceSmall,
                                              // Row(
                                              //   mainAxisSize:
                                              //       MainAxisSize.min,
                                              //   children: [
                                              //     Text(
                                              //         AppLocalizations.of(
                                              //                 context)
                                              //             .memberType,
                                              //         style: headText5),
                                              //   ],
                                              // ),

                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      FlutterI18n.translate(
                                                          context,
                                                          "referralCount"),
                                                      style: headText5),
                                                  UIHelper.horizontalSpaceSmall,
                                                  Text(
                                                      model.children[index]
                                                          .downlineReferralCount
                                                          .toString(),
                                                      style: headText5)
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        UIHelper.horizontalSpaceSmall,
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
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
