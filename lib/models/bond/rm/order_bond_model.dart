import 'dart:convert';

OrderBondModel orderBondRmFromJson(String str) =>
    OrderBondModel.fromJson(json.decode(str));

String orderBondRmToJson(OrderBondModel data) => json.encode(data.toJson());

class OrderBondModel {
  String? symbol;
  int? quantity;
  String? paymentCoin;
  String? paymentChain;
  int? paymentAmount;
  int? paymentCoinAmount;

  OrderBondModel({
    this.symbol,
    this.quantity,
    this.paymentCoin,
    this.paymentChain,
    this.paymentAmount,
    this.paymentCoinAmount,
  });

  factory OrderBondModel.fromJson(Map<String, dynamic> json) => OrderBondModel(
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
