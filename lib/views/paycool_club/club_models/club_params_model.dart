class ClubParams {
  String to;
  String data;

  ClubParams({this.to, this.data});

  ClubParams.fromJson(Map<String, dynamic> json) {
    to = json['to'];
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['to'] = to;
    data['data'] = data;
    return data;
  }
}
