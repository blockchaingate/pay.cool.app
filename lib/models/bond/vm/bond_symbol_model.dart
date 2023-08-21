import 'dart:convert';

BondSembolModel bondSembolVmFromJson(String str) =>
    BondSembolModel.fromJson(json.decode(str));

String bondSembolVmToJson(BondSembolModel data) => json.encode(data.toJson());

class BondSembolModel {
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

  BondSembolModel({
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
  });

  factory BondSembolModel.fromJson(Map<String, dynamic> json) =>
      BondSembolModel(
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
      };
}
