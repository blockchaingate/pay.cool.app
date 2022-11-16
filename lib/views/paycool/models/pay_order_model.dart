import 'package:decimal/decimal.dart';

class PayOrder {
  String orderId;
  Decimal qty;
  Decimal tax;
  Decimal price;
  String title;
  Decimal rebateRate;

  // {
  // 			"title": "b2-order",
  // 			"taxRate": 13,
  // 			"lockedDays": 66,
  // 			"rebateRate": 12,
  // 			"price": 1.2354,
  // 			"quantity": 1,
  // 			"_id": "635ab250f8ba77d673a32475"
  // 		}

  PayOrder(
      {this.orderId,
      this.qty,
      this.tax,
      this.price,
      this.title,
      this.rebateRate});

  PayOrder.fromJson(Map<String, dynamic> json) {
    orderId = json['_id'];
    title = json['title'];
    price = Decimal.parse(json['price'].toString());
    qty = Decimal.parse(json['quantity'].toString());
    tax = Decimal.parse(json['taxRate'].toString());
    rebateRate == Decimal.parse(json['rebateRate'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = orderId;
    data['qty'] = qty;
    data['taxRate'] = tax;
    data['rebateRate'] = rebateRate;
    data['title'] = title;

    return data;
  }
}
