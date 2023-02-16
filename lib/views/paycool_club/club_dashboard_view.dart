import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/constants/ui_var.dart';
import 'package:paycool/utils/number_util.dart';
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
              body: model.isServerDown
                  ? const Center(child: ServerErrorWidget())
                  : model.isBusy
                      ? model.sharedService.loadingIndicator()
                      : WillPopScope(
                          onWillPop: () {
                            model.onBackButtonPressed();

                            return Future(() => false);
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: AssetImage(
                                        "assets/images/club/background.png"))),
                            child: CustomScrollView(
                              slivers: [
                                const SliverToBoxAdapter(
                                    child: UIHelper.verticalSpaceLarge),
                                // model.isBusy
                                //     ? SliverToBoxAdapter(
                                //         child: model.sharedService
                                //             .loadingIndicator())
                                //     : SliverToBoxAdapter(
                                //         child: Container(
                                //           // color: secondaryColor,
                                //           decoration: BoxDecoration(
                                //             image: blurBackgroundImage(),
                                //           ),
                                //           margin:
                                //               const EdgeInsets.only(top: 10),
                                //           height: 255,
                                //           child: Stack(
                                //             children: [
                                //             ],
                                //           ),
                                //         ),
                                //       ),
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
                                          Text(
                                            FlutterI18n.translate(
                                                context, "payCoolClub"),
                                            style: headText1.copyWith(
                                                color: black, letterSpacing: 2),
                                          ),
                                          UIHelper.verticalSpaceMedium,
                                          Text(
                                            FlutterI18n.translate(
                                                context, "paycoolClubDesc"),
                                            style: headText2.copyWith(
                                                fontWeight: FontWeight.w400,
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
                                                    roundedBoxDecoration(
                                                        color: secondaryColor
                                                            .withOpacity(0.66)),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10,
                                                        horizontal: 2),
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 2,
                                                        horizontal: 15),
                                                // color: secondaryColor,
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
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
                                                              Text(
                                                                FlutterI18n
                                                                    .translate(
                                                                        context,
                                                                        "totalRewards"),
                                                                style: headText4.copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color:
                                                                        grey),
                                                              ),
                                                              UIHelper
                                                                  .verticalSpaceSmall,
                                                              Text(
                                                                '\$${model.totatRewardDollarVal}',
                                                                style: headText1
                                                                    .copyWith(
                                                                        color:
                                                                            green),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ), // member type tile
                                                    Container(
                                                      margin: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 2),
                                                      decoration:
                                                          rectangularGradientBoxDecoration(
                                                              colorOne:
                                                                  primaryColor,
                                                              colorTwo:
                                                                  primaryColor
                                                                      .withAlpha(
                                                                          100)),
                                                      child: ListTile(
                                                        // onTap: (() => model
                                                        //     .showJoinedProjectsPopup()),
                                                        horizontalTitleGap: 0,
                                                        leading:
                                                            model.isValidMember
                                                                ? Image.asset(
                                                                    'assets/images/club/member.png',
                                                                    width: 26,
                                                                  )
                                                                : const Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0),
                                                                    child: Icon(
                                                                      FontAwesomeIcons
                                                                          .user,
                                                                      color:
                                                                          primaryColor,
                                                                      size: 18,
                                                                    ),
                                                                  ),
                                                        title: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              FlutterI18n
                                                                  .translate(
                                                                      context,
                                                                      "appTitle"),
                                                              style: headText6.copyWith(
                                                                  color:
                                                                      secondaryColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            Text(
                                                              model
                                                                  .assignMemberType(),
                                                              style: headText4.copyWith(
                                                                  color:
                                                                      secondaryColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Visibility(
                                                      visible:
                                                          model.isValidMember,
                                                      child: ListTile(
                                                        horizontalTitleGap: 0,
                                                        leading: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 4.0),
                                                          child:
                                                              Transform.rotate(
                                                            angle: 12.0,
                                                            child: const Icon(
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
                                                                      .symmetric(
                                                                  vertical: 4),
                                                          child: Text(
                                                            FlutterI18n.translate(
                                                                context,
                                                                "myReferralCode"),
                                                            style: headText6
                                                                .copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                          ),
                                                        ),
                                                        subtitle: Text(
                                                          StringUtils
                                                              .showPartialAddress(
                                                                  startLimit:
                                                                      10,
                                                                  address: model
                                                                      .fabAddress),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: bodyText1
                                                              .copyWith(
                                                                  color: grey),
                                                        ),
                                                        trailing: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons.copy,
                                                                size: 19,
                                                                color: black,
                                                              ),
                                                              onPressed: () => model
                                                                  .sharedService
                                                                  .copyAddress(
                                                                      context,
                                                                      model
                                                                          .fabAddress),
                                                            ),
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons
                                                                    .share_outlined,
                                                                size: 19,
                                                                color:
                                                                    primaryColor,
                                                              ),
                                                              onPressed: () => model
                                                                  .showBarcode(),
                                                            ),
                                                          ],
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
                                                    UIHelper.verticalSpaceSmall,
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        OutlinedButton.icon(
                                                          style:
                                                              generalButtonStyle(
                                                                  white),
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
                                                                  FlutterI18n
                                                                      .translate(
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
                                                                      model.dashboardSummary
                                                                              .summary![
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
                                                                  white),
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
                                                                  FlutterI18n
                                                                      .translate(
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
                                                                          FontWeight
                                                                              .bold),
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
                                                                          .summary![
                                                                              0]
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
                                                    UIHelper.verticalSpaceSmall
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : SliverToBoxAdapter(
                                        child: Container(
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
                                                  FlutterI18n.translate(context,
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
                                                          BorderRadius.circular(
                                                              25),
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
                                          // color: secondaryColor,
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
                                                          context, "projects"),
                                                      style: headText3.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Visibility(
                                                visible: model.isValidMember,
                                                child: Column(
                                                  //shrinkWrap: true,
                                                  children: [
                                                    for (var summary in model
                                                        .dashboardSummary
                                                        .summary!)
                                                      summary.status != 0 &&
                                                              summary.project!
                                                                      .en !=
                                                                  'Paycool'
                                                          ? ListTile(
                                                              onTap: () => model
                                                                  .navigationService
                                                                  .navigateTo(
                                                                      clubProjectDetailsViewRoute,
                                                                      arguments:
                                                                          summary),
                                                              horizontalTitleGap:
                                                                  0,
                                                              leading:
                                                                  SvgPicture
                                                                      .asset(
                                                                'assets/images/club/stake-icon.svg',
                                                                width: 25,
                                                              ),
                                                              //  Image.asset(
                                                              //   'assets/images/club/user.png',
                                                              //   width: 30,
                                                              // ),
                                                              title: Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        4),
                                                                child: Text(
                                                                  model.storageService
                                                                              .language ==
                                                                          'sc'
                                                                      ? summary
                                                                          .project!
                                                                          .sc
                                                                          .toString()
                                                                      : summary
                                                                          .project!
                                                                          .en
                                                                          .toString(),
                                                                  style: headText5.copyWith(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                              // subtitle:
                                                              //     Container(
                                                              //   child: customText(
                                                              //       text:
                                                              //           'Exipration text',
                                                              //       color: red,
                                                              //       isCustomFont:
                                                              //           true,
                                                              //       style:
                                                              //           bodyText1),
                                                              // ),
                                                              trailing: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: const [
                                                                  Icon(
                                                                    Icons
                                                                        .arrow_forward_ios_outlined,
                                                                    size: 19,
                                                                    color:
                                                                        primaryColor,
                                                                  )
                                                                ],
                                                              ),
                                                            )
                                                          : Container(),
                                                  ],
                                                ),
                                              ),

                                              UIHelper.divider,

                                              ListTile(
                                                horizontalTitleGap: 0,
                                                onTap: () =>
                                                    model.showProjectList(),
                                                leading: const Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 4.0),
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
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 4),
                                                  child: Text(
                                                    FlutterI18n.translate(
                                                        context,
                                                        "otherPrograms"),
                                                    style: headText5.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),

                                                trailing: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: const [
                                                    Icon(
                                                      Icons
                                                          .arrow_forward_ios_outlined,
                                                      size: 19,
                                                      color: primaryColor,
                                                    ),
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
                                              UIHelper.verticalSpaceSmall,
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container()
                              ],
                            ),
                          ),
                        ),
              bottomNavigationBar: BottomNavBar(count: 0),
            ),
          );
        });
  }
}
