import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/models/wallet/wallet.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/bond/helper.dart';
import 'package:paycool/views/wallet/wallet_dashboard_viewmodel.dart';
import 'package:stacked_services/stacked_services.dart';

class WalletCardWidget extends StatefulWidget {
  final WalletDashboardViewModel model;
  const WalletCardWidget(this.model, {super.key});

  @override
  State<WalletCardWidget> createState() => _WalletCardWidgetState();
}

class _WalletCardWidgetState extends State<WalletCardWidget> {
  final navigationService = locator<NavigationService>();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      key: widget.key,
      width: size.width,
      height: size.height > 750 ? size.height * 0.25 : size.height * 0.3,
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Container(
          width: size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            image: DecorationImage(
              image: AssetImage('assets/images/cardBg.png'),
              fit: BoxFit.cover,
            ),
          ),
          padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  FlutterI18n.translate(context, "walletAccounts"),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '\$ ${widget.model.totalUsdBalance}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Colors.white),
              ),
              Row(
                children: [
                  widget.model.fabAddress != null
                      ? Text(
                          "${widget.model.fabAddress!.substring(0, 6)}...${widget.model.fabAddress!.substring(widget.model.fabAddress!.length - 4)}",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Colors.white),
                        )
                      : Text(
                          FlutterI18n.translate(context, "noAddress"),
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Colors.white),
                        ),
                  IconButton(
                    icon: Icon(
                      Icons.content_copy,
                      size: 14,
                    ),
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: widget.model.fabAddress!));
                      callSMessage(context,
                          FlutterI18n.translate(context, "copiedToClipboard"),
                          duration: 2);
                    },
                  ),
                ],
              ),
              UIHelper.verticalSpaceSmall,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  iconLabelWidget(
                      icon: Icons.send,
                      label: FlutterI18n.translate(context, "send"),
                      route: () {
                        var walletInfo = WalletInfo(
                            address: "DASDASDAS"); // TODO: get wallet address
                        Navigator.pushNamed(context, SendViewRoute,
                            arguments: walletInfo);
                      }),
                  iconLabelWidget(
                      icon: Icons.qr_code,
                      label: FlutterI18n.translate(context, "receive"),
                      route: () {
                        var walletInfo = WalletInfo(
                            address: "DASDASDAS"); // TODO: get wallet address
                        Navigator.pushNamed(context, ReceiveViewRoute,
                            arguments: walletInfo);
                      }),
                  iconLabelWidget(
                      icon: Icons.local_gas_station,
                      label: FlutterI18n.translate(context, "addGas"),
                      route: () {
                        Navigator.pushNamed(context, AddGasViewRoute);
                      }),
                  iconLabelWidget(
                      icon: Icons.compare_arrows_rounded,
                      label: FlutterI18n.translate(context, "remit"),
                      route: () {
                        navigationService.navigateTo(
                          lightningRemitViewRoute,
                        );
                      })
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget iconLabelWidget(
      {required IconData icon,
      required String label,
      required void Function() route}) {
    return InkWell(
      onTap: route,
      child: Column(
        children: [
          Icon(icon),
          UIHelper.verticalSpaceSmall,
          Text(
            label,
            style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 10, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
