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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/environments/environment_type.dart';
import 'package:paycool/service_locator.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../../logger.dart';

class ConfirmMnemonicViewModel extends BaseViewModel {
  final log = getLogger('ConfirmMnemonicViewModel');

  final count = 12;
  String route = '';
  final List<TextEditingController> importMnemonicController = [];

  List<TextEditingController> tapTextControllerList = [];
  List<TextEditingController> controller = [];

  String errorMessage = '';
  List<String> userTypedMnemonicList = [];
  final List<String> randomMnemonicList = [];
  String listToStringMnemonic = '';
  bool isTap = true;
  List<String> tappedMnemonicList = [];
  List<String> shuffledList = [];
  final navigationService = locator<NavigationService>();
  List<int> lastIndexList = [];
/*----------------------------------------------------------------------
                    init
----------------------------------------------------------------------*/
  init() {
    fillTapControllerList();
  }

/*----------------------------------------------------------------------
                    onBackButtonPressed
----------------------------------------------------------------------*/
  onBackButtonPressed() async {
    await navigationService.navigateTo(BackupMnemonicViewRoute);
  }

/*----------------------------------------------------------------------
                    Clear tapped list
----------------------------------------------------------------------*/
  clearTappedList() {
    setBusy(true);
    tappedMnemonicList.clear();

    lastIndexList = [];
    for (var single in tapTextControllerList) {
      if (single.text.contains(')')) {
        int s = single.text.indexOf(' ') + 1;
        single.text = single.text.substring(s, single.text.length);
      }
    }

    setBusy(false);
  }

  selectWordsInOrder(int i, String singleWord) {
    setBusy(true);
    // if (model.tappedMnemonicList
    //     .contains(singleWord)) {

    //   int duplicateWordIndex = model
    //       .tappedMnemonicList
    //       .indexOf(singleWord);
    //   if (duplicateWordIndex == i) {

    //     return;
    //   }
    // }

    if (tappedMnemonicList.length < count
        // (!tappedMnemonicList.contains(singleWord)) &&
        ) {
      if (!lastIndexList.contains(i)) {
        debugPrint('lastIndexList $lastIndexList');
        debugPrint('if : adding element ');
        tappedMnemonicList.add(singleWord);
        tapTextControllerList[i].text =
            '${tappedMnemonicList.length}) $singleWord';
        lastIndexList.add(i);
      }
      // else {
      //   debugPrint('else : remove this element and number bracket');
      //   tappedMnemonicList.removeLast();
      //   tapTextControllerList[i].text = singleWord;
      // }
    }

    setBusy(false);
  }

/*----------------------------------------------------------------------
                    fill tap controller list
----------------------------------------------------------------------*/
  fillTapControllerList() {
    for (var i = 0; i < count; i++) {
      TextEditingController tapTextController = TextEditingController();
      tapTextControllerList.add(tapTextController);
    }
  }

/*----------------------------------------------------------------------
                    Shuffle mnemonic words
----------------------------------------------------------------------*/
  shuffleStringList(List<String> shuffling) {
    // setBusy(true);

    shuffledList = [];
    // var random = new Random();
    // log.i('before shuffled items $shuffling');
    // // Go through all elements.
    // for (var i = shuffling.length - 1; i > 0; i--) {
    //   // Pick a pseudorandom number according to the list length
    //   var n = random.nextInt(i + 1);

    //   var holder = shuffling[i];
    //   shuffling[i] = shuffling[n];
    //   shuffling[n] = holder;
    // }

    shuffling.shuffle();
    shuffledList = shuffling;
    log.w('shuffled items $shuffling');
    log.e(randomMnemonicList);
    // final res = items.map((e) => e).toSet();
    // res.forEach((element) {
    //   shuffledList.add(element);
    // });
    // log.i('shuffled list $shuffledList');
    // setBusy(false);
  }

/*----------------------------------------------------------------------
                    Select mnemonic confirm method
----------------------------------------------------------------------*/
  selectConfirmMethod(String verifyMethod) {
    setBusy(true);

    if (verifyMethod == 'tap') {
      isTap = true;
    } else {
      isTap = false;
    }

    setBusy(false);
  }

/*----------------------------------------------------------------------
                    Verify mnemonic
----------------------------------------------------------------------*/

