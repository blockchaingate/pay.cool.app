import 'package:flutter/material.dart';
import 'package:paycool/environments/coins.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/views/paycool/paycool_service.dart';
import 'package:paycool/views/red_packet/red_packet_service.dart';
import 'package:paycool/views/red_packet/red_packet_share.dart';
import 'package:stacked/stacked.dart';
import 'dart:math';
import '../../services/local_dialog_service.dart';
import '../../services/shared_service.dart';

class RedPacketSentViewModel extends BaseViewModel {
  final log = getLogger('RedPacketViewModel');

  final dialogService = locator<LocalDialogService>();

  //RedPacketService
  final redPacketService = locator<RedPacketService>();

  //PayCoolService
  final payCoolService = locator<PayCoolService>();

  //WalletService
  final walletService = locator<WalletService>();

  //SharedService
  final sharedService = locator<SharedService>();

  String giftCode = '';

  Map<int, String> coinListMap = newCoinTypeMap;

  late List<String> coinList;

  // int _number = 0;
  // int get number => _number;

  // double _amount = 0;
  // double get amount => _amount;

  // _number input controller
  TextEditingController numberController = TextEditingController();

  // _amount input controller
  TextEditingController amountController = TextEditingController();

  //selectedCoin DropdownButton value
  String selectedCoin = 'FAB';

  late BuildContext _context;

  String contactAddress = '';

  init(context) {
    print('RedPacketViewModel init');

    _context = context;

    //get coinList from coinListMap values
    coinList = coinListMap.values.toList();

    print("Coin List: $coinList");

    giftCode = getGiftCode();

    //getContactAddress
    contactAddress = redPacketService.getContactAddress();
    print('RedPacketSentViewModel contactAddress: $contactAddress');
  }

  // getGiftCode: return a 8 length rangom string (number and letter)
  String getGiftCode() {
    final random = Random();
    const String characters =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    String code = '';

    for (int i = 0; i < 8; i++) {
      final randomIndex = random.nextInt(characters.length);
      code += characters[randomIndex];
    }

    return code;
  }

  int getCoinCode(String coinType) {
    int code = 0;

    //find code from coinListMap keys
    coinListMap.forEach((key, value) {
      if (value == coinType) {
        code = key;
      }
    });

    return code;
  }

  //get input controller value
  Future<void> getNumber() async {
    //if numberController.text is empty, set error message
    if (numberController.text.isEmpty) {
      dialogService.showBasicDialog(
          title: '红包个数错误', description: '请输入红包个数', buttonTitle: '确定');
      return;
    }

    //if amountController.text is empty, set error message
    if (amountController.text.isEmpty) {
      dialogService.showBasicDialog(
          title: '红包金额错误', description: '请输入红包金额', buttonTitle: '确定');
      return;
    }

    int _number = int.parse(numberController.text);
    print('RedPacketViewModel _number: $_number');

    double _amount = double.parse(amountController.text);
    print('RedPacketViewModel _amount: $_amount');

    //print selectCoin
    print('RedPacketViewModel selectCoin: $selectedCoin');

    //getCredentials
    String hex = await redPacketService.getCredentials(
        _context, getCoinCode(selectedCoin), _amount);

    hex = "0x78c94cb5$hex";

    //getRedPacketId
    String packetId =
        await redPacketService.getRedPacketId(giftCode, selectedCoin);

    // print packetId
    print('RedPacketViewModel packetId: $packetId');

    var seed = await walletService.getSeedDialog(_context);

    // String sign = await payCoolService.signSendTx(seed!, hex, contactAddress);

    // String addTempText = "0x8d65fc45dE848e650490F1fFCD51C6Baf52EA595";
    String addTempText = "0xc959a66685cc0e25e8a1c5bea761160c4090fdb1";

    String? sign = await payCoolService.signSendTxBond(seed!, hex, addTempText);
    print('RedPacketViewModel sign: $sign');

    //encodeCreateRedPacketAbiHex
    String? abiHex = await redPacketService.encodeCreateRedPacketAbiHex(
        _context, packetId, getCoinCode(selectedCoin), _amount, _number);

    abiHex = "0x38e30a9c$abiHex";

    // print abiHex
    print('RedPacketViewModel CreateRedPacketAbiHex: $abiHex');

    //createRedPacket
    String? createRedPacket = await payCoolService
        .signSendTxBond(seed, abiHex, contactAddress, incNonce: true);

    // print createRedPacket
    print('RedPacketViewModel createRedPacket: $createRedPacket');

    Navigator.push(
      _context,
      MaterialPageRoute(
          builder: (context) => RedPacketShare(
                giftCode: giftCode,
              )),
    );

    notifyListeners();
  }

  void selectCoin(String value) {
    selectedCoin = value;

    print('RedPacketViewModel selectCoin: $selectedCoin');
    notifyListeners();
  }
}
