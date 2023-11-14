import 'package:exchangily_ui/exchangily_ui.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:paycool/constants/constants.dart';
import 'package:paycool/environments/environment.dart';
import 'package:paycool/environments/environment_type.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/multisig_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/utils/abi_util.dart';
import 'package:paycool/utils/exaddr.dart';
import 'package:paycool/utils/fab_util.dart';
import 'package:paycool/utils/keypair_util.dart';
import 'package:paycool/utils/number_util.dart';
import 'package:paycool/views/multisig/dashboard/multisig_dashboard_view.dart';
import 'package:paycool/views/multisig/multisig_wallet_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:hex/hex.dart';
import '../../../services/api_service.dart';

class CreateMultisigWalletViewModel extends BaseViewModel {
  final log = getLogger('CreateMultisigWalletViewModel');
  final sharedService = locator<SharedService>();
  final navigationService = locator<NavigationService>();
  final apiService = locator<ApiService>();
  final multisigService = locator<MultiSigService>();
  final walletService = locator<WalletService>();
  TextEditingController walletNameController = TextEditingController();
  TextEditingController feeController = TextEditingController();
  List<TextEditingController> ownerControllers = [];
  List<TextEditingController> addressControllers = [];
  Map<String, String> ownerAddress = {};
  int selectedNumberOfOwners = 1;
  int nextDropdownValue = 1;
  List<String> chains = ["Kanban", "ETH", "FAB"];
  String selectedChain = "Kanban";
  int gasPrice = environment['chains']['KANBAN']['gasPrice'];
  int gasLimit = environment['chains']['KANBAN']['gasLimit'];
  int kanbanChainId = environment['chains']['KANBAN']['chainId'];
  Box<MultisigWalletModel> multisigWallets =
      Hive.box<MultisigWalletModel>(Constants.multisigWalletBox);
  Future<void> init() async {
    log.i('MultisigViewModel init');
    addOwner();
    addOwner();
    setFee();
  }

  setFee() => feeController.text =
      NumberUtil.rawStringToDecimal((gasPrice * gasLimit).toString())
          .toString();
  addOwner() {
    ownerControllers.add(TextEditingController());
    addressControllers.add(TextEditingController());
    nextDropdownValue++;
    notifyListeners();
  }

  void removeFields(int index) {
    ownerControllers.removeAt(index);
    addressControllers.removeAt(index);
    notifyListeners();
  }

  onChanged(String value) {
    log.e('onChanged -- ${ownerControllers[0].text}}');
  }
  //KhSC9AKJJo7bQw8mvaewtUydMYBeDg17L4

  multisigWalletSubmit() {
    // validations
    // 1. check if name is empty
    if (walletNameController.text.isEmpty) {
      log.e('name is empty');
      sharedService.sharedSimpleNotification("Wallet name is empty");
      return;
    }
    // 2. check if fee is empty
    if (feeController.text.isEmpty) {
      log.e('fee is empty');
      sharedService.sharedSimpleNotification("Fee is empty");
      return;
    }
    // 3. check if owner name is empty
    if (ownerControllers[0].text.isEmpty) {
      log.e('owner name is empty');
      sharedService.sharedSimpleNotification("Owner name is empty");
      return;
    }
    // 4. check if owner address is empty
    if (addressControllers[0].text.isEmpty) {
      log.e('owner address is empty');
      sharedService.sharedSimpleNotification("Owner address is empty");
      return;
    }
    // 5. check if owner address is valid
    if (!addressControllers[0].text.startsWith('K') && isProduction) {
      log.e('owner address is invalid');
      sharedService.sharedSimpleNotification("Owner address is invalid");
      return;
    }

    for (var element in addressControllers) {
      log.w(element.text);
    }
    reviewDialog();
  }

