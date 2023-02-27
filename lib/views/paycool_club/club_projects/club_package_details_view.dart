import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/services/navigation_service.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/paycool_club/club_projects/models/club_project_model.dart';

class ClubPackageDetailsView extends StatefulWidget {
  final List<ClubProject>? projectDetails;
  const ClubPackageDetailsView({Key? key, this.projectDetails})
      : super(key: key);

  @override
  State<ClubPackageDetailsView> createState() => _ClubPackageDetailsViewState();
}

class _ClubPackageDetailsViewState extends State<ClubPackageDetailsView> {
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
      extendBodyBehindAppBar: true,
      appBar: customAppBarWithTitleNB(
          FlutterI18n.translate(context, "selectPackage")),
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            image:
                imageBackground(path: 'assets/images/club/background-1.png')),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                        color: widget.projectDetails![index].status == 1
                            ? secondaryColor
                            : grey.withOpacity(0.1),
                        elevation: 10,
                        child: ListTile(
                          minVerticalPadding: 15,
                          leading: Container(
                              decoration: roundedBoxDecoration(
                                  color: primaryColor.withAlpha(55)),
                              padding: const EdgeInsets.all(8),
                              child: SvgPicture.asset(
                                  'assets/images/club/stake-icon.svg',
                                  width: 24,
                                  color:
                                      widget.projectDetails![index].name!.en ==
                                              'Package D'
                                          ? const Color(0XFFEF639F)
                                          : widget.projectDetails![index].name!
                                                      .en ==
                                                  'Package E'
                                              ? const Color(0XFFF7A750)
                                              : widget.projectDetails![index]
                                                          .name!.en ==
                                                      'Package M1'
                                                  ? const Color(0XFF5EB190)
                                                  : const Color(0XFF6C6AEB))),
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
                                                    backgroundColor:
                                                        secondaryColor,
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    DropdownButton(
                                      isDense: true,
                                      elevation: 15,
                                      dropdownColor: primaryColor,
                                      underline: const SizedBox.shrink(),
                                      value: selectedCoin[index],
                                      onChanged: (newValue) {
                                        setState(() {
                                          selectedCoin[index] =
                                              newValue.toString();
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.arrow_drop_down,
                                        size: 18,
                                        color: primaryColor,
                                      ),
                                      items: widget
                                          .projectDetails![index].coins!
                                          .map(
                                        (coin) {
                                          return DropdownMenuItem(
                                            value: coin,
                                            child: Text(coin.toString(),
                                                textAlign: TextAlign.center,
                                                style: headText5.copyWith(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          );
                                        },
                                      ).toList(),
                                    ),
                                    customText(
                                        text:
                                            '\$${widget.projectDetails![index].joiningFee}',
                                        style: headText6,
                                        isBold: true)
                                  ],
                                ),
                                UIHelper.horizontalSpaceMedium,
                                widget.projectDetails![index].status == 1
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: IconButton(
                                          onPressed: () {
                                            navigationService.navigateTo(
                                                clubPackageCheckoutViewRoute,
                                                arguments: {
                                                  "package": widget
                                                      .projectDetails![index],
                                                  'paymentCoin':
                                                      selectedCoin[index]
                                                });
                                          },
                                          icon: const Icon(
                                            Icons.arrow_forward_ios,
                                            color: black,
                                            size: 16,
                                          ),
                                        ),
                                      )
                                    : Container(),
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
