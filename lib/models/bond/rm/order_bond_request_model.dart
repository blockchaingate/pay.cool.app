import 'dart:convert';

OrderBondRequestModel orderBondRequestModelFromJson(String str) =>
    OrderBondRequestModel.fromJson(json.decode(str));

String orderBondRequestModelToJson(OrderBondRequestModel data) =>
    json.encode(data.toJson());

class OrderBondRequestModel {
  String? symbol;
  int? quantity;
  int? paymentAmount;

  OrderBondRequestModel({
    this.symbol,
    this.quantity,
    this.paymentAmount,
  });

  factory OrderBondRequestModel.fromJson(Map<String, dynamic> json) =>
      OrderBondRequestModel(
        symbol: json["symbol"],
        quantity: json["quantity"],
        paymentAmount: json["paymentAmount"],
      );

  Map<String, dynamic> toJson() => {
        "symbol": symbol,
        "quantity": quantity,
        "paymentAmount": paymentAmount,
      };
}
