import 'package:decimal/decimal.dart';

class PaymentReward {
  String? sId;
  String? txid;
  String? category;
  int? lockedDays;
  String? rewardCoin;
  Decimal? rewardAmount;
  String? type;
  String? dateCreated;

  PaymentReward(
      {this.sId,
      this.txid,
      this.category,
      this.lockedDays,
      this.rewardCoin,
      this.rewardAmount,
      this.type,
      this.dateCreated});

  PaymentReward.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    txid = json['txid'];

    lockedDays = json['lockedDays'];
    rewardCoin = json['rewardCoin'];
    rewardAmount = Decimal.parse(json['rewardAmount'].toString());
    type = json['type'];
    type = json['category'];
    dateCreated = json['dateCreated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['txid'] = txid;
    data['category'] = category;
    data['lockedDays'] = lockedDays;
    data['rewardCoin'] = rewardCoin;
    data['rewardAmount'] = rewardAmount;
    data['type'] = type;
    data['dateCreated'] = dateCreated;
    return data;
  }
}

class PaymentRewards {
  final List<PaymentReward>? paymentRewards;
  PaymentRewards({this.paymentRewards});

  factory PaymentRewards.fromJson(List<dynamic> parsedJson) {
    List<PaymentReward> paymentRewards = [];
    paymentRewards = parsedJson.map((i) => PaymentReward.fromJson(i)).toList();
    return PaymentRewards(paymentRewards: paymentRewards);
  }
}
