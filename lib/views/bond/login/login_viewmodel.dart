import 'package:flutter/material.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/models/bond/rm/login_model.dart';
import 'package:paycool/models/bond/vm/register_email_model.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/api_service.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/utils/string_validator.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class BondLoginViewModel extends BaseViewModel with WidgetsBindingObserver {
  BondLoginViewModel({BuildContext? context}) : _context = context;
  final BuildContext? _context;
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

    if (emailController.text.isEmpty || !validateEmail(emailController.text)) {
      var snackBar = SnackBar(content: Text('Please enter valid email'));
      ScaffoldMessenger.of(_context!).showSnackBar(snackBar);
    } else if (passwordController.text.isEmpty ||
        !validatePassword(passwordController.text)) {
      var snackBar = SnackBar(
          content: Text(
              "Enter password which is minimum 8 characters long and contains at least 1 uppercase, lowercase, number and a special character (e.g. (@#\$*~'%^()-_))"));
      ScaffoldMessenger.of(_context!).showSnackBar(snackBar);
    } else {
      var param = LoginModel(
          email: emailController.text, password: passwordController.text);

      final RegisterEmailModel? result =
          await apiService.loginWithEmail(context!, param);
      if (result != null) {
        storageService.bondToken = result.token!;
        navigationService.navigateTo(DashboardViewRoute);
      } else {
        var snackBar = SnackBar(content: Text('Login Failed'));
        ScaffoldMessenger.of(_context!).showSnackBar(snackBar);
      }
    }
    setBusy(false);
  }
}
