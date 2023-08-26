import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/constants.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/environments/environment.dart';
import 'package:paycool/models/bond/rm/order_bond_model.dart';
import 'package:paycool/models/bond/vm/bond_symbol_model.dart';
import 'package:paycool/models/bond/vm/me_model.dart';
import 'package:paycool/models/bond/vm/token_balance_model.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/api_service.dart';
import 'package:paycool/services/coin_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/bond/progressIndicator.dart';
import 'package:paycool/views/paycool/paycool_service.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';

class SelectPaymentBondView extends StatefulWidget {
  final int quantity;
  final String symbol;
  final int amount;
  final BondSembolModel? bondSembolVm;
  final BondMeModel? bondMeVm;

  const SelectPaymentBondView(
      this.bondMeVm, this.quantity, this.amount, this.symbol, this.bondSembolVm,
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

  String? selectedValueChainValue;
  String? selectedValueChain;
  List<String> dropdownItemsChainNames = ['ETHEREUM', 'KANBAN', "BSC"];

  String? selectedValueCoin;
  List<String> dropdownItemsCoin = [];
  int index = 0;
  bool isChainSelected = false;

  bool loading = false;

  bool isBalanceOk = false;
  bool isGasOk = false;
  TokensBalanceModel? tokensBalanceModel;

  @override
  void initState() {
    _emailController.text = widget.bondMeVm!.email!;
    super.initState();
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
                          TextField(
                            controller: _emailController,
                            style: TextStyle(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Please enter your e-mail address',
                              hintStyle: TextStyle(
                                  color: inputText,
                                  fontWeight: FontWeight.w400),
                              fillColor: Colors.transparent,
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                  color: Colors
                                      .white54, // Change the color to your desired border color
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                  color: Colors
                                      .white54, // Change the color to your desired border color
                                ),
                              ),
                            ),
                          ),
                          UIHelper.verticalSpaceMedium,
                          Container(
                            width: MediaQuery.of(context).size.width *
                                0.9, // Set the width to 80% of the screen width
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[200],
                            ),
                            child: DropdownButton<String>(
                              value: selectedValueChainValue,
                              hint: Text(
                                'Select Chain',
                                style: TextStyle(color: Colors.black),
                              ),
                              dropdownColor: Colors.white,
                              underline: SizedBox(),
                              isExpanded: true,
                              iconEnabledColor: Colors.black,
                              onChanged: (String? newValue) async {
                                setState(() {
                                  selectedValueChainValue = newValue;
                                  isChainSelected = true;
                                  selectedValueChain = setChainShort(newValue);
                                });
                                await getBalance();
                                setCoins();
                              },
                              items:
                                  dropdownItemsChainNames.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14),
                            ),
                          ),
                          if (isChainSelected) UIHelper.verticalSpaceMedium,
                          if (isChainSelected)
                            Container(
                              width: MediaQuery.of(context).size.width *
                                  0.9, // Set the width to 80% of the screen width
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[200],
                              ),
                              child: DropdownButton<String>(
                                value: selectedValueCoin,
                                hint: Text(
                                  'Select Coin',
                                  style: TextStyle(color: Colors.black),
                                ),
                                dropdownColor: Colors.white,
                                underline: SizedBox(),
                                isExpanded: true,
                                iconEnabledColor: Colors.black,
                                onChanged: (String? newValue) async {
                                  setState(() {
                                    selectedValueCoin = newValue!;
                                    index = dropdownItemsCoin.indexWhere(
                                        (element) => element == newValue);
                                  });
                                  checkBalance();
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
                          UIHelper.verticalSpaceMedium,
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "For more detail visit: ",
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
                                  var snackBar = SnackBar(
                                      content: Text('Copied to Clipboard'));
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
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
                      width: size.width * 0.9,
                      height: 45,
                      decoration: BoxDecoration(
                        gradient: buttoGradient,
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (txHash == null) {
                            if (selectedValueCoin == null ||
                                selectedValueChain == null ||
                                _emailController.text.isEmpty) {
                              var snackBar = SnackBar(
                                  content: Text(
                                      'Please select coin, chain and enter email address'));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                              return;
                            }

                            if (isBalanceOk && isGasOk) {
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
                            } else {
                              var snackBar = SnackBar(
                                  content: Text(
                                      'Please check your balance and gas price'));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                              return;
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
                          txHash == null ? 'Confirm Payment' : "Done",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

  String setChainShort(String? chain) {
    if (chain == "ETHEREUM") {
      return "ETH";
    } else if (chain == "KANBAN") {
      return "KANBAN";
    } else if (chain == "BSC") {
      return "BNB";
    } else {
      return "";
    }
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> bondApprove(Size size) async {
    var amount;

    String toAddress = environment["Bond"]["Chains"]["$selectedValueChain"]
        ["acceptedTokens"][index]["id"];

    if (selectedValueChain == "KANBAN") {
      toAddress = environment["Bond"]["CoinPool"];
    }

    String? abiHex;

    var seed = await walletService.getSeedDialog(sharedService.context);

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
      seed!,
      abiHex!,
      toAddress,
      chain: selectedValueChain!,
    )
        .then((value) async {
      if (value != null) {
        await bondPurchase(seed, size);
      }
    }); //bond address
  }

  Future<void> bondPurchase(Uint8List seed, Size size) async {
    var amount;

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
          .then((value) async {
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
          .then((value) async {
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
          .then((value) async {
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

      await apiService
          .getTokensBalance(context, selectedValueChain!, param)
          .then((value) {
        if (value != null) {
          setState(() {
            tokensBalanceModel = value;
          });
        }
      }).whenComplete(() async {
        await checkGasPrice();
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

  Future<void> checkGasPrice() async {
    int gasPrice = 0;

    if (selectedValueChain == "KANBAN") {
      gasPrice = environment["chains"]["KANBAN"]["gasPrice"] *
          environment["chains"]["KANBAN"]["gasLimit"] *
          2;
    } else {
      gasPrice = environment["Bond"]["Chains"]["ETH"]["gasPrice"] *
          environment["Bond"]["Chains"]["ETH"]["gasLimit"] *
          2;
    }

    if (int.parse(tokensBalanceModel!.native!) >= gasPrice) {
      setState(() {
        isGasOk = true;
      });
    } else {
      var snackBar = SnackBar(content: Text('Insaufficient gas'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(() {
        isGasOk = false;
      });
    }
  }

  Future<void> checkBalance() async {
    double balance;
    var currentTokenIdIndex = tokensBalanceModel!.tokens!.ids!.indexWhere(
        (element) =>
            element ==
            environment["Bond"]["Chains"]["$selectedValueChain"]
                ["acceptedTokens"][index]["id"]);

    if (selectedValueChain == "KANBAN") {
      balance = double.parse(
              tokensBalanceModel!.tokens!.balances![currentTokenIdIndex]) /
          1e18;
    } else {
      balance = double.parse(
              tokensBalanceModel!.tokens!.balances![currentTokenIdIndex]) /
          1e6;
    }

    if (balance >= widget.amount) {
      setState(() {
        isBalanceOk = true;
      });
    } else {
      var snackBar = SnackBar(content: Text('Insaufficient balance'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(() {
        isBalanceOk = false;
      });
    }
  }

  Future<void> showDetails(
    BuildContext context,
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
                    height: MediaQuery.of(context).size.height * 0.8,
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
                                "El Salvador Digital National Bond",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              Text(
                                  "DNB is a national bond guaranteed by the El Salvador government to repay the principal and interest obligations according to the terms of the bond.",
                                  style: TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black)),
                              UIHelper.verticalSpaceMedium,
                              Text("Order Information",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                              Text("Bond Type: ${orderBondRm.symbol!}"),
                              Text("Chain Name: ${orderBondRm.paymentChain!}"),
                              Text("Coin Name: ${orderBondRm.paymentCoin!}"),
                              Text("Quantity: ${orderBondRm.quantity!}"),
                              UIHelper.verticalSpaceMedium,
                              Text("Bond Information",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                              Text("Name: ${widget.bondSembolVm!.name}"),
                              Text(
                                  "Face Value: ${widget.bondSembolVm!.faceValue}"),
                              Text(
                                  "Interest Rate: ${widget.bondSembolVm!.couponRate}% (per year)"),
                              Text(
                                  "Issue price: ${widget.bondSembolVm!.issuePrice}"),
                              Text(
                                  "Maturity: ${widget.bondSembolVm!.maturity} years"),
                              UIHelper.verticalSpaceMedium,
                              Text("Personal Information",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                              Text("Email: ${bondMeVm.email!}"),
                              Text("Referral Code: ${bondMeVm.referralCode!}"),
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
                                    try {
                                      await ApiService()
                                          .orderBond(context, orderBondRm)
                                          .then((value) async {
                                        if (value != null) {
                                          if (widget.bondMeVm!.kycLevel! < 2) {
                                            await apiService
                                                .confirmOrderBondWithoutKyc(
                                                    context,
                                                    value.bondOrder!.bondId
                                                        .toString());
                                          } else {
                                            await apiService.confirmOrderBond(
                                                context,
                                                value.bondOrder!.bondId
                                                    .toString());
                                          }
                                          await bondApprove(size);
                                        }
                                      });
                                    } catch (e) {
                                      setState(() {
                                        loading = false;
                                      });
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                  ),
                                  child: Text(
                                    'Confirm Payment',
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
