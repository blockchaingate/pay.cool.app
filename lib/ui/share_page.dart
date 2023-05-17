// import 'package:flutter/material.dart';
// import 'dart:io';
// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// // import 'package:flutter_svg/svg.dart';
// import 'package:screenshot/screenshot.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
// import 'package:share/share.dart';
// import 'package:qr_flutter/qr_flutter.dart';

// class ExgShare extends StatefulWidget {
//   @override
//   _ExgShareState createState() => _ExgShareState();
// }

// class _ExgShareState extends State<ExgShare> {
//   File _imageFile;

//   //Create an instance of ScreenshotController
//   ScreenshotController screenshotController = ScreenshotController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xfff3f3f3),
//       appBar: AppBar(
//         iconTheme: IconThemeData(color: Color(0xff333333)),
//         title: Text(
//           "分享二维码",
//           style: TextStyle(color: Color(0xff333333)),
//         ),
//         backgroundColor: Colors.transparent,
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: Container(
//         color: Color(0xfff3f3f3),
//         child: Column(
//           children: [
//             Expanded(
//               child: Screenshot(
//                 controller: screenshotController,
//                 child: Container(
//                   color: Color(0xfff3f3f3),
//                   child: new Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: <Widget>[
//                         Container(
//                           // padding: EdgeInsets.symmetric(
//                           //     horizontal: 20, vertical: 40),
//                           color: Color(0xfff3f3f3),
//                           child: Column(
//                             children: <Widget>[
//                               Image.asset(
//                                 "assets/img/login_logo.png",
//                                 width: MediaQuery.of(context).size.width * 0.24,
//                               ),
//                               SizedBox(height: 10),
//                               Text("亿币贝库系统",
//                                   style: TextStyle(
//                                       color: Color(0xff333333),
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 30)),
//                               SizedBox(height: 20),
//                               Container(
//                                 width: MediaQuery.of(context).size.width * 0.66,
//                                 child: Text(
//                                   "我们的会员人人都可以去谈生态应用的项目（当然前期你要学会一系列的 区块链及加密货币知识），拿丰厚的佣金。",
//                                   maxLines: 5,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                               SizedBox(height: 20),
//                               ClipRRect(
//                                 borderRadius: BorderRadius.circular(20),
//                                 child: Container(
//                                   width:
//                                       MediaQuery.of(context).size.width * 0.66,
//                                   height:
//                                       MediaQuery.of(context).size.width * 0.66,
//                                   padding: EdgeInsets.all(10),
//                                   decoration: BoxDecoration(
//                                       color: Color(0xffffffff),
//                                       boxShadow: [
//                                         new BoxShadow(
//                                             offset: Offset(0.0, 5.0),
//                                             blurRadius: 8.0,
//                                             spreadRadius: 1.0,
//                                             color: Color(0x22666666)),
//                                       ]),
//                                   child: QrImageView(
//                                       backgroundColor: Color(0xffffffff),
//                                       data: "www.exchangily.com",
//                                       version: QrVersions.auto,
//                                       size: 300,
//                                       gapless: true,
//                                       errorStateBuilder: (context, err) {
//                                         return Container(
//                                           child: Center(
//                                             child: Text("somethingWentWrong",
//                                                 textAlign: TextAlign.center),
//                                           ),
//                                         );
//                                       }),
//                                 ),
//                               ),
//                               SizedBox(height: 30),
//                               Text(
//                                 "我的邀请码: 5678",
//                                 style: TextStyle(
//                                     color: Color(0xFFcd45ff), fontSize: 16),
//                               ),
//                               // SizedBox(height: 10),
//                               // Text("Lorem ipsum dolor sit amet"),
//                             ],
//                           ),
//                         ),
//                         // _imageFile != null ? Image.file(_imageFile) : Container(),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             InkWell(
//               child: Container(
//                   height: 40,
//                   width: MediaQuery.of(context).size.width * 0.66,
//                   margin: EdgeInsets.fromLTRB(30, 0, 30, 30),
//                   decoration: BoxDecoration(
//                       // color: Color(mainColor),
//                       borderRadius: BorderRadius.circular(10),
//                       gradient: new LinearGradient(colors: [
//                         const Color(0xFFcd45ff),
//                         const Color(0xFF7368ff),
//                       ])),
//                   child: Center(
//                       child: Text(
//                     "分享二维码",
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold),
//                   ))),
//               onTap: () {
//                 _imageFile = null;
//                 screenshotController.capture().then((File image) async {
//                   debugPrint("Capture Done");
//                   debugPrint("image : ");
//                   debugPrint(image.toString());
//                   debugPrint(image.path);
//                   setState(() {
//                     _imageFile = image;
//                   });
//                   final result = await ImageGallerySaver.saveImage(image
//                       .readAsBytesSync()); // Save image to gallery,  Needs plugin  https://pub.dev/packages/image_gallery_saver
//                   debugPrint("File Saved to Gallery");
//                   debugPrint("result: ");
//                   debugPrint(result.toString());

//                   Share.shareFiles([image.path], text: 'Great picture');
//                 }).catchError((onError) {
//                   debugPrint(onError);
//                 });
//               },
//             ),
//           ],
//         ),
//       ),
//       // floatingActionButton: FloatingActionButton(
//       //   onPressed: () {
//       //     // _incrementCounter();
//       //     _imageFile = null;
//       //     screenshotController.capture().then((File image) async {
//       //       debugPrint("Capture Done");
//       //       debugPrint("image : ");
//       //       debugPrint(image.toString());
//       //       debugPrint(image.path);
//       //       setState(() {
//       //         _imageFile = image;
//       //       });
//       //       final result = await ImageGallerySaver.saveImage(image
//       //           .readAsBytesSync()); // Save image to gallery,  Needs plugin  https://pub.dev/packages/image_gallery_saver
//       //       debugPrint("File Saved to Gallery");
//       //       debugPrint("result: ");
//       //       debugPrint(result.toString());

//       //       Share.shareFiles([image.path], text: 'Great picture');
//       //     }).catchError((onError) {
//       //       debugPrint(onError);
//       //     });
//       //   },
//       //   tooltip: 'Increment',
//       //   child: Icon(Icons.add),
//       // ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
