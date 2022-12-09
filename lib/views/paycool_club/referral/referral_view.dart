import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/paycool_club/club_dashboard_model.dart';
import 'package:paycool/views/paycool_club/referral/referral_viewmodel.dart';
import 'package:stacked/stacked.dart';

import 'package:paycool/views/paycool_club/referral/referral_model.dart';

import '../../../constants/colors.dart';

class ReferralView extends StatelessWidget {
  final List<Project> projects;
  const ReferralView({Key key, this.projects}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ReferralViewmodel>.reactive(
      viewModelBuilder: () => ReferralViewmodel(),
      onModelReady: (model) {
        model.projects = projects;
        model.init();
      },
      builder: (
        BuildContext context,
        ReferralViewmodel model,
        Widget child,
      ) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
            backgroundColor: Colors.transparent,
            title: Text(
              FlutterI18n.translate(context, "referrals"),
              style: headText4.copyWith(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            automaticallyImplyLeading: true,
          ),
          body: model.isBusy
              ? SizedBox(
                  height: 500,
                  child: Center(child: model.sharedService.loadingIndicator()))
              : Container(
                  decoration: BoxDecoration(image: blurBackgroundImage()),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                          child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: projects.length,
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      const Divider(
                                        height: 15,
                                      ),
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  decoration: roundedBoxDecoration(
                                      color: white, radius: 10),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  child: ListTile(
                                      onTap: () =>
                                          model.navigationService.navigateTo(
                                            referralDetailsViewRoute,
                                            arguments: ReferalRoute(
                                                project: projects[index],
                                                referrals: model.idReferralsMap[
                                                    projects[index].id]),
                                          ),
                                      title: Text(
                                        projects[index].en,
                                        style: headText4,
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            color: grey,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                      subtitle: Row(
                                        children: [
                                          Text(
                                            FlutterI18n.translate(
                                                context, "referrals"),
                                            style: TextStyle(color: green),
                                          ),
                                          UIHelper.horizontalSpaceSmall,
                                          model.idReferralsMap.containsKey(
                                                  projects[index].id)
                                              ? Text(
                                                  model
                                                      .idReferralsMap[
                                                          projects[index].id]
                                                      .length
                                                      .toString(),
                                                  style: headText5.copyWith(
                                                      color: green),
                                                )
                                              : Text('0',
                                                  style: headText5.copyWith(
                                                      color: green)),
                                        ],
                                      )),
                                );
                              }))
                    ],
                  )),
        );
      },
    );
  }
}
