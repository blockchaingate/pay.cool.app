import 'dart:convert';

VerifyEmailModel verifyEmailRmFromJson(String str) =>
    VerifyEmailModel.fromJson(json.decode(str));

String verifyEmailRmToJson(VerifyEmailModel data) => json.encode(data.toJson());

class VerifyEmailModel {
  String? email;
  String? code;

  VerifyEmailModel({
    this.email,
    this.code,
  });

  factory VerifyEmailModel.fromJson(Map<String, dynamic> json) =>
      VerifyEmailModel(
        email: json["email"],
        code: json["code"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "code": code,
      };
}
