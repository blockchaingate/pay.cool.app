import 'package:exchangily_ui/exchangily_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/models/bond/vm/me_model.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/api_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/views/bond/helper.dart';
import 'package:stacked/stacked.dart';

class PersonalInfoViewModel extends BaseViewModel {
  PersonalInfoViewModel({BuildContext? context});

  BuildContext? context;
  ApiService apiService = locator<ApiService>();
  SharedService sharedService = locator<SharedService>();

  BondMeModel? bondMeVm;

  TextEditingController phone = TextEditingController();
  TextEditingController phoneVerifyCode = TextEditingController();
  bool isSameNumber = false;

  String selectedCountryCode = 'CA';
  String callingCode = '+1';

  PageController controller = PageController(initialPage: 0, keepPage: false);

  init() {
    getUserBondMeData();
  }

  Future<void> getUserBondMeData() async {
    setBusy(true);
    await apiService.getBondMe().then((value) {
      if (value != null) {
        bondMeVm = value;
        notifyListeners();
      }
    });
    setBusy(false);
  }

  Widget buildWidget(BuildContext context, int page) {
    return page == 0
        ? Column(
            children: [
              if (bondMeVm!.phone != null && bondMeVm!.phone!.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${FlutterI18n.translate(context, "phoneNumber")}:  ${bondMeVm!.phone!}",
                      style: headText4.copyWith(color: Colors.black),
                    ),
                    TextButton(
                      onPressed: () {
                        sendCodeRequest(context, bondMeVm!.phone!, fast: true);
                      },
                      child: Text(
                        FlutterI18n.translate(context, "send"),
                      ),
                    ),
                  ],
                ),
              SizedBox(
                height: 50,
                child: Row(children: const <Widget>[
                  Expanded(
                      child: Divider(
                    color: Colors.black,
                  )),
                  Text(
                    "OR",
                    style: TextStyle(color: Colors.black),
                  ),
                  Expanded(
                      child: Divider(
                    color: Colors.black,
                  )),
                ]),
              ),
              StatefulBuilder(
                builder: (context, setState) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width * 0.25,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: DropdownButton<Map<String, String>>(
                            alignment: Alignment.center,
                            underline: const SizedBox.shrink(),
                            isExpanded: true,
                            dropdownColor: Colors.grey[200],
                            disabledHint: Text(
                              countryList
                                  .firstWhere((element) =>
                                      element['isoCode'] ==
                                      selectedCountryCode)['name']
                                  .toString(),
                              style: headText4.copyWith(color: Colors.black),
                              textAlign: TextAlign.start,
                            ),
                            value: countryList.firstWhere(
                              (element) =>
                                  element['isoCode'] == selectedCountryCode,
                              orElse: () => countryList[0],
                            ),
                            items: countryList
                                .map<DropdownMenuItem<Map<String, String>>>(
                                  (Map<String, String> country) =>
                                      DropdownMenuItem<Map<String, String>>(
                                    value: country,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(generateflag(country['isoCode']!)),
                                        Text(
                                          country['callingCode']!,
                                          style: headText4.copyWith(
                                              color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCountryCode =
                                    value!['isoCode'].toString();
                                callingCode = value['callingCode']!;
                                if (!callingCode.startsWith('+')) {
                                  callingCode = '+$callingCode';
                                }
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: TextField(
                            controller: phone,
                            style: TextStyle(color: Colors.black, fontSize: 13),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText:
                                  "${FlutterI18n.translate(context, "phoneNumber")} *",
                              hintStyle: TextStyle(
                                  color: inputText,
                                  fontWeight: FontWeight.w400),
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
                            onChanged: (value) {
                              setState(() {
                                phone.text = value;
                                phone.selection = TextSelection.collapsed(
                                    offset: phone.text.length);
                              });
                            },
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            if (phone.text.isEmpty) {
                              Navigator.pop(context);
                              callSMessage(
                                  context,
                                  FlutterI18n.translate(
                                      context, "pleaseEnterPhoneNumber"),
                                  duration: 3);
                              return;
                            }
                            sendCodeRequest(
                              context,
                              callingCode + phone.text,
                            );
                          },
                          child: Text(
                            FlutterI18n.translate(context, "send"),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          )
        : Column(
            children: [
              UIHelper.verticalSpaceSmall,
              TextField(
                controller: phoneVerifyCode,
                style: TextStyle(color: Colors.black, fontSize: 13),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "${FlutterI18n.translate(context, "code")} *",
                  hintStyle:
                      TextStyle(color: inputText, fontWeight: FontWeight.w400),
                  fillColor: Colors.white,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: inputBorder,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: inputBorder,
                    ),
                  ),
                ),
                onChanged: (value) {
                  phoneVerifyCode.text = value;
                  phoneVerifyCode.selection = TextSelection.collapsed(
                      offset: phoneVerifyCode.text.length);
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: Colors.white),
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      child: Text(
                        FlutterI18n.translate(context, "cancel"),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: Colors.white),
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          apiService
                              .verifyPhone(
                                  context,
                                  isSameNumber
                                      ? bondMeVm!.phone!
                                      : (callingCode + phone.text),
                                  phoneVerifyCode.text)
                              .then((value) {
                            if (value != null) {
                              Navigator.pop(context);
                              callSMessage(context, value, duration: 3);
                              getUserBondMeData();
                            } else {
                              Navigator.pop(context);
                            }
                          });
                        } catch (e) {
                          callSMessage(context,
                              FlutterI18n.translate(context, "anErrorOccurred"),
                              duration: 2);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      child: Text(
                        FlutterI18n.translate(context, "verify"),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
  }

  String? findISOCodeForPhoneNumber(String phoneNumber) {
    for (var country in countryList) {
      final callingCode = country['callingCode'];
      if (phoneNumber.startsWith(callingCode!)) {
        return country['isoCode'];
      }
    }
    return null; // Return null if the ISO code is not found for the given phone number
  }

  Future<void> sendCodeRequest(BuildContext context, String number,
      {bool fast = false}) async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (fast) {
      selectedCountryCode = findISOCodeForPhoneNumber(number)!;
      isSameNumber = true;
      notifyListeners();
    }

    try {
      await apiService
          .sendPhoneCode(context, selectedCountryCode, number)
          .then((value) {
        if (value != null) {
          callSMessage(context, value, duration: 3);
          controller.animateToPage(1,
              duration: Duration(milliseconds: 500), curve: Curves.ease);
        } else {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      callSMessage(context, FlutterI18n.translate(context, "anErrorOccurred"),
          duration: 2);
    }
  }

  showBottomSheet() {
    showModalBottomSheet(
      context: context!,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
              padding: EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.3,
              child: PageView.builder(
                controller: controller,
                itemCount: 2,
                itemBuilder: (contexta, position) {
                  return buildWidget(contexta, position);
                },
              )),
        );
      },
    ).whenComplete(() {
      phone.text = '';
      phoneVerifyCode.text = '';
      isSameNumber = false;
      notifyListeners();
    });
  }
}
