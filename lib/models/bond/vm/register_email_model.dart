import 'dart:convert';

RegisterEmailModel registerEmailVmFromJson(String str) =>
    RegisterEmailModel.fromJson(json.decode(str));

String registerEmailVmToJson(RegisterEmailModel data) =>
    json.encode(data.toJson());

class RegisterEmailModel {
  String? id;
  String? email;
  String? token;

  RegisterEmailModel({
    this.id,
    this.email,
    this.token,
  });

  factory RegisterEmailModel.fromJson(Map<String, dynamic> json) =>
      RegisterEmailModel(
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
