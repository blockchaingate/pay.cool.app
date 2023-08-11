import 'dart:convert';

BondSembolVm bondSembolVmFromJson(String str) =>
    BondSembolVm.fromJson(json.decode(str));

String bondSembolVmToJson(BondSembolVm data) => json.encode(data.toJson());

class BondSembolVm {
  BondInfo? bondInfo;

  BondSembolVm({
    this.bondInfo,
  });

  factory BondSembolVm.fromJson(Map<String, dynamic> json) => BondSembolVm(
        bondInfo: json["bond_info"] == null
            ? null
            : BondInfo.fromJson(json["bond_info"]),
      );

  Map<String, dynamic> toJson() => {
        "bond_info": bondInfo?.toJson(),
      };
}

class BondInfo {
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

  BondInfo({
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

  factory BondInfo.fromJson(Map<String, dynamic> json) => BondInfo(
        id: json["_id"],
        symbol: json["symbol"],
        v: json["__v"],
        couponFrequency: json["coupon_frequency"],
        couponRate: json["coupon_rate"],
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
