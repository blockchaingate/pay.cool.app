class UserSettings {
  int? id;
  String? language;
  String? theme;
  Map<String, String>? walletBalancesBody;
  // List<String> _favWalletCoins;
  // bool _isFavCoinTabSelected;

  UserSettings({
    this.id,
    this.language,
    this.theme,
    this.walletBalancesBody,
    //   List<String> favWalletCoins,
    //  bool isFavCoinTabSelected
  });
  Map<String, dynamic> toJson() => {
        'id': id,
        'language': language,
        'theme': theme,
        'walletBalancesBody': walletBalancesBody,
        // 'favWalletCoins': _favWalletCoins,
        // 'isFavCoinTabSelected': _isFavCoinTabSelected
      };

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
        id: json['id'] as int,
        language: json['language'] as String,
        theme: json['json'] as String,
        walletBalancesBody: json['walletBalancesBody']
        // favWalletCoins: json['favWalletCoins'],
        // isFavCoinTabSelected: json['isFavCoinTabSelected'])
        );
  }

  // Map<String, String> get walletBalancesBody => _walletBalancesBody;
  // set walletBalancesBody(Map<String, String> walletBalancesBody) {
  //   this._walletBalancesBody = walletBalancesBody;
  // }

  // bool get isFavCoinTabSelected => _isFavCoinTabSelected;
  // set isFavCoinTabSelected(bool isFavCoinTabSelected) {
  //   this._isFavCoinTabSelected = isFavCoinTabSelected;
  // }
}
