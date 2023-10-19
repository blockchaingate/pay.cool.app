import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/models/bond/rm/order_bond_request_model.dart';
import 'package:paycool/models/bond/vm/bond_symbol_model.dart';
import 'package:paycool/models/bond/vm/me_model.dart';
import 'package:paycool/models/bond/vm/order_bond_model.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/api_service.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/bond/buyBond/select_payment_bond_view.dart';
import 'package:paycool/views/bond/helper.dart';
import 'package:paycool/views/bond/progressIndicator.dart';

class BondSembolView extends StatefulWidget {
  final BondMeModel? bondMeVm;
  const BondSembolView(this.bondMeVm, {super.key});

  @override
  State<BondSembolView> createState() => _BondSembolViewState();
}

class _BondSembolViewState extends State<BondSembolView> {
  ApiService apiService = locator<ApiService>();

  TextEditingController amountText = TextEditingController();

  List<BondSembolModel> bondSembolVmList = [];
  BondSembolModel? bondSembolVm;
  OrderBondModel? orderBondVm;

  int lastPrice = 0;
  String selectedValue = 'DNB';

  bool loading = false;

  @override
  void initState() {
    _getBondSembol();
    super.initState();
  }

  Future<void> _getBondSembol() async {
    try {
      setState(() {
        loading = true;
      });
      Future.wait([getBondSembol("DNB"), getBondSembol("XDNB")]).then((value) {
        setState(() {
          bondSembolVm = value[0];
          bondSembolVmList.add(value[0]!);
          bondSembolVmList.add(value[1]!);
        });
      }).whenComplete(() {
        setState(() {
          loading = false;
        });
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<BondSembolModel?> getBondSembol(String symbol) async {
    try {
      return await apiService.bondSembol(context, symbol);
    } catch (e) {
      return null;
    }
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UIHelper.verticalSpaceLarge,
                    UIHelper.verticalSpaceLarge,
                    bondSembolVmList.isNotEmpty
                        ? SizedBox(
                            width: size.width,
                            height: 120.0,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemCount: bondSembolVmList.length,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectedValue =
                                              bondSembolVmList[index].symbol!;

                                          bondSembolVm =
                                              bondSembolVmList[index];

                                          lastPrice = 0;

                                          amountText = TextEditingController();
                                        });
                                      },
                                      child: Container(
                                        width: size.width * 0.4,
                                        padding: EdgeInsets.all(10.0),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          color: Colors.white,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                bondSembolVmList[index].symbol!,
                                                style: TextStyle(
                                                  fontSize: 18.0,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                )),
                                            Text(
                                                "Face Value: ${bondSembolVmList[index].faceValue} USD",
                                                style: TextStyle(
                                                  fontSize: 12.0,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                )),
                                            Text(
                                                "${FlutterI18n.translate(context, "interestRate")}: ${bondSembolVmList[index].couponRate} %",
                                                style: TextStyle(
                                                  fontSize: 12.0,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                )),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    bondSembolVmList[index]
                                                                .symbol! ==
                                                            "DNB"
                                                        ? "Type:  ERC721"
                                                        : "Type:  ERC20",
                                                    style: TextStyle(
                                                      fontSize: 14.0,
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    )),
                                                selectedValue ==
                                                        bondSembolVmList[index]
                                                            .symbol
                                                    ? Icon(
                                                        Icons
                                                            .check_circle_outline,
                                                        color: Colors.green,
                                                        size: 24,
                                                      )
                                                    : SizedBox(
                                                        height: 24,
                                                      )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          )
                        : SizedBox(),
                    UIHelper.verticalSpaceLarge,
                    Text(
                      FlutterI18n.translate(context, "amount"),
                      style: TextStyle(
                          fontSize: 18,
                          color: white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.25),
                    ),
                    UIHelper.verticalSpaceSmall,
                    TextField(
                      controller: amountText,
                      style: TextStyle(color: Colors.white, fontSize: 13),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(
                            r'^[0-9]*?[0-9]*',
                          ),
                        ),
                      ],
                      keyboardType: TextInputType.numberWithOptions(
                          decimal: false, signed: false),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          setState(() {
                            lastPrice =
                                (int.parse(value) * bondSembolVm!.faceValue!);
                          });
                        } else {
                          setState(() {
                            lastPrice = 0;
                          });
                        }
                      },
                      decoration: InputDecoration(
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
                      "${FlutterI18n.translate(context, "totalCost")}: $lastPrice ${FlutterI18n.translate(context, "usd")}",
                      style: TextStyle(
                          fontSize: 18,
                          color: white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.25),
                    ),
                    Expanded(child: SizedBox()),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: Container(
                          width: size.width * 0.8,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: buttoGradient,
                            borderRadius: BorderRadius.circular(40.0),
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              if (amountText.text.isNotEmpty) {
                                setState(() {
                                  loading = true;
                                });

                                var param = OrderBondRequestModel(
                                    paymentAmount: lastPrice,
                                    quantity: int.parse(amountText.text),
                                    symbol: selectedValue);

                                try {
                                  await ApiService()
                                      .orderBond(context, param)
                                      .then((value) async {
                                    if (value != null) {
                                      setState(() {
                                        loading = false;
                                      });
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SelectPaymentBondView(
                                                      widget.bondMeVm!,
                                                      int.parse(
                                                          amountText.text),
                                                      lastPrice,
                                                      selectedValue,
                                                      value.bondOrder!.id
                                                          .toString(),
                                                      bondSembolVm)));
                                    }
                                  });
                                } catch (e) {
                                  loading = false;
                                }
                              } else {
                                callSMessage(
                                    context,
                                    FlutterI18n.translate(
                                        context, "enterQuantity"),
                                    duration: 2);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            child: Text(
                              FlutterI18n.translate(context, "orderNow"),
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
}
