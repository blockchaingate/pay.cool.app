import 'package:exchangily_ui/exchangily_ui.dart' show kTextField;
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:stacked/stacked.dart';

import 'create_multisig_wallet_viewmodel.dart';

class CreateMultisigWalletView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CreateMultisigWalletViewModel>.reactive(
      viewModelBuilder: () => CreateMultisigWalletViewModel(),
      onViewModelReady: (CreateMultisigWalletViewModel model) async {
        model.sharedService.context = context;
        await model.init();
      },
      onDispose: (CreateMultisigWalletViewModel model) {
        for (var controller in model.ownerControllers) {
          controller.dispose();
        }
        for (var controller in model.addressControllers) {
          controller.dispose();
        }
      },
      builder: (
        BuildContext context,
        CreateMultisigWalletViewModel model,
        Widget? child,
      ) {
        Widget _buildDynamicFields() {
          List<Widget> fields = [];
          for (var i = 0; i < model.ownerControllers.length; i++) {
            final uniqueKey = UniqueKey();
            fields.add(
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Dismissible(
                    key: uniqueKey,
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      model.removeFields(i);
                      // model.sharedService.sharedSimpleNotification(
                      //     '${model.ownerControllers[i].text} dismissed');
                    },
                    //   background: Container(color: Colors.red),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 2),
                          child: kTextField(
                              controller: model.ownerControllers[i],
                              contentPadding: 0,
                              labelText: FlutterI18n.translate(context, 'name'),
                              hintText:
                                  '${FlutterI18n.translate(context, 'owner')} $i',
                              labelStyle: headText5,
                              cursorColor: green,
                              cursorHeight: 14,
                              errorText: null,
                              fillColor: Colors.transparent,
                              isDense: true,
                              enabledBorderColor: grey,
                              leadingWidget: Icon(
                                FontAwesomeIcons.user,
                                size: 16,
                                color: primaryColor,
                              ),
                              onChanged: (value) =>
                                  debugPrint('Name VALUE $value'),
                              onTap: () => debugPrint('Name VALUE')),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 2),
                          child: kTextField(
                            controller: model.addressControllers[i],
                            contentPadding: 5,
                            textFieldFontSize: 10,
                            hintText: FlutterI18n.translate(context, 'address'),
                            hintStyle: headText6.copyWith(color: grey),
                            labelText: FlutterI18n.translate(
                                context, '${model.selectedChain} address'),
                            labelStyle: headText5,
                            cursorColor: green,
                            cursorHeight: 14,
                            errorText: null,
                            fillColor: Colors.transparent,
                            leadingWidget: Icon(
                              FontAwesomeIcons.addressBook,
                              color: primaryColor,
                            ),
                            isDense: true,
                            enabledBorderColor: grey,
                            onChanged: (value) =>
                                debugPrint('ADdress VALUE $value'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  UIHelper.verticalSpaceMedium,
                ],
              ),
            );
          }
          return Column(children: fields);
        }

        return Scaffold(
          backgroundColor: white,
          appBar: customAppBarWithTitle(
              FlutterI18n.translate(context, 'createMultisigWallet')),
          body: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UIHelper.verticalSpaceLarge,
                  // select chain dropdown
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              customText(
                                  text: FlutterI18n.translate(
                                      context, 'selectChain'),
                                  textAlign: TextAlign.start),
                              DropdownButton<String>(
                                underline: const SizedBox.shrink(),
                                elevation: 15,
                                icon: const Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: Icon(
                                    Icons.arrow_drop_down,
                                    color: black,
                                  ),
                                ),
                                iconEnabledColor: primaryColor,
                                iconDisabledColor:
                                    model.ownerControllers.isEmpty
                                        ? secondaryColor
                                        : grey,
                                iconSize: 26,
                                hint: Padding(
                                  padding: model.ownerControllers.isEmpty
                                      ? const EdgeInsets.all(0)
                                      : const EdgeInsets.only(left: 10.0),
                                ),
                                value: model.selectedChain,
                                items: List.generate(
                                  model.chains.length,
                                  (index) => DropdownMenuItem<String>(
                                    child: Row(
                                      children: [
                                        Text(
                                          model.chains[index],
                                          style: headText4,
                                        ),
                                      ],
                                    ), // Display the index as text
                                    value: model.chains[
                                        index], // Assign the index as the value
                                  ),
                                ),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    model.selectedChain = newValue;
                                    model.setFee();
                                    model.notifyListeners();
                                    model.log.w(
                                        'Selected chain: ${model.selectedChain}');
                                  }
                                },
                              ),
                            ]),
                      ),
                      Expanded(
                        flex: 2,
                        child: kTextField(
                            controller: model.walletNameController,
                            //   hintText: 'Wallet name',
                            labelText: FlutterI18n.translate(
                                context, 'enterWalletName'),
                            labelStyle: headText5,
                            cursorColor: green,
                            cursorHeight: 14,
                            fillColor: Colors.transparent,
                            leadingWidget: Icon(
                              Icons.wallet,
                              color: black,
                            ),
                            isDense: true,
                            focusBorderColor: grey),
                      ),
                    ],
                  ),
                  UIHelper.verticalSpaceSmall,
                  customText(
                      text: '${FlutterI18n.translate(context, 'setOwners')} '),
                  UIHelper.verticalSpaceSmall,
                  _buildDynamicFields(),

                  Container(
                    alignment: Alignment.center,
                    child: ElevatedButton.icon(
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5)),
                          backgroundColor:
                              MaterialStateProperty.all(primaryColor)),
                      icon: Icon(
                        Icons.supervised_user_circle_outlined,
                        size: 18,
                      ),
                      onPressed: model.addOwner,
                      label: Text(
                        FlutterI18n.translate(context, 'addOwner'),
                        style: headText5.copyWith(color: white),
                      ),
                    ),
                  ),
                  UIHelper.verticalSpaceMedium,
                  // minimum signature dropdown
                  customText(
                      text:
                          '${FlutterI18n.translate(context, 'minimumSignatures')} '),
                  UIHelper.verticalSpaceSmall,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButton<int>(
                        underline: const SizedBox.shrink(),
                        elevation: 15,
                        icon: const Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Icon(
                            Icons.arrow_drop_down,
                            color: black,
                          ),
                        ),
                        iconEnabledColor: primaryColor,
                        iconDisabledColor: model.ownerControllers.isEmpty
                            ? secondaryColor
                            : grey,
                        iconSize: 26,
                        hint: Padding(
                          padding: model.ownerControllers.isEmpty
                              ? const EdgeInsets.all(0)
                              : const EdgeInsets.only(left: 10.0),
                        ),
                        value: model.selectedNumberOfOwners,
                        items: List.generate(
                          model.ownerControllers.length,
                          (index) => DropdownMenuItem<int>(
                            child: Row(
                              children: [
                                Text(
                                  '${index + 1}',
                                  style: headText4,
                                ),
                              ],
                            ), // Display the index as text
                            value: index + 1, // Assign the index as the value
                          ),
                        ),
                        onChanged: (int? newValue) {
                          if (newValue != null) {
                            model.selectedNumberOfOwners = newValue;
                            model.notifyListeners();
                            model.log.w(
                                'Selected index: ${model.selectedNumberOfOwners}');
                          }
                        },
                      ),
                      Text(
                        '/  ${model.ownerControllers.length}',
                        style: headText4,
                      ),
                    ],
                  ),
                  UIHelper.verticalSpaceMedium,
                  customText(
                    text: FlutterI18n.translate(context, 'estimatedFee'),
                  ),
                  UIHelper.verticalSpaceSmall,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        flex: 2,
                        child: kTextField(
                          controller: model.feeController,
                          hintText: '0.001',
                          labelText: '${model.selectedChain}',
                          labelStyle: headText5.copyWith(color: grey),
                          cursorColor: green,
                          cursorHeight: 14,
                          fillColor: Colors.transparent,
                          leadingWidget: Icon(
                            Icons.charging_station_rounded,
                            color: black,
                          ),
                          isDense: true,
                          focusBorderColor: grey,
                          suffixWidget: TextButton(
                              onPressed: () => model.showGasBottomSheet(),
                              child: Text(
                                FlutterI18n.translate(context, 'edit'),
                                style: headText5.copyWith(color: primaryColor),
                              )),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 10)),
                          backgroundColor:
                              MaterialStateProperty.all(primaryColor)),
                      onPressed: () => model.multisigWalletSubmit(context),
                      child: Text(
                        FlutterI18n.translate(context, 'next'),
                        style: headText3.copyWith(color: white),
                      ),
                    ),
                  ),

                  UIHelper.verticalSpaceLarge
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
