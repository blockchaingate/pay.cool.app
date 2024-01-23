import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/providers/app_state_provider.dart';
import 'package:paycool/providers/app_state_provider.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/views/paycool/paycool_service.dart';
import 'package:paycool/views/red_packet/red_packet_service.dart';
import 'package:sqflite/utils/utils.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../services/local_dialog_service.dart';

class RedPacketReceiveViewModel extends BaseViewModel {
  final log = getLogger('RedPacketReceiveViewModel');

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

  late AppStateProvider appStateProvider;

  init(context) {
    print('RedPacketReceiveViewModel init');

    _context = context;
  }

  //get gift code from input
  String getGiftCode() {
    return giftCodeController.text;
  }

  redPacketReceive(BuildContext context) async {
    print('RedPacketReceiveViewModel redPacketReceive');
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

    var seed = await walletService.getSeedDialog(_context);

    //get user wallet address

    //call getClaimRedPacketSignedMessage
    // String signedMessage =
    //     await redPacketService.getClaimRedPacketSignedMessage(giftCode, seed!);

    // String hex = await redPacketService.encodeReceiveRedPacketAbiHex();

    String addTempText = "0x8d65fc45dE848e650490F1fFCD51C6Baf52EA595";

    // String? sign = await payCoolService.signSendTxBond(seed!, hex, addTempText,
    //     incNonce: true);
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
