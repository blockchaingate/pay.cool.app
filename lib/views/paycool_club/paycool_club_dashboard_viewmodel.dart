import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
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
import 'package:paycool/views/paycool/paycool_model.dart';
import 'package:share/share.dart';
import 'package:stacked/stacked.dart';
import 'package:paycool/services/db/wallet_database_service.dart';
import 'package:paycool/services/local_dialog_service.dart';
import 'package:paycool/views/paycool_club/paycool_club_model/paycool_club_model.dart';
import 'package:paycool/views/paycool_club/paycool_dashboard_model.dart';
import '../../models/wallet/wallet.dart';
import '../../services/wallet_service.dart';

class PayCoolClubDashboardViewModel extends BaseViewModel {
  final log = getLogger('PayCoolClubDashboardViewModel');
  final apiService = locator<ApiService>();
  final sharedService = locator<SharedService>();
  final walletService = locator<WalletService>();
  final dialogService = locator<LocalDialogService>();
  final payCoolClubService = locator<PayCoolClubService>();
  final walletDatabaseService = locator<WalletDatabaseService>();
  final navigationService = locator<NavigationService>();
  final storageService = locator<LocalStorageService>();
  List<PayCoolClubModel> payCoolClubDetails = [];
  bool isDialogUp = false;
  BuildContext context;
  bool isDUSD = false;
  int gasPrice = environment["chains"]["FAB"]["gasPrice"];
  int gasLimit = environment["chains"]["FAB"]["gasLimitToken"];
  double fee = 0.0;

  String usdtOfficialAddress = '';

  String usdtWalletAddress = '';
  double usdtWalletBalance = 0.0;

  String dusdWalletAddress = '';
  double dusdWalletBalance = 0.0;

  WalletInfo walletInfo;
  String txHash = '';
  String errorMessage = '';
  String fabAddress = '';

  List<PaycoolReferral> children = [];
  TextEditingController refereeReferralCode = TextEditingController();
  bool isEnoughDusdWalletBalance = true;
  bool isClubMember = false;
  bool isPayMember = false;
  GlobalKey globalKey = GlobalKey();
  PaycoolDashboard dashboard = PaycoolDashboard();
  ScanToPayModel scanToPayModel = ScanToPayModel();
  bool isValidClubReferralCode = false;
  bool isFreeFabAvailable = false;
  final freeFabAnswerTextController = TextEditingController();
  String postFreeFabResult = '';
  double gasAmount = 0.0;

  int memberTypeCode = 0;

  int referralCount = 0;
  bool isServerDown = false;
  bool isAcceptingMembers = false;

  void init() async {
    setBusy(true);
    sharedService.context = context;
    fabAddress = await sharedService.getFabAddressFromCoreWalletDatabase();

    await getPayCoolClubDetails();

    await hasJoinedClub();
    log.e('isClubMember : $isClubMember -- isPayMember $isPayMember');
    if (isClubMember || isPayMember) {
      try {
        await getDashboardDetails();
        await getReferralCount();
      } catch (err) {
        log.e('catch during dashboard details or get children $err');
      }
    }
    await checkGas();
    if (gasAmount == 0.0) await checkFreeFabForNewWallet();
    setBusy(false);
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
              context: context,
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
                                    .bodyText1
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
              FlutterI18n.translate(context, "notice"),
              FlutterI18n.translate(context, "freeFabUsedAlready"),
              Icons.notification_important,
              yellow,
              context);
        }
      }
    });
  }

