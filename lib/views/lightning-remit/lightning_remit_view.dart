import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paycool/views/lightning-remit/lightning_remit_transactions_history.view.dart';
import 'package:stacked/stacked.dart';

import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/models/wallet/transaction_history.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/lightning-remit/lightening_remit_viewmodel.dart';
import 'package:paycool/widgets/bottom_nav.dart';

class LightningRemitView extends StatelessWidget {
  const LightningRemitView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // PersistentBottomSheetController persistentBottomSheetController;
    return ViewModelBuilder<LightningRemitViewmodel>.reactive(
      viewModelBuilder: () => LightningRemitViewmodel(),
      onViewModelReady: (model) {
        model.context = context;
        model.init();
      },
      builder: (context, model, _) => WillPopScope(
        onWillPop: () async {
          model.onBackButtonPressed();
          return Future(() => false);
        },
        child: Scaffold(
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
              debugPrint('Close keyboard');
              // persistentBottomSheetController.closed
              //     .then((value) => debugPrint(value));
              if (model.isShowBottomSheet) {
                Navigator.pop(context);
                model.setBusy(true);
                model.isShowBottomSheet = false;
                model.setBusy(false);
                debugPrint('Close bottom sheet');
              }
            },
            child: Container(
              decoration: BoxDecoration(image: blurBackgroundImage()),
              child: ListView(children: [
                SizedBox(
                  // width: double.infinity,
                  height: MediaQuery.of(context).size.width * 0.5,

                  child: Stack(clipBehavior: Clip.antiAlias, children: <Widget>[
                    // Container(
                    //     // height: 350.0,
                    //     decoration: BoxDecoration(
                    //         color: Colors.white,
                    //         gradient: LinearGradient(
                    //             begin: FractionalOffset.topCenter,
                    //             end: FractionalOffset.bottomCenter,
                    //             colors: [
                    //               Colors.grey.withOpacity(0.0),
                    //               secondaryColor.withOpacity(0.4),
                    //               secondaryColor
                    //             ],
                    //             stops: [
                    //               0.0,
                    //               0.5,
                    //               1.0
                    //             ]))),
                    // Positioned(
                    //   bottom: 30,
                    //   top: 0,
                    //   left: 0,
                    //   right: 0,
                    //   child: Container(
                    //     decoration: const BoxDecoration(
                    //         image: DecorationImage(
                    //             image: AssetImage(
                    //               // 'assets/images/wallet-page/background.png'
                    //               'assets/images/paycool/Waves_01_5-3.png',
                    //             ),
                    //             alignment: Alignment.center,
                    //             fit: BoxFit.fitWidth)),
                    //   ),
                    // ),
                    Positioned(
                      // top: 100,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                          // height: 120,
                          // width: 105,
                          alignment: Alignment.topCenter,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Container(
                              //     alignment: Alignment.topCenter,
                              //     child: Image.asset(
                              //       'assets/images/paycool/LightningRemit-Logo-Good.png',
                              //       color: white,
                              //       width:
                              //           MediaQuery.of(context).size.width / 5,
                              //       height:
                              //           MediaQuery.of(context).size.width / 5,
                              //     )),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                FlutterI18n.translate(
                                    context, "lightningRemit"),
                                style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor),
                              ),
                              // SizedBox(
                              //   width: 10,
                              // ),
                            ],
                          )),
                    ),
                  ]),
                ),
                UIHelper.verticalSpaceSmall,
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
/*----------------------------------------------------------------------------------------------------
                                        Coin list dropdown
----------------------------------------------------------------------------------------------------*/

//                       InkWell(
//                         onTap: () {
// model.test();
//                         },
//                         child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text('Choose Coin'),
//                               Icon(Icons.arrow_drop_down)
//                             ]),
//                       ),
                      Platform.isIOS
                          ? CoinListBottomSheetFloatingActionButton(
                              model: model)
                          // Container(
                          //     color: walletCardColor,
                          //     child: CupertinoPicker(
                          //         diameterRatio: 1.3,
                          //         offAxisFraction: 5,
                          //         scrollController: model.scrollController,
                          //         itemExtent: 50,
                          //         onSelectedItemChanged: (int newValue) {
                          //           model.updateSelectedTickernameIOS(newValue);
                          //         },
                          //         children: [
                          //           for (var i = 0; i < model.coins.length; i++)
                          //             Container(
                          //               margin: EdgeInsets.only(left: 10),
                          //               child: Row(
                          //                 children: [
                          //                   Text(
                          //                       model.coins[i]['tickerName']
                          //                           .toString(),
                          //                       style: Theme.of(context)
                          //                           .textTheme
                          //                           .headText5),
                          //                   UIHelper.horizontalSpaceSmall,
                          //                   Text(
                          //                     model.coins[i]['quantity']
                          //                         .toString(),
                          //                     style: Theme.of(context)
                          //                         .textTheme
                          //                         .headText5
                          //                         .copyWith(color: grey),
                          //                   )
                          //                 ],
                          //               ),
                          //             ),
                          //           //    })
                          //           model.coins.length > 0
                          //               ? Container()
                          //               : SizedBox(
                          //                   width: double.infinity,
                          //                   child: Center(
                          //                     child: Text(
                          //                       AppLocalizations.of(context)
                          //                           .insufficientBalance,
                          //                       style: Theme.of(context)
                          //                           .textTheme
                          //                           .bodyText2,
                          //                     ),
                          //                   ),
                          //                 ),
                          //         ]),
                          //   )
                          : Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              //height: 45,
                              decoration:
                                  roundedBoxDecoration(color: secondaryColor),
                              child: DropdownButton(
                                  underline: const SizedBox.shrink(),
                                  elevation: 15,
                                  isExpanded: true,
                                  icon: const Padding(
                                    padding: EdgeInsets.only(right: 8.0),
                                    child: Icon(
                                      Icons.arrow_drop_down,
                                      color: black,
                                    ),
                                  ),
                                  iconEnabledColor: primaryColor,
                                  iconDisabledColor:
                                      model.exchangeBalances.isEmpty
                                          ? secondaryColor
                                          : grey,
                                  iconSize: 30,
                                  hint: Padding(
                                    padding: model.exchangeBalances.isEmpty
                                        ? const EdgeInsets.all(0)
                                        : const EdgeInsets.only(left: 10.0),
                                    child: model.exchangeBalances.isEmpty
                                        ? ListTile(
                                            dense: true,
                                            leading: const Icon(
                                              Icons.account_balance_wallet,
                                              color: red,
                                              size: 18,
                                            ),
                                            title: Text(
                                                FlutterI18n.translate(
                                                    context, "noCoinBalance"),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2),
                                            subtitle: Text(
                                                FlutterI18n.translate(context,
                                                    "transferFundsToExchangeUsingDepositButton"),
                                                style: subText2))
                                        : Text(
                                            FlutterI18n.translate(
                                                context, "selectCoin"),
                                            textAlign: TextAlign.start,
                                            style: headText4,
                                          ),
                                  ),
                                  value: model.tickerName,
                                  onChanged: (newValue) {
                                    model.updateSelectedTickername(
                                        newValue.toString());
                                  },
                                  items: model.exchangeBalances.map(
                                    (coin) {
                                      return DropdownMenuItem(
                                        child: Container(
                                          //   height: 40,
                                          color: secondaryColor,
                                          padding:
                                              const EdgeInsets.only(left: 10.0),
                                          child: Row(
                                            children: [
                                              Text(coin.ticker.toString(),
                                                  textAlign: TextAlign.center,
                                                  style: headText4.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              UIHelper.divider,
                                              UIHelper.horizontalSpaceSmall,
                                              Text(
                                                coin.unlockedAmount.toString(),
                                                style: headText5.copyWith(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            ],
                                          ),
                                        ),
                                        value: coin.ticker,
                                      );
                                    },
                                  ).toList()),
                            ),

                      UIHelper.verticalSpaceMedium,
                      SizedBox(
                        // height: 100,
                        width: 400,
                        height: 45,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Container(
                                // height: 100,
                                // width: 300,
                                child: TextField(
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 10),
                                        suffixIcon: IconButton(
                                            padding: EdgeInsets.zero,
                                            icon: Image.asset(
                                              "assets/images/paycool/paste.png",
                                              width: 20,
                                              height: 20,
                                              color: black,
                                            ),
                                            // Icon(
                                            //   Icons.content_paste,
                                            //   color: green,
                                            //   size: 18,
                                            // ),
                                            onPressed: () =>
                                                model.contentPaste()),
                                        enabledBorder: UnderlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                                color: grey, width: 1)),
                                        focusedBorder:
                                            const UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: primaryColor)),
                                        hintText: FlutterI18n.translate(
                                            context, "receiverWalletAddress"),
                                        hintStyle: headText4),
                                    controller: model.addressController,
                                    style: headText4),
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            IconButton(
                                padding: const EdgeInsets.only(left: 10),
                                alignment: Alignment.centerLeft,
                                tooltip: FlutterI18n.translate(
                                    context, "scanBarCode"),
                                icon: Image.asset(
                                  "assets/images/paycool/qr-code.png",
                                  width: 28,
                                  height: 28,
                                  color: black,
                                ),
                                // Icon(
                                //   Icons.camera_alt,
                                //   color: white,
                                //   size: 18,
                                // ),
                                onPressed: () {
                                  model.scanBarcode();
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                })
                          ],
                        ),
                      ),

