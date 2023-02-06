class JoinClubPaymentModel {
  String? toAddress;
  String? datAbiHex;

  JoinClubPaymentModel({this.toAddress, this.datAbiHex});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['to'] = toAddress;
    data['data'] = datAbiHex;

    return data;
  }

  factory JoinClubPaymentModel.fromJson(Map<String, dynamic> json) {
    return JoinClubPaymentModel(
      toAddress: json['to'],
      datAbiHex: json['data'],
    );
  }
}
