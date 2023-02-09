class WalletTransactionHistory {
  String? tag;
  String? tickerName;
  String? date;
  String? quantity;
  List<Transactions>? transactions;

  WalletTransactionHistory(
      {this.tag, this.tickerName, this.date, this.quantity, this.transactions});

  WalletTransactionHistory.fromJson(Map<String, dynamic> json) {
    var localDate =
        DateTime.fromMillisecondsSinceEpoch(json['timestamp'] * 1000).toLocal();
    tag = json['action'];
    tickerName = json['coin'];
    date = localDate.toString().substring(0, localDate.toString().length - 4);
    quantity = json['quantity'];
    if (json['transactions'] != null) {
      transactions = <Transactions>[];
      json['transactions'].forEach((v) {
        transactions!.add(Transactions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['action'] = tag;
    data['coin'] = tickerName;
    data['timestamp'] = date;
    data['quantity'] = quantity;
    if (transactions != null) {
      data['transactions'] = transactions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Transactions {
  String? chain;
  String? transactionId;
  int? timestamp;
  String? status;

  Transactions({this.chain, this.transactionId, this.timestamp, this.status});

  Transactions.fromJson(Map<String, dynamic> json) {
    chain = json['chain'];
    transactionId = json['transactionId'];
    timestamp = json['timestamp'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['chain'] = chain;
    data['transactionId'] = transactionId;
    data['timestamp'] = timestamp;
    data['status'] = status;
    return data;
  }
}

class WalletTransactionHistoryList {
  final List<WalletTransactionHistory> walletTransactions;
  WalletTransactionHistoryList({required this.walletTransactions});

  factory WalletTransactionHistoryList.fromJson(List<dynamic> parsedJson) {
    List<WalletTransactionHistory> walletTransactions = [];
    walletTransactions =
        parsedJson.map((i) => WalletTransactionHistory.fromJson(i)).toList();
    return WalletTransactionHistoryList(walletTransactions: walletTransactions);
  }
}
