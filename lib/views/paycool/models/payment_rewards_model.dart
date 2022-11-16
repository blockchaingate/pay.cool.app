import 'package:decimal/decimal.dart';

class PaymentRewardsModel {
  String orderId;
  Decimal totalAmount;
  Decimal totalTax;
  Decimal totalShipping;
  int paidCoin;
  String merchantId;
  List<TotalRewards> totalRewards = [];
  List<RewardDetails> rewardDetails;
  String rewardInfo;
  List<Params> params;

  PaymentRewardsModel(
      {this.orderId,
      this.totalAmount,
      this.totalTax,
      this.totalShipping,
      this.paidCoin,
      this.merchantId,
      this.totalRewards,
      this.rewardDetails,
      this.params});

  PaymentRewardsModel.fromJson(Map<String, dynamic> json) {
    orderId = json['orderId'];
    totalAmount = Decimal.parse(json['totalAmount'].toString());
    totalTax = Decimal.parse(json['totalTax'].toString());
    totalShipping = Decimal.parse(json['totalShipping'].toString());
    paidCoin = json['paidCoin'];
    merchantId = json['merchantId'];
    if (json['totalRewards'] != null) {
      totalRewards = <TotalRewards>[];
      json['totalRewards'].forEach((v) {
        totalRewards.add(TotalRewards.fromJson(v));
      });
    }
    if (json['rewardDetails'] != null) {
      rewardDetails = <RewardDetails>[];
      json['rewardDetails'].forEach((v) {
        rewardDetails.add(RewardDetails.fromJson(v));
      });
    }
    if (json['params'] != null) {
      params = [];
      json['params'].forEach((v) {
        params.add(Params.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['orderId'] = this.orderId;
    data['totalAmount'] = this.totalAmount;
    data['totalTax'] = this.totalTax;
    data['totalShipping'] = this.totalShipping;
    data['paidCoin'] = this.paidCoin;
    data['merchantId'] = this.merchantId;
    if (this.totalRewards != null) {
      data['totalRewards'] = this.totalRewards.map((v) => v.toJson()).toList();
    }
    if (this.rewardDetails != null) {
      data['rewardDetails'] =
          this.rewardDetails.map((v) => v.toJson()).toList();
    }
    if (this.params != null) {
      data['params'] = this.params.map((v) => v.toJson()).toList();
    }
    return data;
  }

  Decimal get getTotalRewards => totalRewards == null || totalRewards.isEmpty
      ? Decimal.zero
      : totalRewards
          .map((e) => e.rewards)
          .reduce((value, current) => value + current);
}

class Params {
  String to;
  String data;

  Params({this.to, this.data});

  Params.fromJson(Map<String, dynamic> json) {
    to = json['to'];
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['to'] = this.to;
    data['data'] = this.data;
    return data;
  }
}

class TotalRewards {
  int lockedDays;
  Decimal rewards;

  TotalRewards({this.lockedDays, this.rewards});

  TotalRewards.fromJson(Map<String, dynamic> json) {
    lockedDays = json['lockedDays'];
    rewards = Decimal.parse(json['rewards']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['lockedDays'] = this.lockedDays;
    data['rewards'] = this.rewards;
    return data;
  }
}

class RewardDetails {
  int lockedDays;
  String type;
  String user;
  Decimal value;

  RewardDetails({this.lockedDays, this.type, this.user, this.value});

  RewardDetails.fromJson(Map<String, dynamic> json) {
    lockedDays = json['lockedDays'];
    type = json['type'];
    user = json['user'];
    value = Decimal.parse(json['value'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['lockedDays'] = this.lockedDays;
    data['type'] = this.type;
    data['user'] = this.user;
    data['value'] = this.value;
    return data;
  }
}
