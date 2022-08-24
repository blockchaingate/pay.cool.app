class StoreMerchantModel {
  String sId;
  int status;
  Name name;
  String phone;
  int version;
  int lockedDays;
  String website;
  String openTime;
  String closeTime;
  String coin;
  int giveAwayRate;
  int taxRate;
  String refAddress;
  String image;
  String feeChargerSmartContractAddress;
  String owner;
  String objectId;
  bool hideOnStore;
  Merchant merchant;

  StoreMerchantModel(
      {this.sId,
      this.status,
      this.name,
      this.phone,
      this.version,
      this.lockedDays,
      this.website,
      this.openTime,
      this.closeTime,
      this.coin,
      this.giveAwayRate,
      this.taxRate,
      this.refAddress,
      this.image,
      this.feeChargerSmartContractAddress,
      this.owner,
      this.objectId,
      this.hideOnStore,
      this.merchant});

  StoreMerchantModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'] ?? '';
    status = json['status'] ?? 0;
    name = json['name'] != null ? Name.fromJson(json['name']) : null;
    phone = json['phone'];
    version = json['version'];
    lockedDays = json['lockedDays'];
    website = json['website'];
    openTime = json['openTime'];
    closeTime = json['closeTime'];
    coin = json['coin'];
    giveAwayRate = json['giveAwayRate'];
    taxRate = json['taxRate'];
    refAddress = json['refAddress'];
    image = json['image'];
    feeChargerSmartContractAddress = json['feeChargerSmartContractAddress'];
    owner = json['owner'];
    objectId = json['objectId'];
    hideOnStore = json['hideOnStore'] ?? false;
    merchant =
        json['merchant'] != null ? Merchant.fromJson(json['merchant']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['status'] = status;
    if (name != null) {
      data['name'] = name.toJson();
    }
    data['phone'] = phone;
    data['version'] = version;
    data['lockedDays'] = lockedDays;
    data['website'] = website;
    data['openTime'] = openTime;
    data['closeTime'] = closeTime;
    data['coin'] = coin;
    data['giveAwayRate'] = giveAwayRate;
    data['taxRate'] = taxRate;
    data['refAddress'] = refAddress;
    data['image'] = image;
    data['feeChargerSmartContractAddress'] = feeChargerSmartContractAddress;
    data['owner'] = owner;
    data['objectId'] = objectId;
    data['hideOnStore'] = hideOnStore;
    if (merchant != null) {
      data['merchant'] = merchant.toJson();
    }
    return data;
  }
}

class Name {
  String en;
  String sc;

  Name({this.en, this.sc});

  Name.fromJson(Map<String, dynamic> json) {
    en = json['en'];
    sc = json['sc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['en'] = en;
    data['sc'] = sc;
    return data;
  }
}

class Merchant {
  String sId;
  String owner;
  Name addressLan;
  Name businessContentsLan;
  String closeTime;
  Name contactNameLan;
  String email;
  String fax;
  Name nameLan;
  String openTime;
  String phone;
  String website;

  Merchant(
      {this.sId,
      this.owner,
      this.addressLan,
      this.businessContentsLan,
      this.closeTime,
      this.contactNameLan,
      this.email,
      this.fax,
      this.nameLan,
      this.openTime,
      this.phone,
      this.website});

  Merchant.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    owner = json['owner'];
    addressLan =
        json['addressLan'] != null ? Name.fromJson(json['addressLan']) : null;
    businessContentsLan = json['businessContentsLan'] != null
        ? Name.fromJson(json['businessContentsLan'])
        : null;
    closeTime = json['closeTime'];
    contactNameLan = json['contactNameLan'] != null
        ? Name.fromJson(json['contactNameLan'])
        : null;
    email = json['email'];
    fax = json['fax'];
    nameLan = json['nameLan'] != null ? Name.fromJson(json['nameLan']) : null;
    openTime = json['openTime'];
    phone = json['phone'];
    website = json['website'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['owner'] = owner;
    if (addressLan != null) {
      data['addressLan'] = addressLan.toJson();
    }
    if (businessContentsLan != null) {
      data['businessContentsLan'] = businessContentsLan.toJson();
    }
    data['closeTime'] = closeTime;
    if (contactNameLan != null) {
      data['contactNameLan'] = contactNameLan.toJson();
    }
    data['email'] = email;
    data['fax'] = fax;
    if (nameLan != null) {
      data['nameLan'] = nameLan.toJson();
    }
    data['openTime'] = openTime;
    data['phone'] = phone;
    data['website'] = website;
    return data;
  }
}
