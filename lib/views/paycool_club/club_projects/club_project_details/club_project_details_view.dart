import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/paycool_club/club_dashboard_model.dart';
import 'package:paycool/views/paycool_club/club_projects/club_project_details/club_project_details_viemodel.dart';
import 'package:paycool/views/paycool_club/purchased_package_history/purchased_package_history_view.dart';
import 'package:paycool/views/paycool_club/referral/referral_model.dart';
import 'package:stacked/stacked.dart';

class ClubProjectDetailsView extends StatelessWidget {
  final Summary summary;
  const ClubProjectDetailsView({Key? key, required this.summary})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => ClubProjectDetailsViewModel(),
      onViewModelReady: (model) {
        model.sharedService.context = context;
        model.context = context;
        debugPrint('id ${summary.project!.id} ');
        model.init();
      },
      builder: (context, ClubProjectDetailsViewModel viewmodel, _) => Scaffold(
        // extendBodyBehindAppBar: true,

        body: Container(
          alignment: Alignment.center,
          color: const Color.fromRGBO(159, 157, 241, 1),
          child: Stack(
            children: [
              // UIHelper.verticalSpaceMedium,
              Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      margin: const EdgeInsets.only(top: 90, left: 20),
                      decoration: roundedBoxDecoration(
                          radius: 50, color: secondaryColor),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: black,
                        ),
                        onPressed: () => viewmodel.navigationService.goBack(),
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      margin: const EdgeInsets.only(top: 20, left: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            viewmodel.storageService.language == 'zh'
                                ? summary.project!.sc.toString()
                                : summary.project!.en.toString(),
                            style: headText1,
                          ),
                          viewmodel
                                      .selectedProject(
                                          summary.project!.id.toString())!
                                      .description ==
                                  null
                              ? Container()
                              : Text(
                                  viewmodel.storageService.language == 'zh'
                                      ? viewmodel
                                          .selectedProject(
                                              summary.project!.id.toString())!
                                          .description!
                                          .sc
                                          .toString()
                                      : viewmodel
                                          .selectedProject(
                                              summary.project!.id.toString())!
                                          .description!
                                          .en
                                          .toString(),
                                  style: headText2.copyWith(
                                      color: secondaryColor,
                                      letterSpacing: 1.5),
                                ),
                        ],
                      ),
                    ),
                  ),
                  //UIHelper.verticalSpaceMedium,
                  Container(
                    margin: const EdgeInsets.only(top: 20, left: 25),
                    alignment: Alignment.topLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            UIHelper.verticalSpaceMedium,
                            customText(
                                text: FlutterI18n.translate(
                                    context, "packageDetails"),
                                color: const Color(0xffFFCC7E),
                                style: headText3,
                                isCustomFont: true,
                                size: 17,
                                letterSpace: 0.75),
                            OutlinedButton(
                                style: outlinedButtonStyle(
                                    vPadding: 0,
                                    hPadding: 15,
                                    sideColor: secondaryColor,
                                    backgroundColor: secondaryColor),
                                onPressed: () => viewmodel
                                    .goToProjectPackages(summary.project!),
                                child: customText(
                                    text: FlutterI18n.translate(
                                        context, "selectPackage"),
                                    style: headText5,
                                    letterSpace: 0.75))
                          ],
                        ),
                        UIHelper.horizontalSpaceSmall,
                        Expanded(
                          child: Image.asset(
                            'assets/images/club/fab-graphics.png',
                            fit: BoxFit.contain,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              //  UIHelper.verticalSpaceMedium,
              Positioned(
                top: 392,
                bottom: 0,
                right: 0,
                left: 0,
                child: Container(
                  decoration: roundedTopLeftRightBoxDecoration(
                      color: secondaryColor, radius: 30),
                  padding: const EdgeInsets.only(top: 10, left: 20),
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          summary.status != 0
                              ? SvgPicture.asset(
                                  'assets/images/club/crown-${summary.status}.svg',
                                  width: 50,
                                )
                              : Container(
                                  margin: EdgeInsets.only(left: 5),
                                ),
                          UIHelper.horizontalSpaceSmall,
                          customText(
                              text: viewmodel.assignMemberType(
                                  status: summary.status),
                              style: headText3,
                              letterSpace: 0.7),
                        ],
                      ),
                      UIHelper.verticalSpaceMedium,
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 17.0, vertical: 2),
                        child: customText(
                            text:
                                '${FlutterI18n.translate(context, "programDetails")}:',
                            style: headText4,
                            color: grey,
                            isUnderline: true,
                            letterSpace: 0.7),
                      ),
                      summary.project!.id == 1 || summary.project!.id == 9
                          ? ListTile(
                              horizontalTitleGap: 0,
                              onTap: () => Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) =>
                                          const PurchasedPackageView())),
                              leading: Image.asset(
                                'assets/images/club/packages.png',
                                width: 30,
                              ),
                              title: customText(
                                  text: FlutterI18n.translate(
                                      context, "stackingPackageJoined"),
                                  style: headText5,
                                  letterSpace: 0.5),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: customText(
                                          text: viewmodel.purchasedPackagesCount
                                              .toString(),
                                          style: headText5,
                                          letterSpace: 0.5)),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    color: grey,
                                    size: 16,
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                      ListTile(
                        horizontalTitleGap: 0,
                        onTap: () {
                          viewmodel.goToRewardsView(summary);
                        },
                        leading: Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Image.asset(
                            'assets/images/club/gift.png',
                            width: 22,
                          ),
                        ),
                        title: customText(
                            text: FlutterI18n.translate(context, "rewards"),
                            style: headText5,
                            letterSpace: 0.5),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.arrow_forward_ios,
                              color: grey,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                      ListTile(
                        horizontalTitleGap: 0,
                        onTap: () {
                          viewmodel.navigationService
                              .navigateTo(referralDetailsViewRoute,
                                  arguments: ReferalRoute(
                                    project: summary.project,
                                  ));
                        },
                        leading: Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Image.asset(
                            'assets/images/club/network.png',
                            width: 26,
                          ),
                        ),
                        title: customText(
                            text: FlutterI18n.translate(context, "referrals"),
                            style: headText5,
                            letterSpace: 0.5),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.arrow_forward_ios,
                              color: grey,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
