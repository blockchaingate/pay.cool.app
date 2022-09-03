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

import 'package:exchangily_core/exchangily_core.dart';
import 'package:exchangily_ui/exchangily_ui.dart';
import 'package:flutter/material.dart';
import 'package:paycool/constants/paycool_api_routes.dart';
import 'package:paycool/widgets/bottom_navmodel.dart';

import '../constants/paycool_constants.dart';
import '../services/local_storage_service.dart';

class BottomNavBar extends StatelessWidget {
  final int count;
  BottomNavBar({Key key, this.count}) : super(key: key);
  final localStorageService = locator<LocalStorageService>();
  final NavigationService navigationService = locator<NavigationService>();
  final SharedService sharedService = locator<SharedService>();
  @override
  Widget build(BuildContext context) {
    debugPrint("QQQQWWWW init BottomNavBar. Count is $count");

    return ViewModelBuilder<BottomNavViewmodel>.reactive(
        onModelReady: (model) async {
          debugPrint("QQQQWWWW init BottomNavBar2");
          model.context = context;
          await model.init(count);
        },
        viewModelBuilder: () => BottomNavViewmodel(),
        builder: (context, model, _) => WillPopScope(
              onWillPop: null,
              child: model.isBusy
                  ? Container()
                  : BottomNavigationBar(
                      currentIndex: model.selectedIndex,
                      type: BottomNavigationBarType.fixed,
                      selectedFontSize: 12,
                      unselectedFontSize: 12,
                      elevation: 10,
                      unselectedItemColor: grey,
                      backgroundColor: walletCardColor,
                      selectedItemColor: primaryColor,
                      showUnselectedLabels: true,
                      // selectedIconTheme: IconThemeData(color: primaryColor),
                      // unselectedIconTheme: IconThemeData(color: grey),
                      items: model.mainItems,
                      onTap: (int idx) {
                        String currentRouteName =
                            sharedService.getCurrentRouteName(context);
                        if (localStorageService.showPaycool &&
                            localStorageService.showPaycoolClub) {
                          debugPrint("nav has Paycool and club, id: " +
                              idx.toString());
                          switch (idx) {
                            case 0:
                              if (currentRouteName !=
                                  'PayCoolClubDashboardView') {
                                navigationService
                                    .navigateUsingpopAndPushedNamed(
                                        PaycoolConstants
                                            .payCoolClubDashboardViewRoute);
                              }
                              break;

                            case 1:
                              if (currentRouteName != 'WalletDashboardVieww') {
                                navigationService
                                    .navigateUsingpopAndPushedNamed(
                                        dashboardViewRoute);
                              }
                              break;

                            case 2:
                              if (currentRouteName != 'PayCoolView') {
                                navigationService
                                    .navigateUsingpopAndPushedNamed(
                                        PaycoolConstants.payCoolViewRoute);
                              }
                              break;
                            case 3:
                              if (currentRouteName != 'BindpayView') {
                                navigationService
                                    .navigateUsingpopAndPushedNamed(
                                        lightningRemitViewRoute);
                              }
                              break;

                            case 4:
                              if (currentRouteName != 'SettingsView') {
                                navigationService
                                    .navigateUsingpopAndPushedNamed(
                                        settingViewRoute);
                              } else if (ModalRoute.of(context).settings.name ==
                                  'SettingsView') {
                                return null;
                              }
                              break;
                          }
                        } else if (localStorageService.showPaycool &&
                            !localStorageService.showPaycoolClub) {
                          debugPrint(
                              "nav has Paycool and no Paycool club, id: " +
                                  idx.toString());
                          switch (idx) {
                            case 0:
                              if (currentRouteName != 'WalletDashboardVieww') {
                                navigationService
                                    .navigateUsingpopAndPushedNamed(
                                        dashboardViewRoute);
                              }
                              break;

                            case 1:
                              if (currentRouteName != 'PayCoolView') {
                                navigationService
                                    .navigateUsingpopAndPushedNamed(
                                        PaycoolConstants.payCoolViewRoute);
                              }
                              break;

                            case 2:
                              if (currentRouteName != 'BindpayView') {
                                navigationService
                                    .navigateUsingpopAndPushedNamed(
                                        lightningRemitViewRoute);
                              }
                              break;

                            case 3:
                              if (currentRouteName != 'SettingsView') {
                                navigationService
                                    .navigateUsingpopAndPushedNamed(
                                        settingViewRoute);
                              } else if (ModalRoute.of(context).settings.name ==
                                  'SettingsView') {
                                return null;
                              }
                              break;
                          }
                        } else if (!localStorageService.showPaycool &&
                            localStorageService.showPaycoolClub) {
                          debugPrint(
                              "nav no Paycool and has Paycool club, id: " +
                                  idx.toString());
                          switch (idx) {
                            case 0:
                              if (currentRouteName !=
                                  'PayCoolClubDashboardView') {
                                navigationService
                                    .navigateUsingpopAndPushedNamed(
                                        PaycoolConstants
                                            .payCoolClubDashboardViewRoute);
                              }
                              break;
                            case 1:
                              if (currentRouteName != 'WalletDashboardVieww') {
                                navigationService
                                    .navigateUsingpopAndPushedNamed(
                                        dashboardViewRoute);
                              }
                              break;

                            case 2:
                              if (currentRouteName != 'BindpayView') {
                                navigationService
                                    .navigateUsingpopAndPushedNamed(
                                        lightningRemitViewRoute);
                              }
                              break;

                            case 3:
                              if (currentRouteName != 'SettingsView') {
                                navigationService
                                    .navigateUsingpopAndPushedNamed(
                                        settingViewRoute);
                              } else if (ModalRoute.of(context).settings.name ==
                                  'SettingsView') {
                                return null;
                              }
                              break;
                          }
                        } else {
                          debugPrint(
                              "nav no Paycool and no Paycool club, id: " +
                                  idx.toString());
                          switch (idx) {
                            case 0:
                              if (currentRouteName != 'WalletDashboardVieww') {
                                navigationService
                                    .navigateUsingpopAndPushedNamed(
                                        dashboardViewRoute);
                              }
                              break;
                            case 1:
                              if (currentRouteName != 'BindpayView') {
                                navigationService
                                    .navigateUsingpopAndPushedNamed(
                                        lightningRemitViewRoute);
                              }
                              break;

                            case 2:
                              if (currentRouteName != 'SettingsView') {
                                navigationService
                                    .navigateUsingpopAndPushedNamed(
                                        settingViewRoute);
                              } else if (ModalRoute.of(context).settings.name ==
                                  'SettingsView') {
                                return null;
                              }
                              break;
                          }
                        }
                      },
                    ),
            ));
  }
}
