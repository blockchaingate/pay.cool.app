import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/shared_service.dart';

class CopyClipboardTextWidget extends StatelessWidget {
  final String text;
  const CopyClipboardTextWidget(this.text);

  @override
  Widget build(BuildContext context) {
    final sharedService = locator<SharedService>();
    return CupertinoButton(
        child: const Icon(
          FontAwesomeIcons.copy,
          color: primaryColor,
          size: 16,
        ),
        onPressed: () {
          sharedService.copyAddress(context, text);
        });
  }
}
