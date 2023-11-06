import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:majascan/majascan.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/coin_service.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/utils/fab_util.dart';
import 'package:paycool/views/paycool/paycool_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class WalletConnectViewModel extends BaseViewModel {
  WalletConnectViewModel({BuildContext? context});

  BuildContext? context;
  WalletService walletService = locator<WalletService>();
  final paycoolService = locator<PayCoolService>();
  final NavigationService navigationService = locator<NavigationService>();

  TextEditingController controller = TextEditingController();

  Web3Wallet? web3Wallet;
  SessionProposalEvent? proposal;
  SessionRequestEvent? request;
  ApproveResponse? approveResponse;

  String? method;
  String? chainId;

  bool isConnected = false;

  String? fabAddress;
  String? ethAddress;

  String? txHash;
  String? selectedValueChain;

  bool stopper = false;

  final Queue<SessionRequestEvent> _requestQueue = Queue<SessionRequestEvent>();

  init() {
    setWalletConnect();
  }

  @override
  void dispose() {
    if (approveResponse != null) {
      web3Wallet!.disconnectSession(
          topic: approveResponse!.topic,
          reason: WalletConnectError(code: 6000, message: "user Disconnected"));
    }
    controller.dispose();
    super.dispose();
  }

  Future<void> setWalletConnect() async {
    fabAddress = FabUtils()
        .fabToExgAddress(await CoinService().getCoinWalletAddress("FAB"));
    ethAddress = await CoinService().getCoinWalletAddress("ETH");

    web3Wallet = await Web3Wallet.createInstance(
        projectId: "3acbabd1deb4672edfd4ca48226cfc0f",
        metadata: PairingMetadata(
            name: 'Pay.Cool',
            description: 'Wallet',
            url: 'www.walletconnect.com',
            icons: []));

    web3Wallet!.onSessionProposal.subscribe(_onSessionProposal);
    web3Wallet!.onSessionRequest.subscribe(_onSessionRequest);
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
  }

  void _onSessionProposal(SessionProposalEvent? args) async {
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
        return WillPopScope(
          onWillPop: () async {
            // Return false to prevent dialog dismissal via back button
            return false;
          },
          child: AlertDialog(
            title: Text('DNB'),
            content: SingleChildScrollView(
              child: Column(
                children: [
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
          ),
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

  bool _isProcessing = false;

  Future<void> _onSessionRequest(SessionRequestEvent? args,
      {bool repeat = false}) async {
    if (!repeat) _requestQueue.add(args!); // Add the request to the queue

    if (!_isProcessing) {
      _isProcessing = true;

      _requestQueue.first;

      request = _requestQueue.first;
      await eventFunction(request).whenComplete(() async {
        if (_requestQueue.isNotEmpty) {
          _isProcessing = false;
          await _onSessionRequest(_requestQueue.first, repeat: true);
        }
      });

      _isProcessing = false;
    }

    notifyListeners();
  }

  Future<void> eventFunction(SessionRequestEvent? args) async {
    bool? userApproved = await showConfirmationDialog(context!, args!);

    setBusy(true);

    try {
      if (userApproved!) {
        var seed = await walletService.getSeedDialog(context!);

        selectedValueChain =
            setChainShort(int.parse(args.chainId.substring(7)));

        await paycoolService
            .signSendTxBond(seed!, args.params[0]["data"], args.params[0]["to"],
                chain: selectedValueChain!)
            .then((value) async {
          txHash = value;

          setBusy(false);
        });
        _requestQueue.removeFirst(); // Remove the processed request
      } else {
        setBusy(false);
        _requestQueue.clear();
      }
    } catch (e) {
      setBusy(false);
    }
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
        await pair(uri);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> pair(String uri) async {
    try {
      await web3Wallet!.core.pairing.pair(uri: Uri.parse(uri));
      isConnected = true;
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> handleConnect() async {
    try {
      var chains = proposal!.params.requiredNamespaces["eip155"]!.chains;
      var methods = proposal!.params.requiredNamespaces["eip155"]!.methods;
      var events = proposal!.params.requiredNamespaces["eip155"]!.events;

      List<String>? accounts = [];

      for (var i = 0; i < chains!.length; i++) {
        if (chains[i].contains("eip155:1")) {
          accounts.add("${chains[i]}:$ethAddress");
        } else if (chains[i].contains("eip155:211")) {
          accounts.add("${chains[i]}:$fabAddress");
        } else if (chains[i].contains("eip155:56")) {
          accounts.add("${chains[i]}:$ethAddress");
        }
      }

      Map<String, Namespace> namespaces = {};
      for (var key in proposal!.params.requiredNamespaces.keys) {
        final namespace = Namespace(
          accounts: accounts,
          methods: methods,
          events: events,
        );
        namespaces[key] = namespace;
      }

      approveResponse = await web3Wallet!
          .approveSession(id: proposal!.id, namespaces: namespaces);
    } catch (e) {
      ScaffoldMessenger.of(context!).showSnackBar(
        SnackBar(
          content: Text("Check QR Code, its not valid $e"),
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

  Future<void> signRequestHandler(String topic, dynamic parameters) async {
    print(topic);
    print(parameters);
  }
}
