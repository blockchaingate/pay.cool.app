import 'package:flutter/material.dart';
import 'package:paycool/constants/api_routes.dart';
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

  // _number input controller
  TextEditingController numberController = TextEditingController();

  // _amount input controller
  TextEditingController amountController = TextEditingController();

  // _amount manul input code controller
  TextEditingController manCodeController = TextEditingController();

  //is Customize
  bool isCustomize = false;

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

  //change isCustomize
  void changeIsCustomize() {
    isCustomize = !isCustomize;
    if (isCustomize) {
      giftCode = '';
    } else {
      giftCode = getGiftCode();
    }
    notifyListeners();
  }

  // getGiftCode: return a 8 length rangom string (number and letter)
  String getGiftCode() {
    final random = Random();
    // const String characters =
    //     '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    const String characters = '0123456789';
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
  Future<void> createRedPacket() async {
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

    //if isCustomize is true, get manCodeController.text
    if (isCustomize) {
      giftCode = manCodeController.text;
      if (giftCode.isEmpty) {
        dialogService.showBasicDialog(
            title: '红包代码错误', description: '请输入红包代码', buttonTitle: '确定');
        return;
      }
    }

    //print selectCoin
    print('RedPacketViewModel selectCoin: $selectedCoin');

    //getCredentials
    String hex = await redPacketService.getCredentials(
        _context, getCoinCode(selectedCoin), _amount);

    hex = "0x78c94cb5$hex";

    var seed = await walletService.getSeedDialog(_context);

    // String redPacketContractAdd = "0x2f904065e5bedaf4f55fb0783bdb9c721c4f52b4";
    // String redPacketContractAdd = "0xc959a66685cc0e25e8a1c5bea761160c4090fdb1";

    String redPacketContractAdd = redPacketContractAddress;

    String? sign =
        await payCoolService.signSendTxBond(seed!, hex, redPacketContractAdd);
    print('RedPacketViewModel sign: $sign');

    //encodeCreateRedPacketAbiHex
    // String? abiHex = await redPacketService.encodeCreateRedPacketAbiHex(
    //     _context, giftCode, getCoinCode(selectedCoin), _amount, _number);

    String? abiHex = await redPacketService.encodeCreateRedPacketAbiHex(
        _context, giftCode, selectedCoin, _amount, _number);

    // print abiHex
    print('RedPacketViewModel CreateRedPacketAbiHex: $abiHex');

    //if abi is null, return
    if (abiHex == null) {
      //set error message
      dialogService.showBasicDialog(
          title: '红包创建错误', description: '红包创建失败', buttonTitle: '确定');
      return;
    }

    //if abi start with 0x, remove 0x
    if (abiHex.startsWith('0x')) {
      abiHex = abiHex.substring(2);
    }

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
