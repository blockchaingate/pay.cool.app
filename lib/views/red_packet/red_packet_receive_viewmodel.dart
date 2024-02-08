import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paycool/constants/api_routes.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/models/red/red_packet_rm.dart';
import 'package:paycool/providers/app_state_provider.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/views/paycool/paycool_service.dart';
import 'package:paycool/views/red_packet/red_packet_service.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';

import '../../services/local_dialog_service.dart';

class RedPacketReceiveViewModel extends BaseViewModel {
  final log = getLogger('RedPacketReceiveViewModel');

  late AppStateProvider appStateProvider;

  //DialogService
  final dialogService = locator<LocalDialogService>();

  //RedPacketService
  final redPacketService = locator<RedPacketService>();

  //WalletService
  final walletService = locator<WalletService>();

  //PayCoolService
  final payCoolService = locator<PayCoolService>();

  late BuildContext _context;

  //text controller for gift code input
  TextEditingController giftCodeController = TextEditingController();

  init(context) {
    print('RedPacketReceiveViewModel init');
    appStateProvider = Provider.of<AppStateProvider>(context!, listen: false);
    _context = context;
  }

  //get gift code from input
  String getGiftCode() {
    return giftCodeController.text;
  }

  redPacketReceive(BuildContext context) async {
    print('RedPacketReceiveViewModel redPacketReceive');

    try {
      //get getGiftCode
      String giftCode = getGiftCode();

      if (giftCode.isEmpty) {
        //show error dialog
        await dialogService.showDialog(
            title: 'Error',
            description: 'Please input gift code',
            buttonTitle: 'OK');
        return;
      }

      print("gekdjsadhbakjs");

      String? fabAddress = appStateProvider.getProviderAddressList
          .where((element) => element.name == 'FAB')
          .first
          .address;

      print(fabAddress);

      //get user wallet address

      var seed = await walletService.getSeedDialog(_context);

      // call getClaimRedPacketSignedMessage
      RedPacketResponseModal? signedMessage = await redPacketService
          .getClaimRedPacketSignedMessage(giftCode, fabAddress!);

      // if signedMessage is null, show error dialog
      if (signedMessage == null) {
        await dialogService.showDialog(
            title: 'Error',
            description: 'Failed to get signed message',
            buttonTitle: 'OK');
        return;
      }

      print(signedMessage!.data!.signedMessage!.v);

      String? amount = signedMessage.data!.signedMessage!.amount;
      String? originalAmount =
          signedMessage.data!.signedMessage!.originalAmount;
      String? token = signedMessage.data!.signedMessage!.token;

      String? hex = await redPacketService.encodeReceiveRedPacketAbiHex(
          _context,
          giftCode,
          signedMessage.data!.signedMessage!.amount,
          signedMessage.data!.signedMessage!.messageHash,
          signedMessage.data!.signedMessage!.v,
          signedMessage.data!.signedMessage!.r,
          signedMessage.data!.signedMessage!.s);

      print("-------------------");
      print(hex);

      // String redPacketContractAdd = "0x2f904065e5bedaf4f55fb0783bdb9c721c4f52b4";
      // String redPacketContractAdd = "0xc959a66685cc0e25e8a1c5bea761160c4090fdb1";

      String redPacketContractAdd = redPacketContractAddress;

      var sign = await payCoolService.signSendTxBond(
          seed!, hex!, redPacketContractAdd);

      print("ReceiveRedPacket sign: $sign");

      //if amout is not empty, and sign is not null. then display success dialog
      if (amount != null && sign != null) {
        //flutter dialog
        // await dialogService.showBasicDialog(
        //     title: 'Success',
        //     description: 'Received $amount FAB',
        //     buttonTitle: 'OK');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialog(amount: originalAmount!, type: token!);
          },
        );
      } else {
        await dialogService.showBasicDialog(
            title: 'Failed',
            description: 'Failed to receive red packet',
            buttonTitle: 'OK');
      }
    } catch (e) {
      log.e('CATCH redPacketReceive failed to load the data from the API $e');
      await dialogService.showBasicDialog(
          title: 'Unknow Issue',
          description: 'Failed to receive red packet. ${e.toString()}',
          buttonTitle: 'OK');
    }
  }

  //paste gift code from clipboard
  pasteGiftCode() async {
    //get gift code from clipboard
    String? giftCode = await Clipboard.getData('text/plain').then((value) {
      return value?.text;
    });
    if (giftCode != null) {
      giftCodeController.text = giftCode;
    }
  }
}

class CustomDialog extends StatelessWidget {
  final String amount;
  final String type;

  CustomDialog({this.amount = 'unknow', this.type = 'unknow'});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Stack(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/red-packet/receive.png'), // Provide your image path here
                fit: BoxFit.cover,
              ),
            ),
            width: MediaQuery.of(context).size.width,
            height: 400.0,
          ),
          Positioned(
            top: 130.0,
            left: 20.0,
            right: 20.0,
            child: Column(
              children: [
                Text(
                  'Congratulation!',
                  style: TextStyle(
                    color: Color(0xff741218),
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20.0,
                ),
                SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        amount,
                        style: TextStyle(
                          color: Color(0xffC91B25),
                          fontSize: 35.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        width: 5.0,
                      ),
                      Text(
                        type,
                        style: TextStyle(
                          color: Color(0xffC91B25),
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30.0,
                ),
                Text(
                  'You Received $amount $type',
                  style: TextStyle(
                    color: Color(0xff741218),
                    fontSize: 13.0,
                    fontWeight: FontWeight.w300,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 40.0,
            left: 60.0,
            right: 60.0,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Color(0xfffcd18a),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
              ),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close the dialog when button is pressed
              },
              child: Text(
                'Got It',
                style: TextStyle(
                  color: Color(0xff741218),
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
