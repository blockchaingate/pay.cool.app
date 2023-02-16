import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:paycool/utils/number_util.dart';
import 'package:paycool/utils/string_util.dart';

class ClubRewardsArgs {
  List<Summary> summary;
  Map<String, Decimal>? rewardTokenPriceMap;
  Decimal totalRewardsDollarValue;
  ClubRewardsArgs(
      {required this.summary,
      this.rewardTokenPriceMap,
      required this.totalRewardsDollarValue});
}

class ClubDashboard {
  List<Summary>? summary;
  String? user;
  String? referral; // parentId
  int? status;

  ClubDashboard({this.summary, this.user, this.referral, this.status});

  ClubDashboard.fromJson(Map<String, dynamic> json) {
    int? intStatus;
    if (json['status'] != null) {
      var st = json['status'].toString();
      if (st.toString().contains('.')) {
        st = st.toString().split('.')[0];
      }
      intStatus = int.parse(st.toString());
    }
    var s = json['summary'] as List;
    if (s.isNotEmpty) {
      summary = <Summary>[];
      for (var v in s) {
        summary!.add(Summary.fromJson(v));
      }
    }
    user = json['user'];
    referral = json['referral'];
    status = intStatus;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (summary != null) {
      data['summary'] = summary!.map((v) => v.toJson()).toList();
    }
    data['user'] = user;
    data['referral'] = referral;
    data['status'] = status;
    return data;
  }

  Map<String, Decimal> totalFabRewardsV2() {
    Map<String, Decimal> result = {};

    for (var project in summary!) {
      if (project.totalReward != null) {
        for (var reward in project.totalReward!) {
          if (reward.coin == "FETDUSD-LP" || reward.coin == "UnknownCoin") {
            reward.amount =
                NumberUtil.rawStringToDecimal(reward.amount.toString());
          }
          result.addAll({reward.coin!: reward.amount!});
        }
      }
    }
    debugPrint('Club dashboard model: totalFabRewards-func -- $result');
    return result;
  }

  Map<String, Decimal> totalFabRewards() {
    Map<String, Decimal> result = {};
    var totalFabRewards = Decimal.zero;
    var totalFetRewards = Decimal.zero;
    var totalFetLpRewards = Decimal.zero;
    for (var project in summary!) {
      if (project.totalReward != null) {
        for (var reward in project.totalReward!) {
          if (reward.coin == 'FAB') {
            totalFabRewards += reward.amount!;
          }
          if (reward.coin == 'FET') {
            totalFetRewards += reward.amount!;
          }
          if (reward.coin == 'FETDUSD-LP') {
            if (reward.amount != null) {
              totalFetLpRewards +=
                  NumberUtil.rawStringToDecimal(reward.amount.toString());
            }
          }
        }
      }
    }
    result.addAll({
      'FAB': totalFabRewards,
      'FET': totalFetRewards,
      'FETLP': totalFetLpRewards
    });
    debugPrint('Club dashboard model: totalFabRewards-func -- $result');
    return result;
  }
}

class Summary {
  Project? project;
  Rewards? rewardDistribution;
  List<SummaryReward>? totalReward;
  String? referral; // parentId
  int? status;
  String? expiredAt;

  Summary(
      {this.project,
      this.rewardDistribution,
      this.referral,
      this.status,
      this.expiredAt});

  // int expiredProjectInDays() {
  //   var expiredDate = DateTime.parse(formatStringDateV3(expiredAt));
  //   var diff = expiredDate.difference(DateTime.now());
  //   return diff.inDays;
  // }

  // bool showExpiredProjectWarning() {
  //   bool res = false;
  //   if (expiredAt != null && expiredAt.isNotEmpty) {
  //     if (expiredProjectInDays() < 30) {
  //       res = true;
  //     } else {
  //       res = false;
  //     }
  //   }
  //   return res;
  // }

