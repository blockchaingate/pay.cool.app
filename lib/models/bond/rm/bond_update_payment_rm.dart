import 'dart:convert';

BondUpdatePaymentRm bondUpdatePaymentRmFromJson(String str) =>
    BondUpdatePaymentRm.fromJson(json.decode(str));

String bondUpdatePaymentRmToJson(BondUpdatePaymentRm data) =>
    json.encode(data.toJson());

class BondUpdatePaymentRm {
  String? paymentMethod;
  String? paymentAccount;

  BondUpdatePaymentRm({
    this.paymentMethod,
    this.paymentAccount,
  });

  factory BondUpdatePaymentRm.fromJson(Map<String, dynamic> json) =>
      BondUpdatePaymentRm(
        paymentMethod: json["paymentMethod"],
        paymentAccount: json["paymentAccount"],
      );

  Map<String, dynamic> toJson() => {
        "paymentMethod": paymentMethod,
        "paymentAccount": paymentAccount,
      };
}
