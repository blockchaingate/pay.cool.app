import 'dart:convert';

ForgotPasswordVerifyRm forgotPasswordVerifyRmFromJson(String str) =>
    ForgotPasswordVerifyRm.fromJson(json.decode(str));

String forgotPasswordVerifyRmToJson(ForgotPasswordVerifyRm data) =>
    json.encode(data.toJson());

class ForgotPasswordVerifyRm {
  String? email;
  String? code;
  String? password;

  ForgotPasswordVerifyRm({
    this.email,
    this.code,
    this.password,
  });

  factory ForgotPasswordVerifyRm.fromJson(Map<String, dynamic> json) =>
      ForgotPasswordVerifyRm(
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
