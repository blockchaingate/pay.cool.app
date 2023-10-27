import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/constants.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/environments/environment.dart';
import 'package:paycool/models/bond/rm/order_bond_model.dart';
import 'package:paycool/models/bond/rm/update_order_request_model.dart';
import 'package:paycool/models/bond/vm/bond_symbol_model.dart';
import 'package:paycool/models/bond/vm/me_model.dart';
import 'package:paycool/models/bond/vm/token_balance_model.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/api_service.dart';
import 'package:paycool/services/coin_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/bond/helper.dart';
import 'package:paycool/views/bond/progressIndicator.dart';
import 'package:paycool/views/paycool/paycool_service.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';

class SelectPaymentBondView extends StatefulWidget {
  final int quantity;
  final String symbol;
  final int amount;
  final String orderNumber;
  final BondSembolModel? bondSembolVm;
  final BondMeModel? bondMeVm;

  const SelectPaymentBondView(this.bondMeVm, this.quantity, this.amount,
      this.symbol, this.orderNumber, this.bondSembolVm,
      {super.key});

  @override
  State<SelectPaymentBondView> createState() => _SelectPaymentBondViewState();
}

class _SelectPaymentBondViewState extends State<SelectPaymentBondView> {
  ApiService apiService = locator<ApiService>();
  final NavigationService navigationService = locator<NavigationService>();
  final paycoolService = locator<PayCoolService>();
  WalletService walletService = locator<WalletService>();
  SharedService sharedService = locator<SharedService>();
  final coinService = locator<CoinService>();
  final TextEditingController _emailController = TextEditingController();
  String? txHash;

  String? selectedChainValue;
  String? selectedValueChain;
  List<String> dropdownItemsChainNames = ['ETHEREUM', 'FAB / KANBAN', "BSC"];

  String? selectedValueCoin;
  List<String> dropdownItemsCoin = ["USDT"];
  int index = 0;

  bool loading = false;

  TokensBalanceModel? tokensBalanceModel;

  double? coinBalance;
  double? gasBalance;

  int? needGasBalance;

  bool isButtonEnabled = false;

  @override
  void initState() {
    _emailController.text = widget.bondMeVm!.email!;
    selectedChainValue = dropdownItemsChainNames[1];
    selectedValueCoin = dropdownItemsCoin[0];
    setInitialBalance();
    super.initState();
  }

