import 'dart:convert';

VerifyCaptchaRm verifyCaptchaRmFromJson(String str) =>
    VerifyCaptchaRm.fromJson(json.decode(str));

String verifyCaptchaRmToJson(VerifyCaptchaRm data) =>
    json.encode(data.toJson());

class VerifyCaptchaRm {
  String? captchaResponse;

  VerifyCaptchaRm({
    this.captchaResponse,
  });

  factory VerifyCaptchaRm.fromJson(Map<String, dynamic> json) =>
      VerifyCaptchaRm(
        captchaResponse: json["captchaResponse"],
      );

  Map<String, dynamic> toJson() => {
        "captchaResponse": captchaResponse,
      };
}
