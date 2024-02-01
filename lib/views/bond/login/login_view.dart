import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/bond/login/forgot_password_view.dart';
import 'package:paycool/views/bond/login/login_viewmodel.dart';
import 'package:paycool/views/bond/progress_indicator.dart';
import 'package:paycool/views/bond/register/bond_register_view.dart';
import 'package:stacked/stacked.dart';

class BondLoginView extends StatefulWidget with WidgetsBindingObserver {
  const BondLoginView({super.key});

  @override
  State<BondLoginView> createState() => _BondLoginViewState();
}

class _BondLoginViewState extends State<BondLoginView> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ViewModelBuilder<BondLoginViewModel>.reactive(
      onViewModelReady: (model) async {
        model.context = context;
        await model.init();
      },
      viewModelBuilder: () => BondLoginViewModel(),
      builder: (context, model, _) => ModalProgressHUD(
        inAsyncCall: model.isBusy,
        progressIndicator: CustomIndicator.indicator(),
        child: Scaffold(
          body: GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Container(
              height: size.height,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/bgImage.png"),
                    fit: BoxFit.cover),
              ),
              child: SingleChildScrollView(
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          UIHelper.verticalSpaceLarge,
                          Text(
                            FlutterI18n.translate(context, "welcomeTo"),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          UIHelper.verticalSpaceLarge,
                          Text(
                            FlutterI18n.translate(context, "login"),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          UIHelper.verticalSpaceSmall,
                          Text(
                            FlutterI18n.translate(context, "emailsThatAre"),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w200,
                                color: Colors.white),
                          ),
                          UIHelper.verticalSpaceLarge,
                          TextField(
                            controller: model.emailController,
                            style: TextStyle(color: Colors.white, fontSize: 13),
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
                            style: TextStyle(color: Colors.white, fontSize: 13),
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
                          Container(
                            width: size.width * 0.9,
                            height: 45,
                            decoration: BoxDecoration(
                              gradient: buttoGradient,
                              borderRadius: BorderRadius.circular(40.0),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                model.login();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              child: Text(
                                FlutterI18n.translate(context, "login"),
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          UIHelper.verticalSpaceMedium,
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgotPasswordView()));
                            },
                            child: SizedBox(
                              width: size.width * 0.9,
                              child: Text(
                                FlutterI18n.translate(
                                    context, "forgotPassword"),
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14.0),
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
                                      context, "dontHaveAnAccount"),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      " ${FlutterI18n.translate(context, "registerNow")}",
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
                                                  const BondRegisterView()));
                                    },
                                ),
                              ],
                            ),
                          ),
                        ],
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
