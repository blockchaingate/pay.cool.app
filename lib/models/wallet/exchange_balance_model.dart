import 'package:flutter/widgets.dart';
import 'package:paycool/utils/number_util.dart';

import '../../environments/coins.dart' as coin_list;

class ExchangeBalanceModel {
  String ticker;
  int coinType;
  double unlockedAmount;
  double lockedAmount;

  ExchangeBalanceModel(
      {required this.ticker,
      required this.coinType,
      required this.unlockedAmount,
      required this.lockedAmount}) {}

  factory ExchangeBalanceModel.fromJson(Map<String, dynamic> json) {
    var type = json['coinType'];
    String? tickerName;
    if (type != null) {
      tickerName = coin_list.newCoinTypeMap[type];
      tickerName ??= '';
      debugPrint(
          'Ticker Name -- $tickerName --- coin type ${json['coinType']}');
    }

    return ExchangeBalanceModel(
        ticker: tickerName!,
        coinType: json['coinType'],
        unlockedAmount:
            NumberUtil.rawStringToDecimal(json['unlockedAmount'].toString())
                .toDouble(),
        lockedAmount:
            NumberUtil.rawStringToDecimal(json['lockedAmount'].toString())
                .toDouble());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ticker'] = ticker;
    data['coinType'] = coinType;
    data['unlockedAmount'] = unlockedAmount;
    data['lockedAmount'] = lockedAmount;

    return data;
  }
}

class ExchangeBalanceModelList {
  final List<ExchangeBalanceModel> balances;
  ExchangeBalanceModelList({required this.balances});

  factory ExchangeBalanceModelList.fromJson(List<dynamic> parsedJson) {
    List<ExchangeBalanceModel> balances = [];
    balances = parsedJson.map((i) => ExchangeBalanceModel.fromJson(i)).toList();
    return ExchangeBalanceModelList(balances: balances);
  }
}
