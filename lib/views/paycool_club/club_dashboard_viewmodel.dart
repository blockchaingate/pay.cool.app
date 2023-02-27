import 'dart:convert';
import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:paycool/constants/constants.dart';
import 'package:paycool/utils/number_util.dart';
import 'package:paycool/utils/string_util.dart';
import 'package:paycool/views/paycool_club/club_dashboard_model.dart';
import 'package:paycool/views/paycool_club/club_projects/models/club_project_model.dart';

import 'package:qr_flutter/qr_flutter.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/environments/environment.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/api_service.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/services/navigation_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:paycool/utils/barcode_util.dart';
import 'package:paycool/views/paycool_club/referral/referral_model.dart';
import 'package:paycool/views/paycool_club/paycool_club_service.dart';
import 'package:paycool/views/paycool_club/join_club/join_club_payment_model.dart';

import 'package:share_plus/share_plus.dart';
import 'package:stacked/stacked.dart';
import 'package:paycool/services/db/wallet_database_service.dart';
import 'package:paycool/services/local_dialog_service.dart';
import '../../models/wallet/wallet.dart';
import '../../services/wallet_service.dart';

class ClubDashboardViewModel extends BaseViewModel {
  final log = getLogger('PayCoolClubDashboardViewModel');
  final apiService = locator<ApiService>();
  final sharedService = locator<SharedService>();
  final walletService = locator<WalletService>();
  final dialogService = locator<LocalDialogService>();
  final clubService = locator<PayCoolClubService>();
  final walletDatabaseService = locator<WalletDatabaseService>();
  final navigationService = locator<NavigationService>();
  final storageService = locator<LocalStorageService>();
  List<ClubProject> projects = [];
  BuildContext? context;
  bool isDialogUp = false;
  bool isDUSD = false;
  int gasPrice = environment["chains"]["FAB"]["gasPrice"] ?? 0;
  int gasLimit = environment["chains"]["FAB"]["gasLimitToken"] ?? 0;
  double fee = 0.0;

  String usdtOfficialAddress = '';

  String usdtWalletAddress = '';
  double usdtWalletBalance = 0.0;

  String dusdWalletAddress = '';
  double dusdWalletBalance = 0.0;

  WalletInfo? walletInfo;
  String txHash = '';
  String errorMessage = '';
  String fabAddress = '';

  List<PaycoolReferral> children = [];
  TextEditingController refereeReferralCode = TextEditingController();
  bool isEnoughDusdWalletBalance = true;
  bool isValidMember = false;
  GlobalKey globalKey = GlobalKey(debugLabel: 'showBarcode');
  // GlobalKey globalKey2 = GlobalKey(debugLabel: 'lightening');
  ClubDashboard dashboardSummary = ClubDashboard();
  JoinClubPaymentModel scanToPayModel = JoinClubPaymentModel();
  bool isValidClubReferralCode = false;
  bool isFreeFabAvailable = false;
  final freeFabAnswerTextController = TextEditingController();
  String postFreeFabResult = '';
  double gasAmount = 0.0;

  int memberTypeCode = 0;

  int referralCount = 0;
  bool isServerDown = false;
  bool isAcceptingMembers = false;
  int projectIndex = 0;

  List<Project> joinedProjects = [];
  Map<String, Decimal> rewardTokenPriceMap = {};
  Decimal totatRewardDollarVal = Constants.decimalZero;
  Decimal totalPaycoolRewardDollarVal = Constants.decimalZero;
  bool isShowExpiredWarning = false;

