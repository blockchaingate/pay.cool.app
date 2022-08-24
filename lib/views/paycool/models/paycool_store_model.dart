import 'package:decimal/decimal.dart';
import 'package:paycool/utils/number_util.dart';

class StoreInfoModel {
  Name name;
  int status;
  String sId;
  String coin;
  Decimal giveAwayRate;
  Decimal taxRate;
  String refAddress;
  String image;
  String feeChargerSmartContractAddress;
  String phone;
  String owner;
  String objectId;

  StoreInfoModel(
      {this.name,
      this.status,
      this.sId,
      this.coin,
      this.giveAwayRate,
      this.taxRate,
      this.refAddress,
      this.image,
      this.feeChargerSmartContractAddress,
      this.phone,
      this.owner,
      this.objectId});

  StoreInfoModel.fromJson(Map<String, dynamic> json) {
    name = json['name'] != null ? Name.fromJson(json['name']) : null;
    status = json['status'];
    sId = json['_id'];
    coin = json['coin'];
    giveAwayRate =
        NumberUtil.convertStringToDecimal(json['giveAwayRate'].toString());
    taxRate = NumberUtil.convertStringToDecimal(json['taxRate'].toString());
    refAddress = json['refAddress'];
    image = json['image'];
    feeChargerSmartContractAddress = json['feeChargerSmartContractAddress'];
    phone = json['phone'];
    owner = json['owner'];
    objectId = json['objectId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (name != null) {
      data['name'] = name.toJson();
    }
    data['status'] = status;
    data['_id'] = sId;
    data['coin'] = coin;
    data['giveAwayRate'] = giveAwayRate;
    data['taxRate'] = taxRate;
    data['refAddress'] = refAddress;
    data['image'] = image;
    data['feeChargerSmartContractAddress'] = feeChargerSmartContractAddress;
    data["phone"] = phone;
    data['owner'] = owner;
    data['objectId'] = objectId;
    return data;
  }
}

class Name {
  String en;
  String sc;

  Name({this.en, this.sc});

  Name.fromJson(Map<String, dynamic> json) {
    en = json['en'] ?? "";
    sc = json['sc'] ?? en;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['en'] = en;
    data['sc'] = sc;
    return data;
  }
}
