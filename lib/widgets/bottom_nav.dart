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
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/widgets/bottom_navmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class BottomNavBar extends StatelessWidget {
  final int count;
  BottomNavBar({Key? key, required this.count}) : super(key: key);
  final storageService = locator<LocalStorageService>();
  final NavigationService navigationService = locator<NavigationService>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ViewModelBuilder<BottomNavViewmodel>.reactive(
        onViewModelReady: (model) async {
          model.context = context;
          await model.init(count);
        },
        viewModelBuilder: () => BottomNavViewmodel(),
        builder: (context, model, _) => BottomAppBar(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            height: 50,
            color: Colors.white,
            shape: const CircularNotchedRectangle(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    if (model.currentRouteName != 'WalletDashboardView') {
                      navigationService.navigateTo(DashboardViewRoute);
                    }
                  },
                  child: SizedBox(
                    width: size.width * 0.15,
                    height: 50,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ImageIcon(
                            AssetImage(
                                "assets/images/new-design/wallet_icon.png"),
                            size: 16,
                            color: count == 1 ? primaryColor : grey,
                          ),
                          SizedBox(height: 3),
                          Text(
                            "Home",
                            style: TextStyle(
                              fontSize: 12,
                              color: count == 1 ? primaryColor : grey,
                            ),
                          )
                        ]),
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (model.currentRouteName != 'SettingsView') {
                      navigationService.navigateTo(
                        SettingViewRoute,
                      );
                    }
                  },
                  child: SizedBox(
                    width: size.width * 0.15,
                    height: 50,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ImageIcon(
                            AssetImage("assets/images/new-design/inv_icon.png"),
                            size: 16,
                            color: count == 2 ? primaryColor : grey,
                          ),
                          SizedBox(height: 3),
                          Text(
                            "INV",
                            style: TextStyle(
                              fontSize: 12,
                              color: count == 2 ? primaryColor : grey,
                            ),
                          )
                        ]),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      size.width * 0.1, 20, size.width * 0.1, 0),
                  child:
                      Text("PAY", style: TextStyle(fontSize: 12, color: grey)),
                ),
                InkWell(
                  onTap: () {
                    if (model.currentRouteName != 'SettingsView') {
                      navigationService.navigateTo(
                        SettingViewRoute,
                      );
                    }
                  },
                  child: SizedBox(
                    width: size.width * 0.15,
                    height: 50,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ImageIcon(
                            AssetImage(
                                "assets/images/new-design/dapp_icon.png"),
                            size: 16,
                            color: count == 3 ? primaryColor : grey,
                          ),
                          SizedBox(height: 3),
                          Text(
                            "Dapp",
                            style: TextStyle(
                              fontSize: 12,
                              color: count == 3 ? primaryColor : grey,
                            ),
                          )
                        ]),
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (model.currentRouteName != 'SettingsView') {
                      navigationService.navigateTo(
                        SettingViewRoute,
                      );
                    }
                  },
                  child: SizedBox(
                    width: size.width * 0.15,
                    height: 50,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ImageIcon(
                            AssetImage("assets/images/new-design/me_icon.png"),
                            size: 16,
                            color: count == 4 ? primaryColor : grey,
                          ),
                          SizedBox(height: 3),
                          Text(
                            "Me",
                            style: TextStyle(
                              fontSize: 12,
                              color: count == 4 ? primaryColor : grey,
                            ),
                          )
                        ]),
                  ),
                ),
              ],
            )));
  }
}
