import 'dart:convert';

RegisterEmailVm registerEmailVmFromJson(String str) =>
    RegisterEmailVm.fromJson(json.decode(str));

String registerEmailVmToJson(RegisterEmailVm data) =>
    json.encode(data.toJson());

class RegisterEmailVm {
  String? id;
  String? email;
  String? token;

  RegisterEmailVm({
    this.id,
    this.email,
    this.token,
  });

  factory RegisterEmailVm.fromJson(Map<String, dynamic> json) =>
      RegisterEmailVm(
        id: json["id"],
        email: json["email"],
        token: json["token"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "token": token,
      };
}
