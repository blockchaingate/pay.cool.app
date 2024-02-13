import 'dart:convert';

TokensBalanceModel tokensBalanceModelFromJson(String str) =>
    TokensBalanceModel.fromJson(json.decode(str));

String tokensBalanceModelToJson(TokensBalanceModel data) =>
    json.encode(data.toJson());

class TokensBalanceModel {
  String? native;
  Tokens? tokens;

  TokensBalanceModel({
    this.native,
    this.tokens,
  });

  factory TokensBalanceModel.fromJson(Map<String, dynamic> json) =>
      TokensBalanceModel(
        native: json["native"],
        tokens: json["tokens"] == null ? null : Tokens.fromJson(json["tokens"]),
      );

  Map<String, dynamic> toJson() => {
        "native": native,
        "tokens": tokens?.toJson(),
      };
}

class Tokens {
  List<String>? ids;
  List<dynamic>? balances;
  List<dynamic>? decimals;
  List<String>? symbols;

  Tokens({
    this.ids,
    this.balances,
    this.decimals,
    this.symbols,
  });

  factory Tokens.fromJson(Map<String, dynamic> json) => Tokens(
        ids: json["ids"] == null
            ? []
            : List<String>.from(json["ids"]!.map((x) => x)),
        balances: json["balances"] == null
            ? []
            : List<dynamic>.from(json["balances"]!.map((x) => x)),
        decimals: json["decimals"] == null
            ? []
            : List<dynamic>.from(json["decimals"]!.map((x) => x)),
        symbols: json["symbols"] == null
            ? []
            : List<String>.from(json["symbols"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "ids": ids == null ? [] : List<dynamic>.from(ids!.map((x) => x)),
        "balances":
            balances == null ? [] : List<dynamic>.from(balances!.map((x) => x)),
        "decimals":
            decimals == null ? [] : List<dynamic>.from(decimals!.map((x) => x)),
        "symbols":
            symbols == null ? [] : List<dynamic>.from(symbols!.map((x) => x)),
      };
}
