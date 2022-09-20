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
import 'package:exchangily_wallet_features/exchangily_wallet_features.dart';
import 'package:exchangily_wallet_setup/exchangily_wallet_setup.dart';
import 'package:flutter/material.dart';
import 'package:lightning_remit/lightning_remit.dart';
import 'package:paycool/constants/paycool_styles.dart';
import 'package:settings/settings.dart';
import 'package:paycool/views/home/home_view.dart';
import 'package:referral/referral.dart';
import 'package:wallet_dashboard/wallet_dashboard.dart';
import 'constants/paycool_constants.dart';
import 'views/paycool_club/generate_custom_qrcode/generate_custom_qrcode_view.dart';
import 'views/paycool_club/join_club/join_paycool_club_view.dart';
import 'views/paycool_club/paycool_club_dashboard_view.dart';
import 'views/paycool/rewards/paycool_rewards_view.dart';
import 'views/paycool/paycool_view.dart';
import 'views/paycool/transaction_history/paycool_transaction_history_view.dart';

final log = getLogger('Routes');

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    log.w(
        'generateRoute | name: ${settings.name} arguments:${settings.arguments}');
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomeView());

      case homeViewRoute:
        return MaterialPageRoute(builder: (_) => HomeView(customIndex: args));

/*----------------------------------------------------------------------
                          Wallet Setup
----------------------------------------------------------------------*/

      case chooseWalletLanguageViewRoute:
        return MaterialPageRoute(
            builder: (_) => const ChooseWalletLanguageView());

      case walletSetupViewRoute:
        return MaterialPageRoute(builder: (_) => const WalletSetupView());

      case importWalletViewRoute:
        return MaterialPageRoute(builder: (_) => const ImportWalletView());

      case backupMnemonicViewRoute:
        return MaterialPageRoute(
            builder: (_) => const BackupMnemonicWalletView());

      case confirmMnemonicViewRoute:
        return MaterialPageRoute(
            builder: (_) =>
                ConfirmMnemonicView(randomMnemonicListFromRoute: args));

      case createPasswordViewRoute:
        return MaterialPageRoute(
            builder: (_) => CreatePasswordView(args: args));

/*----------------------------------------------------------------------
                          Wallet Routes
----------------------------------------------------------------------*/

      case dashboardViewRoute:
        return MaterialPageRoute(
            settings: const RouteSettings(name: 'WalletDashboardView'),
            builder: (_) => const WalletDashboardView());

      case addGasViewRoute:
        return MaterialPageRoute(builder: (_) => const AddGasView());

      case smartContractViewRoute:
        return MaterialPageRoute(builder: (_) => const SmartContract());

      case depositViewRoute:
        return MaterialPageRoute(builder: (_) => DepositView(appWallet: args));

      case redepositViewRoute:
        return MaterialPageRoute(builder: (_) => Redeposit(appWallet: args));

      case withdrawViewRoute:
        return MaterialPageRoute(builder: (_) => WithdrawView(appWallet: args));

      case walletFeaturesViewRoute:
        return MaterialPageRoute(
            builder: (_) => WalletFeaturesView(appWallet: args));

      case receiveViewRoute:
        return MaterialPageRoute(
            builder: (_) => ReceiveWalletView(
                  appWallet: args,
                ));

      case sendViewRoute:
        return MaterialPageRoute(
            builder: (_) => SendWalletView(
                  appWallet: args,
                ));

      case transactionHistoryViewRoute:
        return MaterialPageRoute(
            builder: (_) => TransactionHistoryView(
                  appWallet: args,
                ));

/*----------------------------------------------------------------------
                          Paycool Club Routes
----------------------------------------------------------------------*/
      case PaycoolConstants.payCoolClubDashboardViewRoute:
        return MaterialPageRoute(
            settings: const RouteSettings(name: 'PayCoolClubDashboardView'),
            builder: (_) => const PayCoolClubDashboardView());

      case PaycoolConstants.payCoolClubReferralViewRoute:
        return MaterialPageRoute(
            builder: (_) => PaycoolReferralView(
                  address: args,
                ));
      case PaycoolConstants.joinPayCoolClubViewRoute:
        return MaterialPageRoute(
            builder: (_) => JoinPayCoolClubView(
                  scanToPayModel: args,
                ));

      case PaycoolConstants.generateCustomQrViewRoute:
        return MaterialPageRoute(
            builder: (_) => const GenerateCustomQrCodeView());

      case PaycoolConstants.payCoolViewRoute:
        return MaterialPageRoute(
            settings: const RouteSettings(name: 'PayCoolView'),
            builder: (_) => const PayCoolView());

      case PaycoolConstants.payCoolRewardsViewRoute:
        return MaterialPageRoute(
            settings: const RouteSettings(),
            builder: (_) => const PayCoolRewardsView());

      case PaycoolConstants.payCoolTransactionHistoryViewRoute:
        return MaterialPageRoute(
            settings: const RouteSettings(),
            builder: (_) => PayCoolTransactionHistoryView());

/*----------------------------------------------------------------------
                      LightningRemit Routes
----------------------------------------------------------------------*/
      case lightningRemitViewRoute:
        return MaterialPageRoute(
            settings: const RouteSettings(name: 'LightningRemitView'),
            builder: (_) => const LightningRemitView());

/*----------------------------------------------------------------------
                      Navigation Routes
----------------------------------------------------------------------*/
      case settingViewRoute:
        return MaterialPageRoute(
            settings: const RouteSettings(name: 'SettingsView'),
            builder: (_) => const SettingsView());

      default:
        return _errorRoute(settings);
    }
  }

  static Route _errorRoute(settings) {
    BuildContext context;
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(context, "error"),
              style: const TextStyle(color: white)),
        ),
        body: Center(
          child: Text(
              FlutterI18n.translate(context, "noRouteDefined") +
                  ' ${settings.name}',
              style: const TextStyle(color: white)),
        ),
      );
    });
  }
}
