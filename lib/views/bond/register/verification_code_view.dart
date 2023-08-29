import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/models/bond/rm/register_email_model.dart';
import 'package:paycool/models/bond/rm/verify_captcha_model.dart';
import 'package:paycool/models/bond/rm/verify_email_model.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/api_service.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/bond/helper.dart';
import 'package:paycool/views/bond/progressIndicator.dart';
import 'package:paycool/views/wallet/wallet_dashboard_view.dart';

class VerificationCodeView extends StatefulWidget {
  final RegisterEmailModel data;
  final bool justVerify;

  const VerificationCodeView(
      {Key? key, required this.data, this.justVerify = false})
      : super(key: key);

  @override
  State<VerificationCodeView> createState() => _VerificationCodeViewState();
}

class _VerificationCodeViewState extends State<VerificationCodeView> {
  TextEditingController verifyCaptchaController = TextEditingController();
  TextEditingController verifyEmailController = TextEditingController();
  final storageService = locator<LocalStorageService>();
  ApiService apiService = locator<ApiService>();
  String? captcha;

  bool loading = false;

  int _timeout = 120; // Total seconds for the countdown timer
  Timer? _timer;

  bool _isFirstCard = true;

  @override
  void initState() {
    if (widget.justVerify) {
      _isFirstCard = !_isFirstCard;
      sendConfirmationCode(context);
    } else {
      request();
    }

    super.initState();
  }

  @override
  dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (_timeout == 0) {
        timer.cancel();
      } else {
        setState(() {
          _timeout--;
        });
      }
    });
  }

  Future<void> request() async {
    apiService.getCaptcha(context, widget.data.email!).then((value) {
      setState(() {
        captcha = value!.captcha!
            .replaceAll('width="100%"', 'width="150"')
            .replaceAll('height="100%"', 'height="100"');
      });
    });
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
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/bgImage.png"),
                  fit: BoxFit.cover),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    systemOverlayStyle: SystemUiOverlayStyle.light,
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      UIHelper.verticalSpaceLarge,
                      Text(
                        FlutterI18n.translate(context, "verifyCapital"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            decoration: TextDecoration.none,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      UIHelper.verticalSpaceSmall,
                      !_isFirstCard
                          ? Text(
                              "${FlutterI18n.translate(context, "sendTo")} ${widget.data.email}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  decoration: TextDecoration.none,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w200,
                                  color: Colors.white),
                            )
                          : SizedBox(),
                      UIHelper.verticalSpaceMedium,
                      SizedBox(
                        width: size.width,
                        height: size.height * 0.4,
                        child: AnimatedSwitcher(
                            duration: Duration(seconds: 2),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              final rotate =
                                  Tween(begin: pi, end: 0.0).animate(animation);
                              return AnimatedBuilder(
                                  animation: rotate,
                                  child: child,
                                  builder:
                                      (BuildContext context, Widget? child) {
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
                            child: _isFirstCard
                                ? firstCard(size)
                                : secondCard(size)),
                      ),
                      UIHelper.verticalSpaceSmall,
                      !_isFirstCard
                          ? SizedBox(
                              width: size.width,
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: FlutterI18n.translate(
                                          context, "didntReceiveCode"),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          " ${FlutterI18n.translate(context, "resendCode")}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        decoration: TextDecoration.underline,
                                        color: Colors.grey,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          sendConfirmationCode(context);
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '$_timeout', // Display the remaining seconds
            style: TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
          UIHelper.verticalSpaceSmall,
          TextField(
            controller: verifyEmailController,
            style: TextStyle(color: Colors.white, fontSize: 13),
            readOnly: _timeout == 0,
            decoration: InputDecoration(
              hintText: "${FlutterI18n.translate(context, "validationCode")} *",
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
                if (verifyEmailController.text.isEmpty) {
                  callSMessage(context,
                      FlutterI18n.translate(context, "enterValidationCode"),
                      duration: 2);
                } else {
                  setState(() {
                    loading = true;
                  });

                  var param = VerifyEmailModel(
                    email: widget.data.email,
                    code: verifyEmailController.text,
                  );

                  try {
                    await apiService
                        .verifyEmail(context, param)
                        .then((value) async {
                      if (value != null) {
                        if (value) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const WalletDashboardView()));
                        }
                      }
                    });
                  } catch (e) {
                    setState(() {
                      loading = false;
                    });
                    callSMessage(context,
                        FlutterI18n.translate(context, "anErrorOccurred"),
                        duration: 2);
                  }
                }

                setState(() {
                  loading = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: Text(
                FlutterI18n.translate(context, "verify"),
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget firstCard(Size size) {
    return Card(
      key: ValueKey(true),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          captcha == null
              ? SizedBox()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey,
                          )),
                      child: SvgPicture.string(
                        captcha!,
                        width: 200,
                      ),
                    ),
                    Center(
                      child: IconButton(
                          onPressed: () {
                            request();
                          },
                          icon: Icon(
                            Icons.refresh,
                            size: 34,
                          )),
                    ),
                  ],
                ),
          UIHelper.verticalSpaceSmall,
          TextField(
            controller: verifyCaptchaController,
            style: TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Captcha',
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
                setState(() {
                  loading = true;
                });

                if (verifyCaptchaController.text.isNotEmpty) {
                  var param = VerifyCaptchaModel(
                    captchaResponse: verifyCaptchaController.text,
                    email: widget.data.email,
                  );

                  try {
                    await apiService
                        .verifyCaptcha(context, param)
                        .then((value) async {
                      if (value!) {
                        await apiService
                            .registerWithEmail(context, widget.data)
                            .then(
                          (value) async {
                            if (value != null) {
                              storageService.bondToken = value.token!;
                              setState(() {
                                _isFirstCard = !_isFirstCard;
                              });

                              await sendConfirmationCode(context);
                            }
                          },
                        );
                      }
                    });
                  } catch (e) {
                    setState(() {
                      loading = false;
                    });
                    callSMessage(context,
                        FlutterI18n.translate(context, "anErrorOccurred"),
                        duration: 2);
                  }
                } else {
                  callSMessage(
                      context, FlutterI18n.translate(context, "entercaptcha"),
                      duration: 1);
                }
                setState(() {
                  loading = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: Text(
                FlutterI18n.translate(context, "verify"),
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> sendConfirmationCode(BuildContext context) async {
    apiService.sendEmail(context).then((value) {
      if (value != null) {
        callSMessage(context, value, duration: 2);
        setState(() {
          _timeout = 120;
        });
        startTimer();
      } else {
        callSMessage(context, FlutterI18n.translate(context, "anErrorOccurred"),
            duration: 2);
      }
    });
  }
}
