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

import 'package:get_it/get_it.dart';
import 'package:lightning_remit/lightning_remit.dart';
import 'package:exchangily_wallet_setup/exchangily_wallet_setup.dart';
import 'package:referral/referral.dart';
import 'package:settings/settings.dart';
import 'services/local_storage_service.dart';
import 'views/paycool_club/join_club/join_paycool_club_viewmodel.dart';
import 'views/paycool_club/paycool_club_dashboard_viewmodel.dart';
import 'views/paycool_club/paycool_club_service.dart';
import 'views/paycool/rewards/paycool_rewards_viewmodel.dart';
import 'views/paycool/paycool_service.dart';
import 'views/paycool/paycool_viewmodel.dart';
import 'views/paycool/transaction_history/paycool_transaction_history_viewmodel.dart';

GetIt localLocator = GetIt.instance;

Future serviceLocator() async {
  // Singleton returns the old instance

  localLocator.registerLazySingleton(() => PayCoolClubService());
  localLocator.registerLazySingleton(() => PayCoolService());

  // LocalStorageService Singelton
  var instance = await LocalStorageService.getInstance();
  localLocator.registerSingleton<LocalStorageService>(instance);

  // Factory returns the new instance
// wallet
  localLocator.registerFactory(() => WalletSetupViewModel());
  localLocator.registerFactory(() => ConfirmMnemonicViewModel());

  // Paycool Club
  localLocator.registerFactory(() => PayCoolClubDashboardViewModel());
  localLocator.registerFactory(() => JoinPayCoolClubViewModel());
  localLocator.registerFactory(() => PaycoolReferralViewmodel());

  // Paycool
  localLocator.registerFactory(() => PayCoolViewmodel());
  localLocator.registerFactory(() => PayCoolRewardsViewModel());
  localLocator.registerFactory(() => PayCoolTransactionHistoryViewModel());

  localLocator.registerFactory(() => LightningRemitViewmodel());

  localLocator.registerFactory(() => SettingsViewModel());
}
