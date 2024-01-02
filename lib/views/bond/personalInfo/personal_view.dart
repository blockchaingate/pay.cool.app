import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/bond/personalInfo/personal_info_viewmodel.dart';
import 'package:paycool/views/bond/progress_indicator.dart';
import 'package:stacked/stacked.dart';

class PersonalInfoView extends StatefulWidget with WidgetsBindingObserver {
  const PersonalInfoView({super.key});

  @override
  State<PersonalInfoView> createState() => _PersonalInfoViewState();
}

class _PersonalInfoViewState extends State<PersonalInfoView> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ViewModelBuilder<PersonalInfoViewModel>.reactive(
      onViewModelReady: (model) async {
        model.context = context;
        await model.init();
      },
      viewModelBuilder: () => PersonalInfoViewModel(),
      builder: (context, model, _) => ModalProgressHUD(
        inAsyncCall: model.isBusy,
        progressIndicator: CustomIndicator.indicator(),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/bgImage.png"),
                    fit: BoxFit.cover),
              ),
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    systemOverlayStyle: SystemUiOverlayStyle.light,
                    title: Text(
                      FlutterI18n.translate(context, "personalInfo"),
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  model.bondMeVm == null
                      ? Container()
                      : SizedBox(
                          width: size.width,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                UIHelper.verticalSpaceLarge,
                                Container(
                                  padding: EdgeInsets.all(10),
                                  width: size.width,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        FlutterI18n.translate(context, "email"),
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white38),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            model.bondMeVm!.email!,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                          SizedBox(
                                            width: size.width * 0.35,
                                            child: RichText(
                                              textAlign: TextAlign.start,
                                              text: TextSpan(
                                                text:
                                                    "${FlutterI18n.translate(context, "status")}:  ",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text: model.bondMeVm!
                                                            .isEmailVerified!
                                                        ? FlutterI18n.translate(
                                                            context, "verified")
                                                        : FlutterI18n.translate(
                                                            context,
                                                            "notVerified"),
                                                    style: TextStyle(
                                                      color: model.bondMeVm!
                                                              .isEmailVerified!
                                                          ? Colors.green
                                                          : Colors.red,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                UIHelper.verticalSpaceMedium,
                                Container(
                                  padding: EdgeInsets.all(10),
                                  width: size.width,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        FlutterI18n.translate(
                                            context, "phoneNumber"),
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white38),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          model.bondMeVm!.phone == null
                                              ? Text("")
                                              : Text(
                                                  model.bondMeVm!.phone!,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white),
                                                ),
                                          SizedBox(
                                            width: size.width * 0.35,
                                            child: RichText(
                                              text: TextSpan(
                                                text:
                                                    "${FlutterI18n.translate(context, "status")}:  ",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text: model.bondMeVm!
                                                            .isPhoneVerified!
                                                        ? FlutterI18n.translate(
                                                            context, "verified")
                                                        : FlutterI18n.translate(
                                                            context,
                                                            "notVerified"),
                                                    style: TextStyle(
                                                      color: model.bondMeVm!
                                                              .isPhoneVerified!
                                                          ? Colors.green
                                                          : Colors.red,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (!model.bondMeVm!.isPhoneVerified!)
                                        Align(
                                          alignment: Alignment.center,
                                          child: TextButton(
                                            onPressed: () {
                                              model.showBottomSheet();
                                            },
                                            child: Text(
                                              FlutterI18n.translate(
                                                  context, "verify"),
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                UIHelper.verticalSpaceLarge,
                                Text(
                                  "KYC",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                UIHelper.verticalSpaceMedium,
                                Container(
                                  padding: EdgeInsets.all(10),
                                  width: size.width,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Column(
                                            children: [
                                              Text(
                                                FlutterI18n.translate(
                                                    context, "L1"),
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                              UIHelper.verticalSpaceSmall,
                                              Text(
                                                model.bondMeVm!
                                                            .level1ReferralCount! ==
                                                        0
                                                    ? FlutterI18n.translate(
                                                        context, "notCertified")
                                                    : FlutterI18n.translate(
                                                        context, "certified"),
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: size.width * 0.3,
                                            child: Text(
                                              "Personal Information Authentication",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white38),
                                            ),
                                          ),
                                          SizedBox()
                                        ],
                                      ),
                                      model.bondMeVm!.level1ReferralCount! == 0
                                          ? Align(
                                              alignment: Alignment.center,
                                              child: TextButton(
                                                onPressed: () {
                                                  model.checkKycStatusV2();
                                                },
                                                child: Text(
                                                  FlutterI18n.translate(
                                                      context, "continue"),
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.blue),
                                                ),
                                              ),
                                            )
                                          : SizedBox()
                                    ],
                                  ),
                                ),
                                UIHelper.verticalSpaceMedium,
                                Container(
                                  padding: EdgeInsets.all(10),
                                  width: size.width,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Column(
                                            children: [
                                              Text(
                                                FlutterI18n.translate(
                                                    context, "L2"),
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                              UIHelper.verticalSpaceSmall,
                                              Text(
                                                model.bondMeVm!
                                                            .level2ReferralCount! ==
                                                        0
                                                    ? FlutterI18n.translate(
                                                        context, "notCertified")
                                                    : FlutterI18n.translate(
                                                        context, "certified"),
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: size.width * 0.3,
                                            child: Text(
                                              "Address Authentication",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white38),
                                            ),
                                          ),
                                          SizedBox()
                                        ],
                                      ),
                                      model.bondMeVm!.level2ReferralCount! ==
                                                  0 &&
                                              model.bondMeVm!
                                                      .level1ReferralCount! >
                                                  0
                                          ? Align(
                                              alignment: Alignment.center,
                                              child: TextButton(
                                                onPressed: () {
                                                  model.checkKycStatusV2();
                                                },
                                                child: Text(
                                                  FlutterI18n.translate(
                                                      context, "continue"),
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.blue),
                                                ),
                                              ),
                                            )
                                          : SizedBox()
                                    ],
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
      ),
    );
  }
}
