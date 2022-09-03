import 'package:exchangily_core/exchangily_core.dart';

class ScanToPayModelV2 {
  String currency;
  Decimal totalAmount;
  Decimal totalTax;
  Decimal totalRewardInPaidCoin;
  Decimal myreward;
  List<String> regionalAgents;
  List<String> rewardBeneficiary;
  String rewardInfo;
  String feeChargerSmartContractAddress;
  String abiHex;

  ScanToPayModelV2(
      {this.currency,
      this.totalAmount,
      this.totalTax,
      this.totalRewardInPaidCoin,
      this.myreward,
      this.regionalAgents,
      this.rewardBeneficiary,
      this.rewardInfo,
      this.feeChargerSmartContractAddress,
      this.abiHex});

  ScanToPayModelV2.fromJson(Map<String, dynamic> json) {
    var jsonMyRewards;
    if (json['myreward'] != null) {
      jsonMyRewards =
          NumberUtil.stringDecimalParse(json['myreward'].toString());
    }
    currency = json['currency'];
    totalAmount = NumberUtil.stringDecimalParse(json['totalAmount'].toString());

    totalTax = NumberUtil.stringDecimalParse(json['totalTax'].toString());
    totalRewardInPaidCoin =
        NumberUtil.stringDecimalParse(json['totalRewardInPaidCoin'].toString());
    myreward = jsonMyRewards;
    regionalAgents = json['regionalAgents'].cast<String>();
    rewardBeneficiary = json['rewardBeneficiary'].cast<String>();
    rewardInfo = json['rewardInfo'];
    feeChargerSmartContractAddress = json['feeChargerSmartContractAddress'];
    abiHex = json['abihex'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['currency'] = currency;
    data['totalAmount'] = totalAmount;
    data['totalTax'] = totalTax;
    data['totalRewardInPaidCoin'] = totalRewardInPaidCoin;
    data['regionalAgents'] = regionalAgents;
    data['rewardBeneficiary'] = rewardBeneficiary;
    data['rewardInfo'] = rewardInfo;
    data['feeChargerSmartContractAddress'] = feeChargerSmartContractAddress;
    data['abihex'] = abiHex;
    return data;
  }
}
