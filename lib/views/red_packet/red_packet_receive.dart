import 'package:flutter/material.dart';
import 'package:paycool/views/red_packet/red_packet_history.dart';
import 'package:paycool/views/red_packet/red_packet_receive_viewmodel.dart';
import 'package:stacked/stacked.dart';

class RedPacketReceive extends StatelessWidget {
  const RedPacketReceive({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
        viewModelBuilder: () => RedPacketReceiveViewModel(),
        onModelReady: (model) => model.init(),
        builder: (context, model, child) => ListView(
              padding: const EdgeInsets.all(12.0),
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              children: [
                //image
                //
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  // decoration: BoxDecoration(
                  //   image: DecorationImage(
                  //     image: AssetImage('assets/images/red-packet/skin1-L.png'),
                  //     fit: BoxFit.fill,
                  //   ),
                  // ),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/red-packet/skin1-L.png',
                        width: 220,
                        height: 320,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text("Input the code",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xff000000),
                      )),
                ),

                Container(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Color(0xffffffff),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  // width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 150,
                        child: TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Please input the code',
                            labelStyle: TextStyle(
                              fontSize: 14,
                              color: Color(0xff9CA1B3),
                            ),
                          ),
                        ),
                      ),
                      //paste button
                      TextButton(
                        onPressed: () {},
                        child: Text('Paste',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xff333FEA),
                            )),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                //button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Color(0xff333FEA),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () {},
                  child: Text('Share and Claim'),
                ),

                //label
                Center(
                  child:
                      // Text('History')
                      // text button
                      TextButton(
                    onPressed: () {
                      //to RedPacketHistory widget
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RedPacketHistory(),
                        ),
                      );
                    },
                    child: Text('History',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xff333FEA),
                        )),
                  ),
                ),
              ],
            ));
  }
}
