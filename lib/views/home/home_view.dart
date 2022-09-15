import 'package:animations/animations.dart';
import 'package:exchangily_core/exchangily_core.dart';
import 'package:exchangily_ui/exchangily_ui.dart';
import 'package:exchangily_wallet_setup/exchangily_wallet_setup.dart';
import 'package:flutter/material.dart';
import 'package:lightning_remit/lightning_remit.dart';
import 'package:paycool/constants/paycool_styles.dart';
import 'package:paycool/views/paycool/paycool_view.dart';
import 'package:paycool/views/paycool_club/paycool_club_dashboard_view.dart';
import 'package:wallet_dashboard/wallet_dashboard.dart';

import '../settings/settings_view.dart';
import 'home_viewmodel.dart';

class HomeView extends StatelessWidget {
  final int customIndex;
  const HomeView({Key key, this.customIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      onModelReady: (model) {
        int idx = model.storageService.showPaycoolClub ? 2 : 1;
        model.setIndex(customIndex ?? idx);
      },
      builder: (context, HomeViewModel model, child) => Scaffold(
        body:
            // PageTransitionSwitcher(
            //     duration: const Duration(milliseconds: 300),
            //     reverse: model.reverse,
            //     transitionBuilder: (
            //       Widget child,
            //       Animation<double> animation,
            //       Animation<double> secondaryAnimation,
            //     ) {
            //       return SharedAxisTransition(
            //           animation: animation,
            //           secondaryAnimation: secondaryAnimation,
            //           transitionType: SharedAxisTransitionType.horizontal);
            //     },
            //   child:
            model.storageService.showPaycoolClub
                ? getViewForIndex(model.currentIndex)
                : getViewForIndexWithoutClub(model.currentIndex),
        //),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: PaycoolColors.walletCardColor,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 10,
          unselectedItemColor: grey,
          selectedItemColor: PaycoolColors.primaryColor,
          showUnselectedLabels: true,
          currentIndex: model.currentIndex,
          onTap: model.setIndex,
          items: model.storageService.showPaycoolClub
              ? mainNavsWithClub(context, model)
              : mainNavs(context, model),
        ),
      ),
      viewModelBuilder: () => HomeViewModel(),
    );
  }

  Widget getViewForIndex(int index) {
    switch (index) {
      case 0:
        return const PayCoolClubDashboardView();
      case 1:
        return const WalletDashboardView();
      case 2:
        return const PayCoolView();
      case 3:
        return const LightningRemitView();
      case 4:
        return const SettingsView();
      default:
        return const WalletSetupView();
    }
  }

  Widget getViewForIndexWithoutClub(int index) {
    switch (index) {
      case 0:
        return const WalletDashboardView();
      case 1:
        return const PayCoolView();
      case 2:
        return const LightningRemitView();
      case 3:
        return const SettingsView();
      default:
        return const WalletSetupView();
    }
  }

  List<BottomNavigationBarItem> mainNavsWithClub(
      BuildContext context, HomeViewModel model) {
    List<BottomNavigationBarItem> res = [
      BottomNavigationBarItem(
        label: FlutterI18n.translate(context, "club"),
        icon: Image.asset('assets/images/paycool/ribbon-05.png',
            width: 40, height: 30, color: model.setIconColor(0)),
      ),
    ];
    res = res + mainNavs(context, model);
    return res;
  }

  List<BottomNavigationBarItem> mainNavs(
      BuildContext context, HomeViewModel model) {
    int baseIndex = model.storageService.showPaycoolClub ? 1 : 0;

    List<BottomNavigationBarItem> res = [
      BottomNavigationBarItem(
          icon: Image.asset('assets/images/paycool/wallet.png',
              width: 40, height: 30, color: model.setIconColor(baseIndex + 0)),
          label: FlutterI18n.translate(context, "wallet")),
      BottomNavigationBarItem(
        icon: Image.asset('assets/images/paycool/pay.png',
            width: 40, height: 30, color: model.setIconColor(baseIndex + 1)),
        label: FlutterI18n.translate(context, "payCool"),
      ),
      BottomNavigationBarItem(
        icon: Image.asset('assets/images/paycool/remit.png',
            width: 40, height: 30, color: model.setIconColor(baseIndex + 2)),
        label: FlutterI18n.translate(context, "remit"),
      ),
      BottomNavigationBarItem(
          icon: Image.asset('assets/images/paycool/settings-icon.png',
              width: 40, height: 30, color: model.setIconColor(baseIndex + 3)),
          label: FlutterI18n.translate(context, "settings"))
    ];
    return res;
  }
}
