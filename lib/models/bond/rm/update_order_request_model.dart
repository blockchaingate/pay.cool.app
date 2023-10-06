import 'dart:convert';

UpdateOrderRequestModel updateOrderRequestModelFromJson(String str) =>
    UpdateOrderRequestModel.fromJson(json.decode(str));

String updateOrderRequestModelToJson(UpdateOrderRequestModel data) =>
    json.encode(data.toJson());

class UpdateOrderRequestModel {
  String? paymentCoin;
  String? paymentChain;
  int? paymentCoinAmount;

  UpdateOrderRequestModel({
    this.paymentCoin,
    this.paymentChain,
    this.paymentCoinAmount,
  });

  factory UpdateOrderRequestModel.fromJson(Map<String, dynamic> json) =>
      UpdateOrderRequestModel(
        paymentCoin: json["paymentCoin"],
        paymentChain: json["paymentChain"],
        paymentCoinAmount: json["paymentCoinAmount"],
      );

  Map<String, dynamic> toJson() => {
        "paymentCoin": paymentCoin,
        "paymentChain": paymentChain,
        "paymentCoinAmount": paymentCoinAmount,
      };
}
