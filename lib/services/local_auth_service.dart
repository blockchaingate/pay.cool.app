import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:paycool/logger.dart';
import 'package:stacked_services/stacked_services.dart';

import '../constants/route_names.dart';
import '../service_locator.dart';
import 'local_storage_service.dart';

class LocalAuthService {
  final log = getLogger('LocalAuthService');

  final NavigationService? navigationService = locator<NavigationService>();
  final LocalStorageService? localStorageService =
      locator<LocalStorageService>();

  final _auth = LocalAuthentication();

  bool _isLockedOut = false;
  bool get isLockedOut => _isLockedOut;

  bool _isLockedOutPerm = false;
  bool get isLockedOutPerm => _isLockedOutPerm;

  bool _hasAuthorized = false;
  bool get hasAuthorized => _hasAuthorized;

  bool _isCancelled = false;
  bool get isCancelled => _isCancelled;

  bool _authInProgress = false;
  bool get authInProgress => _authInProgress;

  // cancel authentication
  void cancelAuthentication() {
    // &&

    //     navigationService.currentRoute() != SettingViewRoute
    if (localStorageService!.hasAppGoneInTheBackgroundKey) {
      navigationService!.navigateTo(WalletSetupViewRoute);
    }
    _auth.stopAuthentication();
  }

  setIsCancelledValueFalse() {
    _isCancelled = false;
  }

  Future<bool> isDeviceSupported() async {
    return _auth.isDeviceSupported();
  }

  Future<bool> canCheckBiometrics() async {
    return _auth.canCheckBiometrics;
  }

  // Authenticate
  Future<bool> authenticateApp(
      {bool isBiometricOnly = false,
      isStickyAuth = true,
      bool isSensitiveTransaction = true}) async {
    _hasAuthorized = false;
    _authInProgress = true;
    setIsCancelledValueFalse();
    try {
      await _auth
          .authenticate(
        localizedReason: 'Authenticate',
        options: AuthenticationOptions(
          biometricOnly: isBiometricOnly,
          stickyAuth: isStickyAuth,
          sensitiveTransaction: isSensitiveTransaction,
        ),
      )
          .then((res) {
        _hasAuthorized = res;
        // localStorageService!.hasPhoneProtectionEnabled = true;
        localStorageService!.hasCancelledBiometricAuth = false;
        if (_hasAuthorized) {
          localStorageService!.hasAppGoneInTheBackgroundKey = false;
        }
        log.w('_hasAuthorized  $_hasAuthorized');
      });
    } on PlatformException catch (e) {
      _authInProgress = false;
      // when any type of authentication is not set
      if (e.code == auth_error.notAvailable ||
          e.code == auth_error.notEnrolled ||
          e.code == auth_error.passcodeNotSet) {
        localStorageService!.hasCancelledBiometricAuth = false;
        localStorageService!.hasInAppBiometricAuthEnabled = false;
        localStorageService!.hasPhoneProtectionEnabled = false;
      } else if (e.code == 'auth_in_progress') {
        _authInProgress = true;
        return false;
      } else if (e.code == auth_error.lockedOut) {
        // Too manu failed attempts and locked out temp
        _isCancelled = false;
        _isLockedOut = true;
      } else if (e.code == auth_error.permanentlyLockedOut) {
        // Too manu failed attempts and locked out permanently, now required password/pin
        _isLockedOutPerm = true;
      }

      log.e('catch $e');
    }
    log.w(
        '_hasAuthenticated $_hasAuthorized -- _authInProgress $_authInProgress --  storageService.hasInAppBiometricAuthEnabled ${localStorageService!.hasInAppBiometricAuthEnabled} --  _isLockedOutPerm $_isLockedOutPerm -- _isLockedOut $_isLockedOut --  hasPhoneProtectionEnabled ${localStorageService!.hasPhoneProtectionEnabled}');
    if (!isLockedOut && !isLockedOutPerm && !_hasAuthorized) {
      _isCancelled = true;
      localStorageService!.hasCancelledBiometricAuth = true;
    }
    if (_isCancelled &&
        localStorageService!.hasPhoneProtectionEnabled &&
        localStorageService!.hasInAppBiometricAuthEnabled) {
      cancelAuthentication();
    }

    _authInProgress = false;
    log.i(
        '_hasAuthenticated $_hasAuthorized -- _authInProgress $_authInProgress --  _isLockedOutPerm $_isLockedOutPerm -- _isLockedOut $_isLockedOut --  hasPhoneProtectionEnabled ${localStorageService!.hasPhoneProtectionEnabled}');
    return _hasAuthorized;
  }
}
