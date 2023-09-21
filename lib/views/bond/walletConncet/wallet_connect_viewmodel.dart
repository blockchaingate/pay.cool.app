import 'package:flutter/material.dart';
import 'package:majascan/majascan.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/coin_service.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/views/paycool/paycool_service.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class WalletConnectViewModel extends BaseViewModel {
  WalletConnectViewModel({BuildContext? context});

  BuildContext? context;
  WalletService walletService = locator<WalletService>();
  final paycoolService = locator<PayCoolService>();

  Web3Wallet? web3Wallet;
  SessionProposalEvent? proposal;
  SessionRequestEvent? request;
  SessionData? sessionData;

  String? method;
  String? chainId;

  String? topic;
  bool isConnected = false;

  String? fabAddress;
  String? ethAddress;

  String? txHash;
  String? selectedValueChain;

  List<SessionRequestEvent> eventList = [];

  init() async {
    setWalletConnect();
  }

  @override
  void dispose() {
    if (topic != null) {
      web3Wallet!.disconnectSession(
          topic: topic!,
          reason: WalletConnectError(code: 6000, message: "user Disconnected"));
    }
    super.dispose();
  }

  Future<void> setWalletConnect() async {
    print("step1");

    fabAddress = await CoinService().getCoinWalletAddress("FAB");
    ethAddress = await CoinService().getCoinWalletAddress("ETH");

    web3Wallet = await Web3Wallet.createInstance(
        projectId: "3acbabd1deb4672edfd4ca48226cfc0f",
        metadata: PairingMetadata(
            name: 'Pay.Cool',
            description: 'Wallet',
            url: 'www.walletconnect.com',
            icons: []));

    web3Wallet!.onSessionProposal.subscribe(_onSessionProposal);
    web3Wallet!.registerRequestHandler(
        chainId: "eip155:211",
        method: "kanban_sendTransaction",
        handler: signRequestHandler);
    web3Wallet!.registerRequestHandler(
        chainId: "eip155:1",
        method: "eth_sendTransaction",
        handler: signRequestHandler);
    web3Wallet!.registerRequestHandler(
        chainId: "eip155:56",
        method: "eth_sendTransaction",
        handler: signRequestHandler);
    web3Wallet!.onSessionRequest.subscribe(_onSessionRequest);
  }

  void _onSessionProposal(SessionProposalEvent? args) async {
    print("step2");
    if (args != null) {
      proposal = args;
      notifyListeners();
    }
  }

  Future<bool?> showConfirmationDialog(
      BuildContext context, SessionRequestEvent args) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('DNB'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text('Do you want to continue?'),
                Text(
                  "To: ${args.params[0]["to"]}",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  "Data: ${args.params[0]["data"]}",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Return false if "No" is pressed.
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // Return true if "Yes" is pressed.
              },
            ),
          ],
        );
      },
    );
  }

  String setChainShort(int chainId) {
    if (chainId == 1) {
      return "ETH";
    } else if (chainId == 211) {
      return "KANBAN";
    } else if (chainId == 56) {
      return "BNB";
    }

    return "KANBAN";
  }

  Future<void> _onSessionRequest(SessionRequestEvent? args) async {
    print("step4");

    eventList.add(args!);
    request = args;

    notifyListeners();

    if (eventList.length == 2) {
      approveFunction(eventList[0]);
    }
  }

  Future<bool> approveFunction(SessionRequestEvent? args) async {
    bool? userApproved = await showConfirmationDialog(context!, args!);

    setBusy(true);

    if (userApproved!) {
      var seed = await walletService.getSeedDialog(context!);

      selectedValueChain = setChainShort(int.parse(args.chainId.substring(7)));

      await paycoolService
          .signSendTxBond(seed!, args.params[0]["data"], args.params[0]["to"],
              chain: selectedValueChain!)
          .then((value) async {
        print(value);
        print("==============txHash======================");
        txHash = value;
        print("==============txHash======================");
        setBusy(false);
        await purchaseFunction(eventList[1]);
      });
    } else {
      // The user pressed "No" or closed the dialog, handle accordingly.
      print('User did not approve.');
    }
    return true;
  }

  Future<bool> purchaseFunction(SessionRequestEvent? args) async {
    bool? userApproved = await showConfirmationDialog(context!, args!);

    if (userApproved!) {
      var seed = await walletService.getSeedDialog(context!);

      setBusy(true);

      selectedValueChain = setChainShort(int.parse(args.chainId.substring(7)));

      await paycoolService
          .signSendTxBond(seed!, args.params[0]["data"], args.params[0]["to"],
              chain: selectedValueChain!)
          .then((value) async {
        print(value);
        print("==============txHash======================");
        txHash = value;
        print("==============txHash======================");
        setBusy(false);
      });
    } else {
      // The user pressed "No" or closed the dialog, handle accordingly.
      print('User did not approve.');
    }
    return true;
  }

  Future<void> openQr() async {
    String? uri = await MajaScan.startScan(
      title: "Scan QR Code",
      barColor: Colors.red,
      titleColor: Colors.green,
      qRCornerColor: Colors.red,
      qRScannerColor: Colors.green,
      flashlightEnable: true,
      scanAreaScale: 0.7,
    );

    try {
      if (uri != null && uri != "-1") {
        await web3Wallet!.core.pairing.pair(uri: Uri.parse(uri));
        isConnected = true;
        notifyListeners();
      }
    } catch (e) {
      openQr();
    }
  }

  Future<void> handleConnect() async {
    print("step3");
    try {
      Map<String, Namespace> namespaces = {};
      for (var key in proposal!.params.requiredNamespaces.keys) {
        final namespace = Namespace(
          accounts: [
            "eip155:1:$ethAddress",
            "eip155:211:$fabAddress",
            "eip155:56:$ethAddress",
          ],
          methods: [
            'eth_sendTransaction',
            'eth_signTransaction',
            'personal_sign',
            'eth_sign',
            "kanban_sendTransaction",
            "personal_sign"
          ],
          events: ['accountsChanged', 'chainChanged'],
        );
        namespaces[key] = namespace;
      }

      var result = await web3Wallet!
          .approveSession(id: proposal!.id, namespaces: namespaces);

      topic = result.topic;
      sessionData = result.session;
    } catch (e) {
      ScaffoldMessenger.of(context!).showSnackBar(
        SnackBar(
          content: Text("Check QR Code, its not valid"),
        ),
      );
      isConnected = false;
    }
    notifyListeners();
  }

  Future<void> launchUrlFunc(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> signRequestHandler(String topic, dynamic parameters) async {}
}
