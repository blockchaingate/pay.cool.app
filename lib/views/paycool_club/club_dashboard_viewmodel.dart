import 'dart:convert';
import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:paycool/views/paycool_club/club_dashboard_model.dart';
import 'package:paycool/views/paycool_club/club_projects/club_project_model.dart';

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
  bool isDialogUp = false;
  BuildContext? context;
  bool isDUSD = false;
  int gasPrice = environment["chains"]["FAB"]["gasPrice"] as int;
  int gasLimit = environment["chains"]["FAB"]["gasLimitToken"] as int;
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
  GlobalKey globalKey = GlobalKey();
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
  int purchasedPackagesCount = 0;
  List<Project> joinedProjects = [];
  Map<String, Decimal> rewardTokenPriceMap = {};

  void init() async {
    setBusy(true);
    sharedService.context = context;
    fabAddress = await sharedService.getFabAddressFromCoreWalletDatabase();

    await getProjects();

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
    purchasedPackagesCount =
        await clubService.getPurchasedPackageCount(fabAddress);
    await checkGas();

    if (gasAmount == 0.0) await checkFreeFabForNewWallet();
    for (var project in dashboardSummary.summary!) {
      for (var reward in project.totalReward!) {
        if (reward.coin != null) {
          try {
            // reward token price
            var rtp = await clubService.getPriceOfRewardToken(reward.coin!);
            rewardTokenPriceMap.addAll({reward.coin!: rtp});
          } catch (err) {
            log.e(
                'CATCH getPriceOfRewardToken getting price for ${reward.coin}');
          }
        }
      }
    }
    log.e('rewardTokenPriceMap ${rewardTokenPriceMap}');

    setBusy(false);
  } // init ends

  showJoinedProjectsPopup() {
    showDialog(
        context: context!,
        builder: (context) {
          return AlertDialog(
            elevation: 10,
            backgroundColor: white,
            titleTextStyle: headText3.copyWith(color: black),
            title: Text(
              FlutterI18n.translate(context, "joinedProjects"),
              textAlign: TextAlign.center,
              style: headText3.copyWith(color: black),
            ),
            contentTextStyle: const TextStyle(color: grey),
            content: SizedBox(
              child: SingleChildScrollView(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < dashboardSummary.summary!.length; i++)
                        dashboardSummary.summary![i].status != 0
                            ? Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  children: [
                                    Text(
                                      '${storageService.language == "en" ? dashboardSummary.summary![i].project!.en : dashboardSummary.summary![i].project!.sc}  ',
                                      textAlign: TextAlign.start,
                                      style: headText5.copyWith(
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Flexible(
                                      child: Text(
                                        assignMemberType(
                                            status: dashboardSummary
                                                .summary![i].status!
                                                .toInt()),
                                        textAlign: TextAlign.end,
                                        style: headText5.copyWith(color: green),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                    ]),
              ),
            ),
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

/*----------------------------------------------------------------------
                      Show LightningRemit barcode
----------------------------------------------------------------------*/
  showLightningRemitBarcode() async {
    await walletDatabaseService.getWalletBytickerName('FAB').then((coin) {
      String kbAddress = walletService.toKbPaymentAddress(coin!.address!);
      debugPrint('KBADDRESS $kbAddress');
      showDialog(
        context: context!,
        builder: (BuildContext context) {
          return Platform.isIOS
              ? CupertinoAlertDialog(
                  title: Container(
                    child: Center(
                        child: Text(
                            FlutterI18n.translate(context, "receiveAddress"))),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          UIHelper.horizontalSpaceSmall,
                          Expanded(
                            child: Text(
                                // add here cupertino widget to check in these small widgets first then the entire app
                                kbAddress,
                                textAlign: TextAlign.left,
                                style: headText6),
                          ),
                          CupertinoButton(
                              child: const Icon(
                                FontAwesomeIcons.copy,
                                //  CupertinoIcons.,
                                color: primaryColor,
                                size: 16,
                              ),
                              onPressed: () {
                                sharedService.copyAddress(context, kbAddress)();
                              })
                        ],
                      ),
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
                                    data: kbAddress,
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
                      margin: const EdgeInsets.all(5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CupertinoButton(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4)),
                              child: Center(
                                  child: Text(
                                FlutterI18n.translate(context, "share"),
                                style: headText5.copyWith(color: primaryColor),
                              )),
                              onPressed: () {
                                String receiveFileName =
                                    'Lightning-remit-kanban-receive-address.png';
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
                                        Share.shareFiles([onFile.path],
                                            text: kbAddress);
                                      });
                                    });
                                  });
                                });
                              }),
                          CupertinoButton(
                            padding: const EdgeInsets.only(left: 5),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(4)),
                            child: Text(
                              FlutterI18n.translate(context, "close"),
                              style: headText5,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              // Android Alert Dialog
              : AlertDialog(
                  titlePadding: EdgeInsets.zero,
                  contentPadding: EdgeInsets.zero,
                  insetPadding:
                      const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  elevation: 5,
                  backgroundColor: walletCardColor.withOpacity(0.85),
                  title: Container(
                    padding: const EdgeInsets.all(10.0),
                    color: secondaryColor.withOpacity(0.5),
                    child: Center(
                        child: Text(
                            FlutterI18n.translate(context, "receiveAddress"))),
                  ),
                  titleTextStyle:
                      headText4.copyWith(fontWeight: FontWeight.bold),
                  contentTextStyle: const TextStyle(color: grey),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      UIHelper.verticalSpaceLarge,
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          UIHelper.horizontalSpaceSmall,
                          Expanded(
                            child: Center(
                              child: Text(
                                  // add here cupertino widget to check in these small widgets first then the entire app
                                  kbAddress,
                                  style: headText6),
                            ),
                          ),
                          IconButton(
                              icon: const Icon(
                                Icons.content_copy,
                                color: primaryColor,
                                size: 16,
                              ),
                              onPressed: () {
                                sharedService.copyAddress(context, kbAddress)();
                              })
                        ],
                      ),
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
                                    data: kbAddress,
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
                      padding: const EdgeInsets.all(10.0),
                      child: ElevatedButton(
                          child: Text(FlutterI18n.translate(context, "share"),
                              style: headText6),
                          onPressed: () {
                            String receiveFileName =
                                'Lightning-remit-kanban-receive-address.png';
                            getApplicationDocumentsDirectory().then((dir) {
                              String filePath = "${dir.path}/$receiveFileName";
                              File file = File(filePath);

                              Future.delayed(const Duration(milliseconds: 30),
                                  () {
                                sharedService
                                    .capturePng(globalKey: globalKey)
                                    .then((byteData) {
                                  file
                                      .writeAsBytes(byteData!.toList())
                                      .then((onFile) {
                                    Share.shareFiles([onFile.path],
                                        text: kbAddress);
                                  });
                                });
                              });
                            });
                          }),
                    ),
                    OutlinedButton(
                      style: ButtonStyle(
                        side: MaterialStateProperty.all(
                            const BorderSide(color: primaryColor)),
                        // backgroundColor: MaterialStateProperty.all(primaryColor),
                        elevation: MaterialStateProperty.all(5),
                        shape: MaterialStateProperty.all(const StadiumBorder(
                            side: BorderSide(color: primaryColor, width: 2))),
                      ),

                      // style: ButtonStyle(
                      // side: BorderSide(color: primaryColor),
                      // color: primaryColor,
                      // textColor: Colors.white,),
                      child: Text(
                        FlutterI18n.translate(context, "close"),
                        style: headText6,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                  ],
                );
        },
      );
    });
  }

