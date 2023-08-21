import 'dart:convert';

VerifyCaptchaModel verifyCaptchaRmFromJson(String str) =>
    VerifyCaptchaModel.fromJson(json.decode(str));

String verifyCaptchaRmToJson(VerifyCaptchaModel data) =>
    json.encode(data.toJson());

class VerifyCaptchaModel {
  String? captchaResponse;

  VerifyCaptchaModel({
    this.captchaResponse,
  });

  factory VerifyCaptchaModel.fromJson(Map<String, dynamic> json) =>
      VerifyCaptchaModel(
        captchaResponse: json["captchaResponse"],
      );

  Map<String, dynamic> toJson() => {
        "captchaResponse": captchaResponse,
      };
}