  void init() async {
    setBusy(true);
    fabAddress = await sharedService.getFabAddressFromCoreWalletDatabase();

    await memberValidation();
    log.e('isClubMember : $isValidMember');
    if (isValidMember) {
      try {
        await getDashboardSummary();
        await getReferralCount();
      } catch (err) {
        log.e('catch during dashboard details or get children $err');
      }
    }

    await checkGas();

    if (gasAmount == 0.0) await checkFreeFabForNewWallet();

    // total rewards calc
    if (isValidMember)
      // ignore: curly_braces_in_flow_control_structures
      for (var summary in dashboardSummary.summary!) {
        for (var reward in summary.totalReward!) {
          if (reward.coin != null) {
            try {
              // reward token price
              var rtp = await clubService.getPriceOfRewardToken(reward.coin!);
              if (summary.project!.en == 'Paycool') {
                totalPaycoolRewardDollarVal = NumberUtil.decimalLimiter(
                    reward.amount! * rtp,
                    decimalPrecision: 8);
              }
              if (reward.coin == "FETDUSD-LP" || reward.coin == "UnknownCoin") {
                reward.amount =
                    NumberUtil.rawStringToDecimal(reward.amount.toString());
              }
              totatRewardDollarVal += NumberUtil.decimalLimiter(
                  reward.amount! * rtp,
                  decimalPrecision: 2);

              rewardTokenPriceMap.addAll({reward.coin!: rtp});
            } catch (err) {
              log.e(
                  'CATCH getPriceOfRewardToken getting price for ${reward.coin}');
            }
          }
        }
      }
    log.e(
        'rewardTokenPriceMap ${rewardTokenPriceMap} --totatRewardDollarVal $totatRewardDollarVal ');

    setBusy(false);
  } // init ends

  // project expiry status
  int expiredProjectInDays(String date) {
    var expiredDate = DateTime.parse(date);
    var diff = expiredDate.difference(DateTime.now());
    return diff.inDays;
  }

// "2023-02-20T16:44:40.663Z"
  bool showExpiredProjectWarning(String date) {
    bool res = false;
    int days = expiredProjectInDays(date);
    if (date.isNotEmpty) {
      if (days < Constants.clubProjectExpireDays &&
          !days.isNegative &&
          days != 0) {
        res = true;
        isShowExpiredWarning = true;
      } else {
        res = false;
        isShowExpiredWarning = false;
      }
    }

    return res;
  }

  removeWarning() {
    setBusyForObject(true, isShowExpiredWarning);
    isShowExpiredWarning = false;
    setBusyForObject(false, isShowExpiredWarning);
  }

  List<Summary> numberOfProjectNotJoined() {
    List<Summary> notJoinedProjects = [];
    for (var su in dashboardSummary.summary!) {
      // if user has not joined the project and project is not pay.cool
      if (su.status == 0 && su.project!.en != 'Paycool') {
        // then add that project to the unjoined project list
        notJoinedProjects.add(su);
      }
    }
    return notJoinedProjects;
  }

