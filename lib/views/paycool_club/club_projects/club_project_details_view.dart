import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/services/navigation_service.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/paycool_club/club_projects/club_project_model.dart';

class ClubProjectDetailsView extends StatefulWidget {
  final List<ClubProject> projectDetails;
  const ClubProjectDetailsView({Key key, this.projectDetails})
      : super(key: key);

  @override
  State<ClubProjectDetailsView> createState() => _ClubProjectDetailsViewState();
}

class _ClubProjectDetailsViewState extends State<ClubProjectDetailsView> {
  //String selectedCoin = 'DUSD';
  List<String> selectedCoin = [];

  @override
  Widget build(BuildContext context) {
    final storageService = locator<LocalStorageService>();
    final navigationService = locator<NavigationService>();
    //selectedCoin = [];
    for (var element in widget.projectDetails) {
      selectedCoin.add(element.coins[0]);
    }
    if (selectedCoin.length > widget.projectDetails.length) {
      selectedCoin.removeRange(
          widget.projectDetails.length, selectedCoin.length);
    }
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: true,
      ),
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(image: blurBackgroundImage()),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select a Package to unlock',
              style: headText1.copyWith(color: primaryColor),
            ),
            Container(
              alignment: Alignment.center,
              child: ListView.builder(
                  padding: EdgeInsets.only(top: 10),
                  shrinkWrap: true,
                  itemCount: widget.projectDetails.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      padding: const EdgeInsets.all(5),
                      decoration:
                          roundedBoxDecoration(color: grey.withAlpha(150)),
                      child: ListTile(
                        leading: Container(
                            padding: const EdgeInsets.all(8),
                            child: Image.network(
                              widget.projectDetails[index].image,
                              width: 40,
                              height: 40,
                            )),
                        title: Text(
                          storageService.language == 'en'
                              ? widget.projectDetails[index].name.en
                              : widget.projectDetails[index].name.sc,
                          style: headText2.copyWith(
                              fontWeight: FontWeight.bold, color: white),
                        ),
                        subtitle: Text(
                          storageService.language == 'en'
                              ? widget.projectDetails[index].description.en
                              : widget.projectDetails[index].description.sc,
                        ),
                        trailing: SizedBox(
                          width: 200,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              DropdownButton(
                                elevation: 15,
                                underline: const SizedBox.shrink(),
                                value: selectedCoin[index],
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedCoin[index] = newValue;
                                  });
                                },
                                items: widget.projectDetails[index].coins.map(
                                  (coin) {
                                    return DropdownMenuItem(
                                      value: coin,
                                      child: Container(
                                        //   height: 40,
                                        //  color: secondaryColor,
                                        padding:
                                            const EdgeInsets.only(left: 10.0),
                                        child: Text(coin.toString(),
                                            textAlign: TextAlign.center,
                                            style: headText4.copyWith(
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    );
                                  },
                                ).toList(),
                              ),
                              SizedBox(
                                width: 100,
                                height: 50,
                                child: ElevatedButton(
                                    style: generalButtonStyle1.copyWith(
                                        padding: MaterialStateProperty.all(
                                            const EdgeInsets.all(0))),
                                    onPressed: () => navigationService
                                            .navigateTo(
                                                clubPackageCheckoutViewRoute,
                                                arguments: {
                                              "package":
                                                  widget.projectDetails[index],
                                              'paymentCoin': selectedCoin[index]
                                            }),
                                    child: const Text('Buy')),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}
