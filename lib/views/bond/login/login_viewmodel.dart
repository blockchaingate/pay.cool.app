import 'package:flutter/material.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/models/bond/rm/login_model.dart';
import 'package:paycool/models/bond/vm/bond_login_vm.dart';
import 'package:paycool/models/bond/vm/register_email_model.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/api_service.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/utils/string_validator.dart';
import 'package:paycool/views/bond/register/verification_code_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class BondLoginViewModel extends BaseViewModel with WidgetsBindingObserver {
  BondLoginViewModel({BuildContext? context});
  bool isVisible = true;
  bool isKeyboardOpen = false;
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

  @override
  void didChangeMetrics() {
    final mediaQuery = MediaQuery.of(context!);
    final keyboardHeight = mediaQuery.viewInsets.bottom;

    isKeyboardOpen = keyboardHeight > 1;

    notifyListeners();
    super.didChangeMetrics();
  }

  Future<void> login() async {
    setBusy(true);
    try {
      if (emailController.text.isEmpty ||
          !validateEmail(emailController.text)) {
        var snackBar = SnackBar(content: Text('Please enter valid email'));
        ScaffoldMessenger.of(context!).showSnackBar(snackBar);
      } else {
        var param = LoginModel(
            email: emailController.text, password: passwordController.text);
        final BondLoginModel? result =
            await apiService.loginWithEmail(context!, param);
        if (result != null) {
          storageService.bondToken = result.token!;
          if (result.isVerifiedEmail == true) {
            navigationService.navigateTo(DashboardViewRoute);
          } else {
            var value = RegisterEmailModel(
                id: result.id, token: result.token, email: result.email);

            Navigator.push(
              context!,
              MaterialPageRoute(
                builder: (context) => VerificationCodeView(
                  data: value,
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
