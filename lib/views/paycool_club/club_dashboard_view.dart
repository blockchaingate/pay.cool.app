import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/environments/environment_type.dart';
import 'package:paycool/utils/string_util.dart';
import 'package:paycool/views/paycool_club/club_dashboard_model.dart';
import 'package:paycool/views/paycool_club/club_dashboard_viewmodel.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:paycool/widgets/server_error_widget.dart';
import 'package:stacked/stacked.dart';

import 'referral/referral_model.dart';

class ClubDashboardView extends StatelessWidget {
  const ClubDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ClubDashboardViewModel>.reactive(
        createNewViewModelOnInsert: true,
        viewModelBuilder: () => ClubDashboardViewModel(),
        onViewModelReady: (model) async {
          model.sharedService.context = context;
          model.context = context;
          model.init();
        },
        builder: (context, ClubDashboardViewModel model, child) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark,
            child: Scaffold(
              extendBodyBehindAppBar: true,
              body: InteractiveViewer(
                child: model.isServerDown
                    ? const Center(child: ServerErrorWidget())
                    : model.isBusy
                        ? model.sharedService.loadingIndicator(
                            isCustom: true,
                            strokeWidth: 2.5,
                            height: 40,
                            width: 40)
                        : WillPopScope(
                            onWillPop: () {
                              model.onBackButtonPressed();

                              return Future(() => false);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  image: imageBackground(
                                      path:
                                          'assets/images/club/background.png')),
                              child: CustomScrollView(
                                slivers: [
                                  const SliverToBoxAdapter(
                                      child: UIHelper.verticalSpaceLarge),
                                  SliverToBoxAdapter(
                                    child: Container(
                                      margin: const EdgeInsets.all(10.0),
                                      padding: const EdgeInsets.all(15.0),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            customText(
                                                text: FlutterI18n.translate(
                                                    context, "payCoolClub"),
                                                style: largeText1,
                                                letterSpace: 1.6),
                                            UIHelper.verticalSpaceMedium,
                                            UIHelper.verticalSpaceSmall,
                                            customText(
                                              text: FlutterI18n.translate(
                                                  context, "paycoolClubDesc"),
                                              style: headText2.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: 1.2),
                                            )
                                          ]),
                                    ),
                                  ),
                                  model.isValidMember
                                      ? SliverToBoxAdapter(
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Column(
                                              children: [
                                                // SliverPersistentHeader(
                                                //     delegate: delegate),

                                                //display myReferralCode when this user is a basic or VIP member
                                                Container(
                                                  decoration:
                                                      customContainerDecoration(
                                                    bgOpacity: 0.35,
                                                    bgColor: secondaryColor,
                                                    blendMode:
                                                        BlendMode.hardLight,
                                                    borderWidth: 0.2,
                                                  ),
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 10,
                                                      horizontal: 2),
                                                  margin: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 2,
                                                      horizontal: 15),
                                                  // color: secondaryColor,
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10),
                                                        child: Row(
                                                          children: [
                                                            UIHelper
                                                                .horizontalSpaceSmall,
                                                            Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                customText(
                                                                  text: FlutterI18n
                                                                      .translate(
                                                                          context,
                                                                          "totalRewards"),
                                                                  color: grey,
                                                                  style: headText5
                                                                      .copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                UIHelper
                                                                    .verticalSpaceSmall,
                                                                Text(
                                                                  NumberFormat
                                                                          .simpleCurrency()
                                                                      .format(model
                                                                          .totatRewardDollarVal
                                                                          .toDouble()),
                                                                  style: headText1
                                                                      .copyWith(
                                                                          color:
                                                                              black),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ), // member type tile
                                                      Container(
                                                        // width: 200,
                                                        margin: const EdgeInsets
                                                                .symmetric(
                                                            vertical: 2,
                                                            horizontal: 10),
                                                        decoration:
                                                            customContainerDecoration(
                                                                bgColor:
                                                                    secondaryColor,
                                                                bgOpacity: 0.2),
                                                        child: ListTile(
                                                          // onTap: (() => model
                                                          //     .showJoinedProjectsPopup()),
                                                          horizontalTitleGap: 0,
                                                          leading: model
                                                                  .isValidMember
                                                              ? model.dashboardSummary
                                                                          .status ==
                                                                      1
                                                                  ? Image.asset(
                                                                      'assets/images/club/crown.png',
                                                                      width: 32,
                                                                    )
                                                                  : Image.asset(
                                                                      'assets/images/club/crown-vip-member.png',
                                                                      width: 26,
                                                                    )
                                                              : const Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              8.0),
                                                                  child: Icon(
                                                                    FontAwesomeIcons
                                                                        .user,
                                                                    color:
                                                                        primaryColor,
                                                                    size: 22,
                                                                  ),
                                                                ),
                                                          title: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 8.0),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                customText(
                                                                  text: FlutterI18n
                                                                      .translate(
                                                                          context,
                                                                          "appTitle"),
                                                                  style: headText6.copyWith(
                                                                      color:
                                                                          black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      top: 2.0),
                                                                  child: customText(
                                                                      text: model
                                                                          .assignPaycoolMemberType(),
                                                                      style:
                                                                          headText6,
                                                                      color:
                                                                          grey),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        // width: 200,
                                                        margin: const EdgeInsets
                                                                .symmetric(
                                                            vertical: 2,
                                                            horizontal: 10),
                                                        decoration:
                                                            customContainerDecoration(
                                                                bgColor:
                                                                    secondaryColor,
                                                                bgOpacity: 0.2),
                                                        child: Visibility(
                                                          visible: model
                                                              .isValidMember,
                                                          child: ListTile(
                                                            horizontalTitleGap:
                                                                0,
                                                            leading: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 4.0),
                                                              child: Transform
                                                                  .rotate(
                                                                angle: 12.0,
                                                                child:
                                                                    const Icon(
                                                                  Icons
                                                                      .link_outlined,
                                                                  size: 26,
                                                                  color: red,
                                                                ),
                                                              ),
                                                            ),
                                                            //  Image.asset(
                                                            //   'assets/images/club/user.png',
                                                            //   width: 30,
                                                            // ),
                                                            title: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left:
                                                                          8.0),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    FlutterI18n.translate(
                                                                        context,
                                                                        "myReferralCode"),
                                                                    style: headText6.copyWith(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                  customText(
                                                                    text: StringUtils.showPartialAddress(
                                                                        startLimit:
                                                                            10,
                                                                        address:
                                                                            model.fabAddress),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style:
                                                                        headText6,
                                                                    color: grey,
                                                                  )
                                                                ],
                                                              ),
                                                            ),

                                                            trailing: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                IconButton(
                                                                  icon:
                                                                      const Icon(
                                                                    Icons.copy,
                                                                    size: 19,
                                                                    color:
                                                                        black,
                                                                  ),
                                                                  onPressed: () => model
                                                                      .sharedService
                                                                      .copyAddress(
                                                                          context,
                                                                          model
                                                                              .fabAddress),
                                                                ),
                                                                IconButton(
                                                                  icon:
                                                                      const Icon(
                                                                    Icons
                                                                        .share_outlined,
                                                                    size: 19,
                                                                    color:
                                                                        primaryColor,
                                                                  ),
                                                                  onPressed:
                                                                      () => model
                                                                          .showBarcode(),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),

                                                      // joined date tile
                                                      // ListTile(
                                                      //   horizontalTitleGap: 0,
                                                      //   leading: const Icon(
                                                      //     Icons
                                                      //         .stacked_line_chart_sharp,
                                                      //     color: black,
                                                      //     size: 18,
                                                      //   ),
                                                      //   title: Text(
                                                      //     FlutterI18n.translate(
                                                      //         context, "joinedDate"),
                                                      //     style: headText4,
                                                      //   ),
                                                      //   trailing: Text(
                                                      //       model.dashboard
                                                      //           .dateCreated,
                                                      //       style: headText5),
                                                      // ),
                                                      // asset value tile
                                                      UIHelper
                                                          .verticalSpaceSmall,
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          OutlinedButton.icon(
                                                            style:
                                                                generalButtonStyle(
                                                                    white,
                                                                    vPadding:
                                                                        10),
                                                            label: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 2.0),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Text(
                                                                    FlutterI18n.translate(
                                                                        context,
                                                                        "rewards"),
                                                                    style:
                                                                        headText5,
                                                                  ),
                                                                  UIHelper
                                                                      .horizontalSpaceSmall,
                                                                  // const Icon(
                                                                  //   Icons
                                                                  //       .arrow_forward_ios,
                                                                  //   color: grey,
                                                                  //   size: 12,
                                                                  // )
                                                                ],
                                                              ),
                                                            ),
                                                            onPressed: () => model.navigationService.navigateTo(
                                                                clubRewardsViewRoute,
                                                                arguments: ClubRewardsArgs(
                                                                    summary: List<
                                                                            Summary>.filled(
                                                                        1,
                                                                        model.dashboardSummary.summary![
                                                                            0]),
                                                                    rewardTokenPriceMap:
                                                                        model
                                                                            .rewardTokenPriceMap,
                                                                    totalRewardsDollarValue:
                                                                        model
                                                                            .totalPaycoolRewardDollarVal)),
                                                            icon: Image.asset(
                                                              'assets/images/club/gift.png',
                                                              width: 18,
                                                            ),
                                                          ),
                                                          // referral tree button
                                                          OutlinedButton.icon(
                                                            style:
                                                                generalButtonStyle(
                                                                    white,
                                                                    vPadding:
                                                                        10),
                                                            label: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 2.0),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Text(
                                                                    FlutterI18n.translate(
                                                                        context,
                                                                        "myReferralTree"),
                                                                    style:
                                                                        headText5,
                                                                  ),
                                                                  UIHelper
                                                                      .horizontalSpaceSmall,
                                                                  Text(
                                                                    model
                                                                        .referralCount
                                                                        .toString(),
                                                                    style: headText5.copyWith(
                                                                        color:
                                                                            primaryColor,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            onPressed: () {
                                                              model
                                                                  .navigationService
                                                                  .navigateTo(
                                                                      referralDetailsViewRoute,
                                                                      arguments:
                                                                          ReferalRoute(
                                                                        project: model
                                                                            .dashboardSummary
                                                                            .summary![0]
                                                                            .project,
                                                                      ));
                                                            },
                                                            icon: Image.asset(
                                                              'assets/images/club/network.png',
                                                              width: 18,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      UIHelper
                                                          .verticalSpaceSmall
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : SliverToBoxAdapter(
                                          child: Container(
                                            margin: const EdgeInsets.all(10),
                                            alignment: Alignment.center,
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  UIHelper.verticalSpaceLarge,
                                                  UIHelper.verticalSpaceLarge,
                                                  Text(
                                                    FlutterI18n.translate(
                                                        context,
                                                        "paycoolCaption"),
                                                    style: headText2,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  UIHelper.verticalSpaceSmall,
                                                  Container(
                                                    width: 150,
                                                    decoration: BoxDecoration(
                                                        // color: Color(mainColor),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(25),
                                                        gradient:
                                                            const LinearGradient(
                                                                colors: [
                                                              Color(0xFFcd45ff),
                                                              Color(0xFF7368ff),
                                                            ])),
                                                    margin:
                                                        const EdgeInsetsDirectional
                                                            .only(top: 10.0),
                                                    child: TextButton(
                                                      style: ButtonStyle(
                                                          textStyle:
                                                              MaterialStateProperty
                                                                  .all(
                                                                      const TextStyle(
                                                        color: Colors.white,
                                                      ))),
                                                      onPressed: () {
                                                        model.navigationService
                                                            .navigateTo(
                                                                PayCoolViewRoute);
                                                      },
                                                      child: Text(
                                                          FlutterI18n.translate(
                                                              context,
                                                              "joinPayCoolButton"),
                                                          style: headText4.copyWith(
                                                              color:
                                                                  secondaryColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                  const SliverToBoxAdapter(
                                      child: UIHelper.verticalSpaceMedium),
                                  model.isValidMember
                                      ? SliverToBoxAdapter(
                                          child: Container(
                                            decoration: roundedBoxDecoration(
                                                color: secondaryColor
                                                    .withOpacity(0.96)),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 2),
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 2, horizontal: 15),
                                            child: Column(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: Row(
                                                    children: [
                                                      UIHelper
                                                          .horizontalSpaceSmall,
                                                      Text(
                                                        FlutterI18n.translate(
                                                            context,
                                                            "lisOfPrograms"),
                                                        style:
                                                            headText3.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                !model.isValidMember
                                                    ? Container()
                                                    : Visibility(
                                                        visible:
                                                            model.isValidMember,
                                                        child: Column(
                                                          //shrinkWrap: true,
                                                          children: [
                                                            for (var summary
                                                                in model
                                                                    .dashboardSummary
                                                                    .summary!)
                                                              summary.project!
                                                                          .en !=
                                                                      'Paycool'
                                                                  ? (summary.project!.id == 1 &&
                                                                              isProduction) ||
                                                                          summary.project!.id == 9 &&
                                                                              !isProduction
                                                                      ? ListTile(
                                                                          horizontalTitleGap:
                                                                              0,
                                                                          leading:
                                                                              SvgPicture.asset(
                                                                            'assets/images/club/stake-icon.svg',
                                                                            width:
                                                                                25,
                                                                          ),
                                                                          //  Image.asset(
                                                                          //   'assets/images/club/user.png',
                                                                          //   width: 30,
                                                                          // ),
                                                                          title:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.symmetric(vertical: 4),
                                                                                child: Text(
                                                                                  model.storageService.language == 'zh' ? summary.project!.sc.toString() : summary.project!.en.toString(),
                                                                                  style: headText5.copyWith(fontWeight: FontWeight.bold),
                                                                                ),
                                                                              ),
                                                                              summary.status != 0
                                                                                  ? Container(
                                                                                      margin: EdgeInsets.only(top: model.isShowExpiredWarning ? 10 : 0),
                                                                                      child: model.showExpiredProjectWarning(summary.expiredAt.toString()) && model.isShowExpiredWarning && !model.busy(model.isShowExpiredWarning)
                                                                                          ? Stack(
                                                                                              clipBehavior: Clip.none,
                                                                                              children: [
                                                                                                Container(
                                                                                                  width: 200,
                                                                                                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 13),
                                                                                                  child: customText(text: model.storageService.language == 'zh' ? '您的 ${summary.project!.sc} 项目质押将在  ${model.expiredProjectInDays(summary.expiredAt.toString()).toString()} 天后到期, 您可以通过购买月费或年费来续订' : 'Your ${summary.project!.en} project staking is expiring in ${model.expiredProjectInDays(summary.expiredAt.toString()).toString()} days, you can renew it by stacking monthly or annually', color: red, isCustomFont: true, style: bodyText1),
                                                                                                ),
                                                                                                Align(
                                                                                                  alignment: Alignment.topRight,

                                                                                                  // Positioned(
                                                                                                  //   top: -15,
                                                                                                  //   right: 20,
                                                                                                  child: Container(
                                                                                                    width: 25,
                                                                                                    height: 25,
                                                                                                    child: IconButton(
                                                                                                      padding: EdgeInsets.zero,
                                                                                                      icon: const Icon(
                                                                                                        Icons.cancel,
                                                                                                        size: 16,
                                                                                                      ),
                                                                                                      color: red,
                                                                                                      onPressed: () {
                                                                                                        model.removeWarning();
                                                                                                      },
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            )
                                                                                          : Container(),
                                                                                    )
                                                                                  : Container()
                                                                            ],
                                                                          ),

                                                                          trailing:
                                                                              Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: [
                                                                              IconButton(
                                                                                  onPressed: () => model.navigationService.navigateTo(clubProjectDetailsViewRoute, arguments: summary),
                                                                                  icon: const Icon(
                                                                                    Icons.arrow_forward_ios_outlined,
                                                                                    size: 19,
                                                                                    color: primaryColor,
                                                                                  ))
                                                                            ],
                                                                          ),
                                                                        )
                                                                      : Container()
                                                                  : Container(),
                                                          ],
                                                        ),
                                                      ),

                                                !model.isValidMember
                                                    ? Container()
                                                    : UIHelper.divider,
                                                !model.isValidMember ||
                                                        model
                                                                .dashboardSummary
                                                                .summary!
                                                                .length <
                                                            3
                                                    ? Container()
                                                    : ListTile(
                                                        horizontalTitleGap: 0,
                                                        leading: const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 4.0),
                                                          child: Icon(
                                                            Icons
                                                                .dashboard_customize_outlined,
                                                            size: 24,
                                                            color: yellow,
                                                          ),
                                                        ),
                                                        //  Image.asset(
                                                        //   'assets/images/club/user.png',
                                                        //   width: 30,
                                                        // ),
                                                        title: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 4),
                                                          child: Text(
                                                            FlutterI18n.translate(
                                                                context,
                                                                "otherPrograms"),
                                                            style: headText5
                                                                .copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                          ),
                                                        ),

                                                        trailing: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            IconButton(
                                                                onPressed: () =>
                                                                    model
                                                                        .showProjectList(),
                                                                icon:
                                                                    const Icon(
                                                                  Icons
                                                                      .arrow_forward_ios_outlined,
                                                                  size: 19,
                                                                  color:
                                                                      primaryColor,
                                                                ))
                                                          ],
                                                        ),
                                                      ),

                                                // joined date tile
                                                // ListTile(
                                                //   horizontalTitleGap: 0,
                                                //   leading: const Icon(
                                                //     Icons
                                                //         .stacked_line_chart_sharp,
                                                //     color: black,
                                                //     size: 18,
                                                //   ),
                                                //   title: Text(
                                                //     FlutterI18n.translate(
                                                //         context, "joinedDate"),
                                                //     style: headText4,
                                                //   ),
                                                //   trailing: Text(
                                                //       model.dashboard
                                                //           .dateCreated,
                                                //       style: headText5),
                                                // ),
                                                // asset value tile
                                                //  UIHelper.verticalSpaceSmall,
                                              ],
                                            ),
                                          ),
                                        )
                                      : SliverToBoxAdapter(child: Container())
                                ],
                              ),
                            ),
                          ),
              ),
              bottomNavigationBar: BottomNavBar(count: 0),
            ),
          );
        });
  }
}
