import 'dart:convert';

GetCaptchaVm getCaptchaVmFromJson(String str) =>
    GetCaptchaVm.fromJson(json.decode(str));

String getCaptchaVmToJson(GetCaptchaVm data) => json.encode(data.toJson());

class GetCaptchaVm {
  String? captcha;

  GetCaptchaVm({
    this.captcha,
  });

  factory GetCaptchaVm.fromJson(Map<String, dynamic> json) => GetCaptchaVm(
        captcha: json["captcha"],
      );

  Map<String, dynamic> toJson() => {
        "captcha": captcha,
      };
}
