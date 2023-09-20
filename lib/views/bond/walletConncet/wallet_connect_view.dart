import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/environments/environment.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/bond/helper.dart';
import 'package:paycool/views/bond/progressIndicator.dart';
import 'package:paycool/views/bond/walletConncet/wallet_connect_viewmodel.dart';
import 'package:stacked/stacked.dart';

class WalletConnectView extends StatefulWidget with WidgetsBindingObserver {
  const WalletConnectView({super.key});

  @override
  State<WalletConnectView> createState() => _WalletConnectViewState();
}

class _WalletConnectViewState extends State<WalletConnectView> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ViewModelBuilder<WalletConnectViewModel>.reactive(
      onViewModelReady: (model) async {
        model.context = context;
        await model.init();
      },
      viewModelBuilder: () => WalletConnectViewModel(),
      builder: (context, model, _) => ModalProgressHUD(
        inAsyncCall: model.isBusy,
        progressIndicator: CustomIndicator.indicator(),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/bgImage.png"),
                    fit: BoxFit.cover),
              ),
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    systemOverlayStyle: SystemUiOverlayStyle.light,
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: model.isConnected && model.request != null
                        ? SizedBox(
                            width: size.width,
                            height: size.height * 0.7,
                            child: Center(
                              child: model.txHash != null
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: size.width * 0.7,
                                          child: InkWell(
                                            onTap: () {
                                              String link = environment["Bond"]
                                                          ["Endpoints"][
                                                      model
                                                          .selectedValueChain] +
                                                  model.txHash;
                                              model.launchUrlFunc(link);
                                            },
                                            child: RichText(
                                              text: TextSpan(
                                                text: model.txHash!,
                                                style: TextStyle(
                                                    fontSize: 20.0,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    decoration: TextDecoration
                                                        .underline),
                                              ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            Clipboard.setData(ClipboardData(
                                                text: model.txHash!));
                                            callSMessage(
                                                context,
                                                FlutterI18n.translate(context,
                                                    "copiedToClipboard"),
                                                duration: 2);
                                          },
                                          icon: Icon(
                                            Icons.copy,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      "Proceed to sign the transaction in your wallet",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              UIHelper.verticalSpaceLarge,
                              Text(
                                "Wallet Connect",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              UIHelper.verticalSpaceLarge,
                              Text(
                                "Please scan the QR code with your wallet to connect",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              UIHelper.verticalSpaceLarge,
                              !model.isConnected
                                  ? Container(
                                      width: size.width * 0.9,
                                      height: 45,
                                      decoration: BoxDecoration(
                                        gradient: buttoGradient,
                                        borderRadius:
                                            BorderRadius.circular(40.0),
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          model.openQr();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                        ),
                                        child: Text(
                                          "Scan QR Code",
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: size.width * 0.9,
                                      height: 45,
                                      decoration: BoxDecoration(
                                        gradient: buttoGradient,
                                        borderRadius:
                                            BorderRadius.circular(40.0),
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          model.handleConnect();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                        ),
                                        child: Text(
                                          "Approve",
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
