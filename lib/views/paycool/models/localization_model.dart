class LocalizationModel {
  String en;
  String sc;

  LocalizationModel({this.en, this.sc});

  LocalizationModel.fromJson(Map<String, dynamic> json) {
    en = json['en'];
    sc = json['sc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['en'] = en;
    data['sc'] = sc;
    return data;
  }
}
