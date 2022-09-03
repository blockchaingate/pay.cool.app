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
import 'package:referral/referral.dart';
import 'services/local_storage_service.dart';
import 'views/settings/settings_viewmodel.dart';
import 'views/paycool_club/join_club/join_paycool_club_viewmodel.dart';
import 'views/paycool_club/paycool_club_dashboard_viewmodel.dart';
import 'views/paycool_club/paycool_club_service.dart';
import 'views/paycool/rewards/paycool_rewards_viewmodel.dart';
import 'views/paycool/paycool_service.dart';
import 'views/paycool/paycool_viewmodel.dart';
import 'views/paycool/transaction_history/paycool_transaction_history_viewmodel.dart';
import 'widgets/bottom_navmodel.dart';

GetIt localLocator = GetIt.instance;

Future serviceLocator() async {
  // Singleton returns the old instance

  // Seven Star
  localLocator.registerLazySingleton(() => PayCoolClubService());
  localLocator.registerLazySingleton(() => PayCoolService());

  // LocalStorageService Singelton
  var instance = await LocalStorageService.getInstance();
  localLocator.registerSingleton<LocalStorageService>(instance);

  // Factory returns the new instance

  localLocator.registerFactory(() => SettingsViewmodel());

  // Paycool Club
  localLocator.registerFactory(() => PayCoolClubDashboardViewModel());
  localLocator.registerFactory(() => JoinPayCoolClubViewModel());
  localLocator.registerFactory(() => PaycoolReferralViewmodel());

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
  localLocator.registerFactory(() => PayCoolViewmodel());
  localLocator.registerFactory(() => PayCoolRewardsViewModel());
  localLocator.registerFactory(() => PayCoolTransactionHistoryViewModel());

  // BindPay
  localLocator.registerFactory(() => LightningRemitViewmodel());

  //nav
  localLocator.registerFactory(() => BottomNavViewmodel());
}
