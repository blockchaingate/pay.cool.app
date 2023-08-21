import 'dart:convert';

ForgotPasswordVerifyModel forgotPasswordVerifyModelFromJson(String str) =>
    ForgotPasswordVerifyModel.fromJson(json.decode(str));

String forgotPasswordVerifyModelToJson(ForgotPasswordVerifyModel data) =>
    json.encode(data.toJson());

class ForgotPasswordVerifyModel {
  String? email;
  String? code;
  String? password;

  ForgotPasswordVerifyModel({
    this.email,
    this.code,
    this.password,
  });

  factory ForgotPasswordVerifyModel.fromJson(Map<String, dynamic> json) =>
      ForgotPasswordVerifyModel(
        email: json["email"],
        code: json["code"],
        password: json["password"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "code": code,
        "password": password,
      };
}
