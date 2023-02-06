class PaycoolCreateOrderModel {
  String? _walletAdd; // Wallet EXG address

  String? _status;
  // 0: waiting for payment,
  // 1: payment made,
  // 3: payment confirmed,
  // 4: completed - coins sent,
  // 5: cancelled, 6: suspended
  int? _campaignId;
  double? _amount;
  String? _currency;
  String? _referral;
  DateTime? _dateUpdated;
  DateTime? _dateCreated;

  PaycoolCreateOrderModel(
      {String? walletAdd,
      String? status,
      int? campaignId,
      double? amount,
      String? currency,
      String? referral,
      DateTime? dateUpdated,
      DateTime? dateCreated}) {
    _walletAdd = walletAdd;
    _status = status;
    _amount = amount;
    _currency = currency;
    _dateUpdated = dateUpdated;
    _dateCreated = dateCreated;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['walletAdd'] = _walletAdd;
    data['status'] = _status;
    data['campaignId'] = _campaignId;
    data['amount'] = _amount;
    data['currency'] = _currency;
    data['referral'] = _referral;
    data["dateUpdated"] = _dateUpdated;
    data["dateCreated"] = _dateCreated;
    return data;
  }

  factory PaycoolCreateOrderModel.fromJson(Map<String, dynamic> json) {
    return PaycoolCreateOrderModel(
        walletAdd: json['walletAdd'],
        status: json['status'],
        campaignId: json['campaignId'],
        amount: json['amount'],
        currency: json['currency'],
        dateUpdated: json['dateUpdated'],
        dateCreated: json['dateCreated']);
  }

  String get walletAdd => _walletAdd!;
  set walletAdd(String walletAdd) {
    _walletAdd = walletAdd;
  }

  String get status => _status!;
  set status(String status) {
    _status = status;
  }

  int get campaignId => _campaignId!;
  set campaignId(int campaignId) {
    _campaignId = campaignId;
  }

  String get currency => _currency!;
  set currency(String currency) {
    _currency = currency;
  }

  String get referral => _referral!;
  set referral(String referral) {
    _referral = referral;
  }

  double get amount => _amount!;
  set amount(double amount) {
    _amount = amount;
  }

  DateTime get dateUpdated => _dateUpdated!;
  set dateUpdated(DateTime dateUpdated) {
    _dateUpdated = dateUpdated;
  }

  DateTime get dateCreated => _dateCreated!;
  set dateCreated(DateTime dateCreated) {
    _dateCreated = dateCreated;
  }
}
