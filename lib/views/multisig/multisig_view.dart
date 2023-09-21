import 'package:exchangily_ui/exchangily_ui.dart' show kTextField;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/multisig/dashboard/multisig_dashboard_view.dart';
import 'package:stacked/stacked.dart';

import 'multisig_view_viewmodel.dart';

class MultisigView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MultisigViewModel>.reactive(
      viewModelBuilder: () => MultisigViewModel(),
      onViewModelReady: (MultisigViewModel model) async {
        model.sharedService.context = context;
        await model.init();
      },
      onDispose: (MultisigViewModel model) {
        for (var controller in model.ownerControllers) {
          controller.dispose();
        }
        for (var controller in model.addressControllers) {
          controller.dispose();
        }
      },
      builder: (
        BuildContext context,
        MultisigViewModel model,
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
                  Container(
                    decoration: roundedBoxDecoration(
                      radius: 8,
                      color: Colors.grey.shade200,
                    ),
                    padding: EdgeInsets.all(5),
                    child: Dismissible(
                      key: uniqueKey,
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        model.removeFields(i);
                        // model.sharedService.sharedSimpleNotification(
                        //     '${model.ownerControllers[i].text} dismissed');
                      },
                      background: Container(color: Colors.red),
                      child: Column(
                        children: [
                          kTextField(
                              controller: model.ownerControllers[i],
                              contentPadding: 5,
                              labelText: 'Name',
                              hintText: 'Owner $i',
                              labelStyle: headText5,
                              cursorColor: green,
                              cursorHeight: 14,
                              fillColor: Colors.transparent,
                              isDense: true,
                              focusBorderColor: primaryColor,
                              enabledBorderColor: white,
                              leadingWidget: Icon(
                                FontAwesomeIcons.user,
                                size: 16,
                                color: primaryColor,
                              ),
                              onChanged: (value) =>
                                  debugPrint('Name VALUE $value'),
                              onTap: () => debugPrint('Name VALUE')),
                          kTextField(
                            controller: model.addressControllers[i],
                            contentPadding: 5,
                            hintText: 'Address',
                            labelText: 'Address',
                            labelStyle: headText5,
                            cursorColor: green,
                            cursorHeight: 14,
                            fillColor: Colors.transparent,
                            leadingWidget: Icon(
                              FontAwesomeIcons.addressBook,
                              color: primaryColor,
                            ),
                            isDense: true,
                            focusBorderColor: grey,
                            onChanged: (value) =>
                                debugPrint('ADdress VALUE $value'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  UIHelper.verticalSpaceSmall,
                ],
              ),
            );
          }
          return Column(children: fields);
        }

        return Scaffold(
          appBar: customAppBarWithTitle('Create Multisig'),
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
                                  text: 'Select Chain',
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
                            labelText: "Enter wallet name",
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
                  customText(text: 'Set owners '),
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
                        'Add Owner',
                        style: headText5.copyWith(color: white),
                      ),
                    ),
                  ),
                  UIHelper.verticalSpaceMedium,
                  // minimum signature dropdown
                  customText(text: 'Minimum signature '),
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
                  customText(text: 'Estimated fee'),
                  UIHelper.verticalSpaceSmall,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        flex: 2,
                        child: kTextField(
                          controller: model.feeController,
                          hintText: '0.001',
                          labelText: "Kanban fee",
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
                                'Edit',
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
                      onPressed: () => model.multisigWalletSubmit(),
                      child: Text(
                        "Next",
                        style: headText3.copyWith(color: white),
                      ),
                    ),
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
                      onPressed: () => model.navigationService
                          .navigateWithTransition(MultisigDashboardView(
                              txid:
                                  '0x77bf7ad3753a3ecc4402765b7b2a9ca73d07f0e78488de036940d8d073313edf')),
                      child: Text(
                        "Dashboard",
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
