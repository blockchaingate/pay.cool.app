import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/dapp/dapp_viewmodel.dart';
import 'package:paycool/views/dapp/dapp_web_view.dart';
import 'package:paycool/widgets/bottom_nav.dart';
import 'package:stacked/stacked.dart';

class DappView extends StatelessWidget {
  const DappView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ViewModelBuilder<DappViewmodel>.reactive(
      viewModelBuilder: () => DappViewmodel(),
      onViewModelReady: (model) {
        model.context = context;
        model.init();
      },
      builder: (context, model, _) => WillPopScope(
        onWillPop: () async {
          model.onBackButtonPressed();
          return Future(() => false);
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Scaffold(
            backgroundColor: white,
            resizeToAvoidBottomInset: false,
            bottomNavigationBar: BottomNavBar(count: 3),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                model.navigationService.navigateTo(PayCoolViewRoute);
              },
              elevation: 1,
              backgroundColor: Colors.transparent,
              child: Image.asset(
                "assets/images/new-design/pay_cool_icon.png",
                fit: BoxFit.cover,
              ),
            ),
            extendBody: true,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            appBar: AppBar(
              backgroundColor: white,
              leadingWidth: 0,
              centerTitle: true,
              elevation: 0,
              title: Container(
                width: size.width,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: model.searchController,
                  decoration: InputDecoration(
                    hintText: "Search",
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(),
                      child: Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: 18,
                      ),
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(),
                      child: InkWell(
                          onTap: () {},
                          child: Image.asset(
                            "assets/images/new-design/scan_icon.png",
                            scale: 2.9,
                          )),
                    ),
                    contentPadding: EdgeInsets.zero,
                    hintStyle: TextStyle(
                      color: grey,
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UIHelper.verticalSpaceSmall,
                  Text(
                    FlutterI18n.translate(context, "myDapp"),
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: black),
                  ),
                  UIHelper.verticalSpaceSmall,
                  SizedBox(
                    width: size.width,
                    height: size.height * 0.16,
                    child: ListView.builder(
                        itemCount: model.dapps.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DappWebView(
                                    model.dapps[index]["url"].toString(),
                                    model.dapps[index]["title"].toString(),
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  clipBehavior: Clip.antiAlias,
                                  child: SizedBox(
                                    width: size.width * 0.2,
                                    height: size.height * 0.1,
                                    child: Image.network(
                                      model.dapps[index]["image"].toString(),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                UIHelper.verticalSpaceSmall,
                                Text(
                                  model.dapps[index]["title"].toString(),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: black,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                  ),
                  // UIHelper.verticalSpaceMedium,
                  // Text(
                  //   FlutterI18n.translate(context, "hot"),
                  //   style: TextStyle(
                  //       fontSize: 16,
                  //       fontWeight: FontWeight.bold,
                  //       color: black),
                  // ),
                  // UIHelper.verticalSpaceSmall,
                  // SizedBox(
                  //   width: size.width,
                  //   height: size.height * 0.16,
                  //   child: ListView.builder(
                  //     itemCount: 6,
                  //     scrollDirection: Axis.horizontal,
                  //     itemBuilder: (context, index) {
                  //       return Column(
                  //         children: [
                  //           ClipRRect(
                  //             borderRadius: BorderRadius.circular(50),
                  //             clipBehavior: Clip.antiAlias,
                  //             child: SizedBox(
                  //               width: size.width * 0.2,
                  //               child: Image.asset(
                  //                 "assets/images/new-design/biswap_logo.png",
                  //                 fit: BoxFit.cover,
                  //               ),
                  //             ),
                  //           ),
                  //           UIHelper.verticalSpaceSmall,
                  //           Text(
                  //             model.dapps[index]["title"].toString(),
                  //             overflow: TextOverflow.ellipsis,
                  //             style: TextStyle(
                  //               fontSize: 12,
                  //               fontWeight: FontWeight.bold,
                  //               color: black,
                  //             ),
                  //           ),
                  //         ],
                  //       );
                  //     },
                  //   ),
                  // )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
