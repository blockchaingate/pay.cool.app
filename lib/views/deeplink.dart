import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:stacked_services/stacked_services.dart';

class DeeplinkView extends StatefulWidget {
  final List<String>? params;
  const DeeplinkView({this.params, super.key});

  @override
  State<DeeplinkView> createState() => _DeeplinkViewState();
}

class _DeeplinkViewState extends State<DeeplinkView> {
  final navigationService = locator<NavigationService>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(widget.params![0]),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(FlutterI18n.translate(context, "ok")),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: bgGrey,
      appBar: customAppBarWithIcon(
        title: "",
        leading: IconButton(
          onPressed: () => navigationService.clearStackAndShow(DappViewRoute),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 20,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        height: size.height * 0.7,
        width: size.width,
        child: Column(
          children: [
            Container(
              height: size.height * 0.3,
              width: size.width,
              color: red,
            ),
            UIHelper.verticalSpaceMedium,
            Container(
              height: size.height * 0.1,
              width: size.width,
              color: red,
            ),
            UIHelper.verticalSpaceMedium,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                    height: 50,
                    width: size.width * 0.35,
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: buttonPurple,
                      ),
                      child: Text(
                        FlutterI18n.translate(context, "reject"),
                      ),
                    )),
                UIHelper.horizontalSpaceMedium,
                Container(
                    height: 50,
                    width: size.width * 0.35,
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: buttonPurple,
                      ),
                      child: Text(
                        FlutterI18n.translate(context, "confirm"),
                      ),
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
