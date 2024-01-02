import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/utils/number_util.dart';
import 'package:paycool/utils/string_util.dart';
import 'package:paycool/views/paycool_club/join_club/join_club_payment_model.dart';
import 'package:stacked/stacked.dart';
import 'package:paycool/views/paycool_club/join_club/join_paycool_club_viewmodel.dart';

class JoinPayCoolClubView extends StackedView<JoinPayCoolClubViewModel> {
  final JoinClubPaymentModel? scanToPayModel;

  const JoinPayCoolClubView({this.scanToPayModel});
  @override
  void onViewModelReady(JoinPayCoolClubViewModel model) async {
    model.scanToPayModel = scanToPayModel!;
    model.init();
  }

  @override
  Widget builder(
      BuildContext context, JoinPayCoolClubViewModel model, Widget? child) {
    model.context = context;
    model.sharedService.context = context;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(FlutterI18n.translate(context, "joinPaycoolClub"),
            style: headText4.copyWith(fontWeight: FontWeight.bold)),
      ),
      body: GestureDetector(
        onTap: () {
          debugPrint('tap');
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                UIHelper.verticalSpaceLarge,
                // heading
                Container(
                  padding: const EdgeInsets.all(15.0),
                  decoration: const BoxDecoration(
                      color: white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(10))),
                  child: Center(
                      child: Text(
                    FlutterI18n.translate(context, "orderDetails"),
                    style: headText4.copyWith(
                        fontWeight: FontWeight.bold, color: black),
                  )),
                ),
                //amount
                Container(
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(10)),
                      border: Border.all(width: 1.0, color: white)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      UIHelper.verticalSpaceSmall,

                      Container(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                FlutterI18n.translate(context, "amount"),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(color: Colors.blue),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                '${model.fixedAmountToPay} USD',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Payment type container row
                      Container(
                        padding: const EdgeInsets.only(left: 10),
                        color: primaryColor.withAlpha(75),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Text(
                                FlutterI18n.translate(context, "paymentType"),
                                style: headText5,
                                // textAlign: TextAlign.center,
                              ),
                            ),

                            // Row that contains both radio buttons
                            Expanded(
                              flex: 3,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Radio(
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          activeColor: primaryColor,
                                          value: 'DUSD',
                                          groupValue: model.groupValue,
                                          onChanged: (t) =>
                                              model.onPaymentRadioSelection(t)),
                                      Text('DUSD', style: headText6),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Radio(
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          activeColor: primaryColor,
                                          value: 'USDT',
                                          groupValue: model.groupValue,
                                          onChanged: (t) =>
                                              model.onPaymentRadioSelection(t)),
                                      Text('USDT', style: headText6),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Balance row
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                '${FlutterI18n.translate(context, "inExchange")} ${FlutterI18n.translate(context, "balance")}:',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(color: Colors.blue),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                model.groupValue == 'DUSD'
                                    ? NumberUtil.roundDouble(
                                            model.dusdExchangeBalance,
                                            decimalPlaces: 2)
                                        .toString()
                                    : NumberUtil.roundDouble(
                                            model.usdtExchangeBalance,
                                            decimalPlaces: 2)
                                        .toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Gas amount

                      Container(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                '${FlutterI18n.translate(context, "gas")} ${FlutterI18n.translate(context, "balance")}:',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(color: Colors.blue),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                model.gasAmount.toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Official address

                      Container(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                  FlutterI18n.translate(
                                      context, "officialAddress"),
                                  style: headText5),
                            ),
                            Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 2.0),
                                  child: Text(model.paycoolReferralAddress),
                                )),
                          ],
                        ),
                      ),
                      UIHelper.verticalSpaceMedium,
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${FlutterI18n.translate(context, "scanOrPasteReferralCodeBelow")}*',
                            style: headText5,
                          ),
                          UIHelper.verticalSpaceSmall,
                          Container(
                            padding: const EdgeInsets.all(10.0),
                            child: TextField(
                              scrollPadding: EdgeInsets.zero,
                              style: const TextStyle(color: white, height: 2.5),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                                prefixIconConstraints: const BoxConstraints(
                                    maxHeight: 30, minHeight: 25),
                                suffixIconConstraints: const BoxConstraints(
                                    maxHeight: 30, minHeight: 25),
                                suffixIcon: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(
                                    Icons.paste,
                                    size: 19,
                                    color: white,
                                  ),
                                  onPressed: () => model.pasteClipBoardData(),
                                ),
                                prefixIcon: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.camera_alt_outlined,
                                      color: primaryColor,
                                    ),
                                    onPressed: () => model.scanBarCode()),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: primaryColor, width: 1.0),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: white, width: 1.0),
                                ),
                              ),
                              // onChanged: (String value) =>
                              //     model.onTextFieldChange(value),
                              controller: model.referralCode,
                            ),
                          ),
                        ],
                      ),

// Error message
                      model.errorMessage.isEmpty
                          ? Container()
                          : Center(
                              child: Text(
                                  firstCharToUppercase(model.errorMessage)),
                            ),

                      // Button Row
                      UIHelper.verticalSpaceSmall,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(grey)),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              FlutterI18n.translate(context, "cancel"),
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                          UIHelper.horizontalSpaceSmall,
                          ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(primaryColor)),
                            onPressed: () {
                              model.isBusy
                                  ? debugPrint('busy')
                                  : model.joinClub();
                            },
                            child: model.isBusy
                                ? model.sharedService.loadingIndicator()
                                : Text(
                                    FlutterI18n.translate(context, "confirm"),
                                    style:
                                        Theme.of(context).textTheme.labelLarge,
                                  ),
                          ),
                        ],
                      ),
                      UIHelper.verticalSpaceSmall,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  JoinPayCoolClubViewModel viewModelBuilder(BuildContext context) =>
      JoinPayCoolClubViewModel();
}