  Summary.fromJson(Map<String, dynamic> json) {
    var ea;
    if (json['expiredAt'] != null) {
      ea = json['expiredAt'];
    }
    // else {
    //   ea = formatStringDateV3("2023-01-20T16:44:40.663Z");
    // }

    int? intStatus;
    if (json['status'] != null) {
      var st = json['status'].toString();
      if (st.toString().contains('.')) {
        st = st.toString().split('.')[0];
      }
      intStatus = int.parse(st.toString());
    }
    project =
        json['project'] != null ? Project.fromJson(json['project']) : null;
    rewardDistribution =
        json['rewards'] != null ? Rewards.fromJson(json['rewards']) : null;
    totalReward = json['total'] != null
        ? (json['total'] as List).map((e) => SummaryReward.fromJson(e)).toList()
        : null;
    referral = json['referral'];
    status = intStatus;
    expiredAt = ea;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (project != null) {
      data['project'] = project!.toJson();
    }
    if (rewardDistribution != null) {
      data['rewards'] = rewardDistribution!.toJson();
    }
    if (totalReward != null) {
      data['total'] = totalReward!.map((e) => e.toJson()).toList();
    }
    data['referral'] = referral;
    data['status'] = status;
    data['expiredAt'] = expiredAt;
    return data;
  }
}

class Project {
  int? id;
  String? en;
  String? sc;

  Project({this.en, this.sc, this.id});

  Project.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    en = json['en'];
    sc = json['sc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['en'] = en;
    data['sc'] = sc;
    return data;
  }
}

class Rewards {
  List<SummaryReward>? marketing;
  List<SummaryReward>? gap;
  List<SummaryReward>? leadership;
  List<SummaryReward>? global;
  List<SummaryReward>? merchant;
  List<SummaryReward>? merchantReferral;
  List<SummaryReward>? merchantNode;

  Rewards(
      {this.marketing,
      this.gap,
      this.leadership,
      this.global,
      this.merchant,
      this.merchantReferral,
      this.merchantNode});

  Rewards.fromJson(Map<String, dynamic> json) {
    if (json['marketing'] != null) {
      marketing = <SummaryReward>[];
      json['marketing'].forEach((v) {
        marketing!.add(SummaryReward.fromJson(v));
      });
    }
    if (json['gap'] != null) {
      gap = [];
      json['gap'].forEach((v) {
        gap!.add(SummaryReward.fromJson(v));
      });
    }
    if (json['leadership'] != null) {
      leadership = [];
      json['leadership'].forEach((v) {
        leadership!.add(SummaryReward.fromJson(v));
      });
    }
    if (json['global'] != null) {
      global = [];
      json['global'].forEach((v) {
        global!.add(SummaryReward.fromJson(v));
      });
    }
    if (json['merchant'] != null) {
      merchant = [];
      json['merchant'].forEach((v) {
        merchant!.add(SummaryReward.fromJson(v));
      });
    }
    if (json['merchantReferral'] != null) {
      merchantReferral = [];
      json['merchantReferral'].forEach((v) {
        merchantReferral!.add(SummaryReward.fromJson(v));
      });
    }
    if (json['merchantNode'] != null) {
      merchantNode = [];
      json['merchantNode'].forEach((v) {
        merchantNode!.add(SummaryReward.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (marketing != null) {
      data['marketing'] = marketing!.map((v) => v.toJson()).toList();
    }
    if (gap != null) {
      data['gap'] = gap!.map((v) => v.toJson()).toList();
    }
    if (leadership != null) {
      data['leadership'] = leadership!.map((v) => v.toJson()).toList();
    }
    if (global != null) {
      data['global'] = global!.map((v) => v.toJson()).toList();
    }
    if (merchant != null) {
      data['merchant'] = merchant!.map((v) => v.toJson()).toList();
    }
    if (merchantReferral != null) {
      data['merchantReferral'] =
          merchantReferral!.map((v) => v.toJson()).toList();
    }
    if (merchantNode != null) {
      data['merchantNode'] = merchantNode!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class SummaryReward {
  String? coin;
  Decimal? amount;

  SummaryReward({this.coin, this.amount});

  SummaryReward.fromJson(Map<String, dynamic> json) {
    coin = json['coin'];
    amount = Decimal.parse(json['amount'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['coin'] = coin;
    data['amount'] = amount;
    return data;
  }
}
