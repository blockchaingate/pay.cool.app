/*
* Copyright (c) 2020 Exchangily LLC
*
* Licensed under Apache License v2.0
* You may obtain a copy of the License at
*
*      https://www.apache.org/licenses/LICENSE-2.0
*
*----------------------------------------------------------------------
* Author: barry-ruprai@exchangily.com
*----------------------------------------------------------------------
*/

import 'dart:async';
import 'package:flutter/cupertino.dart';

import '../logger.dart';
import '../models/dialog/dialog_request.dart';
import '../models/dialog/dialog_response.dart';

class LocalDialogService {
  final GlobalKey<NavigatorState> _dialogNavigationKey =
      GlobalKey<NavigatorState>();
  Function(DialogRequest) _showDialogListener;
  Function(DialogRequest) _showOrderUpdateDialogListener;
  Function(DialogRequest) _showBasicDialogListener;
  Function(DialogRequest) _showVerifyDialogListener;
  Completer<DialogResponse> _dialogCompleter;

  GlobalKey<NavigatorState> get navigatorKey => _dialogNavigationKey;

  final log = getLogger('LocalDialogService');
  // Registers a callback function, typically to show the dialog box

/*----------------------------------------------------------------------
      Completer the _dialogCompleter to resume the Future's execution
----------------------------------------------------------------------*/

  void dialogComplete(DialogResponse response) {
    //   _dialogNavigationKey.currentState.pop();
    _dialogCompleter.complete(response);
    _dialogCompleter = null;
  }

/*----------------------------------------------------------------------
                Password Dialog
----------------------------------------------------------------------*/

  void registerDialogListener(Function(DialogRequest) showDialogListener) {
    _showDialogListener = showDialogListener;
  }

  // Calls the dialog listener and returns a future that will wait for the dialog to complete
  Future<DialogResponse> showDialog(
      {String title, String description, String buttonTitle}) {
    log.w('In show dialog');
    _dialogCompleter = Completer<DialogResponse>();
    _showDialogListener(DialogRequest(
        title: title, description: description, buttonTitle: buttonTitle));
    log.i('1');
    return _dialogCompleter.future;
  }

  // verify dialog

  void registerVerifyDialogListener(
      Function(DialogRequest) showVerifyDialogListener) {
    _showVerifyDialogListener = showVerifyDialogListener;
  }

  // Calls the dialog listener and returns a future that will wait for the dialog to complete
  Future<DialogResponse> showVerifyDialog(
      {String title,
      String description,
      String buttonTitle,
      String secondaryButton}) {
    log.w('In show verify dialog');
    _dialogCompleter = Completer<DialogResponse>();
    _showVerifyDialogListener(DialogRequest(
        title: title,
        description: description,
        buttonTitle: buttonTitle,
        secondaryButton: secondaryButton));
    return _dialogCompleter.future;
  }

/*----------------------------------------------------------------------
                  Basic dialog
----------------------------------------------------------------------*/

  void registerBasicDialogListener(
      Function(DialogRequest) showBasicDialogListener) {
    _showBasicDialogListener = showBasicDialogListener;
  }

  Future<DialogResponse> showBasicDialog({
    String title,
    String description,
    String buttonTitle,
  }) {
    log.w('In show basic dialog');
    _dialogCompleter = Completer<DialogResponse>();
    _showBasicDialogListener(DialogRequest(
      title: title,
      description: description,
      buttonTitle: buttonTitle,
    ));
    return _dialogCompleter.future;
  }

/*----------------------------------------------------------------------
                Order update dialog
----------------------------------------------------------------------*/
  void registerOrderUpdateDialogListener(
      Function(DialogRequest) showOrerUpdateDialogListener) {
    _showOrderUpdateDialogListener = showOrerUpdateDialogListener;
  }

  // Calls the dialog listener and returns a future that will wait for the dialog to complete
  Future<DialogResponse> showOrderUpdateDialog(
      {String title,
      String description,
      String confirmOrder,
      String cancelOrder}) {
    log.w('showOrerUpdateDialog $title');
    _dialogCompleter = Completer<DialogResponse>();
    _showOrderUpdateDialogListener(DialogRequest(
        title: title,
        description: description,
        buttonTitle: confirmOrder,
        cancelButton: cancelOrder));
    return _dialogCompleter.future;
  }
}
