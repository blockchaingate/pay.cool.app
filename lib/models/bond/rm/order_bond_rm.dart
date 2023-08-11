import 'dart:convert';

OrderBondRm orderBondRmFromJson(String str) =>
    OrderBondRm.fromJson(json.decode(str));

String orderBondRmToJson(OrderBondRm data) => json.encode(data.toJson());

class OrderBondRm {
  String? symbol;
  int? quantity;
  String? paymentCoin;
  String? paymentChain;
  int? paymentAmount;
  int? paymentCoinAmount;

  OrderBondRm({
    this.symbol,
    this.quantity,
    this.paymentCoin,
    this.paymentChain,
    this.paymentAmount,
    this.paymentCoinAmount,
  });

  factory OrderBondRm.fromJson(Map<String, dynamic> json) => OrderBondRm(
        symbol: json["symbol"],
        quantity: json["quantity"],
        paymentCoin: json["paymentCoin"],
        paymentChain: json["paymentChain"],
        paymentAmount: json["paymentAmount"],
        paymentCoinAmount: json["paymentCoinAmount"],
      );

  Map<String, dynamic> toJson() => {
        "symbol": symbol,
        "quantity": quantity,
        "paymentCoin": paymentCoin,
        "paymentChain": paymentChain,
        "paymentAmount": paymentAmount,
        "paymentCoinAmount": paymentCoinAmount,
      };
}
