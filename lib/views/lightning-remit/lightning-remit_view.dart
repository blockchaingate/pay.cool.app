import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';

import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/models/wallet/transaction_history.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/lightning-remit/lightening_remit_viewmodel.dart';
import 'package:paycool/widgets/bottom_nav.dart';

class LightningRemitView extends StatelessWidget {
  const LightningRemitView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // PersistentBottomSheetController persistentBottomSheetController;
    return ViewModelBuilder<LightningRemitViewmodel>.reactive(
      viewModelBuilder: () => LightningRemitViewmodel(),
      onModelReady: (model) {
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
              color: secondaryColor,
              // margin: EdgeInsets.only(top: 40),
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
                    Positioned(
                      bottom: 30,
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(
                                  // 'assets/images/wallet-page/background.png'
                                  'assets/images/paycool/Waves_01_5-3.png',
                                ),
                                alignment: Alignment.center,
                                fit: BoxFit.fitWidth)),
                      ),
                    ),
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
                                    color: white),
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
                              height: 45,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(100.0),
                                border: Border.all(
                                    color: model.exchangeBalances.isEmpty
                                        ? Colors.transparent
                                        : primaryColor,
                                    style: BorderStyle.solid,
                                    width: 0.50),
                              ),
                              child: DropdownButton(
                                  underline: const SizedBox.shrink(),
                                  elevation: 5,
                                  isExpanded: true,
                                  icon: const Padding(
                                    padding: EdgeInsets.only(right: 8.0),
                                    child: Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.white,
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
                                    model.updateSelectedTickername(newValue);
                                  },
                                  items: model.exchangeBalances.map(
                                    (coin) {
                                      return DropdownMenuItem(
                                        child: Container(
                                          height: 40,
                                          color: primaryColor,
                                          padding:
                                              const EdgeInsets.only(left: 10.0),
                                          child: Row(
                                            children: [
                                              Text(coin.ticker.toString(),
                                                  textAlign: TextAlign.center,
                                                  style: headText4.copyWith(
                                                      color: black,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              UIHelper.horizontalSpaceSmall,
                                              Text(
                                                coin.unlockedAmount.toString(),
                                                style: headText5.copyWith(
                                                    color: black,
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

/*----------------------------------------------------------------------------------------------------
                                        Receiver Address textfield
----------------------------------------------------------------------------------------------------*/

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
                                                horizontal: 15, vertical: 0),
                                        suffixIcon: IconButton(
                                            padding: EdgeInsets.zero,
                                            icon: Image.asset(
                                              "assets/images/paycool/paste.png",
                                              width: 20,
                                              height: 20,
                                            ),
                                            // Icon(
                                            //   Icons.content_paste,
                                            //   color: green,
                                            //   size: 18,
                                            // ),
                                            onPressed: () =>
                                                model.contentPaste()),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            borderSide: const BorderSide(
                                                color: primaryColor, width: 1)),
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
                                    horizontal: 15, vertical: 0),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: const BorderSide(
                                        color: primaryColor, width: 1)),
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
                                child: TextButton(
                                  // style: ButtonStyle(textStyle: MaterialStateProperty<TextStyle>()),
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
                                              color: black)),
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
                                    color: tertiaryColor,
                                    borderRadius: BorderRadius.circular(50)),
                                child: TextButton(
                                  onPressed: () {
                                    model.isBusy
                                        ? debugPrint('busy')
                                        : model.showBarcode();
                                  },
                                  child: Text(
                                      FlutterI18n.translate(context, "receive"),
                                      style: headText4.copyWith(
                                        fontWeight: FontWeight.bold,
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
                          onPressed: () async {
                            if (!model.isBusy) {
                              await model.getBindpayTransactionHistory();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => TxHistoryView(
                                          transactionHistory:
                                              model.transactionHistory,
                                          model: model)));
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
  const CoinListBottomSheetFloatingActionButton({Key key, this.model})
      : super(key: key);
  final LightningRemitViewmodel model;

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
              borderRadius: const BorderRadius.all(Radius.circular(100)),
            ),
            width: 400,
            height: 45,
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
          onPressed: () {
            if (model.exchangeBalances.isNotEmpty) {
              model.coinListBottomSheet(context);
            }
          }),
    );
  }
}

// transaction history

class TxHistoryView extends StatelessWidget {
  final List<TransactionHistory> transactionHistory;
  final LightningRemitViewmodel model;
  const TxHistoryView({this.transactionHistory, this.model});
  @override
  Widget build(BuildContext context) {
    /*----------------------------------------------------------------------
                    Copy Order
----------------------------------------------------------------------*/

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(FlutterI18n.translate(context, "transactionHistory"),
            style: headText3),
        backgroundColor: secondaryColor,
      ),
      body: SingleChildScrollView(
        child: Container(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              children: <Widget>[
                for (var transaction in transactionHistory)
                  Card(
                    elevation: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 4.0),
                      color: walletCardColor,
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: 45,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 3.0),
                                  child: Text(transaction.tickerName,
                                      style: subText2),
                                ),
                                // icon
                                transaction.tag == 'send'
                                    ? const Icon(
                                        FontAwesomeIcons.arrowRight,
                                        size: 11,
                                        color: sellPrice,
                                      )
                                    : const Icon(
                                        Icons.arrow_downward,
                                        size: 18,
                                        color: buyPrice,
                                      ),
                              ],
                            ),
                          ),
                          UIHelper.horizontalSpaceSmall,
                          Container(
                            //  width: 200,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          2.5,
                                      child: RichText(
                                        overflow: TextOverflow.ellipsis,
                                        text: TextSpan(
                                            text: transaction.tickerChainTxId,
                                            style: subText2.copyWith(
                                                decoration:
                                                    TextDecoration.underline,
                                                color: primaryColor),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                model.copyAddress(transaction
                                                    .tickerChainTxId);
                                                model.openExplorer(transaction
                                                    .tickerChainTxId);
                                              }),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.copy_outlined,
                                          color: white, size: 16),
                                      onPressed: () => model.copyAddress(
                                          transaction.tickerChainTxId),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: Text(
                                    transaction.date.substring(0, 19),
                                    style: headText5.copyWith(
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          UIHelper.horizontalSpaceSmall,
                          UIHelper.horizontalSpaceSmall,
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(FlutterI18n.translate(context, "quantity"),
                                  style: subText2),
                              Text(
                                transaction.quantity.toStringAsFixed(
                                    // model
                                    //   .decimalConfig
                                    //   .quantityDecimal
                                    2),
                                style: headText5.copyWith(
                                    fontWeight: FontWeight.w400),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            )),
      ),
    );
  }
}
