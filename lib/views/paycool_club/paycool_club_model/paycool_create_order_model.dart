class PaycoolCreateOrderModel {
  String _walletAddress; // fab address
  int _campaignId;
  double _amount;
  String _currency;
  String _referralAddress;
  String _transactionId;

  PaycoolCreateOrderModel(
      {String walletAddress,
      int campaignId,
      double amount,
      String currency,
      String referralAddress,
      String transactionId}) {
    _walletAddress = walletAddress ?? '';
    _amount = amount ?? 0.0;
    _currency = currency ?? 2000.0;
    _campaignId = campaignId ?? 2;
    _referralAddress = referralAddress ?? '';
    _transactionId = transactionId ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['walletAdd'] = _walletAddress;
    data['campaignId'] = _campaignId;
    data['amount'] = _amount;
    data['currency'] = _currency;
    data['referral'] = _referralAddress;
    data['transactionId'] = _transactionId;

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

  String get walletAdd => _walletAddress;
  set walletAdd(String walletAdd) {
    _walletAddress = walletAdd;
  }

  int get campaignId => _campaignId;
  set campaignId(int campaignId) {
    _campaignId = campaignId;
  }

  String get currency => _currency;
  set currency(String currency) {
    _currency = currency;
  }

  String get referral => _referralAddress;
  set referral(String referral) {
    _referralAddress = referral;
  }

  double get amount => _amount;
  set amount(double amount) {
    _amount = amount;
  }

  String get transactionId => _transactionId;
  set transactionId(String transactionId) {
    _transactionId = transactionId;
  }
}
