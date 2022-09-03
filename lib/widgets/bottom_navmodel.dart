import 'dart:developer';

import 'package:exchangily_ui/exchangily_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:stacked/stacked.dart';

import '../service_locator.dart';

class BottomNavViewmodel extends BaseViewModel {
  final storageService = localLocator<LocalStorageService>();

  final double iconSize = 40;
  BuildContext context;
  int selectedIndex = 1;

  List<BottomNavigationBarItem> itemsAll = [];

  List<BottomNavigationBarItem> itemsNo7Pay = [];

  List<BottomNavigationBarItem> itemsNoClubDashboard = [];

  List<BottomNavigationBarItem> itemsNoAll = [];

  List<BottomNavigationBarItem> mainItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.ac_unit),
      label: " ",
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.ac_unit),
      label: " ",
    ),
  ];

  init(count) async {
    setBusy(true);
    log("init BottomNavmodel");
    storageService.showPaycool = true;
    // log("Display Paycool: "+ storageService.showPaycool.toString());
    await countItemNum(count).then((value) async {
      selectedIndex = value;
      log("BottomNav model selected Index: $selectedIndex");
      await setNavItems().then((e) {
        mainItems = e;
        setBusy(false);
      });
    });
  }

  Future<int> countItemNum(_selectedIndex) async {
    if (storageService.showPaycool && storageService.showPaycoolClub) {
      return _selectedIndex;
    } else if (storageService.showPaycool && !storageService.showPaycoolClub) {
      return _selectedIndex - 1;
    } else if (!storageService.showPaycool && storageService.showPaycoolClub) {
      return _selectedIndex <= 1 ? _selectedIndex : _selectedIndex - 1;
    } else {
      return _selectedIndex <= 1 ? _selectedIndex - 1 : _selectedIndex - 2;
    }
    // return _selectedIndex;
  }

  Future<List<BottomNavigationBarItem>> setNavItems() async {
    checkImageColor(num) {
      if (storageService.showPaycool && storageService.showPaycoolClub) {
        return num;
      } else if (storageService.showPaycool &&
          !storageService.showPaycoolClub) {
        return num - 1;
      } else if (!storageService.showPaycool &&
          storageService.showPaycoolClub) {
        return num <= 1 ? num : num - 1;
      } else {
        return num <= 1 ? num - 1 : num - 2;
      }
    }

    BottomNavigationBarItem i1 = BottomNavigationBarItem(
      icon: Image.asset(
        'assets/images/paycool/ribbon-05.png',
        width: 40,
        height: 30,
        color: selectedIndex == checkImageColor(0) ? primaryColor : grey,
      ),
      label: FlutterI18n.translate(context, "club"),
    );

    BottomNavigationBarItem i2 = BottomNavigationBarItem(
        icon: Image.asset(
          'assets/images/paycool/wallet.png',
          width: 40,
          height: 30,
          color: selectedIndex == checkImageColor(1) ? primaryColor : grey,
        ),
        label: FlutterI18n.translate(context, "wallet"));

    BottomNavigationBarItem i3 = BottomNavigationBarItem(
      icon: Image.asset(
        'assets/images/paycool/pay.png',
        width: 40,
        height: 30,
        color: selectedIndex == checkImageColor(2) ? primaryColor : grey,
      ),
      label: FlutterI18n.translate(context, "payCool"),
    );

    BottomNavigationBarItem i4 = BottomNavigationBarItem(
      icon: Image.asset(
        'assets/images/paycool/remit.png',
        width: 40,
        height: 30,
        color: selectedIndex == checkImageColor(3) ? primaryColor : grey,
      ),
      label: FlutterI18n.translate(context, "remit"),
    );
    BottomNavigationBarItem i5 = BottomNavigationBarItem(
        icon: Image.asset(
          'assets/images/paycool/settings-icon.png',
          width: 40,
          height: 30,
          color: selectedIndex == checkImageColor(4) ? primaryColor : grey,
        ),
        label: FlutterI18n.translate(context, "settings"));

    itemsAll = [i1, i2, i3, i4, i5].toList();
    itemsNo7Pay = [i1, i2, i4, i5].toList();
    itemsNoClubDashboard = [i2, i3, i4, i5].toList();
    itemsNoAll = [i2, i4, i5].toList();

    if (storageService.showPaycool && storageService.showPaycoolClub) {
      return itemsAll;
    } else if (storageService.showPaycool && !storageService.showPaycoolClub) {
      return itemsNoClubDashboard;
    } else if (!storageService.showPaycool && storageService.showPaycoolClub) {
      return itemsNo7Pay;
    } else {
      return itemsNoAll;
    }
  }
}
