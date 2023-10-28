import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/models/bond/rm/forgot_password_model.dart';
import 'package:paycool/models/bond/rm/forgot_password_verify_model.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/api_service.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/utils/string_validator.dart';
import 'package:paycool/views/bond/helper.dart';
import 'package:paycool/views/bond/login/login_view.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController verifyPasswordController = TextEditingController();
  TextEditingController codeController = TextEditingController();

  ApiService apiService = locator<ApiService>();

  bool _isFirstCard = true;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        body: Container(
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
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  UIHelper.verticalSpaceLarge,
                  UIHelper.verticalSpaceLarge,
                  Text(
                    FlutterI18n.translate(context, "forgotPassword"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  UIHelper.verticalSpaceLarge,
                  SizedBox(
                    width: size.width,
                    child: AnimatedSwitcher(
                        duration: Duration(seconds: 2),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          final rotate =
                              Tween(begin: pi, end: 0.0).animate(animation);
                          return AnimatedBuilder(
                              animation: rotate,
                              child: child,
                              builder: (BuildContext context, Widget? child) {
                                final angle =
                                    (ValueKey(_isFirstCard) != widget.key)
                                        ? min(rotate.value, pi / 2)
                                        : rotate.value;
                                return Transform(
                                  transform: Matrix4.rotationY(angle),
                                  alignment: Alignment.center,
                                  child: child,
                                );
                              });
                        },
                        switchInCurve: Curves.bounceIn.flipped,
                        switchOutCurve: Curves.easeOutCubic.flipped,
                        child:
                            _isFirstCard ? firstCard(size) : secondCard(size)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget firstCard(Size size) {
    return Card(
      key: ValueKey(false),
      color: Colors.transparent,
      shape: ShapeBorder.lerp(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        1,
      ),
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              style: TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: "${FlutterI18n.translate(context, "email")} *",
                hintStyle:
                    TextStyle(color: inputText, fontWeight: FontWeight.w400),
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
            SizedBox(
              width: size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: size.width * 0.6,
                    child: TextField(
                      controller: codeController,
                      style: TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: "${FlutterI18n.translate(context, "code")} *",
                        hintStyle: TextStyle(
                            color: inputText, fontWeight: FontWeight.w400),
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
                  ),
                  Container(
                    width: size.width * 0.25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: Colors.white),
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (emailController.text.isNotEmpty &&
                            validateEmail(emailController.text)) {
                          var param = ForgotPasswordModel(
                            email: emailController.text,
                          );

                          try {
                            apiService
                                .forgotPassword(context, param)
                                .then((value) {
                              if (value != null) {
                                callSMessage(context, value, duration: 3);
                              }
                            });
                          } catch (e) {
                            callSMessage(
                                context,
                                FlutterI18n.translate(
                                    context, "anErrorOccurred"),
                                duration: 2);
                          }
                        } else {
                          callSMessage(
                              context,
                              FlutterI18n.translate(
                                  context, "enterValidEmailAddress"),
                              duration: 2);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: Text(
                        FlutterI18n.translate(context, "sendCode"),
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
            Container(
              width: size.width * 0.9,
              decoration: BoxDecoration(
                gradient: buttoGradient,
                borderRadius: BorderRadius.circular(40.0),
              ),
              child: ElevatedButton(
                onPressed: () async {
                  if (emailController.text.isNotEmpty &&
                      validateEmail(emailController.text)) {
                    var param = {
                      "email": emailController.text,
                      "code": codeController.text,
                    };

                    try {
                      apiService.verifyEmailCode(context, param).then((value) {
                        if (value != null) {
                          callSMessage(context, value, duration: 2);

                          setState(() {
                            _isFirstCard = !_isFirstCard;
                          });
                        }
                      });
                    } catch (e) {
                      callSMessage(context,
                          FlutterI18n.translate(context, "anErrorOccurred"),
                          duration: 2);
                    }
                  } else {
                    callSMessage(
                        context,
                        FlutterI18n.translate(
                            context, "enterValidEmailAddress"),
                        duration: 2);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: Text(
                  FlutterI18n.translate(context, "submit"),
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget secondCard(Size size) {
    return Card(
      key: ValueKey(false),
      color: Colors.transparent,
      shape: ShapeBorder.lerp(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        1,
      ),
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: passwordController,
              style: TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: "${FlutterI18n.translate(context, "password")} *",
                hintStyle:
                    TextStyle(color: inputText, fontWeight: FontWeight.w400),
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
              controller: verifyPasswordController,
              style: TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText:
                    "${FlutterI18n.translate(context, "verifyPassword")} *",
                hintStyle:
                    TextStyle(color: inputText, fontWeight: FontWeight.w400),
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
              decoration: BoxDecoration(
                gradient: buttoGradient,
                borderRadius: BorderRadius.circular(40.0),
              ),
              child: ElevatedButton(
                onPressed: () async {
                  if (passwordController.text ==
                      verifyPasswordController.text) {
                    var param = ForgotPasswordVerifyModel(
                      email: emailController.text,
                      password: passwordController.text,
                    );

                    try {
                      apiService.resetPassword(context, param).then((value) {
                        if (value != null) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(
                                content: Text(value),
                                duration: Duration(seconds: 1),
                              ))
                              .closed
                              .then((value) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const BondLoginView()));
                          });
                        }
                      });
                    } catch (e) {
                      callSMessage(context,
                          FlutterI18n.translate(context, "anErrorOccurred"),
                          duration: 2);
                    }
                  } else {
                    callSMessage(context,
                        FlutterI18n.translate(context, "passwordNotMatched"),
                        duration: 2);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: Text(
                  FlutterI18n.translate(context, "submit"),
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
