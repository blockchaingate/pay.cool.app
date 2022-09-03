import 'package:exchangily_core/exchangily_core.dart';

class PayCoolTransactionHistoryModel {
  // 0: refunded   1: valid   2: request refund
  // when user made request refund, status will be changed to 2,
  // when he cancel his request, the status will be changed back to 1,
  // when merchant approve the request, status will be changed  to 0
  int status;
  String id;
  String from;
  String address;
  String merchantRecipient;
  String exchangilyRecipient;

  int coinType;
  int rate;
  Decimal merchantGet;
  Decimal feePayment;
  Decimal rewardAmount;
  Decimal tax;
  String dateCreated;
  Decimal totalTransactionAmount;
  String tickerName;

  PayCoolTransactionHistoryModel(
      {this.status,
      this.id,
      this.from,
      this.address,
      this.merchantRecipient,
      this.exchangilyRecipient,
      this.coinType,
      this.rate,
      this.merchantGet,
      this.feePayment,
      this.rewardAmount,
      this.tax,
      this.dateCreated,
      this.totalTransactionAmount,
      this.tickerName});

  factory PayCoolTransactionHistoryModel.fromJson(Map<String, dynamic> json) {
    //double merchantAmount = BigInt.from(json['merchantGet']).toDouble() / 1e8;
    Decimal merchantAmount = NumberUtil.rawStringToDecimal(
        json['merchantGet'].toString(),
        decimalPrecision: 16);
    Decimal exchangilyAmount = NumberUtil.rawStringToDecimal(
        json['feePayment'].toString(),
        decimalPrecision: 16);
    Decimal rewardAmountDouble = NumberUtil.rawStringToDecimal(
        json['rewardAmount'].toString(),
        decimalPrecision: 16);
    Decimal taxAmountDouble = NumberUtil.rawStringToDecimal(
        json['tax'].toString(),
        decimalPrecision: 16);

    Decimal total = Constants.decimalZero;
    if (merchantAmount != null &&
        exchangilyAmount != null &&
        taxAmountDouble != null) {
      total = merchantAmount +
          exchangilyAmount +
          taxAmountDouble +
          rewardAmountDouble;
    }

    String t = Constants.coinTypeWithTicker[json['coinType']];

    return PayCoolTransactionHistoryModel(
        status: json['status'],
        id: json['id'],
        from: json['from'],
        address: json['address'],
        merchantRecipient: json['merchantRecipient'],
        exchangilyRecipient: json['exchangilyRecipient'],
        coinType: json['coinType'],
        rate: json['rate'],
        merchantGet: merchantAmount,
        feePayment: exchangilyAmount,
        rewardAmount: rewardAmountDouble,
        tax: taxAmountDouble,
        dateCreated: json['dateCreated'],
        totalTransactionAmount: total,
        tickerName: t);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['id'] = id;
    data['from'] = from;
    data['address'] = address;
    data['merchantRecipient'] = merchantRecipient;
    data['exchangilyRecipient'] = exchangilyRecipient;
    data['coinType'] = coinType;
    data['rate'] = rate;
    data['merchantGet'] = merchantGet;
    data['exchangilyGet'] = feePayment;
    data['rewardAmount'] = rewardAmount;
    data['tax'] = tax;
    data['dateCreated'] = dateCreated;
    data['totalTransactionAmount'] = totalTransactionAmount;
    return data;
  }
}

class PayCoolTransactionHistoryModelList {
  final List<PayCoolTransactionHistoryModel> transactions;
  PayCoolTransactionHistoryModelList({this.transactions});

  factory PayCoolTransactionHistoryModelList.fromJson(
      List<dynamic> parsedJson) {
    List<PayCoolTransactionHistoryModel> transactions = [];
    transactions = parsedJson
        .map((i) => PayCoolTransactionHistoryModel.fromJson(i))
        .toList();
    return PayCoolTransactionHistoryModelList(transactions: transactions);
  }
}
