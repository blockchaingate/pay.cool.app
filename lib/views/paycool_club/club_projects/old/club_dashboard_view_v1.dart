// import 'package:flutter_i18n/flutter_i18n.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:paycool/constants/colors.dart';
// import 'package:paycool/constants/custom_styles.dart';
// import 'package:paycool/constants/route_names.dart';
// import 'package:paycool/constants/ui_var.dart';
// import 'package:paycool/views/paycool_club/club_dashboard_viewmodel.dart';
// import 'package:paycool/shared/ui_helpers.dart';
// import 'package:paycool/widgets/bottom_nav.dart';
// import 'package:flutter/material.dart';
// import 'package:paycool/widgets/server_error_widget.dart';
// import 'package:stacked/stacked.dart';

// import '../../constants/colors.dart';

// class PayCoolClubDashboardView extends StatelessWidget {
//   const PayCoolClubDashboardView({Key key}) : super(key: key);

//   topPaycoolWidget(context, ClubDashboardViewModel model) {
//     return Column(
//       children: [
//         // SizedBox(height: 30),
//         //join button conatiner
//         Container(
//           width: MediaQuery.of(context).size.width,
//           height: MediaQuery.of(context).size.width < largeSize
//               ? MediaQuery.of(context).size.width * 0.6
//               : largeSize * 0.8,
//           // decoration: const BoxDecoration(
//           //     image: DecorationImage(
//           //         image:
//           //             AssetImage("assets/images/shared/blur-background.png"))),
//           child: Container(
//             child: Stack(
//               children: [
//                 Positioned(
//                   top: MediaQuery.of(context).size.width * 0.32,
//                   left: 0,
//                   right: 0,
//                   child: Center(
//                     child: Container(
//                       width: MediaQuery.of(context).size.width * 0.65,
//                       height: MediaQuery.of(context).size.width < largeSize
//                           ? MediaQuery.of(context).size.width * 0.17
//                           : MediaQuery.of(context).size.width * 0.3,
//                       decoration: BoxDecoration(
//                         color: const Color(0xfff5f5f5),
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         mainAxisSize: MainAxisSize.max,
//                         children: [
//                           Container(
//                             alignment: Alignment.center,
//                             padding: const EdgeInsets.all(5),
//                             width: MediaQuery.of(context).size.width * 0.52,
//                             child: Text(
//                               FlutterI18n.translate(context, "dashboard"),
//                               style: headText2.copyWith(
//                                   color: black, fontWeight: FontWeight.w500),
//                             ),
//                           ),
//                           Visibility(
//                             visible: model.memberTypeCode == 1,
//                             child: Container(
//                               child: Text(
//                                   FlutterI18n.translate(context, "vipMember"),
//                                   style:
//                                       headText5.copyWith(color: primaryColor)),
//                             ),
//                           ),
//                           Visibility(
//                             visible: model.memberTypeCode == 2,
//                             child: Container(
//                               child: Text(
//                                 FlutterI18n.translate(context, "basicMember"),
//                                 style: headText3.copyWith(color: primaryColor),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 Align(
//                   alignment: Alignment.topCenter,
//                   child: Text(
//                     FlutterI18n.translate(context, "payCoolVipClub"),
//                     style: const TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xff333333)),
//                   ),
//                 ),
//                 Positioned(
//                   top: MediaQuery.of(context).size.width * 0.12,
//                   left: 0,
//                   right: 0,
//                   child: Center(
//                     child: Container(
//                       padding: const EdgeInsets.all(3),
//                       width: MediaQuery.of(context).size.width * 0.2,
//                       height: MediaQuery.of(context).size.width * 0.2,
//                       decoration: BoxDecoration(
//                         image: const DecorationImage(
//                             image: AssetImage(
//                           "assets/images/club/crown.png",
//                         )),
//                         color: const Color(0xffeeeeee),
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),

//         // !model.isClubMember ? generateQR(context, model) : Container()
//         // UIHelper.divider,
//         // UIHelper.verticalSpaceMedium,
//         // Text(
//         //     AppLocalizations.of(context)
//         //         .notJoinedPaycoolClub,
//         //     style: headText3),
//         // UIHelper.verticalSpaceSmall,
//         // ElevatedButton(
//         //   style: ButtonStyle(
//         //       backgroundColor:
//         //           MaterialStateProperty
//         //               .all(
//         //                   primaryColor)),
//         //   child: Text(
//         //     AppLocalizations.of(context)
//         //         .clickToJoin,
//         //     style: headText3,
//         //   ),
//         //   onPressed: () {
//         //     model.navigationService
//         //         .navigateTo(
//         //             JoinPayCoolClubViewRoute);
//         //     //  model.joinClub();
//         //   },
//         // ),
//       ],
//     );
//   }