  verifyMnemonic(controller, context, count, routeName) {
    userTypedMnemonicList.clear();

    debugPrint(routeName.toString());
    debugPrint(isTap.toString());
    if (routeName == 'import') isTap = false;
    for (var i = 0; i < count; i++) {
      String mnemonicWord = isTap ? controller[i] : controller[i].text;
      userTypedMnemonicList.add(mnemonicWord.trim());
    }

    if (routeName == 'import') {
      if ((userTypedMnemonicList[0] != '' &&
              userTypedMnemonicList[1] != '' &&
              userTypedMnemonicList[2] != '' &&
              userTypedMnemonicList[3] != '' &&
              userTypedMnemonicList[4] != '' &&
              userTypedMnemonicList[5] != '' &&
              userTypedMnemonicList[6] != '' &&
              userTypedMnemonicList[7] != '' &&
              userTypedMnemonicList[8] != '' &&
              userTypedMnemonicList[9] != '' &&
              userTypedMnemonicList[10] != '' &&
              userTypedMnemonicList[11] != '') ||
          !isProduction) {
        String? localEnv;
        if (!isProduction) {
          try {
            localEnv = dotenv.env['MNEMONIC'];
          } catch (err) {
            localEnv = null;
            log.e('dot env can not find local env mnemonic');
          }
          log.w('local env $localEnv');
        }
        listToStringMnemonic = isProduction
            ? userTypedMnemonicList.join(' ')
            : localEnv ?? userTypedMnemonicList.join(' ');
        bool isValid = bip39.validateMnemonic(listToStringMnemonic);
        if (isValid) {
          importWallet(listToStringMnemonic, context);
        } else {
          showSimpleNotification(
              Text(FlutterI18n.translate(context, "invalidMnemonic"),
                  style: headText4.copyWith(fontWeight: FontWeight.bold)),
              position: NotificationPosition.top,
              background: primaryColor,
              subtitle: Text(FlutterI18n.translate(
                  context, "pleaseFillAllTheTextFieldsCorrectly")));
        }
      } else {
        showSimpleNotification(
            Text(FlutterI18n.translate(context, "invalidMnemonic"),
                style: headText4.copyWith(fontWeight: FontWeight.bold)),
            position: NotificationPosition.bottom,
            background: primaryColor,
            subtitle: Text(FlutterI18n.translate(
                context, "pleaseFillAllTheTextFieldsCorrectly")));
      }
    } else {
      createWallet(context);
    }
  }

  // Import Wallet

  importWallet(String stringMnemonic, context) async {
    var args = {'mnemonic': stringMnemonic, 'isImport': true};
    Navigator.of(context).pushNamed('/createPassword', arguments: args);
    userTypedMnemonicList = [];
  }

// Create Wallet
  createWallet(context) {
    if (listEquals(randomMnemonicList, userTypedMnemonicList)) {
      listToStringMnemonic = randomMnemonicList.join(' ');
      bool isValid = bip39.validateMnemonic(listToStringMnemonic);
      if (isValid) {
        var args = {'mnemonic': listToStringMnemonic, 'isImport': false};
        Navigator.of(context).pushNamed('/createPassword', arguments: args);
        userTypedMnemonicList = [];
      } else {
        showSimpleNotification(
            Text(FlutterI18n.translate(context, "invalidMnemonic"),
                style: headText4.copyWith(fontWeight: FontWeight.bold)),
            position: NotificationPosition.bottom,
            background: primaryColor,
            subtitle: Text(FlutterI18n.translate(
                context, "pleaseFillAllTheTextFieldsCorrectly")));
      }
    } else {
      showSimpleNotification(
          Text(FlutterI18n.translate(context, "invalidMnemonic"),
              style: headText4.copyWith(fontWeight: FontWeight.bold)),
          background: primaryColor,
          position: NotificationPosition.bottom,
          subtitle: Text(FlutterI18n.translate(
              context, "pleaseFillAllTheTextFieldsCorrectly")));
    }
  }
}
