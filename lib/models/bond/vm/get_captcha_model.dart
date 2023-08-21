import 'dart:convert';

GetCaptchaModel getCaptchaVmFromJson(String str) =>
    GetCaptchaModel.fromJson(json.decode(str));

String getCaptchaVmToJson(GetCaptchaModel data) => json.encode(data.toJson());

class GetCaptchaModel {
  String? captcha;

  GetCaptchaModel({
    this.captcha,
  });

  factory GetCaptchaModel.fromJson(Map<String, dynamic> json) =>
      GetCaptchaModel(
        captcha: json["captcha"],
      );

  Map<String, dynamic> toJson() => {
        "captcha": captcha,
      };
}
