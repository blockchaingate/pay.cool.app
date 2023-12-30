import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/bond/login/login_view.dart';
import 'package:paycool/views/bond/progressIndicator.dart';
import 'package:paycool/views/bond/register/bond_register_viewmodel.dart';
import 'package:stacked/stacked.dart';

class BondRegisterView extends StatefulWidget {
  const BondRegisterView({super.key});

  @override
  State<BondRegisterView> createState() => _BondRegisterViewState();
}

class _BondRegisterViewState extends State<BondRegisterView> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ViewModelBuilder<BondRegisterViewModel>.reactive(
        viewModelBuilder: () => BondRegisterViewModel(context: context),
        disposeViewModel: true,
        onViewModelReady: (model) async {
          model.context = context;
          model.init();
        },
        builder: (context, BondRegisterViewModel model, child) {
          return ModalProgressHUD(
            inAsyncCall: model.isBusy,
            progressIndicator: CustomIndicator.indicator(),
            child: Scaffold(
              body: GestureDetector(
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: Container(
                  width: size.width,
                  height: size.height,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/images/bgImage.png"),
                        fit: BoxFit.cover),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PreferredSize(
                            preferredSize: size,
                            child: Container(
                              alignment: Alignment.bottomLeft,
                              width: size.width,
                              height: size.height * 0.1,
                              child: IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            )),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SizedBox(
                            height: size.height * 0.9,
                            width: size.width,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                UIHelper.verticalSpaceMedium,
                                Text(
                                  FlutterI18n.translate(
                                      context, "createAccount"),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                UIHelper.verticalSpaceLarge,
                                TextField(
                                  controller: model.emailController,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 13),
                                  decoration: InputDecoration(
                                    hintText: FlutterI18n.translate(
                                        context, "enterEmailAddress"),
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
                                UIHelper.verticalSpaceSmall,
                                TextField(
                                  controller: model.passwordController,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 13),
                                  obscureText: true,
                                  keyboardType: TextInputType.visiblePassword,
                                  decoration: InputDecoration(
                                    hintText: FlutterI18n.translate(
                                        context, "enterPassword"),
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
                                UIHelper.verticalSpaceSmall,
                                TextField(
                                  controller: model.repeatPasswordController,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 13),
                                  obscureText: true,
                                  keyboardType: TextInputType.visiblePassword,
                                  decoration: InputDecoration(
                                    hintText: FlutterI18n.translate(
                                        context, "repeatPassword"),
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
                                UIHelper.verticalSpaceSmall,
                                model.isReferral
                                    ? TextField(
                                        controller: model.referralController,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 13),
                                        decoration: InputDecoration(
                                          hintText: FlutterI18n.translate(
                                              context, "referralCode"),
                                          hintStyle: TextStyle(
                                              color: inputText,
                                              fontWeight: FontWeight.w400),
                                          fillColor: Colors.transparent,
                                          filled: true,
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            borderSide: BorderSide(
                                              color:
                                                  inputBorder, // Change the color to your desired border color
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            borderSide: BorderSide(
                                              color:
                                                  inputBorder, // Change the color to your desired border color
                                            ),
                                          ),
                                        ),
                                      )
                                    : SizedBox(),
                                UIHelper.verticalSpaceLarge,
                                Container(
                                  width: size.width * 0.9,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    gradient: buttoGradient,
                                    borderRadius: BorderRadius.circular(40.0),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      model.startRegister();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                    ),
                                    child: Text(
                                      FlutterI18n.translate(
                                          context, "register"),
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                UIHelper.verticalSpaceSmall,
                                SizedBox(
                                  width: size.width * 0.9,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        model.isReferral = !model.isReferral;
                                      });
                                    },
                                    child: Text(
                                      FlutterI18n.translate(
                                          context, "doYouHaveReferralCode"),
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14),
                                    ),
                                  ),
                                ),
                                UIHelper.verticalSpaceLarge,
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: FlutterI18n.translate(
                                            context, "youHaveAccount"),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            " ${FlutterI18n.translate(context, "login")}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const BondLoginView()));
                                          },
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(child: SizedBox()),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          model.checkBoxValue =
                                              !model.checkBoxValue;
                                        });
                                      },
                                      child: Container(
                                        width: 25,
                                        height: 25,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: 2.0,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(
                                              2.0), // Adjust padding as needed
                                          child: Checkbox(
                                            shape: OutlinedBorder.lerp(
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50)),
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50)),
                                                1)!,
                                            value: model.checkBoxValue,
                                            activeColor: Colors.white,
                                            onChanged: (value) {
                                              setState(() {
                                                model.checkBoxValue = value!;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: size.width * 0.8,
                                      child: Text(
                                        FlutterI18n.translate(
                                            context, "iHaveReadandAgree"),
                                        textAlign: TextAlign.start,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w200,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                UIHelper.verticalSpaceMedium,
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
        });
  }
}