/*----------------------------------------------------------------------
                      Show LightningRemit barcode
----------------------------------------------------------------------*/
  showLightningRemitBarcode() async {
    await walletDatabaseService.getWalletBytickerName('FAB').then((coin) {
      String kbAddress = walletService.toKbPaymentAddress(coin.address);
      debugPrint('KBADDRESS $kbAddress');
      showDialog(
        context: context,
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
                                          .writeAsBytes(byteData)
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
                      child: RaisedButton(
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
                                  file.writeAsBytes(byteData).then((onFile) {
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
        scanToPayModel = ScanToPayModel.fromJson(jsonDecode(barcode));
        debugPrint('payCoolModel ${scanToPayModel.toJson()}');
        navigationService.navigateTo(JoinPayCoolClubViewRoute,
            arguments: scanToPayModel);
      }

      setBusy(false);
    } on PlatformException catch (e) {
      if (e.code == "PERMISSION_NOT_GRANTED") {
        setBusy(true);
        sharedService.alertDialog(
            '', FlutterI18n.translate(context, "userAccessDenied"),
            isWarning: false);
        // receiverWalletAddressTextController.text =
        //     FlutterI18n.translate(context, "userAccessDenied");
      } else {
        // setBusy(true);
        sharedService.alertDialog(
            '', FlutterI18n.translate(context, "unknownError"),
            isWarning: false);
      }
    } on FormatException {
      sharedService.alertDialog(
          '', FlutterI18n.translate(context, "scanCancelled"),
          isWarning: false);
    } catch (e) {
      sharedService.alertDialog(
          '', FlutterI18n.translate(context, "unknownError"),
          isWarning: false);
    }
    setBusy(false);
  }

  onBackButtonPressed() async {
    await sharedService.onBackButtonPressed(DashboardViewRoute);
  }

  hasJoinedClub() async {
    setBusy(true);
    try {
      await payCoolClubService
          .isValidReferralCode(fabAddress)
          .then((res) => isClubMember = res);

      await payCoolClubService
          .isValidReferralCode(fabAddress, isValidPaycoolMember: true)
          .then((res) => isPayMember = res);
    } catch (err) {
      log.e('Has joined club CATCH $err');
    }
    setBusy(false);
  }

  getPayCoolClubDetails() async {
    setBusy(true);
    isServerDown = false;
    try {
      await payCoolClubService.getPayCoolClubDetails().then((data) {
        if (data != null && data.isNotEmpty) payCoolClubDetails = data;
        isAcceptingMembers = payCoolClubDetails[0].keyNodeAvailable;
      });
    } catch (err) {
      log.e('getPayCoolClubDetails CATCH $err');
      isServerDown = true;
      return;
    }
    setBusy(false);
  }

  getReferralCount() async {
    setBusy(true);
    await payCoolClubService
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

  getDashboardDetails() async {
    setBusy(true);
    await payCoolClubService
        .getDashboardDataByAddress(fabAddress)
        .then((dashboardDetails) async {
      if (isClubMember && dashboardDetails.memberTypeCode == 1) {
        memberTypeCode = 1;
        dashboard = dashboardDetails;
      } else if (isPayMember && dashboardDetails.memberTypeCode == 2) {
        memberTypeCode = 2;
        dashboard = dashboardDetails;
      } else {
        dashboard = null;
      }
    });
    setBusy(false);
  }

  showBarcode() {
    setBusy(true);

    showDialog(
        context: context,
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
                                          .writeAsBytes(byteData)
                                          .then((onFile) {
                                        Share.shareFiles([onFile.path],
                                            text: fabAddress);
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
                          margin: EdgeInsets.all(30),
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
                              minimumSize:
                                  MaterialStateProperty.all(Size(80.0, 30)),
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
                                  minimumSize:
                                      MaterialStateProperty.all(Size(80.0, 30)),
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.symmetric(horizontal: 5)),
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
                                          .writeAsBytes(byteData)
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

      result = await BarcodeUtils().scanQR(context);

      log.i("Barcode Res: $result ");
      scanToPayModel = ScanToPayModel.fromJson(jsonDecode(result));
      navigationService.navigateTo(JoinPayCoolClubViewRoute,
          arguments: scanToPayModel);
      setBusy(false);
    } on PlatformException catch (e) {
      log.i("Barcode PlatformException : ");
      log.i(e.toString());
      if (e.code == "PERMISSION_NOT_GRANTED") {
        setBusy(false);
        sharedService.alertDialog(
            '', FlutterI18n.translate(context, "userAccessDenied"),
            isWarning: false);
        // receiverWalletAddressTextController.text =
        //     FlutterI18n.translate(context, "userAccessDenied");
      } else {
        setBusy(false);
        sharedService.alertDialog(
            '', FlutterI18n.translate(context, "unknownError"),
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
            FlutterI18n.translate(context, "scanCancelled"),
            FlutterI18n.translate(context, "invalidReferralCode"),
            isWarning: false);
      }
    } catch (e) {
      log.i("Barcode error : ");
      log.i(e.toString());
      setBusy(false);
      sharedService.alertDialog(
          '', FlutterI18n.translate(context, "unknownError"),
          isWarning: false);
      // receiverWalletAddressTextController.text =
      //     '${FlutterI18n.translate(context, "unknownError")}: $e';
    }
    setBusy(false);
  }
}
