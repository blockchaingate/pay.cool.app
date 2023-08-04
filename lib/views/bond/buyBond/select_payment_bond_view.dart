import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paycool/shared/ui_helpers.dart';

class SelectPaymentBondView extends StatefulWidget {
  const SelectPaymentBondView({super.key});

  @override
  State<SelectPaymentBondView> createState() => _SelectPaymentBondViewState();
}

class _SelectPaymentBondViewState extends State<SelectPaymentBondView> {
  String? selectedValueCoin;
  List<String> dropdownItemsCoin = ['USDT', 'USDC'];

  String? selectedValueChain;
  List<String> dropdownItemsChain = ['BTC', 'ETH', 'KANBAN'];

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
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 50),
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        UIHelper.verticalSpaceLarge,
                        Container(
                          width: MediaQuery.of(context).size.width *
                              0.8, // Set the width to 80% of the screen width
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
                            style: TextStyle(color: Colors.black, fontSize: 14),
                          ),
                        ),
                        UIHelper.verticalSpaceMedium,
                        Container(
                          width: MediaQuery.of(context).size.width *
                              0.8, // Set the width to 80% of the screen width
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
                            style: TextStyle(color: Colors.black, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
