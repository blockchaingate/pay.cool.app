import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/widgets/bottom_nav.dart';
import 'package:stacked_services/stacked_services.dart';

class BondWelcome extends StatefulWidget {
  const BondWelcome({super.key});

  @override
  State<BondWelcome> createState() => _BondWelcomeState();
}

class _BondWelcomeState extends State<BondWelcome> {
  final navigationService = locator<NavigationService>();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        bottomNavigationBar: BottomNavBar(count: 2),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            navigationService.navigateTo(PayCoolViewRoute);
          },
          elevation: 1,
          backgroundColor: Colors.transparent,
          child: Image.asset(
            "assets/images/new-design/pay_cool_icon.png",
            fit: BoxFit.cover,
          ),
        ),
        extendBody: true,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: Container(
          width: size.width,
          height: size.height,
          color: bgGrey,
          child: Column(
            children: [
              UIHelper.verticalSpaceLarge,
              UIHelper.verticalSpaceMedium,
              SizedBox(
                height: size.height * 0.25,
                width: size.width,
                child: Swiper(
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        Image.asset(
                          "assets/images/new-design/slide1.png",
                        ),
                        Spacer()
                      ],
                    );
                  },
                  itemCount: 3,
                  pagination: SwiperPagination(
                    builder: DotSwiperPaginationBuilder(
                      color: Colors.grey[350],
                      activeColor: buttonPurple,
                    ),
                  ),
                ),
              ),
              UIHelper.verticalSpaceMedium,
              InkWell(
                onTap: () {
                  navigationService.navigateTo(clubDashboardViewRoute);
                },
                child: Container(
                  width: size.width * 0.9,
                  height: size.height * 0.1,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        "assets/images/new-design/club_icon.png",
                        scale: 3,
                      ),
                      UIHelper.horizontalSpaceSmall,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            FlutterI18n.translate(
                                context, "Invite once,gain forever"),
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black38),
                          ),
                          Text(
                            "${FlutterI18n.translate(context, "Invitation 100")}    ${FlutterI18n.translate(context, "Bonus \$100,00")}",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: black),
                          ),
                        ],
                      ),
                      Expanded(child: SizedBox()),
                      Icon(Icons.arrow_forward_ios, color: black, size: 14)
                    ],
                  ),
                ),
              ),
              UIHelper.verticalSpaceMedium,
              SizedBox(
                width: size.width * 0.9,
                child: Text(
                  FlutterI18n.translate(context, "projectList"),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
              ),
              UIHelper.verticalSpaceSmall,
              Expanded(
                flex: 4,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          navigationService.navigateTo(
                            BondDashboardViewRoute,
                          );
                        },
                        child: Container(
                          width: size.width * 0.9,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                  "assets/images/new-design/dnblogo.png",
                                  scale: 3.5),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      "Digital Nation Bond (DNB)",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    UIHelper.verticalSpaceSmall,
                                    Text(
                                      "Start Date     01 JAN 2024",
                                      style: TextStyle(
                                          color: Colors.black38,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    UIHelper.verticalSpaceSmall,
                                    Text(
                                      "End Date       01 JAN 2025",
                                      style: TextStyle(
                                          color: Colors.black38,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    UIHelper.verticalSpaceSmall,
                                    Row(
                                      children: [
                                        Image.asset(
                                            "assets/images/new-design/secure.png",
                                            scale: 3),
                                        UIHelper.horizontalSpaceSmall,
                                        Text(
                                          "Government of EI Salvador",
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      UIHelper.verticalSpaceSmall,
                      Container(
                        width: size.width * 0.9,
                        height: size.height * 0.1,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                                "assets/images/new-design/time_logo.png",
                                scale: 2.5),
                            UIHelper.horizontalSpaceSmall,
                            Text(
                              "Coming Soon",
                              style: TextStyle(
                                  color: Colors.black38,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Spacer(
                flex: 1,
              )
            ],
          ),
        ),
      ),
    );
  }
}
