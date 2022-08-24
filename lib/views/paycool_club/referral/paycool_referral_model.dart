// {
//     _id: String; // wallet EXG address as _id, unique.
//     memberType: String;  // 1-KeyNode, 2-consumer, 3-merchant
//     referralCode: String;  // in case use referralCode instead of my wallet address. didn't use currently
//     parentId: String;  // Referral wallet EXG address
//     campaignId: Number; // 2 person, may have different referal relation in different campaign. // currently not used.
//     dateUpdated: Date,
//     dateCreated: { type: Date, default: Date.now }
// }

class PaycoolReferral {
  String _id; //wallet FAB or EXG address as _id, unique
  String _parentId; // Referral wallet EXG address

  String _dateCreated;

  int _downlineReferralCount;
  String _smartContractAdd;

  PaycoolReferral(
      {String id,
      String parentId,
      String dateCreated,
      String memberType,
      int downlineReferralCount,
      String smartContractAdd}) {
    _id = id;
    _parentId = parentId;
    _dateCreated = dateCreated;
    _downlineReferralCount = downlineReferralCount ?? 0;
    _smartContractAdd = smartContractAdd ?? '';
  }

  factory PaycoolReferral.fromJson(Map<String, dynamic> json) {
    var smartContractAddress = json['smartContractAdd'] ?? '';
    return PaycoolReferral(
        id: json['id'] ?? json['_id'],
        parentId: json['parentId'],
        dateCreated: json['dateCreated'],
        smartContractAdd: smartContractAddress);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = _id;
    data["parentId"] = _parentId;
    data["dateCreated"] = _dateCreated;
    data['downlineReferralCount'] = _downlineReferralCount;
    data['smartContractAdd'] = _smartContractAdd;
    return data;
  }

  String get id => _id;

  set id(String id) {
    _id = id;
  }

  String get parentId => _parentId;

  set parentId(String parentId) {
    _parentId = parentId;
  }

  String get dateCreated => _dateCreated;
  set dateCreated(String dateCreated) {
    _dateCreated = dateCreated;
  }

  int get downlineReferralCount => _downlineReferralCount;

  set downlineReferralCount(int downlineReferralCount) {
    _downlineReferralCount = downlineReferralCount;
  }

  String get smartContractAdd => _smartContractAdd;
  set smartContractAdd(String smartContractAdd) {
    _smartContractAdd = smartContractAdd;
  }
}

class PaycoolReferralList {
  final List<PaycoolReferral> paycoolReferralList;
  PaycoolReferralList({this.paycoolReferralList});

  factory PaycoolReferralList.fromJson(List<dynamic> parsedJson) {
    List<PaycoolReferral> paycoolReferralsListFromApi = [];
    paycoolReferralsListFromApi =
        parsedJson.map((i) => PaycoolReferral.fromJson(i)).toList();
    return PaycoolReferralList(
        paycoolReferralList: paycoolReferralsListFromApi);
  }
}
