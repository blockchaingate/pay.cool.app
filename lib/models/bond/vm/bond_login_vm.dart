import 'dart:convert';

BondLoginModel bondLoginModelFromJson(String str) =>
    BondLoginModel.fromJson(json.decode(str));

String bondLoginModelToJson(BondLoginModel data) => json.encode(data.toJson());

class BondLoginModel {
  String? id;
  String? email;
  String? token;
  String? role;
  bool? isEmailVerified;
  int? kycLevel;

  BondLoginModel({
    this.id,
    this.email,
    this.token,
    this.role,
    this.isEmailVerified,
    this.kycLevel,
  });

  factory BondLoginModel.fromJson(Map<String, dynamic> json) => BondLoginModel(
        id: json["id"],
        email: json["email"],
        token: json["token"],
        role: json["role"],
        isEmailVerified: json["isEmailVerified"],
        kycLevel: json["kyc_level"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "token": token,
        "role": role,
        "isEmailVerified": isEmailVerified,
        "kyc_level": kycLevel,
      };
}
