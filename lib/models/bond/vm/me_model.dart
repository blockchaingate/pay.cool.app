import 'dart:convert';

BondMeModel bondMeModelFromJson(String str) =>
    BondMeModel.fromJson(json.decode(str));

String bondMeModelToJson(BondMeModel data) => json.encode(data.toJson());

class BondMeModel {
  String? userid;
  int? kycLevel;
  String? email;
  bool? isEmailVerified;
  String? phone;
  bool? isPhoneVerified;
  String? referralCode;
  int? level1ReferralCount;
  int? level2ReferralCount;
  String? role;
  DateTime? createdAt;

  BondMeModel({
    this.userid,
    this.kycLevel,
    this.email,
    this.isEmailVerified,
    this.phone,
    this.isPhoneVerified,
    this.referralCode,
    this.level1ReferralCount,
    this.level2ReferralCount,
    this.role,
    this.createdAt,
  });

  factory BondMeModel.fromJson(Map<String, dynamic> json) => BondMeModel(
        userid: json["userid"],
        kycLevel: json["kyc_level"],
        email: json["email"],
        isEmailVerified: json["isEmailVerified"],
        phone: json["phone"],
        isPhoneVerified: json["isPhoneVerified"],
        referralCode: json["referral_code"],
        level1ReferralCount: json["level1_referral_count"],
        level2ReferralCount: json["level2_referral_count"],
        role: json["role"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "userid": userid,
        "kyc_level": kycLevel,
        "email": email,
        "isEmailVerified": isEmailVerified,
        "phone": phone,
        "isPhoneVerified": isPhoneVerified,
        "referral_code": referralCode,
        "level1_referral_count": level1ReferralCount,
        "level2_referral_count": level2ReferralCount,
        "role": role,
        "created_at": createdAt?.toIso8601String(),
      };
}
