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

import 'package:flutter/material.dart';

// Wallet Features Model

class WalletFeatureName {
  String name;
  IconData icon;
  String route;
  Color shadowColor;

  WalletFeatureName(this.name, this.icon, this.route, this.shadowColor);
}

// Wallet Model

class WalletInfo {
  int? id;
  String? name;
  String? tickerName;
  String? tokenType;
  String? address;
  double? lockedBalance;
  double? availableBalance;
  double? usdValue;
  double? inExchange;

  WalletInfo({
    this.id,
    this.tickerName,
    this.tokenType,
    this.address,
    this.lockedBalance,
    this.availableBalance,
    this.usdValue,
    this.name,
    this.inExchange,
  });

  factory WalletInfo.fromJson(Map<String, dynamic> json) {
    return WalletInfo(
      id: json['id'] as int,
      tickerName: json['tickerName'] as String,
      tokenType: json['tokenType'] as String,
      address: json['address'] as String,
      lockedBalance: json['lockedBalance'],
      availableBalance: json['availableBalance'] as double,
      usdValue: json['usdValue'] as double,
      name: json['name'] as String,
      inExchange: json['inExchange'] as double,
    );
  }

  // To json

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['tickerName'] = tickerName;
    data['tokenType'] = tokenType;
    data['address'] = address;
    data['lockedBalance'] = lockedBalance;
    data['availableBalance'] = availableBalance;
    data['usdValue'] = usdValue;
    data['name'] = name;
    data['inExchange'] = inExchange;
    return data;
  }
}

class WalletInfoList {
  final List<WalletInfo> wallets;
  WalletInfoList({required this.wallets});

  factory WalletInfoList.fromJson(List<dynamic> parsedJson) {
    List<WalletInfo> wallets = [];
    wallets = parsedJson.map((i) => WalletInfo.fromJson(i)).toList();
    return WalletInfoList(wallets: wallets);
  }
}