//   generateQR(context, model) {
//     return Column(
//       children: <Widget>[
//         Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Text(
//                 FlutterI18n.translate(context, "generateQrCodeToScanAndPay"),
//                 style: headText5)),
//         UIHelper.verticalSpaceSmall,
//         SizedBox(
//           width: MediaQuery.of(context).size.width * 0.52,
//           child: ElevatedButton(
//             style: ButtonStyle(
//                 backgroundColor: MaterialStateProperty.all(Colors.lightBlue)),
//             child: Text(
//               FlutterI18n.translate(context, "generateQrCode"),
//               style: headText3.copyWith(
//                   color: secondaryColor, fontWeight: FontWeight.w500),
//             ),
//             onPressed: () {
//               model.navigationService.navigateTo(GenerateCustomQrViewRoute);
//               //  model.joinClub();
//             },
//           ),
//         ),
//         UIHelper.verticalSpaceMedium,
//       ],
//     );
//   }

//   scanToPay(context, model) {
//     return Container(
//       child: Column(
//         children: <Widget>[
//           UIHelper.divider,
//           UIHelper.verticalSpaceSmall,
//           Container(
//             // width: MediaQuery.of(context).size.width * 0.52,
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Text(
//               FlutterI18n.translate(context, "scanToPayMessage"),
//               style: headText5,
//             ),
//           ),

//           // UIHelper.verticalSpaceSmall,
//           SizedBox(
//             width: MediaQuery.of(context).size.width * 0.52,
//             child: ElevatedButton(
//               style: ButtonStyle(
//                   backgroundColor: MaterialStateProperty.all(yellow)),
//               child: Text(
//                 FlutterI18n.translate(context, "scanToPay"),
//                 style: headText3.copyWith(
//                     color: black, fontWeight: FontWeight.w500),
//               ),
//               onPressed: () {
//                 model.scanBarCode();
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   bindpayUI(context, model) {
//     return Container(
//       child: Column(
//         children: [
//           UIHelper.divider,
//           UIHelper.verticalSpaceSmall,
//           Container(
//             // width: MediaQuery.of(context).size.width * 0.52,
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Text(
//               FlutterI18n.translate(context, "lightningRemit") +
//                   ' ' +
//                   FlutterI18n.translate(context, "receiveAddress"),
//               style: headText5,
//             ),
//           ),
//           const SizedBox(
//             height: 20,
//           ),
//           SizedBox(
//             width: MediaQuery.of(context).size.width * 0.52,
//             child: ElevatedButton(
//               style: ButtonStyle(
//                   backgroundColor: MaterialStateProperty.all(primaryColor)),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     FlutterI18n.translate(context, "lightningRemit"),
//                     style: headText3,
//                   ),
//                   // Text(
//                   //   FlutterI18n.translate(context, "LightningRemit") +
//                   //       ' ' +
//                   //       AppLocalizations.of(context)
//                   //           .receiveAddress,
//                   //   style: headText3,
//                   // ),
//                   // UIHelper.horizontalSpaceSmall,
//                   // Icon(Icons.qr_code)
//                 ],
//               ),
//               onPressed: () {
//                 model.showLightningRemitBarcode();
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ViewModelBuilder<ClubDashboardViewModel>.reactive(
//         viewModelBuilder: () => ClubDashboardViewModel(),
//         onModelReady: (model) async {
//           model.context = context;
//           model.init();
//         },
//         builder: (context, ClubDashboardViewModel model, child) {
//           return Scaffold(
//             body: model.isServerDown
//                 ? const Center(child: ServerErrorWidget())
//                 : model.isBusy
//                     ? model.sharedService.loadingIndicator()
//                     : WillPopScope(
//                         onWillPop: () {
//                           model.onBackButtonPressed();

//                           return Future(() => false);
//                         },
//                         child: Container(
//                           decoration: const BoxDecoration(
//                               image: DecorationImage(
//                                   fit: BoxFit.cover,
//                                   image: AssetImage(
//                                       "assets/images/shared/blur-background.png"))),
//                           // color: secondaryColor,
//                           //alignment: Alignment.center,
//                           child: ListView(
//                             children: [
//                               // Check if members are being accepting
//                               model.isAcceptingMembers
//                                   // if above is true then check if club member is true
//                                   ? model.isValidMember
//                                       // if above is true then show nothing
//                                       ? Container()
//                                       : //run this if not a member

//                                       /// if not member then
//                                       /// check its own fab address is not valid referral
//                                       ///  and
//                                       /// storage receipt is not null
//                                       /// if above true it means user placed order
//                                       /// and order in progress
//                                       !model.isValidMember &&
//                                               model.storageService
//                                                       .payCoolClubPaymentReceipt !=
//                                                   null
//                                           ? Center(
//                                               child: Text(
//                                                 FlutterI18n.translate(
//                                                     context, "inProgress"),
//                                                 style: headText2,
//                                               ),
//                                             )
//                                           :

//                                           /// if above is false then
//                                           /// it means user is not member
//                                           /// then app checks
//                                           // if txReceipt is not null then never shows join button
//                                           // otherwise show join button
//                                           model.storageService
//                                                       .payCoolClubPaymentReceipt !=
//                                                   null
//                                               ? Container()
//                                               : // Show join club button if not member
//                                               topPaycoolWidget(context, model)
//                                   // if club is not accepting new members then show below text
//                                   : Container(
//                                       child: Center(
//                                           child: Text(FlutterI18n.translate(
//                                               context,
//                                               "noNewMembersBeingAccepted")))),
//                               UIHelper.verticalSpaceSmall,

//                               !model.isValidMember && !model.isBusy
//                                   ? Column(
//                                       children: [
//                                         SizedBox(
//                                           width: MediaQuery.of(context)
//                                                   .size
//                                                   .width *
//                                               0.52,
//                                           child: ElevatedButton(
//                                             style: ButtonStyle(
//                                                 backgroundColor:
//                                                     MaterialStateProperty.all(
//                                                         primaryColor)),
//                                             child: Center(
//                                               child: Text(
//                                                 FlutterI18n.translate(
//                                                     context, "Upgrade to VIP"),
//                                                 style: headText3.copyWith(
//                                                     fontWeight:
//                                                         FontWeight.bold),
//                                               ),
//                                             ),
//                                             onPressed: () {
//                                               model.navigationService
//                                                   .navigateTo(
//                                                       JoinPayCoolClubViewRoute);
//                                               //  model.joinClub();
//                                             },
//                                           ),
//                                         ),
//                                         Container(
//                                           alignment: Alignment.bottomCenter,
//                                           margin: const EdgeInsets.all(20),
//                                           padding: const EdgeInsets.symmetric(
//                                               horizontal: 10, vertical: 8),
//                                           child: Column(
//                                             children: [
//                                               Text(
//                                                 FlutterI18n.translate(context,
//                                                     "joinPayCoolVipClubPNote"),
//                                                 style: headText5,
//                                               ),
//                                               UIHelper.verticalSpaceSmall,
//                                               Text(
//                                                 FlutterI18n.translate(
//                                                     context, "paycoolNote"),
//                                                 style: subText2,
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     )
//                                   : Container(),

//                               // if no star pay member
//                               !model.isPayMember && !model.isBusy
//                                   ? Container(
//                                       alignment: Alignment.bottomCenter,
//                                       margin: const EdgeInsets.all(20),
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 10, vertical: 8),
//                                       child: Column(
//                                         children: [
//                                           ElevatedButton(
//                                             onPressed: () => model
//                                                 .navigationService
//                                                 .navigateTo(PayCoolViewRoute),
//                                             child: Text(
//                                               FlutterI18n.translate(
//                                                   context, "joinPayCoolButton"),
//                                               style: headText4,
//                                             ),
//                                           ),
//                                           UIHelper.verticalSpaceSmall,
//                                           Text(
//                                             FlutterI18n.translate(
//                                                 context, "joinPayCoolNote"),
//                                             style: headText5,
//                                           ),
//                                         ],
//                                       ),
//                                     )
//                                   : Container(),

//                               //get free fab button
//                               !model.isFreeFabAvailable
//                                   ? Container()
//                                   : Column(
//                                       children: [
//                                         SizedBox(
//                                           width: MediaQuery.of(context)
//                                                   .size
//                                                   .width *
//                                               0.52,
//                                           child: ElevatedButton(
//                                             style: ButtonStyle(
//                                                 backgroundColor:
//                                                     MaterialStateProperty.all(
//                                                         primaryColor)),
//                                             child: Center(
//                                               child: Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.center,
//                                                 children: [
//                                                   const Icon(
//                                                     Icons.add,
//                                                     size: 14,
//                                                     color: white,
//                                                   ),
//                                                   Text(
//                                                     FlutterI18n.translate(
//                                                             context,
//                                                             "getFree") +
//                                                         FlutterI18n.translate(
//                                                             context, "gas"),
//                                                     style: headText3.copyWith(
//                                                         fontWeight:
//                                                             FontWeight.bold),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                             onPressed: model.getFreeFab,
//                                           ),
//                                         ),
//                                       ],
//                                     ),

//                               // check if user is not a member in both club and pay
//                               // then just display two buttons to join for both
//                               !model.isValidMember && !model.isPayMember
//                                   ? Container()
//                                   // Show Dashboard if club member is true
//                                   : model.dashboard == null
//                                       ? Container(
//                                           child: Center(
//                                             child: Column(
//                                               children: [
//                                                 Text(FlutterI18n.translate(
//                                                     context, "serverError")),
//                                                 Text(FlutterI18n.translate(
//                                                     context,
//                                                     "pleaseTryAgainLater")),
//                                               ],
//                                             ),
//                                           ),
//                                         )
//                                       : Container(
//                                           child: Column(
//                                             children: [
//                                               model.isPayMember
//                                                   ? UIHelper.verticalSpaceMedium
//                                                   : Container(),
//                                               model.isPayMember &&
//                                                       !model.isValidMember
//                                                   ? Container()
//                                                   : topPaycoolWidget(
//                                                       context, model),
//                                               //display myReferralCode when this user is a basic or VIP member
//                                               Container(
//                                                 decoration:
//                                                     roundedBoxDecoration(
//                                                         color: secondaryColor),
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                         vertical: 10,
//                                                         horizontal: 2),
//                                                 margin:
//                                                     const EdgeInsets.symmetric(
//                                                         vertical: 2,
//                                                         horizontal: 15),
//                                                 // color: secondaryColor,
//                                                 child: Column(
//                                                   children: [
//                                                     Visibility(
//                                                       visible:
//                                                           model.isPayMember,
//                                                       child: ListTile(
//                                                         horizontalTitleGap: 0,
//                                                         leading: const Icon(
//                                                           Icons.link,
//                                                           color: black,
//                                                           size: 18,
//                                                         ),
//                                                         title: Text(
//                                                           FlutterI18n.translate(
//                                                               context,
//                                                               "myReferralCode"),
//                                                           style: headText4,
//                                                         ),
//                                                         subtitle: Text(
//                                                           model.fabAddress,
//                                                           style: bodyText1,
//                                                         ),
//                                                         trailing: Row(
//                                                           mainAxisSize:
//                                                               MainAxisSize.min,
//                                                           children: [
//                                                             IconButton(
//                                                               icon: const Icon(
//                                                                 Icons.copy,
//                                                                 size: 19,
//                                                                 color: black,
//                                                               ),
//                                                               onPressed: () => model
//                                                                   .sharedService
//                                                                   .copyAddress(
//                                                                       context,
//                                                                       model
//                                                                           .fabAddress),
//                                                             ),
//                                                             IconButton(
//                                                               icon: const Icon(
//                                                                 Icons
//                                                                     .share_outlined,
//                                                                 size: 19,
//                                                                 color:
//                                                                     primaryColor,
//                                                               ),
//                                                               onPressed: () => model
//                                                                   .showBarcode(),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ),
//                                                     ),

//                                                     // member type tile
//                                                     ListTile(
//                                                         horizontalTitleGap: 0,
//                                                         leading: const Icon(
//                                                           FontAwesomeIcons.user,
//                                                           color: primaryColor,
//                                                           size: 18,
//                                                         ),
//                                                         title: Text(
//                                                           FlutterI18n.translate(
//                                                               context,
//                                                               "memberType"),
//                                                           style: headText4,
//                                                         ),
//                                                         trailing: Text(
//                                                           model.dashboard
//                                                               .memberType
//                                                               .toString(),
//                                                           style: headText5,
//                                                         )),
//                                                     // joined date tile
//                                                     ListTile(
//                                                       horizontalTitleGap: 0,
//                                                       leading: const Icon(
//                                                         Icons
//                                                             .stacked_line_chart_sharp,
//                                                         color: black,
//                                                         size: 18,
//                                                       ),
//                                                       title: Text(
//                                                         FlutterI18n.translate(
//                                                             context,
//                                                             "joinedDate"),
//                                                         style: headText4,
//                                                       ),
//                                                       trailing: Text(
//                                                           model.dashboard
//                                                               .dateCreated,
//                                                           style: headText5),
//                                                     ),
//                                                     // asset value tile
//                                                     ListTile(
//                                                         horizontalTitleGap: 0,
//                                                         leading: const Icon(
//                                                           Icons
//                                                               .monetization_on_outlined,
//                                                           color: black,
//                                                           size: 18,
//                                                         ),
//                                                         title: Text(
//                                                           FlutterI18n.translate(
//                                                               context,
//                                                               "assetTotalValue"),
//                                                           style: headText4,
//                                                         ),
//                                                         trailing: Text(
//                                                             '\$' +
//                                                                 model.dashboard
//                                                                     .totalPaycoolAssets
//                                                                     .toStringAsFixed(
//                                                                         2),
//                                                             style: headText5)),
//                                                     // ListTile(
//                                                     //   horizontalTitleGap: 0,
//                                                     //   leading: Icon(
//                                                     //     Icons.place_outlined,
//                                                     //     color: white,
//                                                     //     size: 18,
//                                                     //   ),
//                                                     //   title: Text(
//                                                     //     'Region',
//                                                     //     style: Theme.of(context)
//                                                     //         .textTheme
//                                                     //         .headText4,
//                                                     //   ),
//                                                     //   trailing: Text('USA'),
//                                                     // ),
//                                                     InkWell(
//                                                       onTap: () => model
//                                                           .navigationService
//                                                           .navigateTo(
//                                                               PayCoolClubReferralViewRoute),
//                                                       child: ListTile(
//                                                           horizontalTitleGap: 0,
//                                                           leading: const Icon(
//                                                             Icons
//                                                                 .call_split_outlined,
//                                                             color: black,
//                                                             size: 18,
//                                                           ),
//                                                           title: Text(
//                                                             FlutterI18n.translate(
//                                                                 context,
//                                                                 "myReferralsDetails"),
//                                                             style: headText4
//                                                                 .copyWith(
//                                                                     color:
//                                                                         black),
//                                                           ),
//                                                           trailing: Row(
//                                                             mainAxisSize:
//                                                                 MainAxisSize
//                                                                     .min,
//                                                             children: [
//                                                               Padding(
//                                                                 padding:
//                                                                     const EdgeInsets
//                                                                             .all(
//                                                                         8.0),
//                                                                 child: Text(
//                                                                     model.referralCount
//                                                                             .toString() ??
//                                                                         '0',
//                                                                     style:
//                                                                         headText5),
//                                                               ),
//                                                               const Icon(
//                                                                 Icons
//                                                                     .arrow_forward_ios,
//                                                                 color: grey,
//                                                                 size: 16,
//                                                               ),
//                                                             ],
//                                                           )),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),

//                               UIHelper.verticalSpaceMedium,

//                               // Container(
//                               //     margin: EdgeInsets.symmetric(
//                               //         vertical: 8.0, horizontal: 20),
//                               //     decoration: BoxDecoration(
//                               //         color: primaryColor,
//                               //         border: Border.all(
//                               //             color: secondaryColor, width: 1),
//                               //         borderRadius: BorderRadius.only(
//                               //             topLeft: Radius.circular(50),
//                               //             bottomRight: Radius.circular(50))),
//                               //     child: ElevatedButton(
//                               //       style: ButtonStyle(
//                               //         shape: MaterialStateProperty.all(
//                               //             RoundedRectangleBorder(
//                               //                 borderRadius: BorderRadius.only(
//                               //                     topLeft: Radius.circular(45),
//                               //                     bottomRight:
//                               //                         Radius.circular(45)))),
//                               //         backgroundColor:
//                               //             MaterialStateProperty.all(
//                               //                 secondaryColor),
//                               //       ),
//                               //       child: Row(
//                               //         mainAxisAlignment:
//                               //             MainAxisAlignment.center,
//                               //         children: [
//                               //           Icon(
//                               //             Icons.add,
//                               //             size: 14,
//                               //             color: white,
//                               //           ),
//                               //           Text(
//                               //             FlutterI18n.translate(
//                               //                     context, "getFree") +
//                               //                 ' FAB',
//                               //             style: headText5.copyWith(
//                               //                 fontWeight: FontWeight.w400),
//                               //           )
//                               //         ],
//                               //       ),
//                               //       onPressed: model.getFreeFab,
//                               //     )),
//                               UIHelper.verticalSpaceMedium,
//                             ],
//                           ),
//                         ),
//                       ),
//             bottomNavigationBar: BottomNavBar(count: 0),
//           );
//         });
//   }
// }
