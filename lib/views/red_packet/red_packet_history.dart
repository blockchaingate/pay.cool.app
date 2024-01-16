import 'package:flutter/material.dart';

// class RedPacketHistory extends StatelessWidget {
//   const RedPacketHistory({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//           iconTheme: IconThemeData(
//             color: Colors.black, //change your color here
//           ),
//           centerTitle: true,
//           backgroundColor: Color(0xffF7F8FA),
//           title: Container(
//               // width: 101,
//               height: 22,
//               child: Text(
//                 "History",
//                 textAlign: TextAlign.center,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   fontFamily: "",
//                   fontSize: 17,
//                   color: Color(0xFF000000),
//                 ),
//               )),
//           actions: <Widget>[
//             Container(
//                 width: 24,
//                 height: 24,
//                 child: Image.network(
//                     "https://lanhu.oss-cn-beijing.aliyuncs.com/FigmaDDSSlicePNG30bbb9a1445159042edfdf773bdc1f60.png",
//                     fit: BoxFit.fill)),
//             Container(
//                 width: 20,
//                 height: 20,
//                 child: Image.network(
//                     "https://lanhu.oss-cn-beijing.aliyuncs.com/FigmaDDSSlicePNG3c56e1f52f88041570262df27bf07ced.png",
//                     fit: BoxFit.fill)),
//           ]),
//       body: Column(
//         children: <Widget>[
//           // Add the TabBar widget under the AppBar
//           TabBar(
//             controller: _tabController,
//             tabs: [
//               Tab(text: 'Tab 1'),
//               Tab(text: 'Tab 2'),
//               Tab(text: 'Tab 3'),
//             ],
//           ),
//           // Add the TabBarView widget to display the content for each tab
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 // Content for Tab 1
//                 Center(
//                   child: Text('Tab 1 Content'),
//                 ),
//                 // Content for Tab 2
//                 Center(
//                   child: Text('Tab 2 Content'),
//                 ),
//                 // Content for Tab 3
//                 Center(
//                   child: Text('Tab 3 Content'),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),

//       // Column(
//       //   children: [
//       //     //2 text buttons
//       //     Row(
//       //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       //       children: <Widget>[
//       //         TextButton(
//       //           child: Text('Receive'),
//       //           onPressed: () {
//       //             // model.setSendOrReceive(false);
//       //           },
//       //         ),
//       //         TextButton(
//       //           child: Text('Send'),
//       //           onPressed: () {
//       //             // model.setSendOrReceive(true);
//       //           },
//       //         ),
//       //       ],
//       //     ),
//       //     ListView.builder(
//       //       itemCount: 10,
//       //       itemBuilder: (context, index) {
//       //         return ListTile(
//       //           leading: Icon(Icons.monetization_on),
//       //           title: Text('Red Packet $index'),
//       //           subtitle: Text('From: xxx'),
//       //           trailing: Text('Amount: 100'),
//       //         );
//       //       },
//       //     )
//       //   ],
//       // ),
//     );
//   }
// }

class RedPacketHistory extends StatefulWidget {
  @override
  _RedPacketHistoryState createState() => _RedPacketHistoryState();
}

class _RedPacketHistoryState extends State<RedPacketHistory>
    with SingleTickerProviderStateMixin {
  // Create a controller for the TabBar
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this); // Change the length as per your tabs count
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          centerTitle: true,
          backgroundColor: Color(0xffF7F8FA),
          title: Container(
              // width: 101,
              height: 22,
              child: Text(
                "History",
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: "",
                  fontSize: 17,
                  color: Color(0xFF000000),
                ),
              )),
          actions: <Widget>[
            Container(
                width: 24,
                height: 24,
                child: Image.network(
                    "https://lanhu.oss-cn-beijing.aliyuncs.com/FigmaDDSSlicePNG30bbb9a1445159042edfdf773bdc1f60.png",
                    fit: BoxFit.fill)),
            Container(
                width: 20,
                height: 20,
                child: Image.network(
                    "https://lanhu.oss-cn-beijing.aliyuncs.com/FigmaDDSSlicePNG3c56e1f52f88041570262df27bf07ced.png",
                    fit: BoxFit.fill)),
          ]),
      body: Container(
        color: Color(0xffF7F8FA),
        child: Column(
          children: <Widget>[
            // Add the TabBar widget under the AppBar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              // color: Colors.amber,
              child: TabBar(
                tabAlignment: TabAlignment.start,
                // dividerColor: Color(0xff333FEA),
                padding: EdgeInsets.symmetric(horizontal: 0),
                labelPadding: EdgeInsets.symmetric(horizontal: 10),
                indicatorPadding: EdgeInsets.symmetric(horizontal: 20),
                dividerHeight: 0,
                controller: _tabController,
                isScrollable: true,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: Color(0xff333FEA),
                labelStyle: TextStyle(
                  fontSize: 16,
                  color: Color(0xff333FEA),
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 16,
                  color: Color(0xff000000),
                  fontWeight: FontWeight.bold,
                ),
                tabs: [
                  Tab(
                    text: 'Received',
                  ),
                  Tab(text: 'Sended'),
                ],
              ),
            ),
            // Add the TabBarView widget to display the content for each tab
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Content for Tab 1
                  Container(
                    padding: EdgeInsets.only(bottom: 30),
                    child: ListView.builder(
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text('From 0x1234....123456',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xff000000),
                              )),
                          subtitle: Text('2023.12.12 08:30:12',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xff9CA1B3),
                              )),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.monetization_on,
                                  size: 24, color: Color(0xff50AF95)),
                              const SizedBox(width: 3),
                              Text('+1.01USDT',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff000000),
                                  )),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  // Content for Tab 2
                  Center(
                    child: Text('Tab 2 Content'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
