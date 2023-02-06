class PaycoolPayment {
  String? _orderId;
  // 0: waiting for payment,
  // 1: payment made,
  // 3: payment confirmed,
  // 4: completed - coins sent,
  // 5: cancelled, 6: suspended
  String? _status;

  double? _amount;
  String? _currency;
  String? _paymentMethod;
  String? _txId;
  DateTime? _dateUpdated;
  DateTime? _dateCreated;

  PaycoolPayment(
      {String? orderId,
      String? status,
      double? amount,
      String? currency,
      String? paymentMethod,
      String? txId,
      DateTime? dateUpdated,
      DateTime? dateCreated}) {
    _orderId = orderId ?? '';
    _status = status ?? '';
    _amount = amount ?? 0.0;
    _currency = currency;
    _paymentMethod = paymentMethod;
    _txId = txId ?? '';
    _dateUpdated = dateUpdated;
    _dateCreated = dateCreated;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['orderId'] = _orderId;
    data['status'] = _status;
    data['amount'] = _amount;
    data['currency'] = _currency;
    data['paymentMethod'] = _paymentMethod;
    data['transactionId'] = _txId;
    data["dateUpdated"] = _dateUpdated;
    data["dateCreated"] = _dateCreated;
    return data;
  }

  factory PaycoolPayment.fromJson(Map<String, dynamic> json) {
    return PaycoolPayment(
        orderId: json['orderId'],
        status: json['status'],
        amount: json['amount'],
        currency: json['currency'],
        paymentMethod: json['paymentMethod'],
        txId: json['transactionId'],
        dateUpdated: json['dateUpdated'],
        dateCreated: json['dateCreated']);
  }

  String get orderId => _orderId!;
  set orderId(String orderId) {
    _orderId = orderId;
  }

  String get status => _status!;
  set status(String status) {
    _status = status;
  }

  String get currency => _currency!;
  set currency(String currency) {
    _currency = currency;
  }

  String get paymentMethod => _paymentMethod!;
  set paymentMethod(String paymentMethod) {
    _paymentMethod = paymentMethod;
  }

  String get txId => _txId!;
  set txId(String txid) {
    _txId = txid;
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
