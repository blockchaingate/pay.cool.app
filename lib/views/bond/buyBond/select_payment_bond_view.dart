import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/constants.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/environments/environment.dart';
import 'package:paycool/models/bond/vm/me_vm.dart';
import 'package:paycool/models/bond/vm/order_bond_vm.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/api_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/paycool/paycool_service.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';

class SelectPaymentBondView extends StatefulWidget {
  final BondMeVm? bondMeVm;
  final OrderBondVm? orderBondVm;
  const SelectPaymentBondView(this.orderBondVm, this.bondMeVm, {super.key});

  @override
  State<SelectPaymentBondView> createState() => _SelectPaymentBondViewState();
}

class _SelectPaymentBondViewState extends State<SelectPaymentBondView> {
  ApiService apiService = locator<ApiService>();
  final NavigationService navigationService = locator<NavigationService>();
  final paycoolService = locator<PayCoolService>();
  WalletService walletService = locator<WalletService>();
  SharedService sharedService = locator<SharedService>();
  final TextEditingController _emailController = TextEditingController();
  String? txHash;

  String? selectedValueCoin;
  List<String> dropdownItemsCoin = ['USDT'];

  String? selectedValueChain;
  List<String> dropdownItemsChain = ['ETH', 'KANBAN', "BNB"];

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
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
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
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
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
                              value: selectedValueChain,
                              hint: Text(
                                'Select Chain',
                                style: TextStyle(color: Colors.black),
                              ),
                              dropdownColor: Colors.white,
                              underline: SizedBox(),
                              isExpanded: true,
                              iconEnabledColor: Colors.black,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedValueChain = newValue;
                                });
                              },
                              items: dropdownItemsChain.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14),
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
                              value: selectedValueCoin,
                              hint: Text(
                                'Select Coin',
                                style: TextStyle(color: Colors.black),
                              ),
                              dropdownColor: Colors.white,
                              underline: SizedBox(),
                              isExpanded: true,
                              iconEnabledColor: Colors.black,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedValueCoin = newValue!;
                                });
                              },
                              items: dropdownItemsCoin.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14),
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
                        ? Align(
                            alignment: Alignment.center,
                            child: InkWell(
                              onTap: () {
                                selectedValueChain == "KANBAN"
                                    ? _launchUrl(
                                        "https://test.exchangily.com/explorer/tx-detail/$txHash")
                                    : selectedValueChain == "ETH"
                                        ? _launchUrl(
                                            "https://goerli.etherscan.io/tx/$txHash")
                                        : _launchUrl(
                                            "https://testnet.bscscan.com/tx/$txHash");
                              },
                              child: Text(
                                txHash!,
                                style: TextStyle(
                                  fontSize: 24.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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
                            await apiService.confirmOrderBond(
                                context,
                                widget.orderBondVm!.bondOrder!.bondId
                                    .toString());
                            await bondApprove(size);
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

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> bondApprove(Size size) async {
    var amount;

    String toAddress = environment["Bond"]["Chains"]["$selectedValueChain"]
        ["acceptedTokens"]["id"];

    if (selectedValueChain == "KANBAN") {
      toAddress = environment["Bond"]["CoinPool"];
    }

    String? abiHex;

    var seed = await walletService.getSeedDialog(sharedService.context);

    if (selectedValueChain == 'ETH') {
      amount = widget.orderBondVm!.bondOrder!.quantity! * 100 * 1e6;

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
      amount = widget.orderBondVm!.bondOrder!.quantity! * 100 * 1e18;

      await paycoolService
          .encodeKanbanApproveAbiHex(
              context,
              environment["Bond"]["Chains"]["$selectedValueChain"]
                  ["bondAddress"],
              131073,
              amount) //TODO exg cointype will come here
          .then((value) async {
        setState(() {
          abiHex = Constants.bondApproveKanbanAbiCode + value.toString();
        });
      });
    } else if (selectedValueChain == 'BNB') {
      amount = widget.orderBondVm!.bondOrder!.quantity! * 100 * 1e6;

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
      amount = widget.orderBondVm!.bondOrder!.quantity! * 100 * 1e6;

      await paycoolService
          .encodeEthPurchaseAbiHex(
              context,
              _emailController.text,
              environment["Bond"]["Chains"]["$selectedValueChain"]
                  ["acceptedTokens"]["id"],
              amount)
          .then((value) async {
        setState(() {
          abiHex = Constants.bondAbiCodeEth + value.toString();
        });
      });
    } else if (selectedValueChain == 'KANBAN') {
      amount = widget.orderBondVm!.bondOrder!.quantity! * 100 * 1e18;

      await paycoolService
          .encodeKanbanPurchaseAbiHex(
              context, _emailController.text, 131073, amount)
          .then((value) async {
        setState(() {
          abiHex = Constants.bondAbiCodeKanban + value.toString();
        });
      });
    } else if (selectedValueChain == 'BNB') {
      amount = widget.orderBondVm!.bondOrder!.quantity! * 100 * 1e6;

      await paycoolService
          .encodeEthPurchaseAbiHex(
              context,
              _emailController.text,
              environment["Bond"]["Chains"]["$selectedValueChain"]
                  ["acceptedTokens"]["id"],
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
      });
    });
  }
}

//bond address

//    eth       // first email hex +  0x3908eaeeb2aee3f5fccbb01b35596a9acae87f7d + amount hex (token amount multiple by 1e6 * 200(price of bond))
// kanban           // first email hex +  token type hex +  amount hex (token amount multiple by 1e18 * 200(price of bond))
// String abiHex = Constants.bondAbiCodeKanban +
//     fixLength(
//         trimHexPrefix(Constants.bondAddress), 64);

// apiService
//     .confirmOrderBond(
//         context,
//         widget.orderBondVm!.bondOrder!.bondId
//             .toString())
//     .then((value) {
//   print(value);
//   if (value != null) {

//   }
// });

//eth

/**
 {
    "inputs": [
      {
        "internalType": "string",
        "name": "email",
        "type": "string"
      },
      {
        "internalType": "address",
        "name": "_tokenAddr",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      }
    ],
    "name": "purchase",
    "outputs": [
      
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  }
 **/

//eth approve
/** 
 {
      "constant": false,
      "inputs": [
        {
          "internalType": "address",
          "name": "spender",   ---> bond 0x4a22a0733711329c374deb2e2f7d743f791a753b
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "value",    --->  amount hex (token amount multiple by 1e6 * 200(price of bond))
          "type": "uint256"
        }
      ],
      "name": "approve",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function"
    }
**/

// kanban

/** 
  {
    "inputs": [
      {
        "internalType": "string",
        "name": "email",
        "type": "string"
      },
      {
        "internalType": "uint32",
        "name": "_tokenType",
        "type": "uint32"
      },
      {
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      }
    ],
    "name": "purchase",
    "outputs": [
      
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  } 
  **/

/** 
    getApproveFunc() {
    const func = {
      "constant": false,
      "inputs": [
        {
          "internalType": "address",
          "name": "spender",    -----> bond 0x4a22a0733711329c374deb2e2f7d743f791a753b
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "value",      ----->  amount hex (token amount multiple by 1e18 * 200(price of bond))
          "type": "uint256"
        }
      ],
      "name": "approve",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function"
    };

    return func;
  }
  **/

// kanban approve same as in biswap

/**
Eth goeril testnet
Test usd: 0x3908eaeeb2aee3f5fccbb01b35596a9acae87f7d
You can give me your address, so that i can send you test usd.
bond: 0x4a22a0733711329c374deb2e2f7d743f791a753b
with
governAddr = 0x7bEB109B9694940b744F176958eE6f701283Bcc8;
recipientAddr = 0x6FCF05b1b57f862d3dE989801B456d730f3B2e86;
acceptedTokens = 0x3908eaeeb2aee3f5fccbb01b35596a9acae87f7d
**/