  showGasBottomSheet() {
    showModalBottomSheet(
        context: sharedService.context,
        isScrollControlled: true,
        builder: (context) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              decoration: roundedBoxDecoration(color: Colors.grey[100]!),
              height: 300,
              child: Column(
                children: [
                  kTextField(
                      hintText: NumberUtil.rawStringToDecimal(
                              gasPrice.toString(),
                              decimalPrecision: 8)
                          .toString(),
                      labelText: "Gas price",
                      labelStyle: headText5.copyWith(color: black),
                      cursorColor: green,
                      cursorHeight: 14,
                      fillColor: Colors.transparent,
                      leadingWidget: Icon(
                        Icons.charging_station_rounded,
                        color: black,
                      ),
                      isDense: true,
                      onChanged: (value) => gasPrice = int.parse(value),
                      focusBorderColor: grey),
                  UIHelper.verticalSpaceSmall,
                  kTextField(
                      hintText: gasLimit.toString(),
                      labelText: "Gas limit",
                      labelStyle: headText5.copyWith(color: black),
                      cursorColor: green,
                      cursorHeight: 14,
                      fillColor: Colors.transparent,
                      leadingWidget: Icon(
                        Icons.charging_station_rounded,
                        color: black,
                      ),
                      isDense: true,
                      onChanged: (value) => gasLimit = int.parse(value),
                      focusBorderColor: grey),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Close')),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setFee();
                            notifyListeners();
                          },
                          child: Text('Confirm'))
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  // review popup dialog
  reviewDialog() {
    showDialog(
        context: sharedService.context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Container(
                alignment: Alignment.center,
                child: Text(
                  'Review',
                  style: headText3,
                )),
            content: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  UIHelper.verticalSpaceSmall,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Chain Name: '),
                      Text(selectedChain),
                    ],
                  ),
                  UIHelper.verticalSpaceSmall,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Wallet Name: '),
                      Text(walletNameController.text),
                    ],
                  ),
                  UIHelper.verticalSpaceSmall,
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Owners: '),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: ownerControllers.length == 1
                            ? customText(
                                text: ownerControllers[0].text,
                                textAlign: TextAlign.start)
                            : Column(
                                children: [
                                  for (var i = 0;
                                      i < ownerControllers.length;
                                      i++)
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(ownerControllers[i].text),
                                    ),
                                ],
                              ),
                      ),
                      Expanded(
                        flex: 2,
                        child: ownerControllers.length == 1
                            ? Text(addressControllers[0].text)
                            : Column(
                                children: [
                                  for (var i = 0;
                                      i < addressControllers.length;
                                      i++)
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(addressControllers[i].text),
                                    ),
                                ],
                              ),
                      ),
                    ],
                  ),
                  UIHelper.verticalSpaceSmall,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Kanban gas fee: '),
                      Text(feeController.text),
                    ],
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Confirm'),
                onPressed: () {
                  Navigator.of(context).pop();
                  signData();
                },
              ),
            ],
          );
        });
  }

  signData() async {
    log.i('signData');
    log.w('gasPrice: $gasPrice');
    log.w('gasLimit: $gasLimit');
    var fabUtil = FabUtils();
    // remove empty value from address controller
    addressControllers.removeWhere((element) => element.text.isEmpty);
    addressControllers.removeWhere((element) => element.text.isEmpty);
    // convert address controller to list of string
    var addresses = addressControllers
        .asMap()
        .entries
        .map((e) => fabUtil.fabToExgAddress(toLegacyAddress(e.value.text)))
        .toList();

    log.w('addresses: $addresses');
    var rawTxData = await multisigService.multisigData(
        addresses, selectedNumberOfOwners, selectedChain.toUpperCase());
    String exgAddress =
        await sharedService.getExgAddressFromCoreWalletDatabase();
    String ethAddress =
        await sharedService.getCoinAddressFromCoreWalletDatabase('ETH');
    var nonce = await multisigService.getChainNonce(selectedChain.toLowerCase(),
        selectedChain.toLowerCase() == 'kanban' ? exgAddress : ethAddress);
    log.w('nonce: $nonce');
    var seed = await walletService.getSeedDialog(sharedService.context);
    var keyPairKanban = getExgKeyPair(seed);

    var txKanbanHex = await signAbiHexWithPrivateKey(
      rawTxData,
      HEX.encode(keyPairKanban["privateKey"]),
      environment["chains"][selectedChain.toUpperCase()]["Safes"]
          ["SafeProxyFactory"],
      nonce,
      gasPrice,
      gasLimit,
    );

    log.w('txKanbanHex: $txKanbanHex');
    createMutlisigWallet(txKanbanHex, addresses);
  }

  createMutlisigWallet(String txKanbanHex, List<String> addresses) async {
    List<Owners> owners = [];
    for (var i = 0; i < ownerControllers.length; i++) {
      owners.add(Owners(name: ownerControllers[i].text, address: addresses[i]));
    }
    MultisigWalletModel multisigWallet = MultisigWalletModel(
        chain: selectedChain.toUpperCase(),
        name: walletNameController.text,
        // fill owner name:Address in owners
        owners: owners,
        confirmations: selectedNumberOfOwners,
        signedRawtx: txKanbanHex);
    debugPrint(multisigWallet.toJson().toString());
    var txid = await multisigService.createMultiSig(multisigWallet);
    log.w('txid: $txid');
    if (txid != null) {
      multisigWallet.txid = txid;

      var walletData =
          await multisigService.importMultisigWallet(txid, isTxid: true);

      multisigWallet.address = walletData.address;
      log.w('multisigModel: ${multisigWallet.toJson()}');

      sharedService.sharedSimpleNotification("Multisig wallet created");
      saveData(multisigWallet);
      log.e('is in the box ${multisigWallet.isInBox}');
      log.w('box ${multisigWallet.box}');
      Future.delayed(Duration(milliseconds: 750), () {
        navigationService.navigateWithTransition(
            MultisigDashboardView(data: txid),
            transitionStyle: Transition.rightToLeftWithFade,
            duration: Duration(milliseconds: 750));
      });
    }
  }

  saveData(MultisigWalletModel multisigWallet) async {
    var res = await multisigWallets.add(multisigWallet);
    log.w('res: $res');
    print('Number of wallets: ${multisigWallets.length}');
    print("first key: ${multisigWallets.keys}");
  }
}
