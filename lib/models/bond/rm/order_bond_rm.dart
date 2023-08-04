import 'dart:convert';

OrderBondRm orderBondRmFromJson(String str) =>
    OrderBondRm.fromJson(json.decode(str));

String orderBondRmToJson(OrderBondRm data) => json.encode(data.toJson());

class OrderBondRm {
  String? symbol;
  int? quantity;

  OrderBondRm({
    this.symbol,
    this.quantity,
  });

  factory OrderBondRm.fromJson(Map<String, dynamic> json) => OrderBondRm(
        symbol: json["symbol"],
        quantity: json["quantity"],
      );

  Map<String, dynamic> toJson() => {
        "symbol": symbol,
        "quantity": quantity,
      };
}