  Future<void> setInitialBalance() async {
    setChainShort(selectedChainValue);
    setCoins();
    await getBalance();
    checkBalance().whenComplete(() {
      if (coinBalance! >= widget.amount &&
          gasBalance! >= needGasBalance! &&
          _emailController.text.isNotEmpty) {
        setState(() {
          isButtonEnabled = true;
        });
      } else {
        setState(() {
          isButtonEnabled = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: ModalProgressHUD(
        inAsyncCall: loading,
        progressIndicator: CustomIndicator.indicator(),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text(
              FlutterI18n.translate(context, "payment"),
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            elevation: 0,
          ),
          body: SizedBox(
            width: size.width,
            height: size.height,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/bgImage.png"),
                    fit: BoxFit.cover),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: Column(
                  children: [
                    SizedBox(
                      height: size.height * 0.05,
                    ),
                    SizedBox(
                      width: size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          UIHelper.verticalSpaceLarge,
                          SizedBox(
                            width: size.width,
                            child: CustomPaint(
                              painter: DottedBorderPainter(),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "${FlutterI18n.translate(context, "orderNumber")}: ${widget.orderNumber}",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 13)),
                                    UIHelper.verticalSpaceSmall,
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            "${FlutterI18n.translate(context, "orderType")}: ${widget.symbol}",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13)),
                                        Text(
                                            "${FlutterI18n.translate(context, "total")}: ${String.fromCharCodes(Runes('\u0024'))}${widget.amount}",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13)),
                                        SizedBox()
                                      ],
                                    ),
                                    UIHelper.verticalSpaceSmall,
                                    Text(
                                        "${FlutterI18n.translate(context, "amount")}: ${widget.quantity}",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 13)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          UIHelper.verticalSpaceLarge,
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: size.width,
                                child: Text(
                                  FlutterI18n.translate(context, "selectChain"),
                                  style: TextStyle(color: Colors.white),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              SizedBox(
                                width: size.width,
                                child: Text(
                                  gasBalance != null
                                      ? "${FlutterI18n.translate(context, "gasBalance")}: ${makeShort((gasBalance! / 1e18))}"
                                      : "",
                                  style: gasBalance != null &&
                                          needGasBalance != null &&
                                          gasBalance! > needGasBalance!
                                      ? TextStyle(color: Colors.white)
                                      : TextStyle(),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[200],
                                ),
                                child: DropdownButton<String>(
                                  value: selectedChainValue,
                                  dropdownColor: Colors.white,
                                  underline: SizedBox(),
                                  isExpanded: true,
                                  iconEnabledColor: Colors.black,
                                  onChanged: txHash != null
                                      ? null
                                      : (String? newValue) async {
                                          setState(() {
                                            selectedChainValue = newValue;
                                            selectedValueCoin = null;
                                            isButtonEnabled = false;
                                            coinBalance = null;
                                          });
                                          setChainShort(newValue);
                                          setCoins();
                                          await getBalance();
                                        },
                                  items: dropdownItemsChainNames
                                      .map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          UIHelper.verticalSpaceMedium,
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: size.width,
                                child: Text(
                                  FlutterI18n.translate(context, "selectCoin"),
                                  style: TextStyle(color: Colors.white),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              SizedBox(
                                width: size.width,
                                child: Text(
                                  coinBalance != null
                                      ? "${FlutterI18n.translate(context, "coinBalance")}: ${makeShort(coinBalance!)}"
                                      : "",
                                  style: coinBalance != null &&
                                          coinBalance! > widget.amount
                                      ? TextStyle(color: Colors.white)
                                      : TextStyle(),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[200],
                                ),
                                child: DropdownButton<String>(
                                  value: selectedValueCoin,
                                  dropdownColor: Colors.white,
                                  underline: SizedBox(),
                                  isExpanded: true,
                                  iconEnabledColor: Colors.black,
                                  onChanged: txHash != null
                                      ? null
                                      : (String? newValue) async {
                                          setState(() {
                                            selectedValueCoin = newValue!;
                                            index = dropdownItemsCoin
                                                .indexWhere((element) =>
                                                    element == newValue);
                                          });
                                          checkBalance().whenComplete(() {
                                            if (coinBalance! >= widget.amount &&
                                                gasBalance! >=
                                                    needGasBalance! &&
                                                _emailController
                                                    .text.isNotEmpty) {
                                              setState(() {
                                                isButtonEnabled = true;
                                              });
                                            } else {
                                              setState(() {
                                                isButtonEnabled = false;
                                              });
                                            }
                                          });
                                        },
                                  items: dropdownItemsCoin.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          UIHelper.verticalSpaceMedium,
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      "${FlutterI18n.translate(context, "forMoreDetais")}:",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                TextSpan(
                                  text: ' www.dnb.pay.cool',
                                  style: TextStyle(
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      _launchUrl("https://dnb.pay.cool/");
                                    },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    UIHelper.verticalSpaceMedium,
                    txHash != null
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: size.width * 0.7,
                                child: InkWell(
                                  onTap: () {
                                    String link = environment["Bond"]
                                                ["Endpoints"]
                                            ["$selectedValueChain"] +
                                        txHash;
                                    _launchUrl(link);
                                  },
                                  child: RichText(
                                    text: TextSpan(
                                      text: txHash!,
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline),
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Clipboard.setData(
                                      ClipboardData(text: txHash!));
                                  callSMessage(
                                      context,
                                      FlutterI18n.translate(
                                          context, "copiedToClipboard"),
                                      duration: 2);
                                },
                                icon: Icon(
                                  Icons.copy,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : SizedBox(),
                    Expanded(child: SizedBox()),
                    Container(
                      width: size.width * 0.8,
                      height: 50,
                      decoration: isButtonEnabled
                          ? BoxDecoration(
                              gradient: buttoGradient,
                              borderRadius: BorderRadius.circular(40.0),
                            )
                          : BoxDecoration(
                              gradient: buttoGradientDisbale,
                              borderRadius: BorderRadius.circular(40.0),
                            ),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (txHash == null) {
                            if (!isButtonEnabled) {
                              null;
                            } else {
                              var param = OrderBondModel(
                                  paymentAmount: widget.amount,
                                  quantity: widget.quantity,
                                  paymentCoin: selectedValueCoin,
                                  paymentChain: selectedValueChain,
                                  symbol: widget.symbol,
                                  paymentCoinAmount: widget.amount);

                              await showDetails(
                                      context, size, param, widget.bondMeVm!)
                                  .whenComplete(() {
                                setState(() {
                                  loading = false;
                                });
                              });
                            }
                          } else {
                            navigationService.navigateTo(DashboardViewRoute);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(
                            txHash == null
                                ? FlutterI18n.translate(context, "payNow")
                                : FlutterI18n.translate(context, "done"),
                            style: isButtonEnabled
                                ? TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  )
                                : TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white38)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  setChainShort(String? chain) {
    if (chain == "ETHEREUM") {
      setState(() {
        selectedValueChain = "ETH";
      });
    } else if (chain == "FAB / KANBAN") {
      setState(() {
        selectedValueChain = "KANBAN";
      });
    } else if (chain == "BSC") {
      setState(() {
        selectedValueChain = "BNB";
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> bondApprove(Size size) async {
    double amount;

    String toAddress = environment["Bond"]["Chains"]["$selectedValueChain"]
        ["acceptedTokens"][index]["id"];

    if (selectedValueChain == "KANBAN") {
      toAddress = environment["Bond"]["CoinPool"];
    }

    String? abiHex;

    var seed = await walletService.getSeedDialog(sharedService.context);

    if (seed == null) {
      setState(() {
        loading = false;
      });
      throw Exception("Seed is null");
    }

    if (selectedValueChain == 'ETH') {
      amount = widget.quantity * 100 * 1e6;

      await paycoolService
          .encodeEthApproveAbiHex(
              context,
              environment["Bond"]["Chains"]["$selectedValueChain"]
                  ["bondAddress"],
              amount)
          .then((value) async {
        setState(() {
          abiHex = Constants.bondApproveEthAbiCode + value.toString();
        });
      });
    } else if (selectedValueChain == 'KANBAN') {
      amount = widget.quantity * 100 * 1e18;

      await paycoolService
          .encodeKanbanApproveAbiHex(
              context,
              environment["Bond"]["Chains"]["$selectedValueChain"]
                  ["bondAddress"],
              environment["Bond"]["Chains"]["$selectedValueChain"]
                  ["acceptedTokens"][index]["id"],
              amount)
          .then((value) async {
        setState(() {
          abiHex = Constants.bondApproveKanbanAbiCode + value.toString();
        });
      });
    } else if (selectedValueChain == 'BNB') {
      amount = widget.quantity * 100 * 1e6;

      await paycoolService
          .encodeEthApproveAbiHex(
              context,
              environment["Bond"]["Chains"]["$selectedValueChain"]
                  ["bondAddress"],
              amount)
          .then((value) async {
        setState(() {
          abiHex = Constants.bondApproveEthAbiCode + value.toString();
        });
      });
    }

    await paycoolService
        .signSendTxBond(
      seed,
      abiHex!,
      toAddress,
      chain: selectedValueChain!,
    )
        .then((value) async {
      if (value != null) {
        await bondPurchase(seed, size);
      }
    }).whenComplete(() {
      setState(() {
        loading = false;
      });
    });
  }

  Future<void> bondPurchase(Uint8List seed, Size size) async {
    double amount;

    String toAddress =
        environment["Bond"]["Chains"]["$selectedValueChain"]["bondAddress"];

    String? abiHex;

    if (selectedValueChain == 'ETH') {
      amount = widget.quantity * 100 * 1e6;

      await paycoolService
          .encodeEthPurchaseAbiHex(
              context,
              _emailController.text,
              environment["Bond"]["Chains"]["$selectedValueChain"]
                  ["acceptedTokens"][index]["id"],
              amount)
          .then((value) {
        setState(() {
          abiHex = Constants.bondAbiCodeEth + value.toString();
        });
      });
    } else if (selectedValueChain == 'KANBAN') {
      amount = widget.quantity * 100 * 1e18;

      await paycoolService
          .encodeKanbanPurchaseAbiHex(
              context,
              _emailController.text,
              environment["Bond"]["Chains"]["$selectedValueChain"]
                  ["acceptedTokens"][index]["id"],
              amount)
          .then((value) {
        setState(() {
          abiHex = Constants.bondAbiCodeKanban + value.toString();
        });
      });
    } else if (selectedValueChain == 'BNB') {
      amount = widget.quantity * 100 * 1e6;

      await paycoolService
          .encodeEthPurchaseAbiHex(
              context,
              _emailController.text,
              environment["Bond"]["Chains"]["$selectedValueChain"]
                  ["acceptedTokens"][index]["id"],
              amount)
          .then((value) {
        setState(() {
          abiHex = Constants.bondAbiCodeEth + value.toString();
        });
      });
    }

    await paycoolService
        .signSendTxBond(seed, abiHex!, toAddress,
            chain: selectedValueChain!, incNonce: true)
        .then((value) async {
      setState(() {
        txHash = value;
        loading = false;
      });
      await apiService.updateTxid(context, widget.orderNumber, txHash!);
    }).whenComplete(() {
      setState(() {
        loading = false;
      });
    });
  }

  setCoins() {
    dropdownItemsCoin.clear();
    var coins =
        environment["Bond"]["Chains"]["$selectedValueChain"]["acceptedTokens"];

    for (var element in coins) {
      dropdownItemsCoin.add(element["symbol"]);
    }
  }

  Future<void> getBalance() async {
    setState(() {
      loading = true;
    });

    try {
      List<String> tokenIds = [];

      String? walletAddress = selectedValueChain == "KANBAN"
          ? await CoinService().getCoinWalletAddress("FAB")
          : await CoinService().getCoinWalletAddress("ETH");

      var coins = environment["Bond"]["Chains"]["$selectedValueChain"]
          ["acceptedTokens"];

      for (var element in coins) {
        tokenIds.add(element["id"]);
      }

      var param = {"native": walletAddress, "tokens": tokenIds};
      // var param = {
      //   // "native": "0x2F62CEACb04eAbF8Fc53C195C5916DDDfa4BED02", //ETH
      //   // "native": "0x772De0B32771e33dfe05C1a7c2832dF09dabE43a", // BNB
      //   // "native": "0x9d95ee21e4f1b05bbfd0094daf4ce110deb00931", // KANBAN
      //   "tokens": tokenIds
      // };

      await apiService
          .getTokensBalance(context, selectedValueChain!, param)
          .then((value) {
        if (value != null) {
          setState(() {
            tokensBalanceModel = value;
            gasBalance = double.parse(tokensBalanceModel!.native!);

            needGasBalance = environment["Bond"]["Chains"][selectedValueChain]
                    ["gasPrice"] *
                environment["Bond"]["Chains"][selectedValueChain]["gasLimit"] *
                2;
          });
        }
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
    setState(() {
      loading = false;
    });
  }

  Future<bool> checkBalance() async {
    try {
      var currentTokenIdIndex = tokensBalanceModel!.tokens!.ids!.indexWhere(
          (element) =>
              element ==
              environment["Bond"]["Chains"]["$selectedValueChain"]
                  ["acceptedTokens"][index]["id"]);

      if (selectedValueChain == "KANBAN") {
        setState(() {
          coinBalance = double.parse(
                  tokensBalanceModel!.tokens!.balances![currentTokenIdIndex]) /
              1e18;
        });
      } else {
        setState(() {
          coinBalance = double.parse(
                  tokensBalanceModel!.tokens!.balances![currentTokenIdIndex]) /
              1e6;
        });
      }
    } catch (e) {
      setState(() {
        coinBalance = 0;
      });
    }
    return true;
  }

  Future<void> showDetails(
    BuildContext contexta,
    Size size,
    OrderBondModel orderBondRm,
    BondMeModel bondMeVm,
  ) async {
    final scrollController = ScrollController();

    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext dialogContext) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return Dialog(
                elevation: 0.0,
                backgroundColor: Colors.transparent,
                child: Scrollbar(
                  interactive: true,
                  controller: scrollController,
                  thumbVisibility: true,
                  radius: Radius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                FlutterI18n.translate(
                                    context, "elSalvadorDigital"),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              Text(
                                  FlutterI18n.translate(
                                      context, "dnbBondGuarantee"),
                                  style: TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black)),
                              UIHelper.verticalSpaceMedium,
                              Text(
                                  FlutterI18n.translate(
                                      context, "orderInformation"),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                              Text(
                                "${FlutterI18n.translate(context, "bondType")}: ${orderBondRm.symbol!}",
                              ),
                              Text(
                                "${FlutterI18n.translate(context, "chainName")}: ${orderBondRm.paymentChain!}",
                              ),
                              Text(
                                "${FlutterI18n.translate(context, "coinName")}: ${orderBondRm.paymentCoin!}",
                              ),
                              Text(
                                "${FlutterI18n.translate(context, "quantity")}: ${orderBondRm.quantity!}",
                              ),
                              UIHelper.verticalSpaceMedium,
                              Text(
                                  FlutterI18n.translate(
                                      context, "bondInformation"),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                              Text(
                                "${FlutterI18n.translate(context, "name")}: ${widget.bondSembolVm!.name!}",
                              ),
                              Text(
                                "${FlutterI18n.translate(context, "faceValue")}: ${widget.bondSembolVm!.faceValue!} ${FlutterI18n.translate(context, "usd")}",
                              ),
                              Text(
                                "${FlutterI18n.translate(context, "interestRate")}: ${widget.bondSembolVm!.couponRate!} %",
                              ),
                              Text(
                                "${FlutterI18n.translate(context, "issuePrice")}: ${widget.bondSembolVm!.issuePrice!} ${FlutterI18n.translate(context, "usd")}",
                              ),
                              Text(
                                "${FlutterI18n.translate(context, "maturity")}: ${widget.bondSembolVm!.maturity!} ${FlutterI18n.translate(context, "year")}",
                              ),
                              UIHelper.verticalSpaceMedium,
                              Text(
                                  FlutterI18n.translate(
                                      context, "personalInfo"),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                              Text(
                                "${FlutterI18n.translate(context, "email")}: ${bondMeVm.email!}",
                              ),
                              Text(
                                "${FlutterI18n.translate(context, "refferalCode")}: ${bondMeVm.referralCode!}",
                              ),
                              UIHelper.verticalSpaceMedium,
                              Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                height: 45,
                                decoration: BoxDecoration(
                                  gradient: buttoGradient,
                                  borderRadius: BorderRadius.circular(40.0),
                                ),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    Navigator.pop(dialogContext);
                                    setState(() {
                                      loading = true;
                                    });

                                    var param = UpdateOrderRequestModel(
                                        paymentChain: selectedChainValue,
                                        paymentCoin: selectedValueCoin,
                                        paymentCoinAmount: widget.quantity);

                                    try {
                                      await ApiService()
                                          .updatePaymentBond(contexta,
                                              widget.orderNumber, param)
                                          .then((value) async {
                                        if (value != null) {
                                          if (widget.bondMeVm!.kycLevel! < 2) {
                                            await apiService
                                                .confirmOrderBondWithoutKyc(
                                                    context,
                                                    widget.orderNumber);
                                          } else {
                                            await apiService.confirmOrderBond(
                                                context, widget.orderNumber);
                                          }
                                          await bondApprove(size);
                                        }
                                      });
                                    } catch (e) {
                                      loading = false;
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                  ),
                                  child: Text(
                                    FlutterI18n.translate(
                                        context, "confirmPurchase"),
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                      ),
                    ),
                  ),
                ));
          });
        });
  }
}

class DottedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const double dashWidth = 10; // Width of each dash
    const double dashSpace = 10; // Space between each dash

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }

    // Draw right border
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width, startY),
        Offset(size.width, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }

    // Draw bottom border
    startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height),
        Offset(startX + dashWidth, size.height),
        paint,
      );
      startX += dashWidth + dashSpace;
    }

    // Draw left border
    startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
