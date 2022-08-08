class UserSettings {
  int _id;
  String _language;
  String _theme;
  Map<String, String> _walletBalancesBody;
  // List<String> _favWalletCoins;
  // bool _isFavCoinTabSelected;

  UserSettings({
    int id,
    String language,
    String theme,
    Map<String, String> walletBalancesBody,
    //   List<String> favWalletCoins,
    //  bool isFavCoinTabSelected
  }) {
    _id = id;
    _language = language ?? '';
    _theme = theme ?? '';
    _walletBalancesBody = walletBalancesBody;
    // this._favWalletCoins = favWalletCoins;
    // this._isFavCoinTabSelected = isFavCoinTabSelected;
  }

  Map<String, dynamic> toJson() => {
        'id': _id,
        'language': _language,
        'theme': _theme,
        'walletBalancesBody': _walletBalancesBody,
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

  int get id => _id;
  set id(int id) {
    _id = id;
  }

  String get language => _language;
  set language(String language) {
    _language = language;
  }

  String get theme => _theme;
  set theme(String theme) {
    _theme = theme;
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
