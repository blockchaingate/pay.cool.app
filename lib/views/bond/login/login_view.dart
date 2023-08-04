import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/bond/login/forgot_password_view.dart';
import 'package:paycool/views/bond/login/login_viewmodel.dart';
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
      builder: (context, model, _) => Scaffold(
        resizeToAvoidBottomInset: true,
        body: model.isBusy
            ? Center(child: CircularProgressIndicator())
            : GestureDetector(
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/images/bgImage.png"),
                            fit: BoxFit.cover),
                      ),
                    ),
                    AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
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
                      padding: EdgeInsets.fromLTRB(30, 50, 30, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          UIHelper.verticalSpaceLarge,
                          Text(
                            "Welcome to El Salvador Bond",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          UIHelper.verticalSpaceLarge,
                          Text(
                            "Login",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          UIHelper.verticalSpaceSmall,
                          Text(
                            "Emails that are not logged in will be automatically registered",
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
                              hintText: 'Please enter your e-mail address',
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
                            keyboardType: TextInputType.visiblePassword,
                            decoration: InputDecoration(
                              hintText: 'Please enter your password',
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
                                'Login',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          model.isKeyboardOpen
                              ? SizedBox()
                              : UIHelper.verticalSpaceMedium,
                          model.isKeyboardOpen
                              ? SizedBox()
                              : InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ForgotPasswordPage()));
                                  },
                                  child: SizedBox(
                                    width: size.width * 0.9,
                                    child: Text(
                                      "Forgot Password?",
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14.0),
                                    ),
                                  ),
                                ),
                          model.isKeyboardOpen
                              ? SizedBox()
                              : UIHelper.verticalSpaceLarge,
                          model.isKeyboardOpen
                              ? Container()
                              : RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Don't have an account? ",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' Register now',
                                        style: TextStyle(
                                          fontSize: 12,
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {},
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
    );
  }
}
