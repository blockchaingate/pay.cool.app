import 'package:decimal/decimal.dart';

class MultisigTransactionHashModel {
  String? chain;
  String? nonce;
  String? to;
  String? tokenId;
  Decimal? amount;
  int? decimals;
  String? address;

  MultisigTransactionHashModel(
      {this.chain,
      this.nonce,
      this.to,
      this.tokenId,
      this.amount,
      this.decimals,
      this.address});

  MultisigTransactionHashModel.fromJson(Map<String, dynamic> json) {
    chain = json['chain'];
    nonce = json['nonce'];
    to = json['to'];
    tokenId = json['tokenId'];
    amount = json['amount'];
    decimals = json['decimals'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['chain'] = chain;
    data['nonce'] = nonce;
    data['to'] = to;
    data['tokenId'] = tokenId;
    data['amount'] = amount;
    data['decimals'] = decimals;
    data['address'] = address;
    return data;
  }
}