/*----------------------------------------------------------------------------------------------------
                                        Transfer amount textfield
----------------------------------------------------------------------------------------------------*/

                      UIHelper.verticalSpaceMedium,
                      SizedBox(
                        width: 400,
                        height: 45,
                        child: TextField(
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                enabledBorder: UnderlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: grey, width: 1)),
                                focusedBorder: const UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: primaryColor)),
                                hintText: FlutterI18n.translate(
                                    context, "enterAmount"),
                                hintStyle: headText4),
                            controller: model.amountController,
                            style: headText4),
                      ),
                      UIHelper.verticalSpaceMedium,
/*----------------------------------------------------------------------------------------------------
                                        Transfer - Receive Button Row
----------------------------------------------------------------------------------------------------*/

                      SizedBox(
                        width: 400,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 45,
                                // width: 400,
                                decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(50)),
                                child: ElevatedButton(
                                  style: generalButtonStyle(primaryColor),
                                  onPressed: () {
                                    model.isBusy
                                        ? debugPrint('busy')
                                        : model.transfer();
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                          FlutterI18n.translate(
                                              context, "tranfser"),
                                          style: headText4.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: white)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            UIHelper.horizontalSpaceSmall,

/*----------------------------------------------------------------------------------------------------
                                              Receive Button
----------------------------------------------------------------------------------------------------*/

                            Expanded(
                              child: Container(
                                height: 45,
                                // width: 400,
                                decoration: BoxDecoration(
                                    color: buyPrice,
                                    borderRadius: BorderRadius.circular(50)),
                                child: ElevatedButton(
                                  style: generalButtonStyle(secondaryColor),
                                  onPressed: () {
                                    model.isBusy
                                        ? debugPrint('busy')
                                        : model.showBarcode();
                                  },
                                  child: Text(
                                      FlutterI18n.translate(context, "receive"),
                                      style: headText4.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: black,
                                        height: 0.8,
                                      )),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 80,
                      ),
                      Container(
                        width: 400,
                        height: 45,
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(50)),
                        child: TextButton(
                          style: generalButtonStyle(black),
                          onPressed: () async {
                            if (!model.isBusy) {
                              await model.geTransactionstHistory();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          LightningRemitTransactionHistoryView()));
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  FlutterI18n.translate(
                                      context, "transactionHistory"),
                                  style: headText4.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[300])),
                            ],
                          ),
                        ),
                      ),
                      // IconButton(
                      //         //  borderSide: BorderSide(color: primaryColor),
                      //         padding: EdgeInsets.all(15),
                      //         color: primaryColor,
                      //         // textColor: Colors.white,
                      //         onPressed: () async {
                      //           await model.getBindpayTransactionHistory();
                      //           Navigator.push(
                      //               context,
                      //               MaterialPageRoute(
                      //                   builder: (_) => TxHistoryView(
                      //                       transactionHistory:
                      //                           model.transactionHistory,
                      //                       model: model)));
                      //         },
                      //         icon: Icon(Icons.history, color: white, size: 24),
                      //         // child: Text('History',
                      //         //     style: headText4),
                      //       ),
                    ],
                  ),
                ),

