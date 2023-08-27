import 'dart:convert';

RegisterEmailViewModel registerEmailVmFromJson(String str) =>
    RegisterEmailViewModel.fromJson(json.decode(str));

String registerEmailVmToJson(RegisterEmailViewModel data) =>
    json.encode(data.toJson());

class RegisterEmailViewModel {
  String? id;
  String? email;
  String? token;

  RegisterEmailViewModel({
    this.id,
    this.email,
    this.token,
  });

  factory RegisterEmailViewModel.fromJson(Map<String, dynamic> json) =>
      RegisterEmailViewModel(
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
