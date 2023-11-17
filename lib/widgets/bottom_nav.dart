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
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/widgets/bottom_navmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

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
            child: BottomAppBar(
                padding: const EdgeInsets.only(top: 10),
                height: 50,
                color: Colors.white,
                shape: const CircularNotchedRectangle(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Column(children: [
                      IconButton(
                          icon: Image.asset(
                            "assets/images/new-design/wallet_icon.png",
                            fit: BoxFit.cover,
                            color: Colors.red,
                            scale: 2.9,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {}),
                      Text(
                        "Home",
                        style: TextStyle(),
                      )
                    ]),
                    Column(children: [
                      IconButton(
                          icon: Image.asset(
                            "assets/images/new-design/inv_icon.png",
                            fit: BoxFit.cover,
                            color: Colors.red,
                            scale: 2.9,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {}),
                      Text("INV")
                    ]),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text("PAY",
                          style: TextStyle(
                              color: count == 3 ? Colors.black : Colors.red)),
                    ),
                    Column(children: [
                      IconButton(
                          icon: Image.asset(
                            "assets/images/new-design/dapp_icon.png",
                            fit: BoxFit.cover,
                            color: Colors.red,
                            scale: 2.9,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {}),
                      Text("Dapp")
                    ]),
                    Column(children: [
                      IconButton(
                          icon: Image.asset(
                            "assets/images/new-design/me_icon.png",
                            fit: BoxFit.cover,
                            color: Colors.red,
                            scale: 2.9,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {}),
                      Text("Me")
                    ]),
                  ],
                ))

            // BottomNavigationBar(
            //     currentIndex: model.selectedIndex,
            //     // type: BottomNavigationBarType.fixed,
            //     // selectedFontSize: 12,
            //     // unselectedFontSize: 12,
            //     // elevation: 10,
            //     // unselectedItemColor: grey,
            //     // backgroundColor: secondaryColor,
            //     // selectedItemColor: primaryColor,
            //     // showUnselectedLabels: true,
            //     items: model.mainItems,

            //     onTap: (int idx) {
            //       String currentRouteName =
            //           sharedService.getCurrentRouteName(context);
            //       if (storageService.showPaycool &&
            //           storageService.showPaycoolClub) {
            //         debugPrint("nav has Pay.cool and club, id: $idx");
            //         switch (idx) {
            //           case 0:
            //             if (currentRouteName != 'clubDashboardView') {
            //               navigationService
            //                   .navigateTo(clubDashboardViewRoute);
            //             }
            //             break;

            //           case 1:
            //             if (currentRouteName != 'WalletDashboardView') {
            //               navigationService
            //                   .navigateTo(DashboardViewRoute);
            //             }
            //             break;

            //           case 2:
            //             if (currentRouteName != 'PayCoolView') {
            //               navigationService.navigateTo(PayCoolViewRoute);
            //             }
            //             break;
            //           case 3:
            //             if (currentRouteName != 'BindpayView') {
            //               navigationService
            //                   .navigateTo(lightningRemitViewRoute);
            //             }
            //             break;

            //           case 4:
            //             if (currentRouteName != 'SettingsView') {
            //               navigationService.navigateTo(SettingViewRoute);
            //             } else if (ModalRoute.of(context)!
            //                     .settings
            //                     .name ==
            //                 'SettingsView') {
            //               return;
            //             }
            //             break;
            //         }
            //       } else if (storageService.showPaycool &&
            //           !storageService.showPaycoolClub) {
            //         debugPrint(
            //             "nav has Pay.cool and no Pay.cool club, id: $idx");
            //         switch (idx) {
            //           case 0:
            //             if (currentRouteName != 'WalletDashboardView') {
            //               navigationService
            //                   .navigateTo(DashboardViewRoute);
            //             }
            //             break;

            //           case 1:
            //             if (currentRouteName != 'PayCoolView') {
            //               navigationService.navigateTo(PayCoolViewRoute);
            //             }
            //             break;

            //           case 2:
            //             if (currentRouteName != 'BindpayView') {
            //               navigationService
            //                   .navigateTo(lightningRemitViewRoute);
            //             }
            //             break;

            //           case 3:
            //             if (currentRouteName != 'SettingsView') {
            //               navigationService.navigateTo(SettingViewRoute);
            //             } else if (ModalRoute.of(context)!
            //                     .settings
            //                     .name ==
            //                 'SettingsView') {
            //               return;
            //             }
            //             break;
            //         }
            //       } else if (!storageService.showPaycool &&
            //           storageService.showPaycoolClub) {
            //         debugPrint(
            //             "nav no Pay.cool and has Pay.cool club, id: $idx");
            //         switch (idx) {
            //           case 0:
            //             if (currentRouteName != 'clubDashboardView') {
            //               navigationService
            //                   .navigateTo(clubDashboardViewRoute);
            //             }
            //             break;
            //           case 1:
            //             if (currentRouteName != 'WalletDashboardView') {
            //               navigationService
            //                   .navigateTo(DashboardViewRoute);
            //             }
            //             break;

            //           case 2:
            //             if (currentRouteName != 'BindpayView') {
            //               navigationService
            //                   .navigateTo(lightningRemitViewRoute);
            //             }
            //             break;

            //           case 3:
            //             if (currentRouteName != 'SettingsView') {
            //               navigationService.navigateTo(SettingViewRoute);
            //             } else if (ModalRoute.of(context)!
            //                     .settings
            //                     .name ==
            //                 'SettingsView') {
            //               return;
            //             }
            //             break;
            //         }
            //       } else {
            //         debugPrint(
            //             "nav no Pay.cool and no Pay.cool club, id: $idx");
            //         switch (idx) {
            //           case 0:
            //             if (currentRouteName != 'WalletDashboardView') {
            //               navigationService
            //                   .navigateTo(DashboardViewRoute);
            //             }
            //             break;
            //           case 1:
            //             if (currentRouteName != 'BindpayView') {
            //               navigationService
            //                   .navigateTo(lightningRemitViewRoute);
            //             }
            //             break;

            //           case 2:
            //             if (currentRouteName != 'SettingsView') {
            //               navigationService.navigateTo(SettingViewRoute);
            //             } else if (ModalRoute.of(context)!
            //                     .settings
            //                     .name ==
            //                 'SettingsView') {
            //               return;
            //             }
            //             break;
            //         }
            //       }
            //     },
            //   ),
            ));
  }
}
