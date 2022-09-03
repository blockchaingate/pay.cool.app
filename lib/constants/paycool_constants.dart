import 'package:exchangily_core/exchangily_core.dart';

class PaycoolConstants {
  final environmentService = locator<EnvironmentService>();

  // String kReferralAddress = environmentService.kReleaseMode
  //     ? "0xa62d5facbdce11fef7d41c71e7661d7131c8c7f0"
  //     : "";

  static const String appName = 'Paycool';
  static const String androidStoreId = "club.paycool.paycool";
  static const String appleStoreId = "id1571496540";

  static const String referralAddressText = 'referralAddress';
  static const String merchantAddressText = 'merchantAddress';

  static const String payCoolClubSignatureAbi = "0x1827a766";
  static const String payCoolRefundAbi = "0x775274a1";
  static const String payCoolCancelAbi = "0x5806abae";
  static const String payCoolSignOrderAbi = "0x09953d6d";
  static const String payCoolJoinAsReferralAbi = "0x9859387b";

  // View routes
  static const String referralViewRoute = '/referral';
  static const String payCoolClubDashboardViewRoute = '/campaignListDashboard';

  static const String generateCustomQrViewRoute = '/generateCustomQrCode';
  static const String joinPayCoolClubViewRoute = '/joinPayCoolClub';
  static const String payCoolClubReferralViewRoute = '/payCoolClubReferral';

  static const String payCoolViewRoute = '/paycool';
  static const String payCoolRewardsViewRoute = '/payCoolRewards';
  static const String payCoolTransactionHistoryViewRoute =
      '/paycoolTransactionHistory';
}
