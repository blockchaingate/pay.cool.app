import 'package:hive_flutter/hive_flutter.dart';
part 'multisig_wallet_model.g.dart';

@HiveType(typeId: 0)
class MultisigWalletModel extends HiveObject {
  @HiveField(0)
  String? chain;
  @HiveField(1)
  String? name;
  @HiveField(2)
  List<Owners>? owners;
  @HiveField(3)
  int? confirmations;
  @HiveField(4)
  String? signedRawtx;
  @HiveField(5)
  String? txid;
  @HiveField(6)
  String? address;
  @HiveField(7)
  String? creator;
  @HiveField(8)
  String? status;

  MultisigWalletModel(
      {this.chain,
      this.name,
      this.owners,
      this.confirmations,
      this.signedRawtx,
      this.txid,
      this.address,
      this.creator,
      this.status});

  MultisigWalletModel.fromJson(Map<String, dynamic> json) {
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
    txid = json['txid'];
    address = json['address'];
    creator = json['creator'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['chain'] = chain;
    data['name'] = name;
    if (owners != null) {
      data['owners'] = owners!.map((v) => v.toJson()).toList();
    }
    data['confirmations'] = confirmations;
    data['txid'] = txid;
    data['address'] = address;
    data['creator'] = creator;
    data['status'] = status;
    data['rawtx'] = signedRawtx;
    return data;
  }
}

@HiveType(typeId: 1)
class Owners {
  @HiveField(0)
  String? name;
  @HiveField(1)
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
