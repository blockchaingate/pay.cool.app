class ScanToPayModel {
  String toAddress;
  String datAbiHex;

  ScanToPayModel({this.toAddress, this.datAbiHex});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['to'] = toAddress;
    data['data'] = datAbiHex;

    return data;
  }

  factory ScanToPayModel.fromJson(Map<String, dynamic> json) {
    return ScanToPayModel(
      toAddress: json['to'],
      datAbiHex: json['data'],
    );
  }
}