/*----------------------------------------------------------------------------------------------------
                                        Stack loading container
----------------------------------------------------------------------------------------------------*/

                model.isBusy
                    ? Align(
                        alignment: Alignment.center,
                        child: model.sharedService
                            .stackFullScreenLoadingIndicator())
                    : Container()
              ]),
            ),
          ),
          bottomNavigationBar: BottomNavBar(count: 3),
        ),
      ),
    );
  }
}

class CoinListBottomSheetFloatingActionButton extends StatelessWidget {
  const CoinListBottomSheetFloatingActionButton({Key? key, required this.model})
      : super(key: key);
  final LightningRemitViewmodel model;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        child: Container(
          decoration: roundedBoxDecoration(color: secondaryColor),
          //  width: 400,
          //  height: 45,
          padding: const EdgeInsets.all(15),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: model.exchangeBalances.isEmpty
                  ? Text(FlutterI18n.translate(context, "noCoinBalance"))
                  : Text(
                      //model.tickerName == ''
                      // ? FlutterI18n.translate(context, "selectCoin")
                      // :
                      model.tickerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: black,
                      ),
                    ),
            ),
            Text(
              model.quantity == 0.0 ? '' : model.quantity.toString(),
              style: const TextStyle(
                color: black,
              ),
            ),
            model.exchangeBalances.isNotEmpty
                ? const Icon(
                    Icons.arrow_drop_down,
                    color: black,
                  )
                : Container()
          ]),
        ),
        onTap: () {
          if (model.exchangeBalances.isNotEmpty) {
            model.coinListBottomSheet(context);
          }
        });
  }
}

// transaction history

