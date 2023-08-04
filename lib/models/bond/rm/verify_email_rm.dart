import 'dart:convert';

VerifyEmailRm verifyEmailRmFromJson(String str) =>
    VerifyEmailRm.fromJson(json.decode(str));

String verifyEmailRmToJson(VerifyEmailRm data) => json.encode(data.toJson());

class VerifyEmailRm {
  String? email;
  String? code;

  VerifyEmailRm({
    this.email,
    this.code,
  });

  factory VerifyEmailRm.fromJson(Map<String, dynamic> json) => VerifyEmailRm(
        email: json["email"],
        code: json["code"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "code": code,
      };
}
