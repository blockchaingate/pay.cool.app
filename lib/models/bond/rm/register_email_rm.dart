import 'dart:convert';

RegisterEmailRm registerEmailRmFromJson(String str) =>
    RegisterEmailRm.fromJson(json.decode(str));

String registerEmailRmToJson(RegisterEmailRm data) =>
    json.encode(data.toJson());

class RegisterEmailRm {
  String? pidReferralCode;
  String? deviceId;
  String? email;
  String? password;

  RegisterEmailRm({
    this.pidReferralCode,
    this.deviceId,
    this.email,
    this.password,
  });

  factory RegisterEmailRm.fromJson(Map<String, dynamic> json) =>
      RegisterEmailRm(
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
