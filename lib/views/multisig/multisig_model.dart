class MultisigModel {
  String? chain;
  String? name;
  List<Owners>? owners;
  int? confirmations;
  String? signedRawtx;

  MultisigModel(
      {this.chain,
      this.name,
      this.owners,
      this.confirmations,
      this.signedRawtx});

  MultisigModel.fromJson(Map<String, dynamic> json) {
    chain = json['chain'];
    name = json['name'];
    if (json['owners'] != null) {
      owners = <Owners>[];
      json['owners'].forEach((v) {
        owners!.add(Owners.fromJson(v));
      });
    }
    confirmations = json['confirmations'];
    signedRawtx = json['rawtx'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['chain'] = chain;
    data['name'] = name;
    if (owners != null) {
      data['owners'] = owners!.map((v) => v.toJson()).toList();
    }
    data['confirmations'] = confirmations;
    data['rawtx'] = signedRawtx;
    return data;
  }
}

class Owners {
  String? name;
  String? address;

  Owners({this.name, this.address});

  Owners.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['address'] = address;
    return data;
  }
}
