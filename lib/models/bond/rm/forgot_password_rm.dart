import 'dart:convert';

ForgotPasswordRm forgotPasswordRmFromJson(String str) =>
    ForgotPasswordRm.fromJson(json.decode(str));

String forgotPasswordRmToJson(ForgotPasswordRm data) =>
    json.encode(data.toJson());

class ForgotPasswordRm {
  String? email;

  ForgotPasswordRm({
    this.email,
  });

  factory ForgotPasswordRm.fromJson(Map<String, dynamic> json) =>
      ForgotPasswordRm(
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
      };
}
