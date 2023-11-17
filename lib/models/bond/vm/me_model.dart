import 'dart:convert';

BondMeModel bondMeVmFromJson(String str) =>
    BondMeModel.fromJson(json.decode(str));

String bondMeVmToJson(BondMeModel data) => json.encode(data.toJson());

class BondMeModel {
  String? userid;
  int? kycLevel;
  String? email;
  String? referralCode;
  int? level1ReferralCount;
  int? level2ReferralCount;
  bool? isEmailVerified;
  String? role;
  DateTime? createdAt;

  BondMeModel({
    this.userid,
    this.kycLevel,
    this.email,
    this.referralCode,
    this.level1ReferralCount,
    this.level2ReferralCount,
    this.isEmailVerified,
    this.role,
    this.createdAt,
  });

  factory BondMeModel.fromJson(Map<String, dynamic> json) => BondMeModel(
        userid: json["userid"],
        kycLevel: json["kyc_level"],
        email: json["email"],
        referralCode: json["referral_code"],
        level1ReferralCount: json["level1_referral_count"],
        level2ReferralCount: json["level2_referral_count"],
        isEmailVerified: json["isEmailVerified"],
        role: json["role"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "userid": userid,
        "kyc_level": kycLevel,
        "email": email,
        "referral_code": referralCode,
        "level1_referral_count": level1ReferralCount,
        "level2_referral_count": level2ReferralCount,
        "isEmailVerified": isEmailVerified,
        "role": role,
        "created_at": createdAt?.toIso8601String(),
      };
}
