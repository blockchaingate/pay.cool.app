import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/constants/ui_var.dart';
import 'package:paycool/views/paycool_club/club_dashboard_viewmodel.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:paycool/widgets/server_error_widget.dart';
import 'package:stacked/stacked.dart';

import '../../constants/colors.dart';
import 'dart:math' as math;

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => math.max(maxHeight, minHeight);
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class ClubDashboardView extends StatelessWidget {
  const ClubDashboardView({Key key}) : super(key: key);

  topPaycoolWidget(context, ClubDashboardViewModel model) {
    return Column(
      children: [
        // SizedBox(height: 30),
        //join button conatiner
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width < largeSize
              ? MediaQuery.of(context).size.width * 0.6
              : largeSize * 0.8,
          // decoration: const BoxDecoration(
          //     image: DecorationImage(
          //         image:
          //             AssetImage("assets/images/shared/blur-background.png"))),
          child: Container(
            child: Stack(
              children: [
                Positioned(
                  top: MediaQuery.of(context).size.width * 0.32,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.65,
                      height: MediaQuery.of(context).size.width < largeSize
                          ? MediaQuery.of(context).size.width * 0.17
                          : MediaQuery.of(context).size.width * 0.3,
                      decoration: BoxDecoration(
                        color: const Color(0xfff5f5f5),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(5),
                            width: MediaQuery.of(context).size.width * 0.52,
                            child: Text(
                              FlutterI18n.translate(context, "dashboard"),
                              style: headText2.copyWith(
                                  color: black, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Visibility(
                            visible: model.memberTypeCode == 1,
                            child: Container(
                              child: Text(
                                  FlutterI18n.translate(context, "vipMember"),
                                  style:
                                      headText5.copyWith(color: primaryColor)),
                            ),
                          ),
                          Visibility(
                            visible: model.memberTypeCode == 2,
                            child: Container(
                              child: Text(
                                FlutterI18n.translate(context, "basicMember"),
                                style: headText3.copyWith(color: primaryColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    FlutterI18n.translate(context, "payCoolVipClub"),
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff333333)),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.width * 0.12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: MediaQuery.of(context).size.width * 0.2,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                            image: AssetImage(
                          "assets/images/club/crown.png",
                        )),
                        color: const Color(0xffeeeeee),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ClubDashboardViewModel>.reactive(
        viewModelBuilder: () => ClubDashboardViewModel(),
        onModelReady: (model) async {
          model.context = context;
          model.init();
        },
        builder: (context, ClubDashboardViewModel model, child) {
          SliverPersistentHeader makeHeader() {
            return SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                    minHeight: 60.0,
                    maxHeight: 200.0,
                    child: SliverAnimatedList(itemBuilder:
                        (BuildContext context, int index, Animation animation) {
                      return Container(
                        padding: const EdgeInsets.all(15),
                        child: Column(children: [
                          model.storageService.language == 'en'
                              ? Text(model.projects[index].name.en)
                              : Text(model.projects[index].name.sc)
                        ]),
                      );
                    })));
          }

          return Scaffold(
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
                                      "assets/images/shared/blur-background.png"))),
                          child: CustomScrollView(
                            slivers: [
                              SliverToBoxAdapter(
                                  child: UIHelper.verticalSpaceLarge),
                              // makeHeader(),

                              // SliverList(
                              //     delegate: SliverChildBuilderDelegate(
                              //   (context, index) {
                              //     return Container(
                              //       padding: EdgeInsets.all(15),
                              //       child: Column(children: [
                              //         model.storageService.language == 'en'
                              //             ? Text(model.projects[index].name.en)
                              //             : Text(model.projects[index].name.sc)
                              //       ]),
                              //     );
                              //   },
                              //   childCount: model.projects.length,
                              // )),
                              model.isBusy
                                  ? SliverToBoxAdapter(
                                      child: model.sharedService
                                          .loadingIndicator())
                                  : SliverToBoxAdapter(
                                      child: Container(
                                        color: secondaryColor,
                                        height: model.isValidMember ? 200 : 400,
                                        child: Stack(
                                          children: [
                                            SizedBox(
                                              height: 200, // card height
                                              child: PageView.builder(
                                                itemCount:
                                                    model.projects.length,
                                                controller: PageController(
                                                    viewportFraction: 0.7),
                                                onPageChanged: (int index) =>
                                                    model.updateProjectIndex(
                                                        index),
                                                itemBuilder: (_, i) {
                                                  return Transform.scale(
                                                    scale:
                                                        i == model.projectIndex
                                                            ? 1
                                                            : 0.9,
                                                    child: Card(
                                                      color: Colors.transparent,
                                                      elevation: 6,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20)),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                                borderRadius: const BorderRadius
                                                                        .all(
                                                                    Radius
                                                                        .circular(
                                                                            10)),
                                                                gradient:
                                                                    LinearGradient(
                                                                        colors: [
                                                                          primaryColor,
                                                                          primaryColor
                                                                              .withAlpha(155),
                                                                        ],
                                                                        begin: const FractionalOffset(
                                                                            0.0,
                                                                            0.0),
                                                                        end: const FractionalOffset(
                                                                            1.0,
                                                                            0.0),
                                                                        stops: [
                                                                          0.0,
                                                                          1.0
                                                                        ],
                                                                        tileMode:
                                                                            TileMode.clamp)),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets.all(8.0),
                                                                  child: Image.network(
                                                                    model
                                                                        .projects[
                                                                            model
                                                                                .projectIndex]
                                                                        .image
                                                                        .toString(),
                                                                    width: 25,
                                                                    height: 25,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  model.storageService
                                                                              .language ==
                                                                          'en'
                                                                      ? model
                                                                          .projects[model
                                                                              .projectIndex]
                                                                          .name
                                                                          .en
                                                                      : model
                                                                          .projects[
                                                                              model.projectIndex]
                                                                          .name
                                                                          .sc,
                                                                  style:
                                                                      headText1,
                                                                ),
                                                              ],
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                model.storageService
                                                                            .language ==
                                                                        'en'
                                                                    ? model
                                                                        .projects[model
                                                                            .projectIndex]
                                                                        .description
                                                                        .en
                                                                    : model
                                                                        .projects[
                                                                            model.projectIndex]
                                                                        .description
                                                                        .sc,
                                                                style:
                                                                    headText2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                            UIHelper
                                                                .verticalSpaceSmall,
                                                            SizedBox(
                                                              width: 150,
                                                              child:
                                                                  ElevatedButton(
                                                                      style:
                                                                          outlinedButtonStyles2,
                                                                      onPressed:
                                                                          () {
                                                                        model.goToProjectDetails(model
                                                                            .projects[model.projectIndex]
                                                                            .sId);
                                                                      },
                                                                      child:
                                                                          Text(
                                                                        'Join',
                                                                        style: headText4.copyWith(
                                                                            color:
                                                                                secondaryColor),
                                                                      )),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            // ListView.builder(
                                            //     physics:
                                            //         const PageScrollPhysics(),
                                            //     shrinkWrap: true,
                                            //     itemCount:
                                            //         model.projects.length,
                                            //     scrollDirection:
                                            //         Axis.horizontal,
                                            //     itemBuilder:
                                            //         (BuildContext context,
                                            //             int index) {
                                            //       return Row(
                                            //         children: [
                                            //           Container(
                                            //             width: MediaQuery.of(
                                            //                         context)
                                            //                     .size
                                            //                     .width -
                                            //                 10,
                                            //             decoration: BoxDecoration(
                                            //                 image: DecorationImage(
                                            //                     colorFilter:
                                            //                         ColorFilter
                                            //                             .linearToSrgbGamma(),
                                            //                     opacity: 0.5,
                                            //                     fit: BoxFit
                                            //                         .cover,
                                            //                     image: NetworkImage(model
                                            //                         .projects[
                                            //                             index]
                                            //                         .image))),
                                            //             padding:
                                            //                 const EdgeInsets
                                            //                     .all(15),
                                            //             child: Row(
                                            //               mainAxisAlignment:
                                            //                   MainAxisAlignment
                                            //                       .spaceBetween,
                                            //               crossAxisAlignment:
                                            //                   CrossAxisAlignment
                                            //                       .center,
                                            //               children: [
                                            //                 Column(
                                            //                     mainAxisAlignment:
                                            //                         MainAxisAlignment
                                            //                             .center,
                                            //                     crossAxisAlignment:
                                            //                         CrossAxisAlignment
                                            //                             .start,
                                            //                     children: [
                                            //                       Text(
                                            //                         model.storageService.language ==
                                            //                                 'en'
                                            //                             ? model
                                            //                                 .projects[
                                            //                                     index]
                                            //                                 .name
                                            //                                 .en
                                            //                             : model
                                            //                                 .projects[index]
                                            //                                 .name
                                            //                                 .sc,
                                            //                         style:
                                            //                             headText1,
                                            //                       ),
                                            //                       Text(
                                            //                         model.storageService.language ==
                                            //                                 'en'
                                            //                             ? model
                                            //                                 .projects[
                                            //                                     index]
                                            //                                 .description
                                            //                                 .en
                                            //                             : model
                                            //                                 .projects[index]
                                            //                                 .description
                                            //                                 .sc,
                                            //                         style:
                                            //                             headText2,
                                            //                       )
                                            //                     ]),
                                            //                 SizedBox(
                                            //                   width: 150,
                                            //                   child:
                                            //                       ElevatedButton(
                                            //                           style:
                                            //                               generalButtonStyle1,
                                            //                           onPressed:
                                            //                               () {
                                            //                             model.goToProjectDetails(model
                                            //                                 .projects[index]
                                            //                                 .sId);
                                            //                           },
                                            //                           child:
                                            //                               Text(
                                            //                             'Join',
                                            //                             style: headText4.copyWith(
                                            //                                 color:
                                            //                                     secondaryColor),
                                            //                           )),
                                            //                 )
                                            //               ],
                                            //             ),
                                            //           ),
                                            //         ],
                                            //       );
                                            //     }),
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 10),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  for (var i = 0;
                                                      i < model.projects.length;
                                                      i++)
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(2.0),
                                                      child: Align(
                                                          alignment: Alignment
                                                              .bottomCenter,
                                                          child: Icon(
                                                            Icons
                                                                .ac_unit_outlined,
                                                            color:
                                                                model.projectIndex ==
                                                                        i
                                                                    ? white
                                                                    : grey,
                                                            size: 12,
                                                          )),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                              model.isValidMember
                                  ? SliverToBoxAdapter(
                                      child: Container(
                                        child: Column(
                                          children: [
                                            UIHelper.verticalSpaceLarge,
                                            // !model.isValidMember
                                            //     ? Container()
                                            //     : topPaycoolWidget(
                                            //         context, model),
                                            //display myReferralCode when this user is a basic or VIP member
                                            Container(
                                              decoration: roundedBoxDecoration(
                                                  color: secondaryColor),
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
                                                  Visibility(
                                                    visible:
                                                        model.isValidMember,
                                                    child: ListTile(
                                                      horizontalTitleGap: 0,
                                                      leading: const Icon(
                                                        Icons.link,
                                                        color: black,
                                                        size: 18,
                                                      ),
                                                      title: Text(
                                                        FlutterI18n.translate(
                                                            context,
                                                            "myReferralCode"),
                                                        style: headText4,
                                                      ),
                                                      subtitle: Text(
                                                        model.fabAddress,
                                                        style: bodyText1,
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

                                                  // member type tile
                                                  ListTile(
                                                    horizontalTitleGap: 0,
                                                    leading: const Icon(
                                                      FontAwesomeIcons.user,
                                                      color: primaryColor,
                                                      size: 18,
                                                    ),
                                                    title: Text(
                                                      model.memberType,
                                                      style: headText4,
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

                                                  ListTile(
                                                    onTap: () => model
                                                        .navigationService
                                                        .navigateTo(
                                                            clubRewardsViewRoute,
                                                            arguments: model
                                                                .dashboard
                                                                .summary),
                                                    horizontalTitleGap: 0,
                                                    leading: const Icon(
                                                      Icons
                                                          .monetization_on_outlined,
                                                      color: black,
                                                      size: 18,
                                                    ),
                                                    title: Text(
                                                      FlutterI18n.translate(
                                                          context, "rewards"),
                                                      style: headText4,
                                                    ),
                                                    subtitle: SizedBox(
                                                      width: 50,
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                  'FAB'
                                                                          ' ' +
                                                                      model
                                                                          .dashboard
                                                                          .totalFabRewards()[
                                                                              'FAB']
                                                                          .toString(),
                                                                  style:
                                                                      headText5),
                                                              Text(
                                                                  'FET'
                                                                          ' ' +
                                                                      model
                                                                          .dashboard
                                                                          .totalFabRewards()[
                                                                              "FET"]
                                                                          .toString(),
                                                                  style:
                                                                      headText5),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    trailing: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          'Projects joined  ',
                                                          style: headText5,
                                                        ),
                                                        Text(
                                                          model.dashboard
                                                              .summary.length
                                                              .toString(),
                                                          style: headText5,
                                                        ),
                                                        UIHelper
                                                            .horizontalSpaceSmall,
                                                        const Icon(
                                                          Icons
                                                              .arrow_forward_ios,
                                                          color: grey,
                                                          size: 16,
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  InkWell(
                                                    onTap: () => model
                                                        .navigationService
                                                        .navigateTo(
                                                            PayCoolClubReferralViewRoute),
                                                    child: ListTile(
                                                        horizontalTitleGap: 0,
                                                        leading: const Icon(
                                                          Icons
                                                              .call_split_outlined,
                                                          color: black,
                                                          size: 18,
                                                        ),
                                                        title: Text(
                                                          FlutterI18n.translate(
                                                              context,
                                                              "myReferralsDetails"),
                                                          style: headText4
                                                              .copyWith(
                                                                  color: black),
                                                        ),
                                                        trailing: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                  model.referralCount
                                                                          .toString() ??
                                                                      '0',
                                                                  style:
                                                                      headText5),
                                                            ),
                                                            const Icon(
                                                              Icons
                                                                  .arrow_forward_ios,
                                                              color: grey,
                                                              size: 16,
                                                            ),
                                                          ],
                                                        )),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : SliverToBoxAdapter(
                                      child: Container(
                                        child: const Center(
                                          child:
                                              Text('YOU ARE NOT A MEMBER YET'),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
            bottomNavigationBar: BottomNavBar(count: 0),
          );
        });
  }
}
