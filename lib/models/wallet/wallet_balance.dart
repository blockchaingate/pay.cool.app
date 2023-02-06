import '../../utils/number_util.dart';

class UsdValue {
  double? usd;

  UsdValue({this.usd});

  factory UsdValue.fromJson(Map<String, dynamic> json) {
    double jsonUsd = json['USD'].toDouble();

    return UsdValue(usd: jsonUsd);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['USD'] = usd;
    return data;
  }
}

/*----------------------------------------------------------------------
                        deposit err
----------------------------------------------------------------------*/

class DepositErr {
  int? coinType;
  String? transactionID;
  double? amount;
  String? v;
  String? r;
  String? s;

  DepositErr(
      {this.coinType, this.transactionID, this.amount, this.v, this.r, this.s});

  factory DepositErr.fromJson(Map<String, dynamic> json) {
    return DepositErr(
        coinType: json['coinType'],
        transactionID: json['transactionID'],
        amount: json['amount'] != null
            ? NumberUtil().parsedDouble(json['amount'])
            : 0.0,
        v: json['v'],
        r: json['r'],
        s: json['s']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['coinType'] = coinType;
    data['transactionID'] = transactionID;
    data['amount'] = amount;
    data['v'] = v;
    data['r'] = r;
    data['s'] = s;
    return data;
  }
}

/*----------------------------------------------------------------------
                    Wallet Balance
----------------------------------------------------------------------*/

class WalletBalance {
  String? coin;
  double? balance;
  double? unconfirmedBalance;
  double? lockBalance;
  UsdValue? usdValue;
  List<DepositErr>? depositErr;
  double? unlockedExchangeBalance;
  double? lockedExchangeBalance;

  WalletBalance(
      {this.coin,
      this.balance,
      this.unconfirmedBalance,
      this.lockBalance,
      this.usdValue,
      this.depositErr,
      this.unlockedExchangeBalance,
      this.lockedExchangeBalance});

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    List<DepositErr> depositErrList = [];
    var depositErrFromJsonAsList = json['depositErr'] as List;

    depositErrList =
        depositErrFromJsonAsList.map((e) => DepositErr.fromJson(e)).toList();

    double ub = NumberUtil().parsedDouble(json['unconfirmedBalance']);
    if (ub.isNegative) {
      ub = 0.0;
    }
    UsdValue usdVal;
    if (json['usdValue'] != null) {
      usdVal = UsdValue.fromJson(json['usdValue']);
    } else {
      usdVal = UsdValue(usd: 0.0);
    }
    return WalletBalance(
      coin: json['coin'],
      balance: json['balance'] != null
          ? (NumberUtil().parsedDouble(json['balance']))
          : 0.0,
      unconfirmedBalance: json['unconfirmedBalance'] != null ? ub : 0.0,
      lockBalance: json['lockBalance'] != null
          ? (NumberUtil().parsedDouble(json['lockBalance']))
          : 0.0,
      usdValue: usdVal,
      depositErr: depositErrList,
      unlockedExchangeBalance: json['unlockedExchangeBalance'] != null
          ? (NumberUtil().parsedDouble(json['unlockedExchangeBalance']))
          : 0.0,
      lockedExchangeBalance: json['lockedExchangeBalance'] != null
          ? (NumberUtil().parsedDouble(json['lockedExchangeBalance']))
          : 0.0,
    );
  }

// To json
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['coin'] = coin;
    data['balance'] = balance;
    data['unconfirmedBalance'] = unconfirmedBalance;
    data['lockBalance'] = lockBalance;

    data['usdValue'] = usdValue?.toJson();

    data['depositErr'] = depositErr?.map((v) => v.toJson()).toList();

    data['unlockedExchangeBalance'] = unlockedExchangeBalance;
    data['lockedExchangeBalance'] = lockedExchangeBalance;
    return data;
  }
}

class WalletBalanceList {
  final List<WalletBalance> walletBalances;
  WalletBalanceList({required this.walletBalances});

  factory WalletBalanceList.fromJson(List<dynamic> parsedJson) {
    List<WalletBalance> balanceList = <WalletBalance>[];
    balanceList = parsedJson.map((i) => WalletBalance.fromJson(i)).toList();
    return WalletBalanceList(walletBalances: balanceList);
  }
}
