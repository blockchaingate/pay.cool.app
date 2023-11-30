import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/models/bond/rm/login_model.dart';
import 'package:paycool/models/bond/rm/register_email_model.dart';
import 'package:paycool/models/bond/vm/bond_login_vm.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/api_service.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/utils/string_validator.dart';
import 'package:paycool/views/bond/helper.dart';
import 'package:paycool/views/bond/register/verification_code_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class BondLoginViewModel extends BaseViewModel with WidgetsBindingObserver {
  BondLoginViewModel({BuildContext? context});
  String? deviceId;

  ApiService apiService = locator<ApiService>();
  final storageService = locator<LocalStorageService>();
  final NavigationService navigationService = locator<NavigationService>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  BuildContext? context;

  init() async {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> login() async {
    setBusy(true);
    try {
      if (emailController.text.isEmpty ||
          !validateEmail(emailController.text)) {
        callSMessage(
            context!, FlutterI18n.translate(context!, "enterValidEmailAddress"),
            duration: 2);
      } else {
        var param = LoginModel(
            email: emailController.text, password: passwordController.text);
        final BondLoginModel? result =
            await apiService.loginWithEmail(context!, param);
        if (result != null) {
          if (result.isEmailVerified == true) {
            storageService.bondToken = result.token!;

            navigationService.navigateTo(BondDashboardViewRoute);
          } else {
            var value = RegisterEmailModel(
              email: emailController.text,
              password: passwordController.text,
            );

            Navigator.push(
              context!,
              MaterialPageRoute(
                builder: (context) => VerificationCodeView(
                  data: value,
                  justVerify: true,
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      setBusy(false);
    }

    setBusy(false);
  }
}
