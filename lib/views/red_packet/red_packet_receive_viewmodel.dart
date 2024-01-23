import 'package:flutter/material.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/views/paycool/paycool_service.dart';
import 'package:sqflite/utils/utils.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../services/local_dialog_service.dart';

class RedPacketReceiveViewModel extends BaseViewModel {
  final log = getLogger('RedPacketReceiveViewModel');

  //WalletService
  final walletService = locator<WalletService>();

  //PayCoolService
  final payCoolService = locator<PayCoolService>();

  late BuildContext _context;

  //text controller for gift code input
  TextEditingController giftCodeController = TextEditingController();

  init(context) {
    print('RedPacketReceiveViewModel init');

    _context = context;
  }

  //get gift code from input
  String getGiftCode() {
    return giftCodeController.text;
  }

  redPacketReceive(BuildContext context) async {
    var seed = await walletService.getSeedDialog(_context);
    // String hex =

    String addTempText = "0x8d65fc45dE848e650490F1fFCD51C6Baf52EA595";

    // String? sign = await payCoolService.signSendTxBond(seed!, hex, addTempText,
    //     incNonce: true);
  }
}
