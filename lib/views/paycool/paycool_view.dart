import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/constants.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/bond/helper.dart';
import 'package:paycool/views/paycool/paycool_viewmodel.dart';
import 'package:paycool/widgets/bottom_nav.dart';
import 'package:paycool/widgets/server_error_widget.dart';
import 'package:paycool/widgets/shared/will_pop_scope.dart';
import 'package:stacked/stacked.dart';

class PayCoolView extends StatelessWidget {
  const PayCoolView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ViewModelBuilder<PayCoolViewmodel>.reactive(
      viewModelBuilder: () => PayCoolViewmodel(),
      onViewModelReady: (model) {
        model.sharedService.context = context;
        model.init();
      },
      builder: (context, PayCoolViewmodel model, _) => WillPopScope(
        onWillPop: () {
          return WillPopScopeWidget().onWillPop(context);
        },
        child: Scaffold(
          backgroundColor: bgGrey,
          extendBodyBehindAppBar: true,
          bottomNavigationBar: BottomNavBar(count: 0),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            elevation: 1,
            backgroundColor: Colors.transparent,
            child: Image.asset(
              "assets/images/new-design/pay_cool_icon.png",
              fit: BoxFit.cover,
            ),
          ),
          extendBody: true,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          body: model.isServerDown
              ? const ServerErrorWidget()
              : model.isBusy && !model.isPaying
                  ? Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: model.sharedService.loadingIndicator(
                          width: 40, height: 40, isCustomWidthHeight: true),
                    )
                  : !model.isMember!
                      ? Container(
                          decoration: roundedTopLeftRightBoxDecoration(
                              color: secondaryColor),
                          padding: MediaQuery.of(context).size.height < 670
                              ? const EdgeInsets.fromLTRB(10, 70, 10, 10)
                              : const EdgeInsets.fromLTRB(10, 20, 10, 10),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Referral Code textfield

                                UIHelper.verticalSpaceSmall,
                                Container(
                                  margin: const EdgeInsets.all(10),
                                  child: TextField(
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                          prefixIcon: IconButton(
                                              padding: const EdgeInsets.only(
                                                  left: 15),
                                              alignment: Alignment.centerLeft,
                                              tooltip: FlutterI18n.translate(
                                                  context, "scanBarCode"),
                                              icon: const Icon(
                                                Icons.camera_alt,
                                                color: primaryColor,
                                                size: 22,
                                              ),
                                              onPressed: () {
                                                model.scanBarcodeV2(
                                                    addressType: Constants
                                                        .ReferralAddressText);
                                                FocusScope.of(context)
                                                    .requestFocus(FocusNode());
                                              }),
                                          suffixIcon: IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: const Icon(
                                                Icons.content_paste,
                                                color: green,
                                                size: 22,
                                              ),
                                              onPressed: () => model
                                                  .contentPaste(
                                                      addressType: Constants
                                                          .ReferralAddressText)),
                                          focusedBorder:
                                              const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: primaryColor,
                                                      width: 0.5)),
                                          enabledBorder:
                                              const OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: primaryColor,
                                                      width: 0.5)),
                                          hintText: FlutterI18n.translate(
                                              context, "referralCode"),
                                          hintStyle: headText4),
                                      controller: model.referralController,
                                      style: headText4.copyWith(
                                          fontWeight: FontWeight.bold)),
                                ),
                                model.apiRes != null && !model.isBusy
                                    ? Column(children: [
                                        UIHelper.verticalSpaceMedium,
                                        Text(model.apiRes.toString())
                                      ])
                                    : Container(),
                                UIHelper.verticalSpaceMedium,
                                Container(
                                  width: 150,
                                  decoration: BoxDecoration(
                                      // color: Color(mainColor),
                                      borderRadius: BorderRadius.circular(25),
                                      gradient: const LinearGradient(colors: [
                                        Color(0xFFcd45ff),
                                        Color(0xFF7368ff),
                                      ])),
                                  margin: const EdgeInsetsDirectional.only(
                                      top: 10.0),
                                  child: TextButton(
                                    style: ButtonStyle(
                                        textStyle: MaterialStateProperty.all(
                                            const TextStyle(
                                      color: Colors.white,
                                    ))),
                                    onPressed: () {
                                      model.isBusy
                                          ? debugPrint('busy')
                                          : model.createAccount();
                                    },
                                    child: Text(
                                        FlutterI18n.translate(
                                            context, "joinNow"),
                                        style: headText4.copyWith(
                                            color: secondaryColor,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                UIHelper.verticalSpaceSmall,
                                UIHelper.verticalSpaceSmall,
                                Container(
                                    margin: const EdgeInsets.all(10),
                                    child: Center(
                                      child: Text(
                                          FlutterI18n.translate(
                                              context, "joinPaycoolNote"),
                                          style: headText5),
                                    )),
                                UIHelper.verticalSpaceSmall,
                              ]))
                      : Container(
                          width: size.width,
                          height: size.height,
                          padding: EdgeInsets.only(bottom: size.height * 0.1),
                          child: Stack(
                            children: [
                              SizedBox(
                                width: size.width,
                                height: size.height * 0.47,
                                child: Stack(
                                  children: [
                                    SizedBox(
                                      height: size.height * 0.47,
                                      child: model.showDetails
                                          ? model.merchantModel!.image != null
                                              ? Center(
                                                  child: Image.network(
                                                      model.merchantModel!.image
                                                          .toString(),
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (BuildContext context,
                                                              Object exception,
                                                              StackTrace?
                                                                  stackTrace) {
                                                    return Container();
                                                  }),
                                                )
                                              : Text(
                                                  FlutterI18n.translate(
                                                      context, "noCamera"),
                                                )
                                          : MobileScanner(
                                              controller:
                                                  model.cameraController,
                                              onDetect: (barcode) {
                                                if (barcode.raw[0]
                                                        ["displayValue"] !=
                                                    null) {
                                                  model.orderDetails(
                                                      barcodeScanData:
                                                          barcode.raw[0]
                                                              ["displayValue"]);
                                                  model.stopCamera();
                                                }
                                              }),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      child: Container(
                                        width: size.width,
                                        height: size.height * 0.1,
                                        color: Colors.black.withOpacity(0.7),
                                        padding:
                                            EdgeInsets.fromLTRB(20, 5, 20, 30),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                model.startCamera();
                                              },
                                              child: Image.asset(
                                                "assets/images/new-design/scan_circle_icon.png",
                                                scale: 2.9,
                                              ),
                                            ),
                                            Text(
                                              FlutterI18n.translate(
                                                  context, "scanToPay"),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: white54),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                model.scanImageFile();
                                              },
                                              child: Image.asset(
                                                "assets/images/new-design/gallery_icon.png",
                                                scale: 2.9,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: size.height * 0.44,
                                child: Container(
                                  width: size.width,
                                  height: size.height * 0.5,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        model.merchantModel != null &&
                                                model.merchantModel!.name !=
                                                    null
                                            ? Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 10),
                                                    child: Container(
                                                      width: size.width,
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                        color: bgGrey,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            FlutterI18n.translate(
                                                                context,
                                                                "merchantName"),
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    textHintGrey),
                                                          ),
                                                          Expanded(
                                                              child:
                                                                  SizedBox()),
                                                          Text(
                                                              model.storageService
                                                                          .language ==
                                                                      "en"
                                                                  ? model
                                                                      .merchantModel!
                                                                      .name!
                                                                      .en
                                                                      .toString()
                                                                  : model
                                                                      .merchantModel!
                                                                      .name!
                                                                      .sc
                                                                      .toString(),
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                              style: headText5.copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  UIHelper.verticalSpaceSmall,
                                                  model.payOrder.title == null
                                                      ? Container()
                                                      : Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      10),
                                                          child: Container(
                                                            width: size.width,
                                                            height: 50,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: bgGrey,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        10),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  flex: 2,
                                                                  child: Text(
                                                                    FlutterI18n.translate(
                                                                        context,
                                                                        "title"),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color:
                                                                            textHintGrey),
                                                                  ),
                                                                ),
                                                                UIHelper
                                                                    .horizontalSpaceMedium,
                                                                Expanded(
                                                                    flex: 3,
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        Text(
                                                                            model
                                                                                .payOrder.title
                                                                                .toString(),
                                                                            maxLines:
                                                                                2,
                                                                            textAlign:
                                                                                TextAlign.right,
                                                                            style: headText5.copyWith(fontWeight: FontWeight.bold)),
                                                                        TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              model.showOrderDetails();
                                                                            },
                                                                            child:
                                                                                Text(
                                                                              FlutterI18n.translate(context, "details"),
                                                                              style: const TextStyle(fontSize: 12),
                                                                            ))
                                                                      ],
                                                                    )),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                ],
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  InkWell(
                                                    onTap: () async {
                                                      model.coinListBottomSheet(
                                                          context);
                                                    },
                                                    child: Container(
                                                      width: size.width * 0.6,
                                                      height: 45,
                                                      decoration: BoxDecoration(
                                                        color: bgGrey,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          Text(
                                                            FlutterI18n
                                                                .translate(
                                                                    context,
                                                                    "balance"),
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    textHintGrey),
                                                          ),
                                                          Expanded(
                                                              child:
                                                                  SizedBox()),
                                                          Text(
                                                            model.exchangeBalance ==
                                                                    0.0
                                                                ? ''
                                                                : makeShort(model
                                                                    .exchangeBalance),
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: black),
                                                          ),
                                                          UIHelper
                                                              .horizontalSpaceSmall,
                                                          Text(
                                                            model.tickerName,
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: black),
                                                          ),
                                                          Expanded(
                                                              child:
                                                                  SizedBox()),
                                                          Icon(
                                                              Icons
                                                                  .keyboard_arrow_down,
                                                              color: black,
                                                              size: 20)
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () async {
                                                      model.navigationService
                                                          .navigateTo(
                                                              PayCoolRewardsViewRoute);
                                                    },
                                                    child: Container(
                                                      width: size.width * 0.3,
                                                      height: 45,
                                                      decoration: BoxDecoration(
                                                        color: bgGrey,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10),
                                                      child: Center(
                                                        child: Text(
                                                          FlutterI18n.translate(
                                                              context,
                                                              "myReward"),
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: black),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        UIHelper.verticalSpaceSmall,
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Container(
                                            width: size.width,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: bgGrey,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  FlutterI18n.translate(
                                                      context, "amountPayable"),
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: textHintGrey),
                                                ),
                                                Text(
                                                  '${model.amountPayable.toString()} ${model.coinPayable}',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: black),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        UIHelper.verticalSpaceSmall,
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Container(
                                            width: size.width,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: bgGrey,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  FlutterI18n.translate(
                                                      context, "tax"),
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: textHintGrey),
                                                ),
                                                Text(
                                                  '${model.taxAmount.toString()} ${model.coinPayable}',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: black),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        UIHelper.verticalSpaceSmall,
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Container(
                                            width: size.width,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: bgGrey,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  FlutterI18n.translate(
                                                      context, "totalValue"),
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: textHintGrey),
                                                ),
                                                Text(
                                                  '${(model.amountPayable + model.taxAmount).toString()} ${model.coinPayable}',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: black),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        UIHelper.verticalSpaceSmall,
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Container(
                                            width: size.width,
                                            height: 50,
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 5),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                if (model.isBusy ||
                                                    model.rewardInfoModel!
                                                            .params ==
                                                        null) {
                                                  debugPrint('busy or no data');
                                                } else {
                                                  model.storageService
                                                          .enableBiometricPayment
                                                      ? model.makePayment(
                                                          isBiometric: true)
                                                      : model.makePayment();
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                backgroundColor: buttonPurple,
                                              ),
                                              child: Text(FlutterI18n.translate(
                                                  context, "pay")),
                                            ),
                                          ),
                                        ),
                                        UIHelper.verticalSpaceSmall,
                                        model.showDetails
                                            ? SizedBox()
                                            : InkWell(
                                                onTap: () {
                                                  model.navigationService
                                                      .navigateTo(
                                                          PayCoolTransactionHistoryViewRoute);
                                                },
                                                child: SizedBox(
                                                  width: size.width,
                                                  child: Text(
                                                    FlutterI18n.translate(
                                                        context,
                                                        "transactionHistory"),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: textHintGrey),
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
        ),
      ),
    );
  }
}

