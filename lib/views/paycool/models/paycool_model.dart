class ScanToPayModelV2 {
  String currency;
  double totalAmount;
  double totalTax;
  double totalRewardInPaidCoin;
  double myreward;
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
      jsonMyRewards = json['myreward'].toDouble();
    }
    currency = json['currency'];
    totalAmount = //json['totalAmount'] is int
        json['totalAmount'].toDouble();
    // : json['totalAmount'];
    totalTax = json['totalTax'].toDouble();
    totalRewardInPaidCoin = json['totalRewardInPaidCoin'].toDouble();
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
