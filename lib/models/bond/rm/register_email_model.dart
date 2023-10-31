import 'dart:convert';

RegisterEmailModel registerEmailModelFromJson(String str) =>
    RegisterEmailModel.fromJson(json.decode(str));

String registerEmailModelToJson(RegisterEmailModel data) =>
    json.encode(data.toJson());

class RegisterEmailModel {
  String? pidReferralCode;
  String? deviceId;
  String? email;
  String? password;
  String? code;

  RegisterEmailModel({
    this.pidReferralCode,
    this.deviceId,
    this.email,
    this.password,
    this.code,
  });

  factory RegisterEmailModel.fromJson(Map<String, dynamic> json) =>
      RegisterEmailModel(
        pidReferralCode: json["pidReferralCode"],
        deviceId: json["deviceId"],
        email: json["email"],
        password: json["password"],
        code: json["code"],
      );

  Map<String, dynamic> toJson() => {
        "pidReferralCode": pidReferralCode,
        "deviceId": deviceId,
        "email": email,
        "password": password,
        "code": code,
      };
}
