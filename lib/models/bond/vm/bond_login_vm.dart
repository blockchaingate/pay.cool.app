import 'dart:convert';

BondLoginVm bondLoginVmFromJson(String str) =>
    BondLoginVm.fromJson(json.decode(str));

String bondLoginVmToJson(BondLoginVm data) => json.encode(data.toJson());

class BondLoginVm {
  String? id;
  String? email;
  String? token;
  String? role;
  bool? isVerifiedEmail;
  int? kycLevel;

  BondLoginVm({
    this.id,
    this.email,
    this.token,
    this.role,
    this.isVerifiedEmail,
    this.kycLevel,
  });

  factory BondLoginVm.fromJson(Map<String, dynamic> json) => BondLoginVm(
        id: json["id"],
        email: json["email"],
        token: json["token"],
        role: json["role"],
        isVerifiedEmail: json["isVerifiedEmail"],
        kycLevel: json["kyc_level"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "token": token,
        "role": role,
        "isVerifiedEmail": isVerifiedEmail,
        "kyc_level": kycLevel,
      };
}
