// To parse this JSON data, do
//
//     final redPacketResponseModal = redPacketResponseModalFromJson(jsonString);

import 'dart:convert';

RedPacketResponseModal redPacketResponseModalFromJson(String str) =>
    RedPacketResponseModal.fromJson(json.decode(str));

String redPacketResponseModalToJson(RedPacketResponseModal data) =>
    json.encode(data.toJson());

class RedPacketResponseModal {
  bool? success;
  String? message;
  Data? data;

  RedPacketResponseModal({
    this.success,
    this.message,
    this.data,
  });

  factory RedPacketResponseModal.fromJson(Map<String, dynamic> json) =>
      RedPacketResponseModal(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  SignedMessage? signedMessage;

  Data({
    this.signedMessage,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        signedMessage: json["signedMessage"] == null
            ? null
            : SignedMessage.fromJson(json["signedMessage"]),
      );

  Map<String, dynamic> toJson() => {
        "signedMessage": signedMessage?.toJson(),
      };
}

class SignedMessage {
  String? messageHash;
  String? amount;
  String? originalAmount;
  String? token;
  String? v;
  String? r;
  String? s;
  String? signature;
  String? id;

  SignedMessage({
    this.messageHash,
    this.amount,
    this.originalAmount,
    this.token,
    this.v,
    this.r,
    this.s,
    this.signature,
    this.id,
  });

  factory SignedMessage.fromJson(Map<String, dynamic> json) => SignedMessage(
        messageHash: json["messageHash"],
        amount: json["amount"].toString(),
        originalAmount: json["originalAmount"].toString(),
        token: json["token"],
        v: json["v"],
        r: json["r"],
        s: json["s"],
        signature: json["signature"],
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "messageHash": messageHash,
        "amount": amount,
        "originalAmount": originalAmount,
        "token": token,
        "v": v,
        "r": r,
        "s": s,
        "signature": signature,
        "_id": id,
      };
}
