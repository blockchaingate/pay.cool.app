import 'dart:convert';

VerifyCaptchaModel verifyCaptchaModelFromJson(String str) =>
    VerifyCaptchaModel.fromJson(json.decode(str));

String verifyCaptchaModelToJson(VerifyCaptchaModel data) =>
    json.encode(data.toJson());

class VerifyCaptchaModel {
  String? captchaResponse;
  String? email;

  VerifyCaptchaModel({
    this.captchaResponse,
    this.email,
  });

  factory VerifyCaptchaModel.fromJson(Map<String, dynamic> json) =>
      VerifyCaptchaModel(
        captchaResponse: json["captchaResponse"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "captchaResponse": captchaResponse,
        "email": email,
      };
}
