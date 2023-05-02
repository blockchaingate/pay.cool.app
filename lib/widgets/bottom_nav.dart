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

import 'package:flutter/material.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/navigation_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/widgets/bottom_navmodel.dart';
import 'package:stacked/stacked.dart';

class BottomNavBar extends StatelessWidget {
  final int count;
  BottomNavBar({Key? key, required this.count}) : super(key: key);
  final storageService = locator<LocalStorageService>();
  final NavigationService navigationService = locator<NavigationService>();
  final SharedService sharedService = locator<SharedService>();
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<BottomNavViewmodel>.reactive(
        onViewModelReady: (model) async {
          debugPrint("init BottomNavBar2");
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
                      backgroundColor: secondaryColor,
                      selectedItemColor: primaryColor,
                      showUnselectedLabels: true,
                      // selectedIconTheme: IconThemeData(color: primaryColor),
                      // unselectedIconTheme: IconThemeData(color: grey),
                      items: model.mainItems,
                      onTap: (int idx) {
                        String currentRouteName =
                            sharedService.getCurrentRouteName(context);
                        if (storageService.showPaycool &&
                            storageService.showPaycoolClub) {
                          debugPrint("nav has Pay.cool and club, id: $idx");
                          switch (idx) {
                            case 0:
                              if (currentRouteName != 'clubDashboardView') {
                                navigationService
                                    .navigateUsingpopAndPushedNamed(
                                        clubDashboardViewRoute);
                              }
                              break;

                            case 1:
                              if (currentRouteName != 'WalletDashboardView') {
                                navigationService
                                    .navigateUsingpopAndPushedNamed(
                                        DashboardViewRoute);
                              }
                              break;

                            case 2:
                              if (currentRouteName != 'PayCoolView') {
                                navigationService
                                    .navigateUsingpopAndPushedNamed(
                                        PayCoolViewRoute);
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
                                        SettingViewRoute);
                              } else if (ModalRoute.of(context)!
                                      .settings
                                      .name ==
                                  'SettingsView') {
                                return null;
                              }
                              break;
                          }
                        } else if (storageService.showPaycool &&
                            !storageService.showPaycoolClub) {
                          debugPrint(
                              "nav has Pay.cool and no Pay.cool club, id: $idx");
                          switch (idx) {
                            case 0:
                              if (currentRouteName != 'WalletDashboardView') {
                                navigationService
                                    .navigateUsingpopAndPushedNamed(
                                        DashboardViewRoute);
                              }
                              break;

                            case 1:
                              if (currentRouteName != 'PayCoolView') {
                                navigationService
                                    .navigateUsingpopAndPushedNamed(
                                        PayCoolViewRoute);
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
                                        SettingViewRoute);
                              } else if (ModalRoute.of(context)!
                                      .settings
                                      .name ==
                                  'SettingsView') {
                                return null;
                              }
                              break;
                          }
                        } else if (!storageService.showPaycool &&
                            storageService.showPaycoolClub) {
                          debugPrint(
                              "nav no Pay.cool and has Pay.cool club, id: $idx");
                          switch (idx) {
                            case 0:
                              if (currentRouteName != 'clubDashboardView') {
                                navigationService
                                    .navigateUsingpopAndPushedNamed(
                                        clubDashboardViewRoute);
                              }
                              break;
                            case 1:
                              if (currentRouteName != 'WalletDashboardView') {
                                navigationService
                                    .navigateUsingpopAndPushedNamed(
                                        DashboardViewRoute);
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
                                        SettingViewRoute);
                              } else if (ModalRoute.of(context)!
                                      .settings
                                      .name ==
                                  'SettingsView') {
                                return null;
                              }
                              break;
                          }
                        } else {
                          debugPrint(
                              "nav no Pay.cool and no Pay.cool club, id: $idx");
                          switch (idx) {
                            case 0:
                              if (currentRouteName != 'WalletDashboardView') {
                                navigationService
                                    .navigateUsingpopAndPushedNamed(
                                        DashboardViewRoute);
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
                                        SettingViewRoute);
                              } else if (ModalRoute.of(context)!
                                      .settings
                                      .name ==
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
