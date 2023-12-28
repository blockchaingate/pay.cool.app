import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/bond/bond_dashboard.dart';
import 'package:paycool/views/lightning-remit/lightening_remit_viewmodel.dart';
import 'package:paycool/views/lightning-remit/lightning_remit_transfer_history.view.dart';
import 'package:paycool/widgets/bottom_nav.dart';
import 'package:stacked/stacked.dart';

class LightningRemitView extends StatelessWidget {
  const LightningRemitView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
            if (model.isShowBottomSheet) {
              Navigator.pop(context);
              model.isShowBottomSheet = false;
            }
          },
          child: Scaffold(
            backgroundColor: bgGrey,
            appBar: customAppBarWithIcon(
                title: FlutterI18n.translate(context, "lightningRemit"),
                leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black,
                      size: 20,
                    )),
                actions: [
                  IconButton(
                    onPressed: () async {
                      await model.geTransactionstHistory();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  LightningRemitTransferHistoryView()));
                    },
                    icon: Image.asset(
                      "assets/images/new-design/history_icon.png",
                      scale: 2.7,
                    ),
                  )
                ]),
            resizeToAvoidBottomInset: false,
            body: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        FlutterI18n.translate(context, "receiverWalletAddress"),
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: black),
                      ),
                      IconButton(
                        onPressed: () {
                          model.contentPaste();
                        },
                        icon: Image.asset(
                          "assets/images/new-design/scan_icon.png",
                          scale: 2.9,
                        ),
                      )
                    ],
                  ),

                  Container(
                    width: size.width,
                    height: 50,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: model.addressController,
                            onChanged: (value) {},
                            style: TextStyle(fontSize: 16, color: Colors.black),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: FlutterI18n.translate(
                                  context, "receiverWalletAddress"),
                              hintStyle:
                                  TextStyle(fontSize: 16, color: textHintGrey),
                              contentPadding: EdgeInsets.only(left: 10),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: Center(
                            child: IconButton(
                              onPressed: () async {},
                              icon: Image.asset(
                                "assets/images/new-design/clipBoard_icon.png",
                                scale: 2.2,
                                color: textHintGrey,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  UIHelper.verticalSpaceSmall,

                  Container(
                    width: size.width,
                    height: size.height * 0.1,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: model.amountController,
                            onChanged: (value) {},
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '0.00',
                              hintStyle:
                                  TextStyle(fontSize: 16, color: textHintGrey),
                              contentPadding: EdgeInsets.only(left: 10),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: SizedBox(
                            height: size.height * 0.08,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () {
                                    model.coinListBottomSheet(context);
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        model.tickerName,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: black),
                                      ),
                                      Icon(Icons.arrow_drop_down,
                                          color: Colors.black, size: 18)
                                    ],
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: 'Balance: ',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: textHintGrey),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: model.quantity == 0.0
                                              ? ''
                                              : model.quantity.toString(),
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: textHintGrey)),
                                      TextSpan(
                                          text: ' ${model.tickerName}',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: textHintGrey)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  UIHelper.verticalSpaceLarge,
                  if (model.errorMessage != null &&
                      model.errorMessage!.isNotEmpty)
                    Container(
                      width: size.width,
                      height: 50,
                      color: bgLightRed,
                      child: Center(
                          child: Text(
                        model.errorMessage!,
                        style: TextStyle(
                            color: textRed, fontWeight: FontWeight.w500),
                      )),
                    ),
                  UIHelper.verticalSpaceSmall,
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: 50,
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.swap_horizontal_circle_outlined),
                            label: Text(
                                FlutterI18n.translate(context, "Transfer")),
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: buttonOrange,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: 50,
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.arrow_circle_down),
                            label:
                                Text(FlutterI18n.translate(context, "receive")),
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: buttonPurple,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  //     ListView(
                  //       children: [
                  //         UIHelper.verticalSpaceSmall,
                  //         Container(
                  //           margin: const EdgeInsets.symmetric(
                  //               horizontal: 20, vertical: 10),
                  //           child: Column(
                  //             mainAxisAlignment: MainAxisAlignment.center,
                  //             crossAxisAlignment: CrossAxisAlignment.center,
                  //             children: [
                  //               /*----------------------------------------------------------------------------------------------------
                  //                               Coin list dropdown
                  // ----------------------------------------------------------------------------------------------------*/

                  //               Platform.isIOS
                  //                   ? CoinListBottomSheetFloatingActionButton(
                  //                       model: model)
                  //                   : Container(
                  //                       padding: const EdgeInsets.symmetric(
                  //                           horizontal: 10),
                  //                       decoration: roundedBoxDecoration(
                  //                           color: secondaryColor),
                  //                       child: DropdownButton(
                  //                           underline: const SizedBox.shrink(),
                  //                           elevation: 15,
                  //                           isExpanded: true,
                  //                           icon: const Padding(
                  //                             padding: EdgeInsets.only(right: 8.0),
                  //                             child: Icon(
                  //                               Icons.arrow_drop_down,
                  //                               color: black,
                  //                             ),
                  //                           ),
                  //                           iconEnabledColor: primaryColor,
                  //                           iconDisabledColor:
                  //                               model.exchangeBalances.isEmpty
                  //                                   ? secondaryColor
                  //                                   : grey,
                  //                           iconSize: 30,
                  //                           hint: Padding(
                  //                             padding:
                  //                                 model.exchangeBalances.isEmpty
                  //                                     ? const EdgeInsets.all(0)
                  //                                     : const EdgeInsets.only(
                  //                                         left: 10.0),
                  //                             child: model.exchangeBalances.isEmpty
                  //                                 ? ListTile(
                  //                                     dense: true,
                  //                                     leading: const Icon(
                  //                                       Icons
                  //                                           .account_balance_wallet,
                  //                                       color: red,
                  //                                       size: 18,
                  //                                     ),
                  //                                     title: Text(
                  //                                         FlutterI18n.translate(
                  //                                             context,
                  //                                             "noCoinBalance"),
                  //                                         style: Theme.of(context)
                  //                                             .textTheme
                  //                                             .bodyMedium),
                  //                                     subtitle: Text(
                  //                                         FlutterI18n.translate(
                  //                                             context,
                  //                                             "transferFundsToExchangeUsingDepositButton"),
                  //                                         style: subText2))
                  //                                 : Text(
                  //                                     FlutterI18n.translate(
                  //                                         context, "selectCoin"),
                  //                                     textAlign: TextAlign.start,
                  //                                     style: headText4,
                  //                                   ),
                  //                           ),
                  //                           value: model.tickerName,
                  //                           onChanged: (newValue) {
                  //                             model.updateSelectedTickername(
                  //                                 newValue.toString());
                  //                           },
                  //                           items: model.exchangeBalances.map(
                  //                             (coin) {
                  //                               return DropdownMenuItem(
                  //                                 value: coin.ticker,
                  //                                 child: Container(
                  //                                   //   height: 40,
                  //                                   color: secondaryColor,
                  //                                   padding: const EdgeInsets.only(
                  //                                       left: 10.0),
                  //                                   child: Row(
                  //                                     children: [
                  //                                       Text(coin.ticker.toString(),
                  //                                           textAlign:
                  //                                               TextAlign.center,
                  //                                           style:
                  //                                               headText4.copyWith(
                  //                                                   fontWeight:
                  //                                                       FontWeight
                  //                                                           .bold)),
                  //                                       UIHelper.divider,
                  //                                       UIHelper
                  //                                           .horizontalSpaceSmall,
                  //                                       Text(
                  //                                         coin.unlockedAmount
                  //                                             .toString(),
                  //                                         style: headText5.copyWith(
                  //                                             fontWeight:
                  //                                                 FontWeight.bold),
                  //                                       )
                  //                                     ],
                  //                                   ),
                  //                                 ),
                  //                               );
                  //                             },
                  //                           ).toList()),
                  //                     ),
                  //               UIHelper.verticalSpaceMedium,
                  //               SizedBox(
                  //                 width: 400,
                  //                 height: 45,
                  //                 child: Row(
                  //                   mainAxisAlignment:
                  //                       MainAxisAlignment.spaceBetween,
                  //                   children: [
                  //                     Expanded(
                  //                       child: TextField(
                  //                           keyboardType: TextInputType.text,
                  //                           decoration: InputDecoration(
                  //                               contentPadding:
                  //                                   const EdgeInsets.symmetric(
                  //                                       horizontal: 15,
                  //                                       vertical: 10),
                  //                               suffixIcon: IconButton(
                  //                                   padding: EdgeInsets.zero,
                  //                                   icon: Image.asset(
                  //                                     "assets/images/paycool/paste.png",
                  //                                     width: 20,
                  //                                     height: 20,
                  //                                     color: black,
                  //                                   ),
                  //                                   onPressed: () =>
                  //                                       model.contentPaste()),
                  //                               enabledBorder: UnderlineInputBorder(
                  //                                   borderRadius:
                  //                                       BorderRadius.circular(10),
                  //                                   borderSide: const BorderSide(
                  //                                       color: grey, width: 1)),
                  //                               focusedBorder:
                  //                                   const UnderlineInputBorder(
                  //                                       borderSide: BorderSide(
                  //                                           color: primaryColor)),
                  //                               hintText: FlutterI18n.translate(
                  //                                   context,
                  //                                   "receiverWalletAddress"),
                  //                               hintStyle: headText4),
                  //                           controller: model.addressController,
                  //                           style: headText4),
                  //                     ),
                  //                     const SizedBox(
                  //                       width: 5,
                  //                     ),
                  //                     IconButton(
                  //                         padding: const EdgeInsets.only(left: 10),
                  //                         alignment: Alignment.centerLeft,
                  //                         tooltip: FlutterI18n.translate(
                  //                             context, "scanBarCode"),
                  //                         icon: Image.asset(
                  //                           "assets/images/paycool/qr-code.png",
                  //                           width: 28,
                  //                           height: 28,
                  //                           color: black,
                  //                         ),
                  //                         // Icon(
                  //                         //   Icons.camera_alt,
                  //                         //   color: white,
                  //                         //   size: 18,
                  //                         // ),
                  //                         onPressed: () {
                  //                           model.scanBarcode();
                  //                           FocusScope.of(context)
                  //                               .requestFocus(FocusNode());
                  //                         })
                  //                   ],
                  //                 ),
                  //               ),

                  model.isBusy
                      ? Align(
                          alignment: Alignment.center,
                          child: model.sharedService
                              .stackFullScreenLoadingIndicator())
                      : Container()
                ],
              ),
            ),
            bottomNavigationBar: BottomNavBar(count: 3),
            floatingActionButton: model.isShowBottomSheet
                ? null
                : FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const BondDashboard()));
                    },
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
          ),
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
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            model.exchangeBalances.isEmpty
                ? Text(FlutterI18n.translate(context, "noCoinBalance"))
                : Row(
                    children: [
                      Row(
                        children: [
                          Text(
                            model.tickerName,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: black),
                          ),
                          Icon(Icons.arrow_drop_down,
                              color: Colors.black, size: 18)
                        ],
                      ),
                    ],
                  ),
          ]),
        ),
        onTap: () {
          if (model.exchangeBalances.isNotEmpty) {
            model.coinListBottomSheet(context);
          }
        });
  }
}
