import 'package:decimal/decimal.dart';
import 'package:paycool/environments/coins.dart';
import 'package:paycool/utils/number_util.dart';
import 'package:paycool/utils/string_util.dart';
import 'package:paycool/views/paycool_club/club_projects/club_project_model.dart';

class PurchasedPackageHistory {
  String id;
  String smartContractAddress;
  String userAddress;
  String txid;
  int coinType;
  int status;
  Decimal amount;
  ClubProject project;
  String date;

  PurchasedPackageHistory(
      {this.id,
      this.smartContractAddress,
      this.userAddress,
      this.txid,
      this.coinType,
      this.status,
      this.amount,
      this.project,
      this.date});

  PurchasedPackageHistory.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    smartContractAddress = json['address'];
    userAddress = json['user'];
    txid = json['txid'];
    coinType = json['coinType'];
    status = json['type'];
    date = formatStringDateV3(json['dateCreated']);
    amount =
        Decimal.parse(NumberUtil.rawStringToDecimal(json['amount']).toString());
    project = json['projectPackage'] != null
        ? ClubProject.fromJson(json['projectPackage'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = id;
    data['address'] = smartContractAddress;
    data['user'] = userAddress;
    data['txid'] = txid;
    data['coinType'] = coinType;
    data['dateCreated'] = date;
    data['type'] = status;
    data['amount'] = amount;
    data['projectPackage'] = project;
    return data;
  }

  String get paidCoinTicker => newCoinTypeMap[coinType];
}

class PurchasedPackageHistoryList {
  final List<PurchasedPackageHistory> purchasedPackageHistoryList;
  PurchasedPackageHistoryList({this.purchasedPackageHistoryList});

  factory PurchasedPackageHistoryList.fromJson(List<dynamic> parsedJson) {
    List<PurchasedPackageHistory> purchasedPackageHistoryFromApi = [];
    purchasedPackageHistoryFromApi =
        parsedJson.map((i) => PurchasedPackageHistory.fromJson(i)).toList();
    return PurchasedPackageHistoryList(
        purchasedPackageHistoryList: purchasedPackageHistoryFromApi);
  }
}