/*----------------------------------------------------------------------
                    Scan 
----------------------------------------------------------------------*/

  void scanBarcode() async {
    try {
      setBusy(true);

      var barcode;
      //  barcode = await BarcodeScanner.scan().then((value) => value.rawContent);
      //barcodeRes.add(barcode);
      log.i('barcode res $barcode');

      if (barcode != "" || barcode != null) {
        scanToPayModel = JoinClubPaymentModel.fromJson(jsonDecode(barcode));
        debugPrint('payCoolModel ${scanToPayModel.toJson()}');
        navigationService.navigateTo(JoinPayCoolClubViewRoute,
            arguments: scanToPayModel);
      }

      setBusy(false);
    } on PlatformException catch (e) {
      if (e.code == "PERMISSION_NOT_GRANTED") {
        setBusy(true);
        sharedService.alertDialog(
            '', FlutterI18n.translate(context!, "userAccessDenied"),
            isWarning: false);
        // receiverWalletAddressTextController.text =
        //     FlutterI18n.translate(context, "userAccessDenied");
      } else {
        // setBusy(true);
        sharedService.alertDialog(
            '', FlutterI18n.translate(context!, "unknownError"),
            isWarning: false);
      }
    } on FormatException {
      sharedService.alertDialog(
          '', FlutterI18n.translate(context!, "scanCancelled"),
          isWarning: false);
    } catch (e) {
      sharedService.alertDialog(
          '', FlutterI18n.translate(context!, "unknownError"),
          isWarning: false);
    }
    setBusy(false);
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

  goToProjectDetails(String projectId) async {
    var projectDetails =
        await clubService.getProjectDetails(projectId, fabAddress);
    navigationService.navigateTo(clubProjectDetailsViewRoute,
        arguments: projectDetails);
  }

  getProjects() async {
    setBusy(true);
    isServerDown = false;
    try {
      await clubService.getClubProjects().then((data) {
        if (data != null && data.isNotEmpty) projects = data;
        //   isAcceptingMembers = projects[0].keyNodeAvailable;
      });
    } catch (err) {
      log.e('getProjects CATCH $err');
      isServerDown = true;
      return;
    }
    setBusy(false);
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

  String assignMemberType({int? status}) {
    var condition = status ?? dashboardSummary.status;
    if (condition == 0) {
      return FlutterI18n.translate(context!, "noPartner");
    } else if (condition == 1) {
      return FlutterI18n.translate(context!, "basicPartner");
    } else if (condition == 2) {
      return FlutterI18n.translate(context!, "juniorPartner");
    } else if (condition == 3) {
      return FlutterI18n.translate(context!, "seniorPartner");
    } else if (condition == 4) {
      return FlutterI18n.translate(context!, "executivePartner");
    } else {
      return FlutterI18n.translate(context!, "noPartner");
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
      assignMemberType();
    });
    fillJoinedProjects();
    setBusy(false);
  }

  bindpayUI(context, model) {
    return Container(
      child: Column(
        children: [
          UIHelper.divider,
          UIHelper.verticalSpaceSmall,
          Container(
            // width: MediaQuery.of(context).size.width * 0.52,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '${FlutterI18n.translate(context, "lightningRemit")} ${FlutterI18n.translate(context, "receiveAddress")}',
              style: headText5,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.52,
            child: ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(primaryColor)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    FlutterI18n.translate(context, "lightningRemit"),
                    style: headText3,
                  ),
                  // Text(
                  //   FlutterI18n.translate(context, "LightningRemit") +
                  //       ' ' +
                  //       AppLocalizations.of(context)
                  //           .receiveAddress,
                  //   style: headText3,
                  // ),
                  // UIHelper.horizontalSpaceSmall,
                  // Icon(Icons.qr_code)
                ],
              ),
              onPressed: () {
                model.showLightningRemitBarcode();
              },
            ),
          ),
        ],
      ),
    );
  }

  scanToPay(context, model) {
    return Container(
      child: Column(
        children: <Widget>[
          UIHelper.divider,
          UIHelper.verticalSpaceSmall,
          Container(
            // width: MediaQuery.of(context).size.width * 0.52,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              FlutterI18n.translate(context, "scanToPayMessage"),
              style: headText5,
            ),
          ),

          // UIHelper.verticalSpaceSmall,
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.52,
            child: ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(yellow)),
              child: Text(
                FlutterI18n.translate(context, "scanToPay"),
                style: headText3.copyWith(
                    color: black, fontWeight: FontWeight.w500),
              ),
              onPressed: () {
                model.scanBarCode();
              },
            ),
          ),
        ],
      ),
    );
  }

  generateQR(context, model) {
    return Column(
      children: <Widget>[
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
                FlutterI18n.translate(context, "generateQrCodeToScanAndPay"),
                style: headText5)),
        UIHelper.verticalSpaceSmall,
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.52,
          child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.lightBlue)),
            child: Text(
              FlutterI18n.translate(context, "generateQrCode"),
              style: headText3.copyWith(
                  color: secondaryColor, fontWeight: FontWeight.w500),
            ),
            onPressed: () {
              model.navigationService.navigateTo(GenerateCustomQrViewRoute);
              //  model.joinClub();
            },
          ),
        ),
        UIHelper.verticalSpaceMedium,
      ],
    );
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
                          CupertinoButton(
                            padding: const EdgeInsets.only(left: 5),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(4)),
                            child: Text(
                              FlutterI18n.translate(context, "close"),
                              style: headText5,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
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
                                        Share.shareFiles([onFile.path],
                                            text: fabAddress);
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

  scanBarCode() async {
    log.i("Barcode: going to scan");
    setBusy(true);
    var result;
    try {
      log.i("Barcode: try");

      result = await BarcodeUtils().scanQR(context!);

      log.i("Barcode Res: $result ");
      scanToPayModel = JoinClubPaymentModel.fromJson(jsonDecode(result));
      navigationService.navigateTo(JoinPayCoolClubViewRoute,
          arguments: scanToPayModel);
      setBusy(false);
    } on PlatformException catch (e) {
      log.i("Barcode PlatformException : ");
      log.i(e.toString());
      if (e.code == "PERMISSION_NOT_GRANTED") {
        setBusy(false);
        sharedService.alertDialog(
            '', FlutterI18n.translate(context!, "userAccessDenied"),
            isWarning: false);
        // receiverWalletAddressTextController.text =
        //     FlutterI18n.translate(context, "userAccessDenied");
      } else {
        setBusy(false);
        sharedService.alertDialog(
            '', FlutterI18n.translate(context!, "unknownError"),
            isWarning: false);
        // receiverWalletAddressTextController.text =
        //     '${FlutterI18n.translate(context, "unknownError")}: $e';
      }
    } on FormatException {
      log.i("Barcode FormatException : ");
      // log.i(e.toString());
      setBusy(false);

      // navigationService.navigateTo(PayCoolClubDashboardViewRoute);
      if (result != null && result != '') {
        sharedService.alertDialog(
            FlutterI18n.translate(context!, "scanCancelled"),
            FlutterI18n.translate(context!, "invalidReferralCode"),
            isWarning: false);
      }
    } catch (e) {
      log.i("Barcode error : ");
      log.i(e.toString());
      setBusy(false);
      sharedService.alertDialog(
          '', FlutterI18n.translate(context!, "unknownError"),
          isWarning: false);
      // receiverWalletAddressTextController.text =
      //     '${FlutterI18n.translate(context, "unknownError")}: $e';
    }
    setBusy(false);
  }
}
