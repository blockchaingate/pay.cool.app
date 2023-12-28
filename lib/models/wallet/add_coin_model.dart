// To parse this JSON data, do
//
//     final addCoinModel = addCoinModelFromJson(jsonString);

import 'dart:convert';

List<AddCoinModel> addCoinModelFromJson(String str) => List<AddCoinModel>.from(
    json.decode(str).map((x) => AddCoinModel.fromJson(x)));

String addCoinModelToJson(List<AddCoinModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AddCoinModel {
  String? id;
  Token? token;
  int? v;

  AddCoinModel({
    this.id,
    this.token,
    this.v,
  });

  factory AddCoinModel.fromJson(Map<String, dynamic> json) => AddCoinModel(
        id: json["_id"],
        token: json["token"] == null ? null : Token.fromJson(json["token"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "token": token?.toJson(),
        "__v": v,
      };
}

class Token {
  String? id;
  String? chain;
  String? tokenId;
  String? name;
  String? symbol;
  int? decimals;
  String? image;
  int? v;
  String? url;

  Token({
    this.id,
    this.chain,
    this.tokenId,
    this.name,
    this.symbol,
    this.decimals,
    this.image,
    this.v,
    this.url,
  });

  factory Token.fromJson(Map<String, dynamic> json) => Token(
        id: json["_id"],
        chain: json["chain"],
        tokenId: json["id"],
        name: json["name"],
        symbol: json["symbol"],
        decimals: json["decimals"],
        image: json["image"],
        v: json["__v"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "chain": chain,
        "id": tokenId,
        "name": name,
        "symbol": symbol,
        "decimals": decimals,
        "image": image,
        "__v": v,
        "url": url,
      };
}
