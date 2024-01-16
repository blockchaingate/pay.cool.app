import 'package:flutter/material.dart';
import 'package:paycool/views/red_packet/red_packet_receive.dart';
import 'package:paycool/views/red_packet/red_packet_sent.dart';
import 'package:paycool/views/red_packet/red_packet_viewmodel.dart';
import 'package:stacked/stacked.dart';

class RedPacket extends StatelessWidget {
  const RedPacket({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<RedPacketViewModel>.reactive(
        viewModelBuilder: () => RedPacketViewModel(),
        onViewModelReady: (model) => model.init(),
        builder: (context, model, child) => Scaffold(
            appBar: AppBar(
                iconTheme: IconThemeData(
                  color: Colors.black, //change your color here
                ),
                centerTitle: true,
                backgroundColor: Color(0xffF7F8FA),
                title: Container(
                    // width: 101,
                    height: 22,
                    child: Text(
                      "Lucky money",
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
              child: ListView(
                padding: EdgeInsets.only(top: 20),
                children: <Widget>[
                  //2 pill shape buttons in a row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          foregroundColor:
                              model.isSend ? Colors.black : Colors.white,
                          backgroundColor:
                              Color(model.isSend ? 0xffE9EBF9 : 0xff333FEA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                        ),
                        child: SizedBox(
                            width: 60, child: Center(child: Text('Receive'))),
                        onPressed: () {
                          model.setSendOrReceive(false);
                        },
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          foregroundColor:
                              model.isSend ? Colors.white : Colors.black,
                          backgroundColor:
                              Color(model.isSend ? 0xff333FEA : 0xffE9EBF9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                        ),
                        child: SizedBox(
                            width: 60, child: Center(child: Text('Send'))),
                        onPressed: () {
                          model.setSendOrReceive(true);
                        },
                      ),
                    ],
                  ),
                  //send or receive red packet widget
                  model.isSend ? RedPacketSent() : RedPacketReceive(),
                ],
              ),
            )));
  }
}
