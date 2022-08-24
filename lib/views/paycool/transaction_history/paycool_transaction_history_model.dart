import 'package:paycool/utils/string_util.dart';
import '../../../environments/coins.dart' as coinList;

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
  double merchantGet;
  double feePayment;
  double rewardAmount;
  double tax;
  String dateCreated;
  double totalTransactionAmount;
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
    double merchantAmount =
        bigNum2Double(json['merchantGet'] ?? 0.0, decimalLength: 16);
    double exchangilyAmount =
        bigNum2Double(json['feePayment'] ?? 0.0, decimalLength: 16);
    double rewardAmountDouble =
        bigNum2Double(json['rewardAmount'] ?? 0.0, decimalLength: 16);
    double taxAmountDouble = bigNum2Double(json['tax'] ?? 0, decimalLength: 16);

    double total = 0.0;
    if (merchantAmount != null &&
        exchangilyAmount != null &&
        taxAmountDouble != null) {
      total = merchantAmount +
          exchangilyAmount +
          taxAmountDouble +
          rewardAmountDouble;
    }

    String t = coinList.newCoinTypeMap[json['coinType']];

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
