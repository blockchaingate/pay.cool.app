import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:paycool/enums/chain_enum.dart';
import 'package:paycool/models/wallet/token_model.dart';
part 'multi_wallet_model.g.dart';

@HiveType(typeId: 2)
class MultiWalletModel extends HiveObject {
  @HiveField(0)
  String? encryptedMnemonic;
  @HiveField(1)
  String? name;
  @HiveField(2)
  late List<TokenModel> selectedTokens;
  @HiveField(3)
  late List<WalletAddressModel> chainAddresses;
  @HiveField(4)
  bool? isSelected;

  MultiWalletModel(
      {this.encryptedMnemonic,
      this.name,
      List<TokenModel>? tokens,
      List<WalletAddressModel>? addresses,
      this.isSelected}) {
    chainAddresses = addresses ?? [];
    selectedTokens = tokens ?? [];
  }

  MultiWalletModel.fromJson(Map<String, dynamic> json) {
    encryptedMnemonic = json['chain'];
    name = json['name'];
    selectedTokens = (json['selectedTokens'] as List<dynamic>?)
            ?.map((v) => TokenModel.fromJson(v as Map<String, dynamic>))
            .toList() ??
        [];
    chainAddresses = (json['chainAddresses'] as List<dynamic>?)
            ?.map((item) =>
                WalletAddressModel.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];
    isSelected = json['isSelected'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['chain'] = encryptedMnemonic;
    data['name'] = name;

    data['selectedTokens'] = selectedTokens.map((v) => v.toJson()).toList();
    data['chainAddresses'] = chainAddresses.map((v) => v.toJson()).toList();
    data['isSelected'] = isSelected;
    return data;
  }

  bool isWalletAddressEmpty() => chainAddresses.isEmpty;

  bool isSelectedTokenListEmpty() => selectedTokens?.isEmpty ?? true;

  void addAddress(WalletAddressModel address) {
    chainAddresses.add(address);
  }

  void addAddresses(List<WalletAddressModel> addresses) {
    chainAddresses.addAll(addresses);
  }

  void removeAddress(WalletAddressModel address) {
    chainAddresses.remove(address);
  }

  void removeAddresses(List<WalletAddressModel> addresses) {
    chainAddresses.removeWhere((element) => addresses.contains(element));
  }

  walletBalanceBody() {
    Map<String, dynamic> wbb = {
      'btcAddress': getAddressByChain(Chain.btc),
      'ethAddress': getAddressByChain(Chain.eth),
      'fabAddress': getAddressByChain(Chain.fab),
      'ltcAddress': getAddressByChain(Chain.ltc),
      'dogeAddress': getAddressByChain(Chain.doge),
      'bchAddress': getAddressByChain(Chain.bch),
      'trxAddress': getAddressByChain(Chain.trx),
      "showEXGAssets": "true"
    };
    debugPrint('Multiwallet: wallet balance body $wbb');
    return wbb;
  }

  /// Use Chain.btc instead of 'btc'
  /// There is file named chain_enum.dart in enums folder
  /// which contains all the chains as enum
  String? getAddressByChain(Chain chain) {
    try {
      String chainName = chain.toString().split('.').last;
      return chainAddresses
          .firstWhere((wallet) => wallet.chain!.toLowerCase() == chainName)
          .address!;
    } catch (e) {
      debugPrint('Multiwallet model getAddressByChainName CATCH $e');
      return '';
    }
  }
}

// @HiveType(typeId: 3)
// class SelectedWalletTokenHiveModel {
//   @HiveField(0)
//   String? tickerName;
//   @HiveField(1)
//   String? chain;

//   SelectedWalletTokenHiveModel({this.tickerName, this.chain});

//   SelectedWalletTokenHiveModel.fromJson(Map<String, dynamic> json) {
//     tickerName = json['tickerName'];
//     chain = json['chain'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['tickerName'] = tickerName;
//     data['chain'] = chain;
//     return data;
//   }
// }

@HiveType(typeId: 3)
class WalletAddressModel {
  @HiveField(0)
  String? tickerName;
  @HiveField(1)
  String? address;
  @HiveField(2)
  String? chain;

  WalletAddressModel(
      {this.tickerName = '', this.address = '', this.chain = ''});

  WalletAddressModel.fromJson(Map<String, dynamic> json) {
    tickerName = json['name'];
    address = json['address'];
    chain = json['chain'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = tickerName;
    data['address'] = address;
    data['chain'] = chain;
    return data;
  }
}
// can you please check this file
// Path: lib/views/wallet/wallet_setup/multi_wallet_model.dart
