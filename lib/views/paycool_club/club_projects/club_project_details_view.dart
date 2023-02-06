import 'package:flutter/gestures.dart';
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
  final List<ClubProject>? projectDetails;
  const ClubProjectDetailsView({Key? key, this.projectDetails})
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
    for (var element in widget.projectDetails!) {
      selectedCoin.add(element.coins![0]);
    }
    if (selectedCoin.length > widget.projectDetails!.length) {
      selectedCoin.removeRange(
          widget.projectDetails!.length, selectedCoin.length);
    }
    debugPrint('projects length ${widget.projectDetails!.length}');
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: customAppBarWithTitleNB(
          FlutterI18n.translate(context, "selectPackageDetails")),
      body: Container(
        margin: const EdgeInsets.only(bottom: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(image: blurBackgroundImage()),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UIHelper.verticalSpaceMedium,

            // Text(
            //   FlutterI18n.translate(context, "selectPackageDetails"),
            //   style: headText1.copyWith(
            //       color: primaryColor, fontWeight: FontWeight.bold),
            // ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: ListView.builder(
                    padding: const EdgeInsets.only(top: 10),
                    shrinkWrap: true,
                    itemCount: widget.projectDetails!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                        color: secondaryColor,
                        elevation: 10,
                        child: ListTile(
                          minVerticalPadding: 15,
                          onTap: () => navigationService.navigateTo(
                              clubPackageCheckoutViewRoute,
                              arguments: {
                                "package": widget.projectDetails![index],
                                'paymentCoin': selectedCoin[index]
                              }),
                          leading: widget.projectDetails![index].image == null
                              ? Container(
                                  width: 30,
                                  height: 30,
                                  decoration: roundedBoxDecoration(),
                                )
                              : Container(
                                  // decoration:
                                  //     roundedBoxDecoration(color: secondaryColor),
                                  // padding: const EdgeInsets.all(8),
                                  child: CircleAvatar(
                                      onBackgroundImageError:
                                          ((exception, stackTrace) =>
                                              const Placeholder(
                                                color: primaryColor,
                                              )),
                                      backgroundImage: NetworkImage(
                                        widget.projectDetails![index].image
                                            .toString(),
                                      ))),
                          title: Text(
                            storageService.language == 'en'
                                ? widget.projectDetails![index].name!.en
                                    .toString()
                                : widget.projectDetails![index].name!.sc
                                    .toString(),
                            style: headText4.copyWith(
                                fontWeight: FontWeight.bold, color: black),
                          ),
                          subtitle: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: RichText(
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                      text: storageService.language == 'en'
                                          ? widget.projectDetails![index]
                                              .description!.en
                                          : widget.projectDetails![index]
                                              .description!.sc,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          decoration: TextDecoration.underline,
                                          color: primaryColor),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                    titleTextStyle: headText3
                                                        .copyWith(color: black),
                                                    title: Text(
                                                      FlutterI18n.translate(
                                                          context,
                                                          "description"),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: headText3.copyWith(
                                                          color: black),
                                                    ),
                                                    contentTextStyle:
                                                        const TextStyle(
                                                            color: grey),
                                                    content: SizedBox(
                                                      height: 120,
                                                      child:
                                                          SingleChildScrollView(
                                                              child: Text(
                                                        storageService
                                                                    .language ==
                                                                'en'
                                                            ? widget
                                                                .projectDetails![
                                                                    index]
                                                                .description!
                                                                .en
                                                                .toString()
                                                            : widget
                                                                .projectDetails![
                                                                    index]
                                                                .description!
                                                                .sc
                                                                .toString(),
                                                        style: headText3,
                                                      )),
                                                    ));
                                              });
                                        }),
                                ),
                              ),
                            ],
                          ),
                          trailing: SizedBox(
                            // width: 200,
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
                                      selectedCoin[index] = newValue.toString();
                                    });
                                  },
                                  items:
                                      widget.projectDetails![index].coins!.map(
                                    (coin) {
                                      return DropdownMenuItem(
                                        value: coin,
                                        child: Container(
                                          //   height: 40,
                                          //  color: secondaryColor,
                                          //  decoration:
                                          padding:
                                              const EdgeInsets.only(left: 10.0),
                                          child: Text(coin.toString(),
                                              textAlign: TextAlign.center,
                                              style: headText5.copyWith(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      );
                                    },
                                  ).toList(),
                                ),
                                UIHelper.horizontalSpaceMedium,
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: primaryColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
