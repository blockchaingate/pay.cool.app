/*
* Copyright (c) 2020 Exchangily LLC
*
* Licensed under Apache License v2.0
* You may obtain a copy of the License at
*
*      https://www.apache.org/licenses/LICENSE-2.0
*
*----------------------------------------------------------------------
* Author: ken.qiu@exchangily.com
*----------------------------------------------------------------------
*/

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/utils/number_util.dart';
import 'package:paycool/views/wallet/wallet_features/add_gas/add_gas_viewmodel.dart';
import 'package:stacked/stacked.dart';

class AddGasView extends StatefulWidget {
  @override
  State<AddGasView> createState() => _AddGasViewState();
}

class _AddGasViewState extends State<AddGasView>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  double aniheight = 0.0;

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500), // Adjust the duration as needed
        animationBehavior: AnimationBehavior.preserve);

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ViewModelBuilder<AddGasViewModel>.reactive(
        onViewModelReady: (model) async {
          model.context = context;
          await model.init();
        },
        viewModelBuilder: () => AddGasViewModel(),
        builder: (context, AddGasViewModel model, _) => GestureDetector(
              onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: bgGrey,
                appBar: customAppBarWithIcon(
                  title: FlutterI18n.translate(context, "addGas"),
                  leading: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black,
                        size: 20,
                      )),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
                floatingActionButton: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 50,
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.arrow_circle_up),
                          label: Text(
                            FlutterI18n.translate(context, "confirm"),
                          ),
                          onPressed: () {
                            Decimal amount = Decimal.zero;
                            if (model.amountController.text != '') {
                              amount =
                                  Decimal.parse(model.amountController.text);
                            }

                            model.amountController.text == ''
                                ? model.sharedService.showInfoFlushbar(
                                    FlutterI18n.translate(
                                        context, "invalidAmount"),
                                    FlutterI18n.translate(
                                        context, "pleaseEnterValidNumber"),
                                    Icons.cancel,
                                    red,
                                    context)
                                : model.checkPass(amount, context);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: buttonGreen,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                body: Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UIHelper.verticalSpaceMedium,
                      Text(
                        FlutterI18n.translate(context, "amount"),
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: black),
                      ),
                      UIHelper.verticalSpaceSmall,
                      Container(
                        width: size.width,
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: model.amountController,
                                onChanged: (v) => model.updateTransFee(),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '0.00',
                                  hintStyle: TextStyle(
                                      fontSize: 16, color: textHintGrey),
                                  contentPadding: EdgeInsets.only(left: 10),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                "FAB",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: black),
                              ),
                            )
                          ],
                        ),
                      ),
                      UIHelper.verticalSpaceSmall,
                      Row(
                        children: [
                          Text(
                            '${FlutterI18n.translate(context, "gas")} ${FlutterI18n.translate(context, "balance")}',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: textHintGrey),
                          ),
                          UIHelper.horizontalSpaceSmall,
                          Text(model.gasBalance.toString(),
                              style: const TextStyle(
                                  fontSize: 12.0, color: Colors.black))
                        ],
                      ),
                      UIHelper.verticalSpaceSmall,
                      Row(
                        children: [
                          Text(
                            'FAB ${FlutterI18n.translate(context, "balance")}',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: textHintGrey),
                          ),
                          UIHelper.horizontalSpaceSmall,
                          Text(model.fabBalance.toString(),
                              style:
                                  const TextStyle(fontSize: 12.0, color: black))
                        ],
                      ),
                      UIHelper.verticalSpaceMedium,
                      Text(
                        FlutterI18n.translate(context, "gasFee"),
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: black),
                      ),
                      UIHelper.verticalSpaceSmall,
                      Container(
                        width: size.width,
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.only(right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${FlutterI18n.translate(context, "about")} ${NumberUtil.roundDouble(model.transFee, decimalPlaces: 8)} FAB ',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: black),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (aniheight == 0) {
                                    aniheight = 120;
                                  } else {
                                    aniheight = 0;
                                  }
                                });
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    FlutterI18n.translate(context, "advance"),
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: black),
                                  ),
                                  Icon(Icons.arrow_drop_down,
                                      color: Colors.black, size: 18)
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      UIHelper.verticalSpaceSmall,
                      AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        height: aniheight,
                        child: ListView(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          children: [
                            Container(
                              width: size.width,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Center(
                                    child: Text(
                                      FlutterI18n.translate(
                                          context, "gasPrice"),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: textHintGrey,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: model.gasPriceTextController,
                                      onChanged: (value) {},
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                      textAlign: TextAlign.right,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "0.00000",
                                        hintStyle: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: textHintGrey,
                                        ),
                                        contentPadding:
                                            EdgeInsets.only(left: 10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 3),
                            Container(
                              width: size.width,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Center(
                                    child: Text(
                                      FlutterI18n.translate(
                                          context, "gasLimit"),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: textHintGrey,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: model.gasLimitTextController,
                                      onChanged: (value) {},
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                      textAlign: TextAlign.right,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "0.00000",
                                        hintStyle: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: textHintGrey,
                                        ),
                                        contentPadding:
                                            EdgeInsets.only(left: 10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                //  Container(
                //     padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                //     child: ListView(
                //       children: <Widget>[
                //         Container(
                //             padding: const EdgeInsets.all(30),
                //             decoration: const BoxDecoration(
                //                 shape: BoxShape.circle, color: primaryColor),
                //             child: Image.asset("assets/images/img/gas.png",
                //                 width: 100, height: 100)),
                //         const SizedBox(height: 30),
                //         TextField(
                //           inputFormatters: [
                //             DecimalTextInputFormatter(
                //                 decimalRange: 6,
                //                 activatedNegativeValues: false)
                //           ],
                //           keyboardType: const TextInputType.numberWithOptions(
                //               decimal: true),
                //           onChanged: (v) => model.updateTransFee(),
                //           decoration: InputDecoration(
                //             focusedBorder: const UnderlineInputBorder(
                //                 borderSide: BorderSide(
                //                     color: primaryColor, width: 1.0)),
                //             enabledBorder: const OutlineInputBorder(
                //                 borderSide: BorderSide(
                //                     color: primaryColor, width: 1.0)),
                //             hintText:
                //                 '${FlutterI18n.translate(context, "enterAmount")}(FAB)',
                //             hintStyle: headText6,
                //           ),
                //           controller: model.amountController,
                //           style: TextStyle(
                //               fontSize: 16.0,
                //               color: model.isAmountInvalid ? red : black),
                //         ),
                //         UIHelper.verticalSpaceSmall,
                //         // Balance
                //         Row(children: [
                //           Padding(
                //             padding: const EdgeInsets.only(
                //                 left: 2.0, right: 4.0, top: 2.0),
                //             child: Text(
                //                 '${FlutterI18n.translate(context, "gas")} ${FlutterI18n.translate(context, "balance")}',
                //                 style: const TextStyle(
                //                     fontSize: 12.0, color: black)),
                //           ),
                //           Text(model.gasBalance.toString(),
                //               style: const TextStyle(
                //                   fontSize: 12.0, color: Colors.black))
                //         ]),
                //         UIHelper.verticalSpaceSmall,
                //         Row(children: [
                //           Padding(
                //             padding: const EdgeInsets.only(
                //                 left: 2.0, right: 4.0, top: 2.0),
                //             child: Text(
                //                 'FAB ${FlutterI18n.translate(context, "balance")}',
                //                 style: const TextStyle(
                //                     fontSize: 12.0, color: black)),
                //           ),
                //           Text(model.fabBalance.toString(),
                //               style: const TextStyle(
                //                   fontSize: 12.0, color: black))
                //         ]),
                //         UIHelper.verticalSpaceSmall,
                //         // Gas Fee
                //         Row(children: [
                //           Padding(
                //             padding: const EdgeInsets.only(
                //                 left: 2.0, right: 4.0, top: 2.0),
                //             child: Text(
                //                 FlutterI18n.translate(context, "gasFee"),
                //                 style: const TextStyle(
                //                     fontSize: 12.0, color: black)),
                //           ),
                //           Text('${model.transFee} FAB',
                //               style: const TextStyle(
                //                   fontSize: 13.0, color: black))
                //         ]),
                //         // Slider
                //         Slider(
                //           divisions: 100,
                //           label: '${model.sliderValue.toStringAsFixed(2)}%',
                //           activeColor: primaryColor,
                //           min: 0.0,
                //           max: 100.0,
                //           onChanged: (newValue) {
                //             model.sliderOnchange(newValue);
                //           },
                //           value: model.sliderValue,
                //         ),
                //         // Advance
                //         Row(children: <Widget>[
                //           Text(FlutterI18n.translate(context, "advance"),
                //               style: headText5.copyWith(
                //                   fontWeight: FontWeight.w300)),
                //           Switch(
                //             value: model.isAdvance,
                //             inactiveTrackColor: grey,
                //             dragStartBehavior: DragStartBehavior.start,
                //             activeColor: primaryColor,
                //             onChanged: (bool isOn) {
                //               model.setBusy(true);
                //               model.isAdvance = isOn;
                //               model.setBusy(false);
                //             },
                //           ),
                //         ]),
                //         model.isAdvance
                //             ? Row(
                //                 mainAxisAlignment:
                //                     MainAxisAlignment.spaceEvenly,
                //                 children: <Widget>[
                //                   Expanded(
                //                     flex: 3,
                //                     child: Text(
                //                         FlutterI18n.translate(
                //                             context, "gasPrice"),
                //                         style: headText5.copyWith(
                //                             fontWeight: FontWeight.w300)),
                //                   ),
                //                   Expanded(
                //                       flex: 5,
                //                       child: TextField(
                //                           controller:
                //                               model.gasPriceTextController,
                //                           onChanged: (String amount) {
                //                             //   model.updateTransFee();
                //                           },
                //                           keyboardType: const TextInputType
                //                                   .numberWithOptions(
                //                               decimal:
                //                                   true), // numnber keyboard
                //                           decoration: InputDecoration(
                //                               focusedBorder:
                //                                   const UnderlineInputBorder(
                //                                       borderSide: BorderSide(
                //                                           color:
                //                                               primaryColor)),
                //                               enabledBorder:
                //                                   const UnderlineInputBorder(
                //                                       borderSide: BorderSide(
                //                                           color: grey)),
                //                               hintText: '0.00000',
                //                               hintStyle: headText5.copyWith(
                //                                   fontWeight:
                //                                       FontWeight.w300)),
                //                           style: headText5.copyWith(
                //                               fontWeight: FontWeight.w300)))
                //                 ],
                //               )
                //             : Container(),
                //         model.isAdvance
                //             ? Row(
                //                 children: <Widget>[
                //                   Expanded(
                //                       flex: 3,
                //                       child: Text(
                //                         FlutterI18n.translate(
                //                             context, "gasLimit"),
                //                         style: headText5.copyWith(
                //                             fontWeight: FontWeight.w300),
                //                       )),
                //                   Expanded(
                //                       flex: 5,
                //                       child: TextField(
                //                           controller:
                //                               model.gasLimitTextController,
                //                           onChanged: (String amount) {
                //                             // updateTransFee();
                //                           },
                //                           keyboardType: const TextInputType
                //                                   .numberWithOptions(
                //                               decimal:
                //                                   true), // numnber keyboard
                //                           decoration: InputDecoration(
                //                               focusedBorder:
                //                                   const UnderlineInputBorder(
                //                                       borderSide: BorderSide(
                //                                           color:
                //                                               primaryColor)),
                //                               enabledBorder:
                //                                   const UnderlineInputBorder(
                //                                       borderSide: BorderSide(
                //                                           color: grey)),
                //                               hintText: '0.00000',
                //                               hintStyle: headText5.copyWith(
                //                                   fontWeight:
                //                                       FontWeight.w300)),
                //                           style: headText5.copyWith(
                //                               fontWeight: FontWeight.w300)))
                //                 ],
                //               )
                //             : Container(),
                //         const SizedBox(height: 30),
                //         Row(
                //           children: <Widget>[
                //             Expanded(
                //               child: MaterialButton(
                //                   // borderSide: BorderSide(color: globals.primaryColor),
                //                   color: primaryColor,
                //                   onPressed: () {
                //                     Navigator.pop(context);
                //                   },
                //                   child: Text(
                //                       FlutterI18n.translate(
                //                           context, "cancel"),
                //                       style: const TextStyle(
                //                           color: Colors.white))),
                //             ),
                //             const SizedBox(width: 8),
                //             Expanded(
                //               child: OutlinedButton(
                //                 style: outlinedButtonStyles1,
                //                 onPressed: () async {
                //                   double amount = 0;
                //                   if (model.amountController.text != '') {
                //                     amount = double.parse(
                //                         model.amountController.text);
                //                   }
                //                   // var res = await AddGasDo(double.parse(myController.text));
                //                   model.amountController.text == ''
                //                       ? model.sharedService.showInfoFlushbar(
                //                           FlutterI18n.translate(
                //                               context, "invalidAmount"),
                //                           FlutterI18n.translate(context,
                //                               "pleaseEnterValidNumber"),
                //                           Icons.cancel,
                //                           red,
                //                           context)
                //                       : model.checkPass(amount, context);
                //                   //   debugPrint(res);
                //                 },
                //                 child: Text(
                //                   FlutterI18n.translate(context, "confirm"),
                //                   style: Theme.of(context)
                //                       .textTheme
                //                       .labelLarge!
                //                       .copyWith(color: black),
                //                 ),
                //               ),
                //             ),
                //           ],
                //         )
                //       ],
                //     ),
                // ),
              ),
            ));
  }
}
