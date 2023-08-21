import 'dart:convert';

BondUpdatePaymentModel bondUpdatePaymentModelFromJson(String str) =>
    BondUpdatePaymentModel.fromJson(json.decode(str));

String bondUpdatePaymentModelToJson(BondUpdatePaymentModel data) =>
    json.encode(data.toJson());

class BondUpdatePaymentModel {
  String? paymentMethod;
  String? paymentAccount;

  BondUpdatePaymentModel({
    this.paymentMethod,
    this.paymentAccount,
  });

  factory BondUpdatePaymentModel.fromJson(Map<String, dynamic> json) =>
      BondUpdatePaymentModel(
        paymentMethod: json["paymentMethod"],
        paymentAccount: json["paymentAccount"],
      );

  Map<String, dynamic> toJson() => {
        "paymentMethod": paymentMethod,
        "paymentAccount": paymentAccount,
      };
}
