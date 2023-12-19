import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/models/wallet/wallet.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/utils/number_util.dart';
import 'package:paycool/views/wallet/wallet_features/transfer/transfer_viewmodel.dart';
import 'package:paycool/widgets/wallet/decimal_limit_widget.dart';
import 'package:stacked/stacked.dart';

class TransferView extends StatefulWidget {
  final WalletInfo walletInfo;
  const TransferView({Key? key, required this.walletInfo}) : super(key: key);

  @override
  State<TransferView> createState() => _TransferViewState();
}

class _TransferViewState extends State<TransferView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500), // Adjust the duration as needed
    );

    _animation = Tween<double>(begin: 0, end: 250).animate(_controller);
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

    return ViewModelBuilder<TransferViewModel>.reactive(
        viewModelBuilder: () => TransferViewModel(),
        onViewModelReady: (model) {
          model.context = context;
          model.selectedCoinWalletInfo = widget.walletInfo;
          model.initState();
        },
        builder: (context, model, child) => GestureDetector(
              onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: bgGrey,
                appBar: customAppBarWithIcon(
                  title: FlutterI18n.translate(context, "Transfer"),
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
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          child: ElevatedButton(
                            onPressed: () {
                              if (model.amountTextController.text.isEmpty ||
                                  double.parse(
                                          model.amountTextController.text) <=
                                      0) {
                                if (model.toText == 'Exchangily') {
                                } else {
                                  model.isWithdrawChoice
                                      ? model.withdrawConfirmation()
                                      : model.checkPass();
                                }
                              } else {}
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor:
                                  model.amountTextController.text.isEmpty
                                      ? grey
                                      : buttonPurple,
                            ),
                            child: Text("Confirm"),
                          )),
                    ),
                  ],
                ),
                body: Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: size.width,
                        height: size.height * 0.1,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  FlutterI18n.translate(context, "From"),
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: textHintGrey),
                                ),
                                Text(
                                  FlutterI18n.translate(context, "To"),
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: textHintGrey),
                                ),
                              ],
                            ),
                            UIHelper.horizontalSpaceMedium,
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  FlutterI18n.translate(
                                      context, model.fromText),
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: black),
                                ),
                                Text(
                                  FlutterI18n.translate(context, model.toText),
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: black),
                                ),
                              ],
                            ),
                            Expanded(child: SizedBox()),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  var temp = model.fromText;
                                  model.fromText = model.toText;
                                  model.toText = temp;
                                  model.isMoveToWallet = !model.isMoveToWallet;
                                });
                                if (model.toText == 'Exchangily') {
                                  model.toExchangeInit();
                                } else {
                                  model.toWalletInit();
                                }
                              },
                              icon: Image.asset(
                                "assets/images/new-design/swap_icon.png",
                                scale: 2.2,
                                color: textHintGrey,
                              ),
                            )
                          ],
                        ),
                      ),
                      if (model.isMoveToWallet) UIHelper.verticalSpaceSmall,
                      if (model.isMoveToWallet)
                        Container(
                          width: size.width,
                          height: 50,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: DropdownButton<String>(
                            value: model.selectedChain,
                            onChanged: (String? newValue) {
                              setState(() {
                                model.radioButtonSelection(newValue);
                                model.selectedChain = newValue;
                              });
                            },
                            items: model.chainNames
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              );
                            }).toList(),
                            underline:
                                Container(), // Removes the default underline
                            icon: Icon(Icons.arrow_drop_down,
                                color: Colors.black, size: 18),
                            isExpanded: true,
                          ),
                        ),
                      UIHelper.verticalSpaceSmall,
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
                        height: size.height * 0.1,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  TextField(
                                    controller: model.amountTextController,
                                    onChanged: (String amount) {
                                      model.updateTransFee();
                                    },
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    inputFormatters: [
                                      DecimalTextInputFormatter(
                                          decimalRange: model.token.decimal,
                                          activatedNegativeValues: false)
                                    ],
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '0.0',
                                      hintStyle: TextStyle(
                                          fontSize: 16, color: textHintGrey),
                                      contentPadding: EdgeInsets.only(left: 10),
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                          '${FlutterI18n.translate(context, "minimumAmount")}: ',
                                          style: headText6),
                                      Text(
                                          model.token.minWithdraw == null
                                              ? FlutterI18n.translate(
                                                  context, "loading")
                                              : model.token.minWithdraw
                                                  .toString(),
                                          style: headText6),
                                    ],
                                  ),
                                  model.token.minWithdraw == null
                                      ? Container()
                                      : DecimalLimitWidget(
                                          decimalLimit: model.token.decimal!)
                                ],
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
                                    Text(
                                      model.selectedCoinWalletInfo!.tickerName!,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: black),
                                    ),
                                    Text(
                                      "${FlutterI18n.translate(context, "balance")} ${model.selectedCoinWalletInfo!.availableBalance}",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: textHintGrey),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
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
                        height: size.height * 0.1,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  FlutterI18n.translate(context, "gasFee"),
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: textHintGrey),
                                ),
                                Text(
                                  FlutterI18n.translate(
                                      context, "kanbanGasFee"),
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: textHintGrey),
                                ),
                              ],
                            ),
                            UIHelper.horizontalSpaceMedium,
                            Expanded(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${NumberUtil.roundDouble(model.gasFee, decimalPlaces: model.tokenModel.decimal ?? model.decimalLimit).toString()} ${model.tokenModel.tickerName}',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: black),
                                  ),
                                  Text(
                                    '${model.kanbanGasFee} ${FlutterI18n.translate(context, "GAS")}',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: black),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (_controller.isCompleted) {
                                    _controller.reverse();
                                  } else {
                                    _controller.forward();
                                  }
                                });
                              },
                              child: Row(
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
                          duration: Duration(
                              milliseconds:
                                  500), // Adjust the duration as needed
                          height: _animation.value,
                          child: SingleChildScrollView(
                            child: Column(
                                children: model.getFeeWidget(context, size)),
                          )),
                    ],
                  ),
                ),
              ),
            ));
  }
}
