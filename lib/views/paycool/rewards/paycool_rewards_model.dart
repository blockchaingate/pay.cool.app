import 'package:exchangily_core/exchangily_core.dart';

class PayCoolRewardsModel {
  List<int> coinType;
  List<String> amount;
  List<String> txids;
  int status;
  String sId;
  String id;
  String address;
  String user;
  int releaseTime;
  String lockerCreator;
  String dateCreated;

  PayCoolRewardsModel(
      {this.coinType,
      this.amount,
      this.txids,
      this.status,
      this.sId,
      this.id,
      this.address,
      this.user,
      this.releaseTime,
      this.lockerCreator,
      this.dateCreated});

  PayCoolRewardsModel.fromJson(Map<String, dynamic> json) {
    coinType = json['coinType'].cast<int>();
    amount = json['amount'].cast<String>();
    txids = json['txids'].cast<String>();
    status = json['status'];
    sId = json['_id'];
    id = json['id'];
    address = json['address'];
    user = json['user'];
    releaseTime = json['releaseTime'];
    lockerCreator = json['lockerCreator'];
    dateCreated = json['dateCreated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['coinType'] = coinType;
    data['amount'] = amount;
    data['txids'] = txids;
    data['status'] = status;
    data['_id'] = sId;
    data['id'] = id;
    data['address'] = address;
    data['user'] = user;
    data['releaseTime'] = releaseTime;
    data['lockerCreator'] = lockerCreator;
    data['dateCreated'] = dateCreated;
    return data;
  }

  String releaseDateTimeString() {
    var date = dateFromMilliseconds(releaseTime);
    return formatStringDateV2(date.toString());
  }
}

class PayCoolRewardsModelList {
  final List<PayCoolRewardsModel> rewards;
  PayCoolRewardsModelList({this.rewards});

  factory PayCoolRewardsModelList.fromJson(List<dynamic> parsedJson) {
    List<PayCoolRewardsModel> rewards = [];
    rewards = parsedJson.map((i) => PayCoolRewardsModel.fromJson(i)).toList();
    return PayCoolRewardsModelList(rewards: rewards);
  }
}
