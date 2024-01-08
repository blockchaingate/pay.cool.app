import 'package:flutter/gestures.dart';
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
  const TransferView({super.key, required this.walletInfo});

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
        viewModelBuilder: () =>
            TransferViewModel(context: context, walletInfo: widget.walletInfo),
        onViewModelReady: (model) => model.toExchangeInit(),
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  FlutterI18n.translate(context, "From"),
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: textHintGrey),
                                ),
                                UIHelper.verticalSpaceSmall,
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
                            Expanded(
                              child: ListView(
                                reverse: !model.isDeposit,
                                shrinkWrap: true,
                                padding: EdgeInsets.symmetric(vertical: 5),
                                children: [
                                  Text(
                                    FlutterI18n.translate(context, "wallet"),
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: black),
                                  ),
                                  UIHelper.verticalSpaceSmall,
                                  Text(
                                    FlutterI18n.translate(context, "exchange"),
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: black),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(child: SizedBox()),
                            IconButton(
                              onPressed: () => model.swapFunction(),
                              icon: Image.asset(
                                "assets/images/new-design/swap_icon.png",
                                scale: 2.2,
                                color: textHintGrey,
                              ),
                            )
                          ],
                        ),
                      ),
                      if (!model.isDeposit) UIHelper.verticalSpaceSmall,
                      if (!model.isDeposit)
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextField(
                                    controller: model.amountController,
                                    onChanged: (String amount) {
                                      if (model.isDeposit)
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
                                  model.isDeposit
                                      ? Container()
                                      : Padding(
                                          padding:
                                              const EdgeInsets.only(left: 4.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  '${FlutterI18n.translate(context, "minimumAmount")}: ',
                                                  style: headText6),
                                              Text(
                                                  model.token.minWithdraw ==
                                                          null
                                                      ? FlutterI18n.translate(
                                                          context, "loading")
                                                      : model.token.minWithdraw
                                                          .toString(),
                                                  style: headText6),
                                            ],
                                          ),
                                        ),
                                  model.token.minWithdraw == null
                                      ? Container()
                                      : Padding(
                                          padding:
                                              const EdgeInsets.only(left: 4.0),
                                          child: DecimalLimitWidget(
                                              decimalLimit:
                                                  model.token.decimal!),
                                        )
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
                                      model.walletInfo.tickerName!,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: black),
                                    ),
                                    Text(
                                      "${FlutterI18n.translate(context, "balance")} ${model.isDeposit ? model.walletInfo.availableBalance : model.walletInfo.inExchange}",
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
                        FlutterI18n.translate(context, "transactionFee"),
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
                                  model.isDeposit
                                      ? Text(
                                          '${model.transFee.toString()} ${model.feeUnit}',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: black),
                                        )
                                      : Text(
                                          '${model.token.feeWithdraw} ${model.specialTicker!.contains('(') ? model.specialTicker!.split('(')[0] : model.specialTicker}',
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
                            milliseconds: 500), // Adjust the duration as needed
                        height: _animation.value,
                        child: SingleChildScrollView(
                          child: Column(
                              children: model.getFeeWidget(context, size)),
                        ),
                      ),
                      UIHelper.verticalSpaceSmall,
                      model.isShowErrorDetailsButton
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: RichText(
                                    text: TextSpan(
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                fontWeight: FontWeight.bold),
                                        text:
                                            '${FlutterI18n.translate(context, "error")} ${FlutterI18n.translate(context, "details")}',
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            model.showDetailsMessageToggle();
                                          }),
                                  ),
                                ),
                                !model.isShowDetailsMessage
                                    ? const Icon(Icons.arrow_drop_down,
                                        color: Colors.red, size: 26)
                                    : const Icon(Icons.arrow_drop_up,
                                        color: Colors.red, size: 26)
                              ],
                            )
                          : Container(),
                      model.isShowDetailsMessage
                          ? Center(
                              child: Text(model.serverError, style: headText6),
                            )
                          : Container(),
                    ],
                  ),
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
                          margin: EdgeInsets.symmetric(horizontal: 15),
                          child: ElevatedButton(
                            onPressed: () => model.verifyFields(),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor:
                                  model.amountController.text.isEmpty
                                      ? grey
                                      : buttonPurple,
                            ),
                            child: Text(
                              "Confirm",
                              style: buttonText,
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            ));
  }
}
