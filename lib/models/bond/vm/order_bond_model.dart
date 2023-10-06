import 'dart:convert';

OrderBondModel orderBondModelFromJson(String str) =>
    OrderBondModel.fromJson(json.decode(str));

String orderBondModelToJson(OrderBondModel data) => json.encode(data.toJson());

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
  int? paymentAmount;
  String? status;
  DateTime? createdAt;
  String? id;
  int? v;

  BondOrder({
    this.user,
    this.bondId,
    this.quantity,
    this.paymentAmount,
    this.status,
    this.createdAt,
    this.id,
    this.v,
  });

  factory BondOrder.fromJson(Map<String, dynamic> json) => BondOrder(
        user: json["user"],
        bondId: json["bondId"],
        quantity: json["quantity"],
        paymentAmount: json["paymentAmount"],
        status: json["status"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        id: json["_id"],
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "user": user,
        "bondId": bondId,
        "quantity": quantity,
        "paymentAmount": paymentAmount,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "_id": id,
        "__v": v,
      };
}
