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

import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:kyc/kyc.dart';
import 'package:paycool/providers/app_state_provider.dart';
import 'package:paycool/services/db/core_wallet_database_service.dart';
import 'package:paycool/services/hive_service.dart';
import 'package:paycool/services/multisig_service.dart';
import 'package:stacked_services/stacked_services.dart'
    show DialogService, NavigationService, BottomSheetService;

import 'environments/environment_type.dart';
import 'services/api_service.dart';
import 'services/coin_service.dart';
import 'services/config_service.dart';
import 'services/db/decimal_config_database_service.dart';
import 'services/db/token_list_database_service.dart';
import 'services/db/transaction_history_database_service.dart';
import 'services/db/user_settings_database_service.dart';
import 'services/db/wallet_database_service.dart';
import 'services/local_auth_service.dart';
import 'services/local_dialog_service.dart';
import 'services/local_storage_service.dart';
import 'services/shared_service.dart';
import 'services/vault_service.dart';
import 'services/wallet_service.dart';
import 'views/lightning-remit/lightening_remit_viewmodel.dart';
import 'views/paycool/paycool_service.dart';
import 'views/paycool/paycool_viewmodel.dart';
import 'views/paycool/rewards/paycool_rewards_viewmodel.dart';
import 'views/paycool/transaction_history/paycool_transaction_history_viewmodel.dart';
import 'views/paycool_club/club_dashboard_viewmodel.dart';
import 'views/paycool_club/join_club/join_paycool_club_viewmodel.dart';
import 'views/paycool_club/paycool_club_service.dart';
import 'views/paycool_club/referral/referral_viewmodel.dart';
import 'views/settings/settings_viewmodel.dart';
import 'views/wallet/wallet_dashboard_viewmodel.dart';
import 'views/wallet/wallet_features/move_to_exchange/move_to_exchange_viewmodel.dart';
import 'views/wallet/wallet_features/move_to_wallet/move_to_wallet_viewmodel.dart';
import 'views/wallet/wallet_features/redeposit/redeposit_viewmodel.dart';
import 'views/wallet/wallet_features/send/send_viewmodel.dart';
import 'views/wallet/wallet_features/transaction_history/transaction_history_viewmodel.dart';
import 'views/wallet/wallet_features/wallet_features_viewmodel.dart';
import 'views/wallet/wallet_setup/backup_mnemonic_view.dart/backup_mnemonic_viewmodel.dart';
import 'views/wallet/wallet_setup/confirm_mnemonic/confirm_mnemonic_viewmodel.dart';
import 'views/wallet/wallet_setup/create_password/create_password_viewmodel.dart';
import 'views/wallet/wallet_setup/select_language/choose_wallet_language_viewmodel.dart';
import 'views/wallet/wallet_setup/wallet_setup_viewmodel.dart';
import 'widgets/bottom_navmodel.dart';

GetIt locator = GetIt.instance;

Future serviceLocator() async {
  // Singleton returns the old instance

  locator.registerLazySingleton(() => KycBaseService(
      isProd: isProduction, xAccessToken: ValueNotifier<String?>(null)));
  locator.registerLazySingleton<KycNavigationService>(
      () => KycNavigationService());
  // Wallet
  locator.registerLazySingleton(() => WalletService());
  locator.registerLazySingleton(() => WalletDatabaseService());
  locator.registerLazySingleton(() => VaultService());
  locator.registerLazySingleton(() => TokenListDatabaseService());
  locator.registerLazySingleton(() => UserSettingsDatabaseService());
  locator.registerLazySingleton(() => LocalAuthService());
  locator.registerLazySingleton(() => CoreWalletDatabaseService());
  locator.registerLazySingleton(() => MultiSigService());
  // Shared
  locator.registerLazySingleton(() => ApiService());
  locator.registerLazySingleton(() => SharedService());
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => CoinService());

  locator.registerLazySingleton(() => LocalDialogService());
  locator.registerLazySingleton(() => DialogService());
  locator.registerLazySingleton(() => BottomSheetService());

  locator.registerLazySingleton(() => ConfigService());
  locator.registerLazySingleton(() => DecimalConfigDatabaseService());
  locator.registerLazySingleton(() => TransactionHistoryDatabaseService());

  // Seven Star
  locator.registerLazySingleton(() => PayCoolClubService());
  locator.registerLazySingleton(() => PayCoolService());
  locator.registerLazySingleton(() => HiveService());

  //Version Service
  //locator.registerLazySingleton(() => VersionService());

  // LocalStorageService Singelton
  var instance = await LocalStorageService.getInstance();
  locator.registerSingleton<LocalStorageService>(instance!);

  // Factory returns the new instance

  // Wallet
  //locator.registerFactory(() => AnnouncementListScreenState());
  locator.registerFactory(() => ConfirmMnemonicViewModel());
  locator.registerFactory(() => CreatePasswordViewModel());
  locator.registerFactory(() => WalletDashboardViewModel());
  locator.registerFactory(() => WalletFeaturesViewModel());
  locator.registerFactory(() => SendViewModel());
  locator.registerFactory(() => SettingsViewModel());
  //locator.registerFactory(() => LanguageScreenState());
  locator.registerFactory(() => WalletSetupViewmodel());
  locator.registerFactory(() => BackupMnemonicViewModel());
  locator.registerFactory(() => ChooseWalletLanguageViewModel());
  locator.registerFactory(() => MoveToExchangeViewModel());
  locator.registerFactory(() => MoveToWalletViewmodel());
  locator.registerFactory(() => TransactionHistoryViewmodel());
  locator.registerFactory(() => RedepositViewModel());

  // Pay.cool Club
  locator.registerFactory(() => ClubDashboardViewModel());
  locator.registerFactory(() => JoinPayCoolClubViewModel());
  locator.registerFactory(() => ReferralViewmodel());

  // Campaign
  // locator.registerFactory(() => CampaignInstructionsScreenState());
  // locator.registerFactory(() => CampaignPaymentScreenState());
  // locator.registerFactory(() => CampaignDashboardScreenState());
  // locator.registerFactory(() => CampaignLoginScreenState());
  // locator.registerFactory(() => CampaignRegisterAccountScreenState());
  // locator.registerFactory(() => TeamRewardDetailsScreenState());
  // locator.registerFactory(() => CampaignSingleScreenState());
  // locator.registerFactory(() => CarouselWidgetState());

  // Seven Star Pay
  locator.registerFactory(() => PayCoolViewmodel());
  locator.registerFactory(() => PayCoolRewardsViewModel());
  locator.registerFactory(() => PayCoolTransactionHistoryViewModel());

  // BindPay
  locator.registerFactory(() => LightningRemitViewmodel());

  //nav
  locator.registerFactory(() => BottomNavViewmodel());

  // Provider
  locator.registerFactory(() => AppStateProvider());
}
