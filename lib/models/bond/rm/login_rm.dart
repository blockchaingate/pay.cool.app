import 'dart:convert';

LoginRm loginRmFromJson(String str) => LoginRm.fromJson(json.decode(str));

String loginRmToJson(LoginRm data) => json.encode(data.toJson());

class LoginRm {
  String? email;
  String? password;

  LoginRm({
    this.email,
    this.password,
  });

  factory LoginRm.fromJson(Map<String, dynamic> json) => LoginRm(
        email: json["email"],
        password: json["password"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "password": password,
      };
}
