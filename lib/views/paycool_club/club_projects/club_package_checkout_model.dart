import 'package:decimal/decimal.dart';

import '../club_models/club_params_model.dart';

class ClubPackageCheckout {
  List<RewardDetails>? rewardDetails;
  List<ClubParams>? clubParams;

  ClubPackageCheckout({this.rewardDetails, this.clubParams});

  ClubPackageCheckout.fromJson(Map<String, dynamic> json) {
    if (json['rewardDetails'] != null) {
      rewardDetails = <RewardDetails>[];
      json['rewardDetails'].forEach((v) {
        rewardDetails!.add(RewardDetails.fromJson(v));
      });
    }
    if (json['params'] != null) {
      clubParams = <ClubParams>[];
      json['params'].forEach((v) {
        clubParams!.add(ClubParams.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (rewardDetails != null) {
      data['rewardDetails'] = rewardDetails!.map((v) => v.toJson()).toList();
    }
    if (clubParams != null) {
      data['params'] = clubParams!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RewardDetails {
  String? type;
  String? user;
  Decimal? value;

  RewardDetails({this.type, this.user, this.value});

  RewardDetails.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    user = json['user'];
    value = Decimal.parse(json['value'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['user'] = user;
    data['value'] = value;
    return data;
  }
}

// class ClubPackageCheckoutList {
//   final List<ClubPackageCheckout> paycoolReferralList;
//   ClubPackageCheckoutList({this.paycoolReferralList});

//   factory ClubPackageCheckoutList.fromJson(List<dynamic> parsedJson) {
//     List<ClubPackageCheckout> paycoolReferralsListFromApi = [];
//     paycoolReferralsListFromApi =
//         parsedJson.map((i) => ClubPackageCheckout.fromJson(i)).toList();
//     return ClubPackageCheckoutList(
//         paycoolReferralList: paycoolReferralsListFromApi);
//   }
//}

