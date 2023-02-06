import 'transactions.dart';

class TransactionHistoryEvents {
  String action;
  String coin;
  int timestamp;
  String quantity;
  List<Transactions> transactions;

  TransactionHistoryEvents({
    required this.action,
    required this.coin,
    required this.timestamp,
    required this.quantity,
    required this.transactions,
  });

  @override
  String toString() {
    return 'TransactionHistoryEvents(action: $action, coin: $coin, timestamp: $timestamp, quantity: $quantity, transactions: $transactions)';
  }

  factory TransactionHistoryEvents.fromJson(Map<String, dynamic> json) {
    var t = json['transactions'] as List<Transactions>;
    var txs = t.map((e) {
      Transactions.fromJson(e as Map<String, dynamic>);
    }).toList();
    return TransactionHistoryEvents(
      action: json['action'] as String,
      coin: json['coin'] as String,
      timestamp: json['timestamp'] as int,
      quantity: json['quantity'] as String,
      transactions: txs as List<Transactions>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'coin': coin,
      'timestamp': timestamp,
      'quantity': quantity,
      'transactions': transactions?.map((e) => e?.toJson())?.toList(),
    };
  }
}

class TransactionHistoryEventsList {
  final List<TransactionHistoryEvents> transactions;
  TransactionHistoryEventsList({required this.transactions});

  factory TransactionHistoryEventsList.fromJson(List<dynamic> parsedJson) {
    List<TransactionHistoryEvents> transactions = [];
    transactions =
        parsedJson.map((i) => TransactionHistoryEvents.fromJson(i)).toList();
    return TransactionHistoryEventsList(transactions: transactions);
  }
}
