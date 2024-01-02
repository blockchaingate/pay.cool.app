import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/lightning-remit/lightening_remit_viewmodel.dart';
import 'package:paycool/views/lightning-remit/lightning_remit_transfer_history.view.dart';
import 'package:stacked/stacked.dart';

class LightningRemitView extends StatelessWidget {
  const LightningRemitView({super.key});

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
            key: model.scaffoldKey,
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
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
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
                              onPressed: () async {
                                model.contentPaste();
                              },
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
                  model.exchangeBalances.isNotEmpty
                      ? Container(
                          width: size.width,
                          //  height: size.height * 0.1,
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
                                child: SizedBox(
                                  height: size.height * 0.08,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
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
                        )
                      : SizedBox(),
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
                            onPressed: () => model.transfer(),
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
                            onPressed: () {
                              model.showBarcode();
                            },
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
                  model.isBusy
                      ? Align(
                          alignment: Alignment.center,
                          child: model.sharedService
                              .stackFullScreenLoadingIndicator())
                      : Container()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CoinListBottomSheetFloatingActionButton extends StatelessWidget {
  const CoinListBottomSheetFloatingActionButton(
      {super.key, required this.model});
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
