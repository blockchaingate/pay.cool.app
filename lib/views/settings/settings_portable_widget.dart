import 'package:exchangily_ui/exchangily_ui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter/material.dart';
import 'package:paycool/constants/paycool_styles.dart';
import 'package:paycool/views/settings/settings_viewmodel.dart';
import 'package:stacked/stacked.dart';

class SettingsPortableView extends StatelessWidget {
  const SettingsPortableView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SettingsViewmodel>.reactive(
      onModelReady: (model) async {
        model.context = context;
        await model.init();
      },
      viewModelBuilder: () => SettingsViewmodel(),
      builder: (context, model, _) => Scaffold(
        // When the keyboard appears, the Flutter widgets resize to avoid that we use resizeToAvoidBottomInset: false
        resizeToAvoidBottomInset: false,

        body: model.isBusy
            ? Center(child: model.sharedService.loadingIndicator())
            : SettingsPortableContainer(model: model),
      ),
    );
  }
}

class SettingsPortableContainer extends StatelessWidget {
  const SettingsPortableContainer({Key key, this.model}) : super(key: key);
  final SettingsViewmodel model;
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(10.0),
        //  alignment: Alignment.center,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              UIHelper.verticalSpaceLarge,

              // Show/Hide dialog warning checkbox
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Icon(Icons.warning, color: yellow, size: 16),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                        FlutterI18n.translate(context, "showDialogWarnings"),
                        style: headText5,
                        textAlign: TextAlign.left),
                  ),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 20,
                      child: Switch(
                          inactiveThumbColor: grey,
                          activeTrackColor: white,
                          activeColor: PaycoolColors.primaryColor,
                          inactiveTrackColor: white,
                          value: model.isDialogDisplay,
                          onChanged: (value) {
                            model.setIsDialogWarningValue(value);
                          }),
                    ),
                  ),
                ],
              ),

              UIHelper.verticalSpaceMedium,
              // Showcase ON/OFF
              Row(
                //  crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Icon(Icons.insert_comment, color: white, size: 16),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                        FlutterI18n.translate(
                            context, "settingsShowcaseInstructions"),
                        style: headText5,
                        textAlign: TextAlign.left),
                  ),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 20,
                      child: Switch(
                          inactiveThumbColor: grey,
                          activeTrackColor: white,
                          activeColor: PaycoolColors.primaryColor,
                          inactiveTrackColor: white,
                          value: !model.isShowCaseOnce,
                          onChanged: (value) {
                            model.storageService.isShowCaseView = !value;

                            model.setBusy(true);
                            // get new value and assign it to the viewmodel variable
                            model.isShowCaseOnce =
                                model.storageService.isShowCaseView;
                            model.setBusy(false);
                          }),
                    ),
                  ),
                ],
              ),
            ]));
  }
}
