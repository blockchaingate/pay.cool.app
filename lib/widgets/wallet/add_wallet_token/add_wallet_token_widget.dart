import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/widgets/wallet/add_wallet_token/add_wallet_token_viewmodel.dart';
import 'package:stacked/stacked.dart';

class AddWalletTokenWidget extends StatelessWidget {
  final String chainName;
  const AddWalletTokenWidget({super.key, required this.chainName});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddWalletTokenWidgetViewModel>.reactive(
      onViewModelReady: (viewModel) => viewModel.init(),
      viewModelBuilder: () =>
          AddWalletTokenWidgetViewModel(chainName: chainName.toUpperCase()),
      builder: (
        BuildContext context,
        AddWalletTokenWidgetViewModel model,
        Widget? child,
      ) {
        return Container(
          child: model.busy(model.selectedTokens)
              ? Container()
              : Visibility(
                  child: Container(
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(35),
                    ),
                    width: model.selectedTokens.isNotEmpty ? 140 : 120,
                    child: GestureDetector(
                      onTap: () => model.showAddTokensBottomSheet(context),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            UIHelper.horizontalSpaceSmall,
                            Icon(
                              model.selectedTokens.isNotEmpty
                                  ? Icons.mode_edit_outline_outlined
                                  : FontAwesomeIcons.plus,
                              size: model.selectedTokens.isNotEmpty ? 16 : 14,
                              color: model.selectedTokens.isNotEmpty
                                  ? yellow
                                  : green,
                            ),
                            Expanded(
                              child: model.selectedTokens.isNotEmpty
                                  ? Text(
                                      ' ${FlutterI18n.translate(context, "editTokenList")}',
                                      style: const TextStyle(
                                          color: white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold),
                                    )
                                  : Text(
                                      ' ${FlutterI18n.translate(context, "addToken")}',
                                      style: const TextStyle(
                                          color: white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
