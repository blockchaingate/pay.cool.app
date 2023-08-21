import 'dart:convert';

OrderBondModel orderBondVmFromJson(String str) =>
    OrderBondModel.fromJson(json.decode(str));

String orderBondVmToJson(OrderBondModel data) => json.encode(data.toJson());

class OrderBondModel {
  BondOrder? bondOrder;

  OrderBondModel({
    this.bondOrder,
  });

  factory OrderBondModel.fromJson(Map<String, dynamic> json) => OrderBondModel(
        bondOrder: json["bond_order"] == null
            ? null
            : BondOrder.fromJson(json["bond_order"]),
      );

  Map<String, dynamic> toJson() => {
        "bond_order": bondOrder?.toJson(),
      };
}

class BondOrder {
  String? user;
  String? bondId;
  int? quantity;
  bool? kyCverified;
  String? status;
  DateTime? createdAt;

  BondOrder({
    this.user,
    this.bondId,
    this.quantity,
    this.kyCverified,
    this.status,
    this.createdAt,
  });

  factory BondOrder.fromJson(Map<String, dynamic> json) => BondOrder(
        user: json["user"],
        bondId: json["bondId"],
        quantity: json["quantity"],
        kyCverified: json["KYCverified"],
        status: json["status"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "user": user,
        "bondId": bondId,
        "quantity": quantity,
        "KYCverified": kyCverified,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
      };
}
