class PaycoolDashboard {
  double _totalPaycoolAssets;
  String _memberType;
  String _dateCreated;
  int _memberTypeCode;

  PaycoolDashboard(
      {double totalPaycoolAssets,
      String memberType,
      String dateCreated,
      int memberTypeCode}) {
    _totalPaycoolAssets = totalPaycoolAssets ?? 0.0;

    _memberType = memberType ?? '';

    _dateCreated = dateCreated ?? '';
    _memberTypeCode = memberTypeCode;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalPaycoolAssets'] = _totalPaycoolAssets;
    data['memberType'] = _memberType;
    data["dateCreated"] = _dateCreated;
    data["memberTypeCode"] = _memberTypeCode;
    return data;
  }

  factory PaycoolDashboard.fromJson(Map<String, dynamic> json) {
    var member = json['memberType'].toString();

    var date = json['dateCreated'];
    if (date != null) date = date.substring(0, 10);
    String mt = '';
    if (member == '1') {
      // mt = 'Key Node';
      mt = 'Key Node(VIP)';
    }
    if (member == '2') {
      // mt = 'Consumer';
      mt = 'Basic Member';
    }
    if (member == '3') {
      mt = 'Merchant';
    }
    return PaycoolDashboard(
        totalPaycoolAssets: double.parse(json['total7StarAssets'].toString()),
        memberType: mt,
        dateCreated: date,
        memberTypeCode: json['memberType']);
  }

  double get totalPaycoolAssets => _totalPaycoolAssets;
  set totalPaycoolAssets(double totalPaycoolAssets) {
    _totalPaycoolAssets = totalPaycoolAssets;
  }

  String get memberType => _memberType;
  set memberType(String memberType) {
    _memberType = memberType;
  }

  String get dateCreated => _dateCreated;
  set dateCreated(String dateCreated) {
    _dateCreated = dateCreated;
  }

  int get memberTypeCode => _memberTypeCode;
  set memberTypeCode(int memberTypeCode) {
    _memberTypeCode = memberTypeCode;
  }
}
