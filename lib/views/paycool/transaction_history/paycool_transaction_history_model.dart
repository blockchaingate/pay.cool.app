import 'package:decimal/decimal.dart';
import 'package:paycool/constants/constants.dart';
import 'package:paycool/utils/number_util.dart';
import '../../../environments/coins.dart' as coin_list;

class PayCoolTransactionHistory {
  // 0: refunded   1: valid   2: request refund
  // when user made request refund, status will be changed to 2,
  // when he cancel his request, the status will be changed back to 1,
  // when merchant approve the request, status will be changed  to 0
  //int status;
  String? id;
  String? from;
  String? address;
  String? merchantRecipient;
  String? exchangilyRecipient;
  String? txid;
  String? orderId;
  int? coinType;
  int? rate;
  Decimal? merchantGet;
  Decimal? feePayment;
  Decimal? rewardAmount;
  Decimal? tax;
  String? dateCreated;
  Decimal? totalTransactionAmount;
  String? tickerName;
  List<Refunds>? refunds = [];

  PayCoolTransactionHistory(
      { //this.status,
      this.id,
      this.from,
      this.address,
      this.merchantRecipient,
      this.exchangilyRecipient,
      this.coinType,
      this.rate,
      this.merchantGet,
      this.txid,
      this.orderId,
      this.feePayment,
      this.rewardAmount,
      this.tax,
      this.dateCreated,
      this.totalTransactionAmount,
      this.tickerName,
      this.refunds});

  factory PayCoolTransactionHistory.fromJson(Map<String, dynamic> json) {
    //double merchantAmount = BigInt.from(json['merchantGet']).toDouble() / 1e8;
    List<Refunds> r = [];
    Decimal merchantAmount = json['merchantGet'] == null
        ? Constants.decimalZero
        : NumberUtil.rawStringToDecimal(
            json['merchantGet'].toString(),
          );
    Decimal exchangilyAmount = NumberUtil.rawStringToDecimal(
      json['paymentFee'].toString(),
    );
    Decimal rewardAmount = NumberUtil.rawStringToDecimal(
      json['totalReward'].toString(),
    );
    Decimal taxAmount = NumberUtil.rawStringToDecimal(
      json['tax'].toString(),
    );

    Decimal total = Constants.decimalZero;
    total = merchantAmount + exchangilyAmount + taxAmount + rewardAmount;

    String? ticker = coin_list.newCoinTypeMap[json['paidCoin']];
    if (json['refunds'] != null) {
      r = <Refunds>[];
      json['refunds'].forEach((v) {
        r.add(Refunds.fromJson(v));
      });
    }
    return PayCoolTransactionHistory(
        // status: json['status'],
        id: json['_id'],
        // from: json['from'],
        address: json['address'],
        merchantRecipient: json['merchantRecipient'] ?? '',
        exchangilyRecipient: json['exchangilyRecipient'] ?? '',
        coinType: json['paidCoin'],
        //rate: json['rate'],
        merchantGet: merchantAmount,
        feePayment: exchangilyAmount,
        rewardAmount: rewardAmount,
        tax: taxAmount,
        dateCreated: json['dateCreated'],
        totalTransactionAmount: total,
        txid: json['txid'],
        refunds: r,
        orderId: json['orderId'],
        tickerName: ticker ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    //  data['status'] = status;
    data['_id'] = id;
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
    data['txid'] = txid;
    data['orderId'] = orderId;
    data['dateCreated'] = dateCreated;
    data['totalTransactionAmount'] = totalTransactionAmount;
    return data;
  }
}

class Refunds {
  bool? refundAll;
  List? items;
  String? requestRefundId;
  String? r;
  String? s;
  String? v;
  String? sId;
  String? dateCreated;
  int? status;
  String? txid;

  Refunds(
      {this.refundAll,
      this.items,
      this.requestRefundId,
      this.r,
      this.s,
      this.v,
      this.sId,
      this.dateCreated});

  Refunds.fromJson(Map<String, dynamic> json) {
    refundAll = json['refundAll'];
    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) {
        items!.add((v));
      });
    }
    requestRefundId = json['requestRefundId'];
    r = json['r'];
    s = json['s'];
    v = json['v'];
    sId = json['_id'];
    txid = json['txid'];
    status = json['status'];
    dateCreated = json['dateCreated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['refundAll'] = refundAll;
    if (items != null) {
      data['items'] = items!.map((v) => v!.toJson()).toList();
    }
    data['requestRefundId'] = requestRefundId;
    data['r'] = r;
    data['s'] = s;
    data['v'] = v;
    data['_id'] = sId;
    data['status'] = status;
    data['txid'] = txid;
    data['dateCreated'] = dateCreated;
    return data;
  }
}

class PayCoolTransactionHistoryModelList {
  final List<PayCoolTransactionHistory>? transactions;
  PayCoolTransactionHistoryModelList({this.transactions});

  factory PayCoolTransactionHistoryModelList.fromJson(
      List<dynamic> parsedJson) {
    List<PayCoolTransactionHistory> transactions = [];
    transactions =
        parsedJson.map((i) => PayCoolTransactionHistory.fromJson(i)).toList();
    return PayCoolTransactionHistoryModelList(transactions: transactions);
  }
}
