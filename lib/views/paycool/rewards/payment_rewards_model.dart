import 'package:decimal/decimal.dart';

class PaymentReward {
  String sId;
  String orderid;
  String user;
  int lockedDays;
  String coin;
  Decimal amount;
  String type;
  String dateCreated;

  PaymentReward(
      {this.sId,
      this.orderid,
      this.user,
      this.lockedDays,
      this.coin,
      this.amount,
      this.type,
      this.dateCreated});

  PaymentReward.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    orderid = json['order'];
    user = json['user'];
    lockedDays = json['lockedDays'];
    coin = json['coin'];
    amount = Decimal.parse(json['amount'].toString());
    type = json['type'];
    dateCreated = json['dateCreated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['order'] = orderid;
    data['user'] = user;
    data['lockedDays'] = lockedDays;
    data['coin'] = coin;
    data['amount'] = amount;
    data['type'] = type;
    data['dateCreated'] = dateCreated;
    return data;
  }
}

class PaymentRewards {
  final List<PaymentReward> paymentRewards;
  PaymentRewards({this.paymentRewards});

  factory PaymentRewards.fromJson(List<dynamic> parsedJson) {
    List<PaymentReward> paymentRewards = [];
    paymentRewards = parsedJson.map((i) => PaymentReward.fromJson(i)).toList();
    return PaymentRewards(paymentRewards: paymentRewards);
  }
}
