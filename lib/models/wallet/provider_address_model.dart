import 'dart:convert';

ProviderAddressModel providerAddressModelFromJson(String str) =>
    ProviderAddressModel.fromJson(json.decode(str));

String providerAddressModelToJson(ProviderAddressModel data) =>
    json.encode(data.toJson());

class ProviderAddressModel {
  String? name;
  String? address;

  ProviderAddressModel({
    this.name,
    this.address,
  });

  factory ProviderAddressModel.fromJson(Map<String, dynamic> json) =>
      ProviderAddressModel(
        name: json["name"],
        address: json["address"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "address": address,
      };
}
