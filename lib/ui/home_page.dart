// import 'package:flutter/material.dart';
// import 'package:paycool/style/theme.dart' as Theme;
// import '../widgets/card.dart';
// import 'share_page.dart';
// import 'pdf_page.dart';
// import 'event_detail_page.dart';
// import 'account_setting_page.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(
//       //   title: Text('Title'),
//       // ),
//       body: Container(
//           color: Color(0xfff0f3f6),
//           // decoration: new BoxDecoration(
//           //   gradient: new LinearGradient(
//           //       colors: [
//           //         Theme.Colors.loginGradientStart.withOpacity(0.1),
//           //         Theme.Colors.loginGradientEnd.withOpacity(0.1)
//           //       ],
//           //       begin: const FractionalOffset(0.0, 0.0),
//           //       end: const FractionalOffset(1.0, 1.0),
//           //       stops: [0.0, 1.0],
//           //       tileMode: TileMode.clamp),
//           // ),
//           child: ListView(
//             padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
//             children: [
//               SizedBox(
//                 height: 20,
//               ),
//               Container(
//                   child: Text("您好！",
//                       style:
//                           TextStyle(color: Color(0xff776666), fontSize: 18))),
//               SizedBox(
//                 height: 10,
//               ),
//               Container(
//                   child: Text("Jack@exchangily.ca",
//                       style: TextStyle(
//                           color: Color(0xff333333),
//                           fontSize: 30,
//                           fontWeight: FontWeight.bold))),
//               SizedBox(
//                 height: 20,
//               ),
//               ExgCard(),
//               SizedBox(
//                 height: 20,
//               ),
//               Container(
//                   child: Text("活动选项",
//                       style:
//                           TextStyle(color: Color(0xff776666), fontSize: 18))),
//               SizedBox(
//                 height: 10,
//               ),
//               InkWell(
//                 onTap: () {
//                   Navigator.push(context,
//                       MaterialPageRoute(builder: (context) => EventDetail()));
//                 },
//                 child: Material(
//                   borderRadius: BorderRadius.circular(10),
//                   elevation: 5,
//                   child: Container(
//                     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//                     child: Row(
//                       children: [
//                         FaIcon(FontAwesomeIcons.coins,
//                             color: Color(0xFF7F00FF)),
//                         SizedBox(
//                           width: 20,
//                         ),
//                         Column(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Container(
//                                 child: Text("活动收益",
//                                     style: TextStyle(
//                                         color: Color(0xff333333),
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold))),
//                             SizedBox(
//                               height: 2,
//                             ),
//                             Container(
//                                 child: Text("活动收益详细情况以及下线人数",
//                                     style: TextStyle(
//                                         color: Color(0xff888888),
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.bold))),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               InkWell(
//                 onTap: () {
//                   Navigator.push(context,
//                       MaterialPageRoute(builder: (context) => PdfPage()));
//                 },
//                 child: Material(
//                   borderRadius: BorderRadius.circular(10),
//                   elevation: 5,
//                   child: Container(
//                     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//                     child: Row(
//                       children: [
//                         FaIcon(FontAwesomeIcons.ruler,
//                             color: Color(0xFFE100FF)),
//                         SizedBox(
//                           width: 20,
//                         ),
//                         Column(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Container(
//                                 child: Text("活动规则",
//                                     style: TextStyle(
//                                         color: Color(0xff333333),
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold))),
//                             SizedBox(
//                               height: 2,
//                             ),
//                             Container(
//                                 child: Text("活动规则详解pdf",
//                                     style: TextStyle(
//                                         color: Color(0xff888888),
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.bold))),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               InkWell(
//                 onTap: () {
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => AccountSetting()));
//                 },
//                 child: Material(
//                   borderRadius: BorderRadius.circular(10),
//                   elevation: 5,
//                   child: Container(
//                     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//                     child: Row(
//                       children: [
//                         FaIcon(FontAwesomeIcons.userAlt,
//                             color: Color(0xFF88dd77)),
//                         SizedBox(
//                           width: 20,
//                         ),
//                         Column(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Container(
//                                 child: Text("账号设置",
//                                     style: TextStyle(
//                                         color: Color(0xff333333),
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold))),
//                             SizedBox(
//                               height: 2,
//                             ),
//                             Container(
//                                 child: Text("修改钱包地址等信息",
//                                     style: TextStyle(
//                                         color: Color(0xff888888),
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.bold))),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               Container(
//                   child: Text("活动推广",
//                       style:
//                           TextStyle(color: Color(0xff776666), fontSize: 18))),
//               SizedBox(
//                 height: 10,
//               ),
//               InkWell(
//                 onTap: () {
//                   Navigator.push(context,
//                       MaterialPageRoute(builder: (context) => ExgShare()));
//                 },
//                 child: Material(
//                   borderRadius: BorderRadius.circular(10),
//                   elevation: 5,
//                   child: Container(
//                     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//                     child: Row(
//                       children: [
//                         FaIcon(FontAwesomeIcons.share, color: Colors.pink),
//                         SizedBox(
//                           width: 20,
//                         ),
//                         Column(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Container(
//                                 child: Text("活动推广",
//                                     style: TextStyle(
//                                         color: Color(0xff333333),
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold))),
//                             SizedBox(
//                               height: 2,
//                             ),
//                             Container(
//                                 child: Text("分享活动推广赚取收益",
//                                     style: TextStyle(
//                                         color: Color(0xff888888),
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.bold))),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: 30,
//               ),
//             ],
//           )),
//     );
//   }
// }
