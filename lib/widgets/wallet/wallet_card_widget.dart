import 'package:flutter/material.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/models/wallet/wallet.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:stacked_services/stacked_services.dart';

class WalletCardWidget extends StatefulWidget {
  const WalletCardWidget({super.key});

  @override
  State<WalletCardWidget> createState() => _WalletCardWidgetState();
}

class _WalletCardWidgetState extends State<WalletCardWidget> {
  final NavigationService navigationService = locator<NavigationService>();
  WalletService walletService = locator<WalletService>();
  WalletInfo? get walletInfo => walletService.walletInfoDetails;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
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
                  'Wallet Accounts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '\$10,000.00',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Colors.white),
              ),
              Row(
                children: [
                  Text(
                    '0xhgts...hgtf',
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
                    onPressed: () {},
                  ),
                ],
              ),
              UIHelper.verticalSpaceSmall,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconLabelWidget(
                      icon: Icons.send,
                      label: 'Send',
                      route: () {
                        print("---------1----------");
                        Navigator.pushNamed(context, SendViewRoute,
                            arguments: walletInfo);
                      }),
                  IconLabelWidget(
                      icon: Icons.qr_code,
                      label: 'Receive',
                      route: () {
                        var walletInfo = WalletInfo(address: "DASDASDAS");

                        Navigator.pushNamed(context, ReceiveViewRoute,
                            arguments: walletInfo);
                        print("--------2-----------");
                      }),
                  IconLabelWidget(
                      icon: Icons.local_gas_station,
                      label: 'Add Gas',
                      route: () {
                        print("--------3-----------");
                        Navigator.pushNamed(context, AddGasViewRoute);
                      }),
                  IconLabelWidget(
                      icon: Icons.compare_arrows_rounded,
                      label: 'Remit',
                      route: () {
                        print("---------4----------");
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

  Widget IconLabelWidget(
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
