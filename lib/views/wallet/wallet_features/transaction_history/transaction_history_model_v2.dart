import 'package:paycool/utils/string_util.dart';

class Transaction {
  String chain;
  final String transactionId;
  final int? timestamp;
  final String status;

  Transaction({
    required this.chain,
    required this.transactionId,
    this.timestamp,
    required this.status,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      chain: json['chain'] ?? '',
      transactionId: json['transactionId'] ?? '',
      timestamp: json['timestamp'] ?? 0,
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chain': chain,
      'transactionId': transactionId,
      'timestamp': timestamp,
      'status': status,
    };
  }
}

class HistoryItem {
  final String action;
  String coin;
  final int timestamp;
  final String quantity;
  final List<Transaction> transactions;

  HistoryItem({
    required this.action,
    required this.coin,
    required this.timestamp,
    required this.quantity,
    required this.transactions,
  });

  date() {
    return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000)
        .toLocal()
        .toString()
        .substring(0, date.toString().length - 4);
  }

  String setFilteredDate(String date) {
    return formatStringDateV2(date);
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      action: json['action'].toString().toLowerCase(),
      coin: json['coin'] ?? '',
      timestamp: json['timestamp'] ?? 0,
      quantity: json['quantity'] ?? '',
      transactions: List<Transaction>.from(
        json['transactions']
            .map((transaction) => Transaction.fromJson(transaction)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'coin': coin,
      'timestamp': timestamp,
      'quantity': quantity,
      'transactions':
          transactions.map((transaction) => transaction.toJson()).toList(),
    };
  }
}

class TransactionHistoryEventsData {
  final int pageNum;
  final int totalCount;
  final List<HistoryItem> history;

  TransactionHistoryEventsData({
    required this.pageNum,
    required this.totalCount,
    required this.history,
  });

  factory TransactionHistoryEventsData.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryEventsData(
      pageNum: json['pageNum'],
      totalCount: json['totalCount'],
      history: List<HistoryItem>.from(
        json['history'].map((item) => HistoryItem.fromJson(item)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pageNum': pageNum,
      'totalCount': totalCount,
      'history': history.map((item) => item.toJson()).toList(),
    };
  }
}

class TransactionHistoryEvents {
  final bool? success;
  final TransactionHistoryEventsData? data;

  TransactionHistoryEvents({
    this.success,
    this.data,
  });

  factory TransactionHistoryEvents.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryEvents(
      success: json['success'],
      data: TransactionHistoryEventsData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data!.toJson(),
    };
  }
}
