import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AccountWallet extends StatefulWidget {
  @override
  _AccountWalletState createState() => _AccountWalletState();
}

class _AccountWalletState extends State<AccountWallet> {
  final FocusNode myFocusNodeWallet = FocusNode();
  TextEditingController signupWalletController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          iconTheme: const IconThemeData(color: Color(0xff333333)),
          backgroundColor: const Color(0xfff0f3f6),
          elevation: 0,
          title: const Text("修改钱包地址",
              style: TextStyle(color: Color(0xff333333), fontSize: 18))),
      body: Container(
          color: const Color(0xfff0f3f6),
          child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              children: [
                Container(
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: myFocusNodeWallet,
                          controller: signupWalletController,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.words,
                          style: const TextStyle(
                              fontFamily: "WorkSansSemiBold",
                              fontSize: 16.0,
                              color: Colors.black),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.wallet,
                              color: Colors.black,
                            ),
                            hintText: "亿币钱包地址",
                            hintStyle: TextStyle(
                                fontFamily: "WorkSansSemiBold", fontSize: 16.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                    height: 40,
                    // width: MediaQuery.of(context).size.width * 0.66,
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                    decoration: BoxDecoration(
                        // color: Color(mainColor),
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(colors: [
                          Color(0xFFcd45ff),
                          Color(0xFF7368ff),
                        ])),
                    child: const Center(
                        child: Text(
                      "修改钱包地址",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ))),
              ])),
    );
  }
}
