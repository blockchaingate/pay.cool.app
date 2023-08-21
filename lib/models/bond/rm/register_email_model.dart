import 'dart:convert';

RegisterEmailModel registerEmailRmFromJson(String str) =>
    RegisterEmailModel.fromJson(json.decode(str));

String registerEmailRmToJson(RegisterEmailModel data) =>
    json.encode(data.toJson());

class RegisterEmailModel {
  String? pidReferralCode;
  String? deviceId;
  String? email;
  String? password;

  RegisterEmailModel({
    this.pidReferralCode,
    this.deviceId,
    this.email,
    this.password,
  });

  factory RegisterEmailModel.fromJson(Map<String, dynamic> json) =>
      RegisterEmailModel(
        pidReferralCode: json["pidReferralCode"],
        deviceId: json["deviceId"],
        email: json["email"],
        password: json["password"],
      );

  Map<String, dynamic> toJson() => {
        "pidReferralCode": pidReferralCode,
        "deviceId": deviceId,
        "email": email,
        "password": password,
      };
}
