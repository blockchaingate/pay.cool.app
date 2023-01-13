class LpLockerModel {
  String sId;
  String txid;
  //type: 0, package,  type 1: monthly fee, type 2: annual fee, type 3: global reward
  int type;
  String address;
  String id;
  String user;
  String amount;
  int timestamp;
  int status;
  int iV;

  LpLockerModel(
      {this.sId,
      this.txid,
      this.type,
      this.address,
      this.id,
      this.user,
      this.amount,
      this.timestamp,
      this.status,
      this.iV});

  LpLockerModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    txid = json['txid'];
    type = json['type'];
    address = json['address'];
    id = json['id'];
    user = json['user'];
    amount = json['amount'];
    timestamp = json['timestamp'];
    status = json['status'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['txid'] = txid;
    data['type'] = type;
    data['address'] = address;
    data['id'] = id;
    data['user'] = user;
    data['amount'] = amount;
    data['timestamp'] = timestamp;
    data['status'] = status;
    data['__v'] = iV;
    return data;
  }
}
