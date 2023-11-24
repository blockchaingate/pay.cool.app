import 'package:flutter/material.dart';
import 'package:paycool/shared/ui_helpers.dart';

class WalletCardWidget extends StatefulWidget {
  const WalletCardWidget({super.key});

  @override
  State<WalletCardWidget> createState() => _WalletCardWidgetState();
}

class _WalletCardWidgetState extends State<WalletCardWidget> {
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
                children: const [
                  IconLabelWidget(icon: Icons.send, label: 'Send'),
                  IconLabelWidget(icon: Icons.qr_code, label: 'Receive'),
                  IconLabelWidget(
                      icon: Icons.local_gas_station, label: 'Add Gas'),
                  IconLabelWidget(
                      icon: Icons.compare_arrows_rounded, label: 'Remit'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IconLabelWidget extends StatelessWidget {
  final IconData icon;
  final String label;

  const IconLabelWidget({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon),
        UIHelper.verticalSpaceSmall,
        Text(
          label,
          style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 10, color: Colors.white),
        ),
      ],
    );
  }
}
