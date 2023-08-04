import 'dart:convert';

BondMeVm bondMeVmFromJson(String str) => BondMeVm.fromJson(json.decode(str));

String bondMeVmToJson(BondMeVm data) => json.encode(data.toJson());

class BondMeVm {
  String? userid;
  int? kycLevel;
  String? email;
  String? referralCode;
  int? level1ReferralCount;
  int? level2ReferralCount;
  bool? isVerifiedEmail;
  String? role;
  DateTime? createdAt;

  BondMeVm({
    this.userid,
    this.kycLevel,
    this.email,
    this.referralCode,
    this.level1ReferralCount,
    this.level2ReferralCount,
    this.isVerifiedEmail,
    this.role,
    this.createdAt,
  });

  factory BondMeVm.fromJson(Map<String, dynamic> json) => BondMeVm(
        userid: json["userid"],
        kycLevel: json["kyc_level"],
        email: json["email"],
        referralCode: json["referral_code"],
        level1ReferralCount: json["level1_referral_count"],
        level2ReferralCount: json["level2_referral_count"],
        isVerifiedEmail: json["isVerifiedEmail"],
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
        "isVerifiedEmail": isVerifiedEmail,
        "role": role,
        "created_at": createdAt?.toIso8601String(),
      };
}
