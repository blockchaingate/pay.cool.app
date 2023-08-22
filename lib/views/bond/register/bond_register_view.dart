import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/bond/login/login_view.dart';
import 'package:paycool/views/bond/progressIndicator.dart';
import 'package:paycool/views/bond/register/bond_register_viewmodel.dart';
import 'package:stacked/stacked.dart';

class BondRegisterView extends StatefulWidget {
  const BondRegisterView({Key? key}) : super(key: key);

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
              resizeToAvoidBottomInset: true,
              body: SingleChildScrollView(
                child: Container(
                  width: size.width,
                  height: size.height,
                  decoration: const BoxDecoration(
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SizedBox(
                          height: size.height * 0.8,
                          width: size.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              UIHelper.verticalSpaceLarge,
                              Text(
                                "El Salvador Digital National Bond",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              UIHelper.verticalSpaceLarge,
                              Text(
                                "Register Page",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              UIHelper.verticalSpaceSmall,
                              Text(
                                "If you have an inviting relationship, please fill out the invitation form.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w200,
                                    color: Colors.white),
                              ),
                              UIHelper.verticalSpaceLarge,
                              TextField(
                                controller: model.emailController,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 13),
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
                                style: TextStyle(
                                    color: Colors.white, fontSize: 13),
                                obscureText: true,
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
                              model.isReferral
                                  ? TextField(
                                      controller: model.referralController,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 13),
                                      decoration: InputDecoration(
                                        hintText: 'Referral Code',
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
                              model.isReferral
                                  ? UIHelper.verticalSpaceSmall
                                  : SizedBox(),
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
                                    'Register',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: size.width * 0.9,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      model.isReferral = !model.isReferral;
                                    });
                                  },
                                  child: Text(
                                    "Do you have referral code?",
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
                                      text: "Already have an account?",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' Login',
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
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
