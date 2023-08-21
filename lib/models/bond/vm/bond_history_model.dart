import 'dart:convert';

List<BondHistoryModel> bondHistoryVmFromJson(String str) =>
    List<BondHistoryModel>.from(
        json.decode(str).map((x) => BondHistoryModel.fromJson(x)));

String bondHistoryVmToJson(List<BondHistoryModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BondHistoryModel {
  String? id;
  String? user;
  BondId? bondId;
  int? quantity;
  String? paymentCoin;
  String? paymentChain;
  int? paymentAmount;
  int? paymentCoinAmount;
  String? status;
  DateTime? createdAt;
  int? v;

  BondHistoryModel({
    this.id,
    this.user,
    this.bondId,
    this.quantity,
    this.paymentCoin,
    this.paymentChain,
    this.paymentAmount,
    this.paymentCoinAmount,
    this.status,
    this.createdAt,
    this.v,
  });

  factory BondHistoryModel.fromJson(Map<String, dynamic> json) =>
      BondHistoryModel(
        id: json["_id"],
        user: json["user"],
        bondId: json["bondId"] == null ? null : BondId.fromJson(json["bondId"]),
        quantity: json["quantity"],
        paymentCoin: json["paymentCoin"],
        paymentChain: json["paymentChain"],
        paymentAmount: json["paymentAmount"],
        paymentCoinAmount: json["paymentCoinAmount"],
        status: json["status"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "user": user,
        "bondId": bondId?.toJson(),
        "quantity": quantity,
        "paymentCoin": paymentCoin,
        "paymentChain": paymentChain,
        "paymentAmount": paymentAmount,
        "paymentCoinAmount": paymentCoinAmount,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "__v": v,
      };
}

class BondId {
  String? id;
  String? symbol;
  int? v;
  int? couponFrequency;
  double? couponRate;
  String? description;
  int? faceValue;
  int? issuePrice;
  String? issuer;
  int? maturity;
  String? name;
  int? redemptionPrice;
  int? totalSupply;

  BondId({
    this.id,
    this.symbol,
    this.v,
    this.couponFrequency,
    this.couponRate,
    this.description,
    this.faceValue,
    this.issuePrice,
    this.issuer,
    this.maturity,
    this.name,
    this.redemptionPrice,
    this.totalSupply,
  });

  factory BondId.fromJson(Map<String, dynamic> json) => BondId(
        id: json["_id"],
        symbol: json["symbol"],
        v: json["__v"],
        couponFrequency: json["coupon_frequency"],
        couponRate: json["coupon_rate"]?.toDouble(),
        description: json["description"],
        faceValue: json["face_value"],
        issuePrice: json["issue_price"],
        issuer: json["issuer"],
        maturity: json["maturity"],
        name: json["name"],
        redemptionPrice: json["redemption_price"],
        totalSupply: json["total_supply"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "symbol": symbol,
        "__v": v,
        "coupon_frequency": couponFrequency,
        "coupon_rate": couponRate,
        "description": description,
        "face_value": faceValue,
        "issue_price": issuePrice,
        "issuer": issuer,
        "maturity": maturity,
        "name": name,
        "redemption_price": redemptionPrice,
        "total_supply": totalSupply,
      };
}
