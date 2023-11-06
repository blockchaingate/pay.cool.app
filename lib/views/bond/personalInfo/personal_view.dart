import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/bond/personalInfo/personal_info_viewmodel.dart';
import 'package:paycool/views/bond/progressIndicator.dart';
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
                                Text(
                                  FlutterI18n.translate(
                                      context, "personalInfo"),
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                UIHelper.verticalSpaceLarge,
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  width: size.width,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${FlutterI18n.translate(context, "email")}: ${model.bondMeVm!.email!}",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      model.bondMeVm!.isEmailVerified!
                                          ? Icon(
                                              Icons.verified,
                                              color: Colors.green,
                                            )
                                          : InkWell(
                                              onTap: () {
                                                print("go to verify email");
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                child: Text(
                                                  FlutterI18n.translate(
                                                      context, "verify"),
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            )
                                    ],
                                  ),
                                ),
                                UIHelper.verticalSpaceLarge,
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  width: size.width,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${FlutterI18n.translate(context, "phoneNumber")}: ${model.bondMeVm!.phone!}",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      model.bondMeVm!.isPhoneVerified!
                                          ? Icon(
                                              Icons.verified,
                                              color: Colors.green,
                                            )
                                          : InkWell(
                                              onTap: () {
                                                model.showBottomSheet();
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                child: Text(
                                                  FlutterI18n.translate(
                                                      context, "verify"),
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            )
                                    ],
                                  ),
                                ),
                                UIHelper.verticalSpaceLarge,
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  width: size.width,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      print("go to change password");
                                    },
                                    child: Center(
                                      child: Text(
                                        "${FlutterI18n.translate(context, "change")} ${FlutterI18n.translate(context, "password")}",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ),
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
