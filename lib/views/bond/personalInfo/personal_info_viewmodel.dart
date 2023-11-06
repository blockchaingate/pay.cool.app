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
  String? selectedCountryCode;
  String callingCode = '';

  init() {
    getUserBondMeData();
  }

  Future<void> getUserBondMeData() async {
    setBusy(true);
    await apiService.getBondMe().then((value) {
      if (value != null) {
        bondMeVm = value;
        phone.text = bondMeVm!.phone ?? "";
        notifyListeners();
      }
    });
    setBusy(false);
  }

  showBottomSheet() {
    showModalBottomSheet(
        context: context!,
        isScrollControlled: true,
        builder: (context) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  decoration: roundedBoxDecoration(color: Colors.grey[100]!),
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width * 0.25,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.red,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: DropdownButton<Map<String, String>>(
                                alignment: Alignment.center,
                                underline: const SizedBox.shrink(),
                                isExpanded: true,
                                dropdownColor: Colors.grey[200],
                                disabledHint: selectedCountryCode == null
                                    ? const Text('')
                                    : Text(
                                        countryList
                                            .firstWhere((element) =>
                                                element['isoCode'] ==
                                                selectedCountryCode)['name']
                                            .toString(),
                                        style: headText4.copyWith(
                                            color: Colors.black),
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
                                          children: [
                                            Text(generateflag(
                                                country['isoCode']!)),
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
                                style: TextStyle(
                                    color: Colors.white, fontSize: 13),
                                decoration: InputDecoration(
                                  hintText:
                                      "${FlutterI18n.translate(context, "code")} *",
                                  hintStyle: TextStyle(
                                      color: inputText,
                                      fontWeight: FontWeight.w400),
                                  fillColor: Colors.black,
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
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.2,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                                border: Border.all(color: Colors.white),
                              ),
                              child: ElevatedButton(
                                onPressed: () async {
                                  try {
                                    apiService
                                        .sendPhoneCode(context,
                                            selectedCountryCode!, phone.text)
                                        .then((value) {
                                      if (value != null) {
                                        callSMessage(context, value,
                                            duration: 3);
                                      }
                                    });
                                  } catch (e) {
                                    callSMessage(
                                        context,
                                        FlutterI18n.translate(
                                            context, "anErrorOccurred"),
                                        duration: 2);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                ),
                                child: Text(
                                  FlutterI18n.translate(context, "send"),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      UIHelper.verticalSpaceSmall,
                      TextField(
                        controller: phoneVerifyCode,
                        style: TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText:
                              "${FlutterI18n.translate(context, "code")} *",
                          hintStyle: TextStyle(
                              color: inputText, fontWeight: FontWeight.w400),
                          fillColor: Colors.black,
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
                                      .verifyPhone(context, phone.text,
                                          phoneVerifyCode.text)
                                      .then((value) {
                                    if (value != null) {
                                      callSMessage(context, value, duration: 3);
                                    }
                                  }).whenComplete(() => showBottomSheet());
                                } catch (e) {
                                  callSMessage(
                                      context,
                                      FlutterI18n.translate(
                                          context, "anErrorOccurred"),
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
                      UIHelper.verticalSpaceLarge,
                    ],
                  ),
                );
              },
            ),
          );
        });
  }
}
