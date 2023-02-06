class PaycoolReferral {
  String? _id; //wallet FAB or EXG address as _id, unique
  String? _parentId; // Referral wallet EXG address
  DateTime? _dateUpdated;
  DateTime? _dateCreated;
  String? _memberType;
  String? _referralCode;
  int? _campaignId;

  PaycoolReferral({
    String? id,
    String? parentId,
    DateTime? dateUpdated,
    DateTime? dateCreated,
    String? memberType,
    String? referralCode,
    int? campaignId,
  }) {
    _id = id;
    _parentId = parentId;
    _dateUpdated = dateUpdated;
    _dateCreated = dateCreated;
    _memberType = memberType;
    _referralCode = referralCode;
    _campaignId = campaignId;
  }

  factory PaycoolReferral.fromJson(Map<String, dynamic> json) {
    return PaycoolReferral(
      id: json['id'],
      parentId: json['memberId']['parentId'],
      dateUpdated: json['dateUpdated'],
      dateCreated: json['dateCreated'],
      memberType: json['memberType'],
      referralCode: json['referralCode'],
      campaignId: json['campaignId'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = _id;
    data["parentId"] = _parentId;
    data["dateUpdated"] = _dateUpdated;
    data["dateCreated"] = _dateCreated;
    data["memberType"] = _memberType;
    data["referralCode"] = _referralCode;
    data["campaignId"] = _campaignId;
    return data;
  }

  String get id => _id!;

  set id(String id) {
    _id = id;
  }

  String get parentId => _parentId!;

  set parentId(String parentId) {
    _parentId = parentId;
  }

  DateTime get dateUpdated => _dateUpdated!;
  set dateUpdated(DateTime dateUpdated) {
    _dateUpdated = dateUpdated;
  }

  DateTime get dateCreated => _dateCreated!;
  set dateCreated(DateTime dateCreated) {
    _dateCreated = dateCreated;
  }

  String get memberType => _memberType!;

  set memberType(String memberType) {
    _memberType = memberType;
  }

  String get referralCode => _referralCode!;

  set referralCode(String referralCode) {
    _referralCode = referralCode;
  }

  int get campaignId => _campaignId!;

  set campaignId(int campaignId) {
    _campaignId = campaignId;
  }
}

class StarReferralList {
  final List<PaycoolReferral> starReferralsList;
  StarReferralList({required this.starReferralsList});

  factory StarReferralList.fromJson(List<dynamic> parsedJson) {
    List<PaycoolReferral> starReferralsListFromApi = [];
    starReferralsListFromApi =
        parsedJson.map((i) => PaycoolReferral.fromJson(i)).toList();
    return StarReferralList(starReferralsList: starReferralsListFromApi);
  }
}
