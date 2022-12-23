import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/constants.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/constants/ui_var.dart';
import 'package:paycool/environments/environment_type.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/utils/number_util.dart';
import 'package:paycool/views/paycool/paycool_viewmodel.dart';
import 'package:paycool/widgets/bottom_nav.dart';
import 'package:paycool/widgets/server_error_widget.dart';
import 'package:stacked/stacked.dart';

class PayCoolView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PayCoolViewmodel>.reactive(
      viewModelBuilder: () => PayCoolViewmodel(),
      onModelReady: (model) {
        model.context = context;
        model.init();
      },
      builder: (context, PayCoolViewmodel model, _) => WillPopScope(
        onWillPop: () async {
          model.onBackButtonPressed();
          return Future(() => false);
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          //  backgroundColor: secondaryColor,
          //  appBar: customAppBar(color: secondaryColor),
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
              debugPrint('Close keyboard');
              // persistentBottomSheetController.closed
              //     .then((value) => debugPrint(value));
              // if (model.isShowBottomSheet) {
              //   Navigator.pop(context);
              //   model.setBusy(true);
              //   model.isShowBottomSheet = false;
              //   model.setBusy(false);
              //   debugPrint('Close bottom sheet');
              // }
            },
            child: Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      scale: 1,
                      opacity: isTulum ? 0.2 : 1,
                      image: isTulum
                          ? AssetImage(
                              "assets/images/tulum/background.jpg",
                            )
                          : AssetImage(
                              "assets/images/paycool/dashboard-background.png"),
                      fit: BoxFit.cover)),
              child: Scrollbar(
                child: ListView(
                  children: [
                    Container(
                        // height: isPhone() ? 250 : 350,
                        //width: MediaQuery.of(context).size.width,
                        child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          isTulum
                              ? 'assets/images/tulum/2DCoin.png'
                              : 'assets/images/paycool/bank.png',
                          height: 170,
                          width: 170,
                          fit: BoxFit.contain,
                        ),
                        Text(
                          FlutterI18n.translate(context, "payCool"),
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: black),
                        ),
                        UIHelper.verticalSpaceSmall,
                      ],
                    )),
                    model.isServerDown
                        ? const ServerErrorWidget()
                        : model.isBusy && !model.isPaying
                            ? Padding(
                                padding: const EdgeInsets.only(top: 30.0),
                                child: model.sharedService.loadingIndicator(),
                              )
                            : !model.isMember
                                ? Container(
                                    decoration:
                                        roundedTopLeftRightBoxDecoration(
                                            color: secondaryColor),
                                    padding:
                                        MediaQuery.of(context).size.height < 670
                                            ? const EdgeInsets.fromLTRB(
                                                10, 70, 10, 10)
                                            : const EdgeInsets.fromLTRB(
                                                10, 20, 10, 10),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          // Referral Code textfield

                                          UIHelper.verticalSpaceSmall,
                                          Container(
                                            margin: const EdgeInsets.all(10),
                                            child: TextField(
                                                keyboardType:
                                                    TextInputType.text,
                                                decoration: InputDecoration(
                                                    prefixIcon: IconButton(
                                                        padding:
                                                            const EdgeInsets.only(
                                                                left: 15),
                                                        alignment: Alignment
                                                            .centerLeft,
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
                                                              .requestFocus(
                                                                  FocusNode());
                                                        }),
                                                    suffixIcon: IconButton(
                                                        padding:
                                                            EdgeInsets.zero,
                                                        icon: const Icon(
                                                          Icons.content_paste,
                                                          color: green,
                                                          size: 22,
                                                        ),
                                                        onPressed: () => model.contentPaste(
                                                            addressType: Constants
                                                                .ReferralAddressText)),
                                                    focusedBorder: const UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: primaryColor,
                                                            width: 0.5)),
                                                    enabledBorder:
                                                        const OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color: primaryColor,
                                                                width: 0.5)),
                                                    hintText: FlutterI18n.translate(context, "referralCode"),
                                                    hintStyle: headText4),
                                                controller: model.referralController,
                                                style: headText4.copyWith(fontWeight: FontWeight.bold)),
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
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                                gradient: const LinearGradient(
                                                    colors: isTulum?
                                                    [
                                                      tulumColor,
                                                      tulumColor,
                                                    ]:
                                                    [
                                                      Color(0xFFcd45ff),
                                                      Color(0xFF7368ff),
                                                    ])),
                                            margin: const EdgeInsetsDirectional
                                                .only(top: 10.0),
                                            child: TextButton(
                                              style: ButtonStyle(
                                                  textStyle:
                                                      MaterialStateProperty.all(
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
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                          ),
                                          UIHelper.verticalSpaceSmall,
                                          UIHelper.verticalSpaceSmall,
                                          Container(
                                              margin: const EdgeInsets.all(10),
                                              child: Center(
                                                child: Text(
                                                    FlutterI18n.translate(
                                                        context,
                                                        "joinPaycoolNote"),
                                                    style: headText5),
                                              )),
                                          UIHelper.verticalSpaceSmall,
                                        ]))
                                : Container(
                                    padding: const EdgeInsets.only(
                                        top: 20, left: 15, right: 15),
                                    decoration: roundedBoxDecoration(
                                        color: secondaryColor),
                                    child: Container(
                                      margin:
                                          MediaQuery.of(context).size.height <
                                                  670
                                              ? const EdgeInsets.fromLTRB(
                                                  10, 70, 10, 10)
                                              : const EdgeInsets.fromLTRB(
                                                  10, 0, 10, 10),
                                      child: Stack(
                                        children: [
                                          Column(
                                            children: [
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  // Coin list dropdown

                                                  Platform.isIOS
                                                      ? CoinListBottomSheetFloatingActionButton(
                                                          model: model)
                                                      : Container(
                                                          width: 400,
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      10),
                                                          height: 45,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: primaryColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100.0),
                                                            border: Border.all(
                                                                color: model
                                                                        .exchangeBalances
                                                                        .isEmpty
                                                                    ? Colors
                                                                        .transparent
                                                                    : primaryColor,
                                                                style:
                                                                    BorderStyle
                                                                        .solid,
                                                                width: 0.50),
                                                          ),
                                                          child: DropdownButton(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              underline:
                                                                  const SizedBox
                                                                      .shrink(),
                                                              elevation: 20,
                                                              isExpanded: true,
                                                              icon:
                                                                  const Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        right:
                                                                            8.0),
                                                                child: Icon(
                                                                  Icons
                                                                      .arrow_drop_down,
                                                                  color:
                                                                      secondaryColor,
                                                                ),
                                                              ),
                                                              iconEnabledColor:
                                                                  primaryColor,
                                                              iconDisabledColor: model
                                                                      .exchangeBalances
                                                                      .isEmpty
                                                                  ? secondaryColor
                                                                  : white,
                                                              iconSize: 28,
                                                              hint: Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Padding(
                                                                  padding: model
                                                                          .exchangeBalances
                                                                          .isEmpty
                                                                      ? const EdgeInsets
                                                                              .all(
                                                                          0)
                                                                      : const EdgeInsets
                                                                              .only(
                                                                          left:
                                                                              10.0),
                                                                  child: model
                                                                          .exchangeBalances
                                                                          .isEmpty
                                                                      ? ListTile(
                                                                          dense:
                                                                              true,
                                                                          leading:
                                                                              const Icon(
                                                                            Icons.account_balance_wallet,
                                                                            color:
                                                                                red,
                                                                            size:
                                                                                18,
                                                                          ),
                                                                          title: Text(
                                                                              FlutterI18n.translate(context, "noCoinBalance"),
                                                                              style: Theme.of(context).textTheme.bodyText2),
                                                                          subtitle: Text(FlutterI18n.translate(context, "transferFundsToExchangeUsingDepositButton"), style: subText2.copyWith(color: white)))
                                                                      : Center(
                                                                          child:
                                                                              Text(
                                                                            FlutterI18n.translate(context,
                                                                                "selectCoin"),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style:
                                                                                headText4,
                                                                          ),
                                                                        ),
                                                                ),
                                                              ),
                                                              value: model
                                                                  .tickerName,
                                                              onChanged:
                                                                  (newValue) {
                                                                model.updateSelectedTickername(
                                                                    newValue);
                                                              },
                                                              items: model
                                                                  .exchangeBalances
                                                                  .map(
                                                                (coin) {
                                                                  return DropdownMenuItem(
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          40,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color:
                                                                            primaryColor,
                                                                        //           border: Border.all(
                                                                        // color: model
                                                                        //         .exchangeBalances
                                                                        //         .isEmpty
                                                                        //     ? Colors.transparent
                                                                        //         : primaryColor,
                                                                        // style:
                                                                        //     BorderStyle.solid,
                                                                        // width: 0.50),
                                                                        borderRadius:
                                                                            BorderRadius.circular(100.0),
                                                                      ),
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            const EdgeInsets.only(left: 10.0),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Text(coin.ticker.toString(),
                                                                                textAlign: TextAlign.center,
                                                                                style: headText4.copyWith(fontWeight: FontWeight.bold, color: secondaryColor)),
                                                                            UIHelper.horizontalSpaceSmall,
                                                                            Text(
                                                                              coin.unlockedAmount.toString(),
                                                                              textAlign: TextAlign.center,
                                                                              style: headText5.copyWith(color: secondaryColor, fontWeight: FontWeight.bold),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    value: coin
                                                                        .ticker,
                                                                  );
                                                                },
                                                              ).toList()),
                                                        ),

                                                  //  Merchant Address

                                                  UIHelper.verticalSpaceSmall,
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: ElevatedButton(
                                                            style: ButtonStyle(
                                                                elevation:
                                                                    MaterialStateProperty
                                                                        .all(
                                                                            10.0),
                                                                backgroundColor:
                                                                    MaterialStateProperty
                                                                        .all(
                                                                            secondaryColor),
                                                                shape: buttonRoundShape(
                                                                    secondaryColor),
                                                                textStyle:
                                                                    MaterialStateProperty
                                                                        .all(
                                                                            const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                ))),
                                                            onPressed: () => model
                                                                .scanBarcodeV2(
                                                                    addressType:
                                                                        Constants
                                                                            .MerchantAddressText),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                SizedBox(
                                                                  width: FlutterI18n.currentLocale(context)
                                                                              .countryCode ==
                                                                          'es'
                                                                      ? 60
                                                                      : 80,
                                                                  child: Text(
                                                                      FlutterI18n.translate(
                                                                          context,
                                                                          "scanBarCode"),
                                                                      maxLines:
                                                                          2,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: headText5.copyWith(
                                                                          fontWeight:
                                                                              FontWeight.bold)),
                                                                ),
                                                                IconButton(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    tooltip: FlutterI18n.translate(
                                                                        context,
                                                                        "scanBarCode"),
                                                                    icon: Image
                                                                        .asset(
                                                                      "assets/images/shared/scan-barcode.png",
                                                                      width: 18,
                                                                      height:
                                                                          18,
                                                                    ),
                                                                    onPressed:
                                                                        () {
                                                                      model.scanBarcodeV2(
                                                                          addressType:
                                                                              Constants.MerchantAddressText);
                                                                      FocusScope.of(
                                                                              context)
                                                                          .requestFocus(
                                                                              FocusNode());
                                                                    }),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        UIHelper
                                                            .horizontalSpaceSmall,
                                                        Expanded(
                                                          child: ElevatedButton(
                                                            style: ButtonStyle(
                                                                elevation:
                                                                    MaterialStateProperty
                                                                        .all(
                                                                            10.0),
                                                                backgroundColor:
                                                                    MaterialStateProperty.all(
                                                                        secondaryColor),
                                                                padding: MaterialStateProperty.all(
                                                                    const EdgeInsets
                                                                            .all(
                                                                        6.0)),
                                                                shape: buttonRoundShape(
                                                                    secondaryColor)),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                SizedBox(
                                                                  width: FlutterI18n.currentLocale(context)
                                                                              .countryCode ==
                                                                          'es'
                                                                      ? 60
                                                                      : 80,
                                                                  child: Text(
                                                                    model.isScanningImage
                                                                        ? FlutterI18n.translate(
                                                                            context,
                                                                            "loading")
                                                                        : FlutterI18n.translate(
                                                                            context,
                                                                            "scanImage"),
                                                                    style:
                                                                        headText5,
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      vertical:
                                                                          8.0,
                                                                      horizontal:
                                                                          1),
                                                                  child: Icon(
                                                                    FontAwesomeIcons
                                                                        .fileImage,
                                                                    color: black
                                                                        .withAlpha(
                                                                            200),
                                                                    size: 21,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            onPressed: () {
                                                              model
                                                                  .scanImageFile();
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  model.loadingStatus.isEmpty
                                                      ? Container()
                                                      : Column(
                                                          children: [
                                                            UIHelper
                                                                .verticalSpaceSmall,
                                                            Text(
                                                              model
                                                                  .loadingStatus,
                                                              style: headText5,
                                                            ),
                                                          ],
                                                        ),

                                                  //  Transfer amount textfield

                                                  UIHelper.verticalSpaceMedium,
                                                  // Column(
                                                  //   children: [
                                                  //     Text('paste data below'),
                                                  //     Text(model.pasteRes.toString()),
                                                  //     Text('Barcode res data below'),
                                                  //     for (var i = 0;
                                                  //         i < model.barcodeRes.length;
                                                  //         i++)
                                                  //       Text(i.toString() +
                                                  //           model.barcodeRes[i].toString()),
                                                  //     Text('amount payable'),
                                                  //     Text(model.amountPayable.toString())
                                                  //   ],
                                                  // ),
                                                  //  UIHelper.verticalSpaceSmall,
                                                  UIHelper.verticalSpaceSmall,
                                                  Container(
                                                    margin: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 8),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        // merchant name
                                                        model.merchantModel !=
                                                                    null &&
                                                                model.merchantModel
                                                                        .name !=
                                                                    null
                                                            ? Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            5),
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child: Text(
                                                                          FlutterI18n.translate(
                                                                              context,
                                                                              "merchantName"),
                                                                          style:
                                                                              headText5),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 2,
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            const EdgeInsets.only(right: 8.0),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.end,
                                                                          children: [
                                                                            model.merchantModel.image != null
                                                                                ? Image.network(
                                                                                    model.merchantModel.image,
                                                                                    width: 20,
                                                                                    height: 20,
                                                                                  )
                                                                                : Container(),
                                                                            UIHelper.horizontalSpaceSmall,
                                                                            Text(model.storageService.language == "en" ? model.merchantModel.name.en : model.merchantModel.name.sc,
                                                                                textAlign: TextAlign.right,
                                                                                style: headText5.copyWith(fontWeight: FontWeight.bold)),
                                                                            // TextButton(
                                                                            //     onPressed: () {
                                                                            //       model.showMerchantDetails();
                                                                            //     },
                                                                            //     child: Text(
                                                                            //       FlutterI18n.translate(context, "details"),
                                                                            //       style: const TextStyle(fontSize: 12),
                                                                            //     ))
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                            : Container(),
                                                        // merchant address
                                                        // model.merchangeModel != null &&
                                                        //         model.merchangeModel
                                                        //                 .owner !=
                                                        //             null
                                                        //     ? UIHelper
                                                        //         .verticalSpaceSmall
                                                        //     : Container(),
                                                        // model.merchangeModel != null &&
                                                        //         model.merchangeModel
                                                        //                 .owner !=
                                                        //             null
                                                        //     ? Container(
                                                        //         padding:
                                                        //             const EdgeInsets
                                                        //                 .only(left: 5),
                                                        //         child: Row(
                                                        //           children: [
                                                        //             Expanded(
                                                        //               flex: 1,
                                                        //               child: Text(
                                                        //                   FlutterI18n
                                                        //                       .translate(
                                                        //                           context,
                                                        //                           "merchantAddress"),
                                                        //                   style:
                                                        //                       headText5),
                                                        //             ),
                                                        //             UIHelper
                                                        //                 .horizontalSpaceMedium,
                                                        //             Expanded(
                                                        //               flex: 2,
                                                        //               child: Text(
                                                        //                   model.storageService.language ==
                                                        //                           "en"
                                                        //                       ? model
                                                        //                           .merchangeModel
                                                        //                           .name
                                                        //                           .en
                                                        //                       : model
                                                        //                           .merchangeModel
                                                        //                           .name
                                                        //                           .sc,
                                                        //                   textAlign:
                                                        //                       TextAlign
                                                        //                           .right,
                                                        //                   style: headText5.copyWith(
                                                        //                       fontWeight:
                                                        //                           FontWeight
                                                        //                               .bold)),
                                                        //             ),
                                                        //           ],
                                                        //         ),
                                                        //       )
                                                        //     : Container(),
                                                        UIHelper
                                                            .verticalSpaceSmall,
                                                        // order details
                                                        model.payOrder.title ==
                                                                null
                                                            ? Container()
                                                            : Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            5),
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                      flex: 2,
                                                                      child: Text(
                                                                          FlutterI18n.translate(
                                                                              context,
                                                                              "title"),
                                                                          style:
                                                                              headText5),
                                                                    ),
                                                                    UIHelper
                                                                        .horizontalSpaceMedium,
                                                                    Expanded(
                                                                        flex: 2,
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.end,
                                                                          children: [
                                                                            Text(model.payOrder.title,
                                                                                maxLines: 2,
                                                                                textAlign: TextAlign.right,
                                                                                style: headText5.copyWith(fontWeight: FontWeight.bold)),
                                                                            TextButton(
                                                                                onPressed: () {
                                                                                  model.showOrderDetails();
                                                                                },
                                                                                child: Text(
                                                                                  FlutterI18n.translate(context, "details"),
                                                                                  style: const TextStyle(fontSize: 12),
                                                                                ))
                                                                          ],
                                                                        )),
                                                                  ],
                                                                ),
                                                              ),

                                                        UIHelper.divider,
                                                        UIHelper
                                                            .verticalSpaceSmall,
                                                        // amount payable
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 5),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                flex: 2,
                                                                child: Text(
                                                                    FlutterI18n.translate(
                                                                        context,
                                                                        "amountPayable"),
                                                                    style:
                                                                        headText5),
                                                              ),
                                                              UIHelper
                                                                  .horizontalSpaceMedium,
                                                              Expanded(
                                                                  flex: 2,
                                                                  child: Text(
                                                                      '${model.amountPayable.toString()} ${model.coinPayable}',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .right,
                                                                      style: headText5.copyWith(
                                                                          fontWeight:
                                                                              FontWeight.bold))),
                                                            ],
                                                          ),
                                                        ),
                                                        UIHelper
                                                            .verticalSpaceSmall,
                                                        UIHelper.divider,
                                                        UIHelper
                                                            .verticalSpaceSmall,
                                                        Container(
                                                          width: 400,
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 5),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                flex: 1,
                                                                child: Text(
                                                                    FlutterI18n.translate(
                                                                        context,
                                                                        "tax"),
                                                                    style:
                                                                        headText5),
                                                              ),
                                                              UIHelper
                                                                  .horizontalSpaceMedium,
                                                              Expanded(
                                                                flex: 2,
                                                                child: Text(
                                                                    '${model.taxAmount.toString()} ${model.coinPayable}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .right,
                                                                    style: headText5.copyWith(
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                              ),
                                                            ],
                                                          ),
                                                        ),

                                                        UIHelper
                                                            .verticalSpaceSmall,
                                                        UIHelper.divider,
                                                        UIHelper
                                                            .verticalSpaceSmall,
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 5),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                flex: 1,
                                                                child: Text(
                                                                    FlutterI18n.translate(
                                                                        context,
                                                                        "totalValue"),
                                                                    style:
                                                                        headText5),
                                                              ),
                                                              Expanded(
                                                                flex: 2,
                                                                child: Text(
                                                                    '${(model.amountPayable + model.taxAmount).toString()} ${model.coinPayable}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .right,
                                                                    style: headText5.copyWith(
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        UIHelper
                                                            .verticalSpaceSmall,
                                                        Visibility(
                                                          visible: model
                                                                  .amountPayable !=
                                                              Decimal.zero,
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        5.0,
                                                                    horizontal:
                                                                        5.0),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  flex: 1,
                                                                  child: Text(
                                                                      FlutterI18n.translate(
                                                                          context,
                                                                          "rewards"),
                                                                      style: headText5.copyWith(
                                                                          color:
                                                                              green)),
                                                                ),
                                                                UIHelper
                                                                    .horizontalSpaceMedium,
                                                                Expanded(
                                                                  flex: 2,
                                                                  child: Text(
                                                                      '${model.rewardInfoModel.getTotalRewards.toString()} ${model.merchantModel.rewardCoin}',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .right,
                                                                      style: headText5.copyWith(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              green)),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  UIHelper.verticalSpaceMedium,
                                                  // Pay - Receive Button Row

                                                  SizedBox(
                                                    width: 400,
                                                    height: 45,
                                                    child: ElevatedButton(
                                                      style: ButtonStyle(
                                                          elevation:
                                                              MaterialStateProperty
                                                                  .all(20.0),
                                                          shape:
                                                              shapeRoundBorder,
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all(
                                                                      primaryColor),
                                                          textStyle:
                                                              MaterialStateProperty
                                                                  .all(
                                                                      const TextStyle(
                                                            color: Colors.white,
                                                          ))),
                                                      onPressed: () {
                                                        if (model.isBusy ||
                                                            model.rewardInfoModel
                                                                    .params ==
                                                                null) {
                                                          debugPrint(
                                                              'busy or no data');
                                                        } else {
                                                          model.makePayment();
                                                        }
                                                      },
                                                      child: Text(
                                                          FlutterI18n.translate(
                                                                  context,
                                                                  "pay")
                                                              .toUpperCase(),
                                                          strutStyle:
                                                              const StrutStyle(),
                                                          style: headText4.copyWith(
                                                              color:
                                                                  secondaryColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ),
                                                  ),
                                                  //  UIHelper.horizontalSpaceSmall,
                                                  SizedBox(
                                                    height: isPhone() ? 50 : 80,
                                                  ),

                                                  //transaction History
                                                  ElevatedButton(
                                                    style: ButtonStyle(
                                                        elevation:
                                                            MaterialStateProperty.all(
                                                                20.0),
                                                        padding: MaterialStateProperty.all(
                                                            const EdgeInsets.symmetric(
                                                                vertical: 12,
                                                                horizontal:
                                                                    10)),
                                                        shape: MaterialStateProperty.all(
                                                            RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            45)
                                                                // BorderRadius.only(
                                                                //     topRight: Radius.circular(45),
                                                                //     bottomRight:
                                                                //         Radius.circular(45))
                                                                )),
                                                        backgroundColor:
                                                            // MaterialStateProperty.all(priceColor),
                                                            MaterialStateProperty.all(
                                                                secondaryColor),
                                                        textStyle:
                                                            MaterialStateProperty.all(
                                                                const TextStyle(
                                                          color: Colors.white,
                                                        ))),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        // Icon(
                                                        //   Icons.history_rounded,
                                                        //   // color: secondaryColor,
                                                        //   size: 16,
                                                        // ),
                                                        Image.asset(
                                                          "assets/images/img/time.png",
                                                          width: 20,
                                                          height: 20,
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        Container(
                                                          constraints:
                                                              BoxConstraints(
                                                            minWidth: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.35,
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              FlutterI18n.translate(
                                                                  context,
                                                                  "transactionHistory"),
                                                              style:
                                                                  const TextStyle(
                                                                color: black,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    onPressed: () {
                                                      model.navigationService
                                                          .navigateTo(
                                                              PayCoolTransactionHistoryViewRoute);
                                                    },
                                                  ),
                                                  SizedBox(
                                                    height: isPhone() ? 7 : 12,
                                                  ),
                                                  SizedBox(
                                                    width: 400,
                                                    height: 45,
                                                    child: ElevatedButton(
                                                      style: ButtonStyle(
                                                          elevation:
                                                              MaterialStateProperty
                                                                  .all(20.0),
                                                          padding: MaterialStateProperty.all(
                                                              const EdgeInsets.symmetric(
                                                                  vertical: 15,
                                                                  horizontal:
                                                                      20)),
                                                          shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      45)

                                                              // BorderRadius.only(
                                                              //     topLeft: Radius.circular(45),
                                                              //     bottomLeft: Radius.circular(45))

                                                              )),
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all(green),
                                                          textStyle:
                                                              MaterialStateProperty.all(
                                                                  const TextStyle(
                                                            color: Color(
                                                                0xffcccccc),
                                                          ))),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          // Icon(
                                                          //   Icons.wallet_giftcard_sharp,
                                                          //   // color: primaryColor,
                                                          //   size: 16,
                                                          // ),
                                                          Image.asset(
                                                            "assets/images/img/rewards.png",
                                                            width: 25,
                                                            height: 25,
                                                          ),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          Container(
                                                            constraints:
                                                                BoxConstraints(
                                                              minWidth: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.35,
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                FlutterI18n
                                                                    .translate(
                                                                        context,
                                                                        "myRewardDetails"),
                                                                style:
                                                                    const TextStyle(
                                                                  color: white,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      onPressed: () {
                                                        model.navigationService
                                                            .navigateTo(
                                                                PayCoolRewardsViewRoute);
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          model.isBusy
                                              ? Positioned(
                                                  top: 50,
                                                  bottom: 50,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    decoration:
                                                        roundedBoxDecoration(
                                                            color: primaryColor
                                                                .withOpacity(
                                                                    0.2),
                                                            radius: 10),
                                                    height: 250,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width -
                                                            20,
                                                    child: model.sharedService
                                                        .loadingIndicator(),
                                                  ),
                                                )
                                              : Container(),
                                        ],
                                      ),
                                    ),
                                  ),
                  ],
                ),
              ),
            ),
          ),

          bottomNavigationBar: BottomNavBar(count: 2),
          // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          // floatingActionButton: Container(
          //   color: primaryColor,
          //   child: IconButton(
          //     onPressed: () {
          //       model.scanImageFile();
          //     },
          //     icon: const Icon(
          //       FontAwesomeIcons.fileImage,
          //       color: white,
          //     ),
          //  ),
          // ),
        ),
      ),
    );
  }
}

class CoinListBottomSheetFloatingActionButton extends StatelessWidget {
  const CoinListBottomSheetFloatingActionButton({Key key, this.model})
      : super(key: key);
  final PayCoolViewmodel model;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // padding: EdgeInsets.all(10.0),
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
            //  color: secondaryColor,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Padding(
                padding: const EdgeInsets.only(right: 5.0),
                child: model.exchangeBalances.isEmpty
                    ? Text(FlutterI18n.translate(context, "noCoinBalance"))
                    : Text(
                        //model.tickerName == ''
                        // ? FlutterI18n.translate(context, "selectCoin")
                        // :
                        model.tickerName),
              ),
              Text(model.quantity == 0.0 ? '' : model.quantity.toString()),
              model.exchangeBalances.isNotEmpty
                  ? const Icon(Icons.arrow_drop_down)
                  : Container()
            ]),
          ),
          onPressed: () {
            if (model.exchangeBalances.isNotEmpty) {
              model.coinListBottomSheet(context);
            }
          }),
    );
  }
}
