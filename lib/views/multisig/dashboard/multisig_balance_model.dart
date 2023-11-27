import 'package:paycool/utils/number_util.dart';

class MultisigBalanceModel {
  String? native;
  Tokens? tokens;

  MultisigBalanceModel({this.native, this.tokens});

  MultisigBalanceModel.fromJson(Map<String, dynamic> json) {
    native = NumberUtil.rawStringToDecimal(json['native'], decimalPrecision: 18)
        .toString();
    tokens = json['tokens'] != null && json['tokens']['ids'] != null
        ? Tokens.fromJson(json['tokens'])
        : Tokens(ids: [], balances: [], decimals: [], tickers: []);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['native'] = native;
    if (tokens != null) {
      data['tokens'] = tokens!.toJson();
    }
    return data;
  }
}

class Tokens {
  List<String>? ids;
  List<String>? balances;
  List<String>? decimals;
  List<String>? tickers;

  Tokens({this.ids, this.balances, this.decimals, this.tickers});

  Tokens.fromJson(Map<String, dynamic> json) {
    var idList = json['ids'].cast<String>();
    var decimalList = json['decimals'] == null
        ? List<String>.generate(idList!.length, (index) => '18')
        : json['decimals'].cast<String>();

    var bals = json['balances'] as List;
    for (var i = 0; i < bals.length; i++) {
      bals[i] = NumberUtil.rawStringToDecimal(bals[i],
              decimalPrecision: int.parse(decimalList[i]))
          .toString();
    }

    ids = idList;
    decimals = decimalList;
    balances = json['balances'].cast<String>();
    tickers = json['tickers'] == null
        ? List<String>.generate(ids!.length, (index) => '')
        : json['tickers'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ids'] = ids;
    data['balances'] = balances;
    data['decimals'] = decimals;
    data['tickers'] = tickers;
    return data;
  }
}
