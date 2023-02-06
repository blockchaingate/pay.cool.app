class PaycoolCreateOrderModel {
  String? walletAddress; // fab address
  int? campaignId;
  double? amount;
  String? currency;
  String? referralAddress;
  String? transactionId;

  PaycoolCreateOrderModel(
      {this.walletAddress,
      this.campaignId,
      this.amount,
      this.currency,
      this.referralAddress,
      this.transactionId});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['walletAdd'] = walletAddress;
    data['campaignId'] = campaignId;
    data['amount'] = amount;
    data['currency'] = currency;
    data['referral'] = referralAddress;
    data['transactionId'] = transactionId;

    return data;
  }

  factory PaycoolCreateOrderModel.fromJson(Map<String, dynamic> json) {
    return PaycoolCreateOrderModel(
        walletAddress: json['walletAdd'],
        campaignId: json['campaignId'],
        amount: json['amount'],
        currency: json['currency'],
        referralAddress: json['referral'],
        transactionId: json['transactionId']);
  }
}
