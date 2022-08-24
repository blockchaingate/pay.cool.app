import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'account_password_page.dart';
import 'account_wallet_page.dart';

class AccountSetting extends StatefulWidget {
  @override
  _AccountSettingState createState() => _AccountSettingState();
}

class _AccountSettingState extends State<AccountSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          iconTheme: const IconThemeData(color: Color(0xff333333)),
          backgroundColor: const Color(0xfff0f3f6),
          elevation: 0,
          title: const Text("账号设置",
              style: TextStyle(color: Color(0xff333333), fontSize: 18))),
      body: Container(
          color: const Color(0xfff0f3f6),
          child:
              ListView(padding: const EdgeInsets.fromLTRB(20, 0, 20, 10), children: [
            const SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AccountWallet()));
              },
              child: Material(
                borderRadius: BorderRadius.circular(10),
                elevation: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.wallet, color: Colors.pink),
                      const SizedBox(
                        width: 20,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              child: const Text("修改钱包地址",
                                  style: TextStyle(
                                      color: Color(0xff333333),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AccountPassword()));
              },
              child: Material(
                borderRadius: BorderRadius.circular(10),
                elevation: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.lock, color: Colors.blue),
                      const SizedBox(
                        width: 20,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              child: const Text("修改密码",
                                  style: TextStyle(
                                      color: Color(0xff333333),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ])),
    );
  }
}
