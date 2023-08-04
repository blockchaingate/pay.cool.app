import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/models/bond/rm/order_bond_rm.dart';
import 'package:paycool/models/bond/vm/bond_sembol_vm.dart';
import 'package:paycool/models/bond/vm/order_bond_vm.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/api_service.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/bond/buyBond/select_payment_bond_view.dart';
import 'package:paycool/widgets/keyboard_down.dart';

class BondSembolView extends StatefulWidget {
  const BondSembolView({super.key});

  @override
  State<BondSembolView> createState() => _BondSembolViewState();
}

class _BondSembolViewState extends State<BondSembolView>
    with WidgetsBindingObserver {
  ApiService apiService = locator<ApiService>();

  TextEditingController amountText = TextEditingController();
  bool isKeyboardOpen = false;
  double keyboardHeight = 0;

  BondSembolVm? bondSembolVm;
  OrderBondVm? orderBondVm;

  int lastPrice = 0;
  String selectedValue = 'DNB';
  List<String> dropdownItems = ['DNB', 'GDNB'];

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _getBondSembol();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final mediaQuery = MediaQuery.of(context);
    keyboardHeight = mediaQuery.viewInsets.bottom;
    isKeyboardOpen = keyboardHeight > 1;
    super.didChangeMetrics();
  }

  Future<void> _getBondSembol() async {
    await apiService.bondSembol(context, selectedValue).then((value) {
      if (value != null) {
        setState(() {
          bondSembolVm = value;
        });
      } else {
        setState(() {
          bondSembolVm = null;
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
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: SizedBox(
            width: size.width,
            height: size.height,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/images/bgImage.png"),
                        fit: BoxFit.cover),
                  ),
                ),
                if (Platform.isIOS && isKeyboardOpen && keyboardHeight > 100)
                  Positioned(
                    right: 10,
                    bottom: keyboardHeight,
                    child: KeyboardClose(),
                  ),

                Positioned(
                  top: 100,
                  left: size.width * 0.1,
                  child: Container(
                    width: MediaQuery.of(context).size.width *
                        0.8, // Set the width to 80% of the screen width
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: DropdownButton<String>(
                      value: selectedValue,
                      dropdownColor: Colors.white,
                      underline: SizedBox(),
                      isExpanded: true,
                      iconEnabledColor: Colors.black,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedValue = newValue!;
                          lastPrice = 0;
                          bondSembolVm = null;
                          _getBondSembol();
                        });
                      },
                      items: dropdownItems.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ),
                ),

                bondSembolVm != null
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(20, 100, 20, 100),
                        child: SizedBox(
                          width: size.width,
                          height: size.height,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              UIHelper.verticalSpaceSmall,
                              Text(
                                'Selected Bond: $selectedValue',
                                style: bondText1,
                              ),
                              UIHelper.verticalSpaceLarge,
                              Text(
                                "${bondSembolVm!.bondInfo!.issuer}",
                                style: bondText1,
                              ),
                              Text(
                                "Face Value: ${bondSembolVm!.bondInfo!.faceValue}",
                                style: bondText1,
                              ),
                              Text(
                                "Issue Price: ${bondSembolVm!.bondInfo!.issuePrice}",
                                style: bondText1,
                              ),
                              Text(
                                "Redemption Price: ${bondSembolVm!.bondInfo!.redemptionPrice}",
                                style: bondText1,
                              ),
                              UIHelper.verticalSpaceMedium,
                              TextField(
                                controller: amountText,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 13),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    setState(() {
                                      lastPrice = (int.parse(value) *
                                          bondSembolVm!.bondInfo!.faceValue!);
                                    });
                                  } else {
                                    setState(() {
                                      lastPrice = 0;
                                    });
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: 'Please enter amount',
                                  hintStyle: TextStyle(
                                      color: inputText,
                                      fontWeight: FontWeight.w400),
                                  fillColor: Colors.transparent,
                                  filled: true,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color:
                                          inputBorder, // Change the color to your desired border color
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color:
                                          inputBorder, // Change the color to your desired border color
                                    ),
                                  ),
                                ),
                              ),
                              UIHelper.verticalSpaceMedium,
                              Text(
                                "Last Price: $lastPrice",
                                style: bondText1,
                              ),
                            ],
                          ),
                        ),
                      )
                    : SizedBox(
                        child: Center(
                            child: Text("Sorry this bond is not ready ")),
                      ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: Container(
                      width: size.width * 0.9,
                      height: 45,
                      decoration: BoxDecoration(
                        gradient: buttoGradient,
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          if (amountText.text.isNotEmpty) {
                            var param = OrderBondRm(
                                symbol: selectedValue,
                                quantity: int.parse(amountText.text));

                            apiService.orderBond(context, param).then((value) {
                              if (value != null) {
                                setState(() {
                                  orderBondVm = value;
                                });
                                print(value.bondOrder!.bondId);
                              }
                            }).whenComplete(() {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SelectPaymentBondView()));
                            });
                          } else {
                            var snackBar = SnackBar(
                                content: Text('Please enter amount first'));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(
                          'Order Now',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Align(
                //   alignment: Alignment.bottomCenter,
                //   child: Padding(
                //     padding: const EdgeInsets.only(bottom: 100),
                //     child: Container(
                //       width: size.width * 0.9,
                //       height: 45,
                //       decoration: BoxDecoration(
                //         gradient: buttoGradient,
                //         borderRadius: BorderRadius.circular(40.0),
                //       ),
                //       child: ElevatedButton(
                //         onPressed: () {
                //           var param = BondUpdatePaymentRm(
                //             paymentAccount: "Digital Currency",
                //             paymentMethod: "64ac153764ff60fbaadfd331",
                //           );

                //           apiService
                //               .updatePaymentBond(
                //                   context,
                //                   orderBondVm!.bondOrder!.bondId.toString(),
                //                   param)
                //               .then((value) {
                //             if (value != null) {
                //               print(value.bondOrder!.bondId);
                //             }
                //           });
                //         },
                //         style: ElevatedButton.styleFrom(
                //           backgroundColor: Colors.transparent,
                //           shadowColor: Colors.transparent,
                //         ),
                //         child: Text(
                //           'Update Payment',
                //           style: TextStyle(
                //             fontSize: 16.0,
                //             fontWeight: FontWeight.bold,
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
