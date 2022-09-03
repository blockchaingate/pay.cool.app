import 'package:exchangily_core/exchangily_core.dart';

class PaycoolApiRoutes {
  static const String paycoolRef = '7star-ref';
  static const String campaignListUrl = baseBlockchainGateV2Url + 'campaigns';
  static const String campaignEntryStatusUrl =
      baseBlockchainGateV2Url + '7star-order/address-campaign/';

  static const String payCoolClubrRefUrl =
      baseBlockchainGateV2Url + paycoolRef + '/';
  static const String payCoolClubCreateOrderUrl =
      baseBlockchainGateV2Url + '7star-order/' + 'create';

  static const String payCoolClubSaveOrderUrl =
      baseBlockchainGateV2Url + paycoolRef + '/' + 'savePayment';
  static const String isValidPaidReferralCodeUrl =
      baseBlockchainGateV2Url + paycoolRef + '/' + 'isValid/';

/*----------------------------------------------------------------------
                        Paycool Pay
----------------------------------------------------------------------*/

// Referral

// https://fabtest.info/api/userreferral/user/myVKCpWKSpMDvpZZRS69re3KmSta29ZFnK
  static const String isValidPaycoolReferralRoute = "api/userreferral/user/";

// Get downline (count / pagenumber)
// https://fabtest.info/api/userreferral/user/myVKCpWKSpMDvpZZRS69re3KmSta29ZFnK/10/0

// Get total referral count
// https://fabtest.info/api/userreferral/user/myVKCpWKSpMDvpZZRS69re3KmSta29ZFnK/totalCount
  static const String totalCountRoute = "/totalCount";

// ** https://api.blockchaingate.com/v2/stores/feeChargerSmartContractAddress/0x1e89b7d555fe1b68c048b68eb28724950e1051f2
  static const String storeInfoPayCoolUrl =
      baseBlockchainGateV2Url + 'stores/feeChargerSmartContractAddress/';

// https://test.blockchaingate.com/v2/7star-agent/smartContractAdd/0xb0dbab271cd9b9e53adc4cbe4e333aa3e06d2a9e09ea6b376dfa04f7b3989202

  static const String regionalAgentStarPayUrl =
      baseBlockchainGateV2Url + '7star-agent/smartContractAdd/';

  static const String isValidReferralStarPayMemberUrl =
      baseBlockchainGateV2Url + paycoolRef + '/' + 'isValidMember/';

  static const String paycoolTextApiRoute = "7starpay";
  static const String chargeTextApiRoute = "charge";
  static const String ordersTextApiRoute = "orders/";

  static const String payOrderApiRoute = ordersTextApiRoute + "code/";

  static const String payCoolApiRoute =
      kanbanApiRoute + 'coders/encodeFunctionCall';

  static const String payCoolCreateReferralUrl =
      baseBlockchainGateV2Url + paycoolRef + '/create';

  static const String payCoolRewardUrl =
      baseBlockchainGateV2Url + '7star-locker/ownedBy/';

  static String payCoolDecodeAbiUrl = kanbanApiRoute + 'coders/decodeParams';

  static const String payCoolEncodeAbiUrl =
      kanbanApiRoute + 'coders/encodeParams';

  static const String payCoolTransactionHistoryUrl =
      baseBlockchainGateV2Url + '7star-charge-fund/customer/';

  static const String paycoolParentAddressUrl =
      baseBlockchainGateV2Url + paycoolRef + '/parents/';
}
