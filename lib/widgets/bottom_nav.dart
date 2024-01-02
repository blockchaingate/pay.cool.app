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
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:stacked_services/stacked_services.dart';

class BottomNavBar extends StatelessWidget {
  final int count;
  BottomNavBar({super.key, required this.count});

  final navigationService = locator<NavigationService>();
  final sharedService = locator<SharedService>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
          ),
        ],
      ),
      child: BottomAppBar(
        elevation: 8,
        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        height: 50,
        color: white,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            InkWell(
              onTap: () {
                if (sharedService.getCurrentRouteName(context) !=
                    'WalletDashboardView') {
                  navigationService.clearStackAndShow(DashboardViewRoute);
                }
              },
              child: SizedBox(
                width: size.width * 0.15,
                height: 50,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ImageIcon(
                        AssetImage("assets/images/new-design/wallet_icon.png"),
                        size: 16,
                        color: count == 1 ? primaryColor : grey,
                      ),
                      SizedBox(height: 3),
                      Text(
                        FlutterI18n.translate(context, "home"),
                        style: TextStyle(
                            fontSize: 12,
                            color: count == 1 ? primaryColor : grey,
                            fontWeight: FontWeight.bold),
                      )
                    ]),
              ),
            ),
            InkWell(
              onTap: () {
                if (sharedService.getCurrentRouteName(context) !=
                    'BondWelcomeView') {
                  navigationService.clearStackAndShow(
                    BondWelcomeViewRoute,
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
                        FlutterI18n.translate(context, "inv"),
                        style: TextStyle(
                            fontSize: 12,
                            color: count == 2 ? primaryColor : grey,
                            fontWeight: FontWeight.bold),
                      )
                    ]),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  size.width * 0.1, 20, size.width * 0.1, 0),
              child: Text(FlutterI18n.translate(context, "pay"),
                  style: TextStyle(
                      fontSize: 12,
                      color: count == 0 ? primaryColor : grey,
                      fontWeight: FontWeight.bold)),
            ),
            InkWell(
              onTap: () {
                if (sharedService.getCurrentRouteName(context) != 'DappView') {
                  navigationService.clearStackAndShow(
                    DappViewRoute,
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
                        AssetImage("assets/images/new-design/dapp_icon.png"),
                        size: 16,
                        color: count == 3 ? primaryColor : grey,
                      ),
                      SizedBox(height: 3),
                      Text(
                        "Dapp",
                        style: TextStyle(
                            fontSize: 12,
                            color: count == 3 ? primaryColor : grey,
                            fontWeight: FontWeight.bold),
                      )
                    ]),
              ),
            ),
            InkWell(
              onTap: () {
                if (sharedService.getCurrentRouteName(context) != 'MeView') {
                  navigationService.clearStackAndShow(
                    MeViewRoute,
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
                        FlutterI18n.translate(context, "me"),
                        style: TextStyle(
                            fontSize: 12,
                            color: count == 4 ? primaryColor : grey,
                            fontWeight: FontWeight.bold),
                      )
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