class CoinListBottomSheetFloatingActionButton extends StatelessWidget {
  const CoinListBottomSheetFloatingActionButton({Key? key, this.model})
      : super(key: key);
  final PayCoolViewmodel? model;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FloatingActionButton(
          backgroundColor: secondaryColor,
          child: Container(
            decoration: BoxDecoration(
              color: primaryColor,
              border: Border.all(width: 1),
              borderRadius: const BorderRadius.all(Radius.circular(50)),
            ),
            width: 400,
            height: 220,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Padding(
                padding: const EdgeInsets.only(right: 5.0),
                child: model!.exchangeBalances.isEmpty
                    ? Text(FlutterI18n.translate(context, "noCoinBalance"))
                    : Text(model!.tickerName,
                        style: headText4.copyWith(color: white)),
              ),
              Text(
                  model!.exchangeBalance == 0.0
                      ? ''
                      : model!.exchangeBalance.toString(),
                  style: headText4.copyWith(color: white)),
              model!.exchangeBalances.isNotEmpty
                  ? const Icon(Icons.arrow_drop_down, color: white)
                  : Container()
            ]),
          ),
          onPressed: () {
            if (model!.exchangeBalances.isNotEmpty) {
              model!.coinListBottomSheet(context);
            }
          }),
    );
  }
}