  showProjectList() {
    showDialog(
        context: context!,
        builder: (context) {
          return Container(
            child: AlertDialog(
              elevation: 10,
              backgroundColor: white,
              titleTextStyle: headText3.copyWith(color: black),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      // color: grey.withAlpha(125),
                      child: Text(
                        numberOfProjectNotJoined().isNotEmpty
                            ? FlutterI18n.translate(context, "lisOfPrograms")
                            : FlutterI18n.translate(
                                context, "currentlyNoOtherPrograms"),
                        textAlign: TextAlign.center,
                        style: headText3.copyWith(color: black),
                      ),
                    ),
                  ),
                ],
              ),
              contentTextStyle: const TextStyle(color: grey),
              content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < dashboardSummary.summary!.length; i++)
                      dashboardSummary.summary![i].status == 0 &&
                              dashboardSummary.summary![i].project!.en !=
                                  'Paycool' &&
                              (dashboardSummary.summary![i].project!.id != 1 &&
                                  dashboardSummary.summary![i].project!.id != 9)
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${storageService.language == "en" ? dashboardSummary.summary![i].project!.en : dashboardSummary.summary![i].project!.sc}  ',
                                    textAlign: TextAlign.start,
                                    style: headText5.copyWith(
                                        color: black,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                // Flexible(
                                //   child: Text(
                                //     assignMemberType(
                                //         status: dashboardSummary
                                //             .summary![i].status!
                                //             .toInt()),
                                //     textAlign: TextAlign.end,
                                //     style: headText5.copyWith(color: green),
                                //   ),
                                // ),

                                Expanded(
                                  flex: 1,
                                  child: TextButton(
                                    // style: ButtonStyle(
                                    //     shape: shapeRoundBorder,
                                    //     backgroundColor:
                                    //         MaterialStateProperty.all(
                                    //             secondaryColor)),
                                    onPressed: () {
                                      navigationService.navigateTo(
                                          clubProjectDetailsViewRoute,
                                          arguments:
                                              dashboardSummary.summary![i]);
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      FlutterI18n.translate(context, "details"),
                                      style: const TextStyle(
                                          decoration: TextDecoration.underline),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                  ]),
              actions: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: generalButtonStyle(primaryColor),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        FlutterI18n.translate(context, "close"),
                        style: headText5.copyWith(color: white),
                      ),
                    ),
                  ),
                ),
                UIHelper.verticalSpaceSmall
              ],
            ),
          );
        });
  }

  showJoinPaycoolPopup() {
    showDialog(
        context: context!,
        builder: (context) {
          return AlertDialog(
            titleTextStyle: headText3.copyWith(color: black),
            title: Text(
              FlutterI18n.translate(context, "notJoinedPaycool"),
              textAlign: TextAlign.center,
              style: headText3.copyWith(color: black),
            ),
            contentTextStyle: const TextStyle(color: grey),
            content: SizedBox(
              height: 50,
              child: SingleChildScrollView(
                  child: Text(
                FlutterI18n.translate(context, "joinPayCoolNote"),
                style: headText3,
              )),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: generalButtonStyle1,
                        onPressed: () {
                          Navigator.of(context).pop();
                          navigationService.navigateTo(PayCoolViewRoute);
                        },
                        child: Text(
                          FlutterI18n.translate(context, "join"),
                          style: buttonText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              UIHelper.verticalSpaceSmall
            ],
          );
        });
  }

  updateProjectIndex(int i) {
    projectIndex = i;
    notifyListeners();
  }

  checkGas() async {
    String address = await sharedService.getExgAddressFromCoreWalletDatabase();
    await walletService.gasBalance(address).then((data) {
      gasAmount = data;
    }).catchError((onError) => log.e(onError));
    log.w('gas amount $gasAmount');
  }

  checkFreeFabForNewWallet() async {
    var res = await apiService.getFreeFab(fabAddress);
    if (res != null) {
      setBusy(true);
      isFreeFabAvailable = res['ok'];
      setBusy(false);
      log.w('isFreeFabAvailable $isFreeFabAvailable');
    } else {
      log.i('Fab or gas balance available already');
      // storageService.isShowCaseView = false;
    }
  }

  getFreeFab() async {
    String address = await sharedService.getExgAddressFromCoreWalletDatabase();
    await apiService.getFreeFab(address).then((res) {
      if (res != null) {
        if (res['ok']) {
          isFreeFabAvailable = res['ok'];

          showDialog(
              context: context!,
              builder: (context) {
                return Center(
                  child: SizedBox(
                    height: 250,
                    child: ListView(
                      children: [
                        AlertDialog(
                          titlePadding:
                              const EdgeInsets.only(top: 0, bottom: 10),
                          actionsPadding: const EdgeInsets.all(0),
                          elevation: 5,
                          titleTextStyle:
                              headText4.copyWith(fontStyle: FontStyle.italic),
                          contentTextStyle: const TextStyle(color: grey),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10),
                          backgroundColor: walletCardColor.withOpacity(0.95),
                          title: Container(
                            color: secondaryColor,
                            child: Text(
                              FlutterI18n.translate(context, "question"),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          content: Column(
                            children: <Widget>[
                              UIHelper.verticalSpaceSmall,
                              Text(
                                res['_body']['question'].toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        color: red,
                                        fontWeight: FontWeight.bold),
                              ),
                              UIHelper.verticalSpaceSmall,
                              TextField(
                                minLines: 1,
                                maxLines: 1,
                                style: const TextStyle(color: white),
                                controller: freeFabAnswerTextController,
                                obscureText: false,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(3),
                                  isCollapsed: true,
                                  isDense: true,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: primaryColor, width: 1.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: white, width: 1.0),
                                  ),
                                  icon: Icon(
                                    Icons.question_answer,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                              UIHelper.verticalSpaceSmall,
                              postFreeFabResult != ''
                                  ? Text(postFreeFabResult)
                                  : Container()
                            ],
                          ),
                          actions: [
                            Container(
                                margin: const EdgeInsetsDirectional.only(
                                    bottom: 10),
                                child: StatefulBuilder(builder:
                                    (BuildContext context,
                                        StateSetter setState) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Cancel
                                      OutlinedButton(
                                          style: ButtonStyle(
                                              shape: MaterialStateProperty.all(
                                                  const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  15))))),
                                          child: Center(
                                            child: Text(
                                              FlutterI18n.translate(
                                                  context, "close"),
                                              style: headText5,
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                            setState(() =>
                                                freeFabAnswerTextController
                                                    .text = '');
                                            FocusScope.of(context)
                                                .requestFocus(FocusNode());
                                          }),
                                      UIHelper.horizontalSpaceSmall,
                                      // Confirm
                                      TextButton(
                                          style: ButtonStyle(
                                              shape: MaterialStateProperty.all(
                                                  const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  15))))),
                                          child: Center(
                                            child: Text(
                                              FlutterI18n.translate(
                                                  context, "confirm"),
                                              style: headText5.copyWith(
                                                  color: green),
                                            ),
                                          ),
                                          onPressed: () async {
                                            String fabAddress = await sharedService
                                                .getFabAddressFromCoreWalletDatabase();
                                            postFreeFabResult = '';
                                            Map data = {
                                              "address": fabAddress,
                                              "questionair_id": res['_body']
                                                  ['_id'],
                                              "answer":
                                                  freeFabAnswerTextController
                                                      .text
                                            };
                                            log.e('free fab post data $data');
                                            await apiService
                                                .postFreeFab(data)
                                                .then(
                                              (res) {
                                                if (res != null) {
                                                  log.w(res['ok']);

                                                  if (res['ok']) {
                                                    Navigator.of(context)
                                                        .pop(false);
                                                    setState(() =>
                                                        isFreeFabAvailable =
                                                            false);
                                                    walletService.showInfoFlushbar(
                                                        FlutterI18n.translate(
                                                            context,
                                                            "freeFabUpdate"),
                                                        FlutterI18n.translate(
                                                            context,
                                                            "freeFabSuccess"),
                                                        Icons.account_balance,
                                                        green,
                                                        context);
                                                  } else {
                                                    walletService.showInfoFlushbar(
                                                        FlutterI18n.translate(
                                                            context,
                                                            "freeFabUpdate"),
                                                        FlutterI18n.translate(
                                                            context,
                                                            "incorrectAnswer"),
                                                        Icons.cancel,
                                                        red,
                                                        context);
                                                  }
                                                } else {
                                                  walletService
                                                      .showInfoFlushbar(
                                                          FlutterI18n.translate(
                                                              context, "ice"),
                                                          FlutterI18n.translate(
                                                              context,
                                                              "genericError"),
                                                          Icons.cancel,
                                                          red,
                                                          context);
                                                }
                                              },
                                            );
                                            //  navigationService.goBack();
                                            freeFabAnswerTextController.text =
                                                '';
                                            postFreeFabResult = '';
                                            FocusScope.of(context)
                                                .requestFocus(FocusNode());
                                          }),
                                    ],
                                  );
                                })),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              });
        } else {
          debugPrint(isFreeFabAvailable.toString());
          isFreeFabAvailable = res['ok'];
          debugPrint(isFreeFabAvailable.toString());

          walletService.showInfoFlushbar(
              FlutterI18n.translate(context!, "notice"),
              FlutterI18n.translate(context!, "freeFabUsedAlready"),
              Icons.notification_important,
              yellow,
              context!);
        }
      }
    });
  }

  onBackButtonPressed() async {
    await sharedService.onBackButtonPressed(DashboardViewRoute);
  }

  memberValidation() async {
    setBusy(true);
    try {
      await clubService
          .isValidMember(fabAddress)
          .then((res) => isValidMember = res);
    } catch (err) {
      log.e('memberValidation CATCH $err');
    }
    setBusy(false);
  }

  goToProjectDetails(Project project) async {
    String? passedProjectId = '';
    for (var p in projects) {
      if (p.id == project.id.toString()) {
        passedProjectId = p.projectId;
      }
    }

    var projectDetails =
        await clubService.getProjectDetails(passedProjectId!, fabAddress);
    navigationService.navigateTo(clubProjectDetailsViewRoute,
        arguments: project);
  }

  getReferralCount() async {
    setBusy(true);
    await clubService
        .getUserReferralCount(
      fabAddress,
    )
        .then((refCount) {
      referralCount = refCount;
      log.w('getReferralCount $referralCount');
    }).timeout(const Duration(seconds: 5), onTimeout: () async {
      log.e('time out');

      setBusy(false);
      return;
    });
    // setBusy(false);
  }

  String assignPaycoolMemberType({int? status}) {
    var condition = status ?? dashboardSummary.status;
    if (condition == 0) {
      return FlutterI18n.translate(context!, "noPartner");
    } else if (condition == 1) {
      return FlutterI18n.translate(context!, "member");
    } else {
      return FlutterI18n.translate(context!, "vipMember");
    }
  }

