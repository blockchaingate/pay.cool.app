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
import 'package:paycool/logger.dart';
import 'package:paycool/views/paycool_club/checkout/club_package_checkout_view.dart';
import 'package:paycool/views/paycool_club/club_projects/club_project_details_view.dart';
import 'package:paycool/widgets/club/club_rewards_view.dart';
import 'constants/route_names.dart';
import 'views/lightning-remit/lightning-remit_view.dart';
import 'views/settings/settings_view.dart';
import 'views/paycool_club/join_club/join_paycool_club_view.dart';
import 'views/paycool_club/referral/paycool_referral_view.dart';
import 'views/paycool_club/club_dashboard_view.dart';
import 'views/paycool/rewards/paycool_rewards_view.dart';
import 'views/paycool/paycool_view.dart';
import 'views/paycool/transaction_history/paycool_transaction_history_view.dart';
import 'views/wallet/wallet_dashboard_view.dart';
import 'views/wallet/wallet_features/add_gas/add_gas.dart';
import 'views/wallet/wallet_features/move_to_exchange/move_to_exchange.dart';
import 'views/wallet/wallet_features/move_to_wallet/move_to_wallet.dart';
import 'views/wallet/wallet_features/receive.dart';
import 'views/wallet/wallet_features/redeposit/redeposit.dart';
import 'views/wallet/wallet_features/send/send_view.dart';
import 'views/wallet/wallet_features/smart_contract.dart';
import 'views/wallet/wallet_features/transaction_history/transaction_history_view.dart';
import 'views/wallet/wallet_features/wallet_features_view.dart';
import 'views/wallet/wallet_setup/backup_mnemonic_view.dart/backup_mnemonic.dart';
import 'views/wallet/wallet_setup/confirm_mnemonic/confirm_mnemonic_view.dart';
import 'views/wallet/wallet_setup/create_password/create_password_view.dart';
import 'views/wallet/wallet_setup/mnemonic_input/import_wallet_view.dart';
import 'views/wallet/wallet_setup/select_language/choose_wallet_language.dart';
import 'views/wallet/wallet_setup/wallet_setup_view.dart';

final log = getLogger('Routes');

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    log.w(
        'generateRoute | name: ${settings.name} arguments:${settings.arguments}');
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const WalletSetupView());

/*----------------------------------------------------------------------
                          Wallet Setup
----------------------------------------------------------------------*/

      case ChooseWalletLanguageViewRoute:
        return MaterialPageRoute(builder: (_) => ChooseWalletLanguageView());
      case WalletSetupViewRoute:
        return MaterialPageRoute(builder: (_) => const WalletSetupView());

      case ImportWalletViewRoute:
        return MaterialPageRoute(builder: (_) => ImportWalletView());

      case BackupMnemonicViewRoute:
        return MaterialPageRoute(builder: (_) => BackupMnemonicWalletView());

      case ConfirmMnemonicViewRoute:
        return MaterialPageRoute(
            builder: (_) =>
                ConfirmMnemonicView(randomMnemonicListFromRoute: args));

      case CreatePasswordViewRoute:
        return MaterialPageRoute(
            builder: (_) => CreatePasswordView(args: args));

/*----------------------------------------------------------------------
                          Wallet Routes
----------------------------------------------------------------------*/

      case DashboardViewRoute:
        return MaterialPageRoute(
            settings: const RouteSettings(name: 'WalletDashboardVieww'),
            builder: (_) => const WalletDashboardView());

      case AddGasViewRoute:
        return MaterialPageRoute(builder: (_) => AddGasView());

      case SmartContractViewRoute:
        return MaterialPageRoute(builder: (_) => const SmartContractView());

      case DepositViewRoute:
        return MaterialPageRoute(
            builder: (_) => MoveToExchangeView(walletInfo: args));

      case RedepositViewRoute:
        return MaterialPageRoute(
            builder: (_) => RedepositView(walletInfo: args));

      case WithdrawViewRoute:
        return MaterialPageRoute(
            builder: (_) => MoveToWalletView(walletInfo: args));

      case WalletFeaturesViewRoute:
        return MaterialPageRoute(
            builder: (_) => WalletFeaturesView(walletInfo: args));

      case ReceiveViewRoute:
        return MaterialPageRoute(
            builder: (_) => ReceiveWalletScreen(
                  walletInfo: args,
                ));

      case SendViewRoute:
        return MaterialPageRoute(
            builder: (_) => SendWalletView(
                  walletInfo: args,
                ));

      case TransactionHistoryViewRoute:
        return MaterialPageRoute(
            builder: (_) => TransactionHistoryView(
                  walletInfo: args,
                ));

/*----------------------------------------------------------------------
                          Pay.cool Club Routes
----------------------------------------------------------------------*/
      case PayCoolClubDashboardViewRoute:
        return MaterialPageRoute(
            settings: const RouteSettings(name: 'PayCoolClubDashboardView'),
            builder: (_) => const ClubDashboardView());

      case PayCoolClubReferralViewRoute:
        return MaterialPageRoute(
            builder: (_) => PaycoolReferralView(
                  address: args,
                ));
      case clubRewardsViewRoute:
        return MaterialPageRoute(
            builder: (_) => ClubRewardsView(
                  rewardsSummary: args,
                ));
      case clubProjectDetailsViewRoute:
        return MaterialPageRoute(
            builder: (_) => ClubProjectDetailsView(
                  projectDetails: args,
                ));

      case clubPackageCheckoutViewRoute:
        return MaterialPageRoute(
            builder: (_) => ClubPackageCheckoutView(
                  packageWithPaymentCoin: args,
                ));
      case JoinPayCoolClubViewRoute:
        return MaterialPageRoute(
            builder: (_) => JoinPayCoolClubView(
                  scanToPayModel: args,
                ));

/*----------------------------------------------------------------------
                      Pay.cool Routes
----------------------------------------------------------------------*/
      case PayCoolViewRoute:
        return MaterialPageRoute(
            settings: const RouteSettings(name: 'PayCoolView'),
            builder: (_) => PayCoolView());

      case PayCoolRewardsViewRoute:
        return MaterialPageRoute(
            settings: const RouteSettings(),
            builder: (_) => const PayCoolRewardsView());

      case PayCoolTransactionHistoryViewRoute:
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
      case SettingViewRoute:
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
              style: const TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: Text(
              FlutterI18n.translate(context, "noRouteDefined") +
                  ' ${settings.name}',
              style: const TextStyle(color: Colors.white)),
        ),
      );
    });
  }
}
