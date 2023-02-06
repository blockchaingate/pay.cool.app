/*
* Copyright (c) 2020 Exchangily LLC
*
* Licensed under Apache License v2.0
* You may obtain a copy of the License at
*
*      https://www.apache.org/licenses/LICENSE-2.0
*
*----------------------------------------------------------------------
* Author: barry-ruprai@exchangily.com
*----------------------------------------------------------------------
*/

class TokenModel {
  int? id;
  int? decimal;
  String? coinName;
  String? chainName;
  String? tickerName;
  int? coinType;
  String? contract;
  String? minWithdraw;
  String? feeWithdraw;

  TokenModel(
      {this.id,
      this.decimal,
      this.coinName,
      this.tickerName,
      this.chainName,
      this.coinType,
      this.contract,
      this.minWithdraw,
      this.feeWithdraw});

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    var mw = json['minWithdraw'];
    String minWithdraw = mw.toString();

    var fw = json['feeWithdraw'];
    String feeWithdraw = fw.toString();

    return TokenModel(
        decimal: json['decimal'] as int,
        tickerName: json['tickerName'] as String,
        coinName: json['coinName'] as String,
        chainName: json['chainName'] as String,
        coinType: json['type'] as int,
        contract: json['contract'] as String,
        minWithdraw: minWithdraw,
        feeWithdraw: feeWithdraw);
  }

  // To json

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['decimal'] = decimal;
    data['tickerName'] = tickerName;
    data['coinName'] = coinName;
    data['chainName'] = chainName;
    data['type'] = coinType;
    data['contract'] = contract;
    data['minWithdraw'] = minWithdraw;
    data['feeWithdraw'] = feeWithdraw;
    return data;
  }

  void clear() {
    id = null;
    decimal = null;
    coinName = '';
    chainName = '';
    tickerName = '';
    coinType = null;
    contract = '';
    minWithdraw = '';
    feeWithdraw = '';
  }
}

class TokenList {
  final List<TokenModel> tokens;
  TokenList({required this.tokens});

  factory TokenList.fromJson(List<dynamic> parsedJson) {
    List<TokenModel> tokens = <TokenModel>[];
    tokens = parsedJson.map((i) => TokenModel.fromJson(i)).toList();
    return TokenList(tokens: tokens);
  }
}