// joined projects
  fillJoinedProjects() {
    for (var summary in dashboardSummary.summary!) {
      if (summary.status != 0) {
        joinedProjects.add(summary.project!);
      }
    }
  }

  getDashboardSummary() async {
    setBusy(true);
    await clubService
        .getDashboardSummary(fabAddress)
        .then((dashboardDetails) async {
      dashboardSummary = dashboardDetails!;
      assignPaycoolMemberType();
    });
    fillJoinedProjects();
    setBusy(false);
  }

  showBarcode() {
    setBusy(true);

    showDialog(
        context: context!,
        builder: (BuildContext context) {
          return Platform.isIOS
              ? CupertinoAlertDialog(
                  title: Container(
                    child: Center(
                        child: Text(
                            FlutterI18n.translate(context, "referralCode"))),
                  ),
                  content: Column(
                    children: [
                      // UIHelper.verticalSpaceLarge,
                      Container(
                          margin: const EdgeInsets.only(top: 10.0),
                          width: 250,
                          height: 250,
                          child: Center(
                            child: Container(
                              child: RepaintBoundary(
                                key: globalKey,
                                child: QrImage(
                                    backgroundColor: white,
                                    data: fabAddress,
                                    version: QrVersions.auto,
                                    size: 300,
                                    gapless: true,
                                    errorStateBuilder: (context, err) {
                                      return Container(
                                        child: Center(
                                          child: Text(
                                              FlutterI18n.translate(context,
                                                  "somethingWentWrong"),
                                              textAlign: TextAlign.center),
                                        ),
                                      );
                                    }),
                              ),
                            ),
                          )),
                    ],
                  ),
                  actions: <Widget>[
                    // QR image share button
                    Container(
                      margin: const EdgeInsets.all(35),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CupertinoButton(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(15)),
                              child: Center(
                                  child: Text(
                                FlutterI18n.translate(context, "share"),
                                style: headText5.copyWith(color: primaryColor),
                              )),
                              onPressed: () {
                                String receiveFileName =
                                    'Pay.cool-referral-code.png';
                                getApplicationDocumentsDirectory().then((dir) {
                                  String filePath =
                                      "${dir.path}/$receiveFileName";
                                  File file = File(filePath);
                                  Future.delayed(
                                      const Duration(milliseconds: 30), () {
                                    sharedService
                                        .capturePng(globalKey: globalKey)
                                        .then((byteData) {
                                      file
                                          .writeAsBytes(byteData!.toList())
                                          .then((onFile) {
                                        Share.share(onFile.path,
                                            subject: fabAddress);
                                      });
                                    });
                                  });
                                });
                              }),
                          SizedBox(
                            height: 30,
                            child: CupertinoButton(
                              color: secondaryColor,
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(25)),
                              child: Text(
                                FlutterI18n.translate(context, "close"),
                                style: headText5,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              // Android Alert Dialog
              : AlertDialog(
                  titlePadding: EdgeInsets.zero,
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      UIHelper.verticalSpaceMedium,
                      Text(
                        FlutterI18n.translate(context, 'referralCode'),
                        style: headText4.copyWith(
                            color: black, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  contentPadding: EdgeInsets.zero,
                  insetPadding:
                      const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  elevation: 5,
                  backgroundColor: secondaryColor.withOpacity(0.85),
                  contentTextStyle: const TextStyle(color: grey),
                  content: SizedBox(
                      width: 250,
                      height: 250,
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.all(30),
                          child: RepaintBoundary(
                            key: globalKey,
                            child: QrImage(
                                backgroundColor: white,
                                data: fabAddress,
                                version: QrVersions.auto,
                                gapless: true,
                                errorStateBuilder: (context, err) {
                                  return Container(
                                    child: Center(
                                      child: Text(
                                          FlutterI18n.translate(
                                              context, "somethingWentWrong"),
                                          textAlign: TextAlign.center),
                                    ),
                                  );
                                }),
                          ),
                        ),
                      )),
                  actions: <Widget>[
                    // QR image share button

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all(
                                  const Size(80.0, 30)),
                              shape: shapeRoundBorder,
                              textStyle: MaterialStateProperty.all(
                                  const TextStyle(color: Colors.white))),
                          child: Text(
                            FlutterI18n.translate(context, "close"),
                            style: headText6,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        Container(
                          padding: const EdgeInsets.all(10.0),
                          child: ElevatedButton(
                              style: ButtonStyle(
                                  minimumSize: MaterialStateProperty.all(
                                      const Size(80.0, 30)),
                                  padding: MaterialStateProperty.all(
                                      const EdgeInsets.symmetric(
                                          horizontal: 5)),
                                  shape: shapeRoundBorder,
                                  backgroundColor:
                                      MaterialStateProperty.all(primaryColor),
                                  textStyle: MaterialStateProperty.all(
                                      const TextStyle(color: Colors.white))),
                              child: Text(
                                  FlutterI18n.translate(context, "share"),
                                  style: headText6.copyWith(
                                      color: secondaryColor)),
                              onPressed: () {
                                String receiveFileName =
                                    'pay.cool-referral-code.png';
                                getApplicationDocumentsDirectory().then((dir) {
                                  String filePath =
                                      "${dir.path}/$receiveFileName";
                                  File file = File(filePath);

                                  Future.delayed(
                                      const Duration(milliseconds: 30), () {
                                    sharedService
                                        .capturePng(globalKey: globalKey)
                                        .then((byteData) {
                                      file
                                          .writeAsBytes(byteData!.toList())
                                          .then((onFile) {
                                        Share.share(onFile.path,
                                            subject: fabAddress);
                                      });
                                    });
                                  });
                                });
                              }),
                        ),
                      ],
                    ),
                  ],
                );
        });
    setBusy(false);
  }
}
