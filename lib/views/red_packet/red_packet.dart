import 'package:flutter/material.dart';
import 'package:paycool/views/red_packet/red_packet_sent.dart';
import 'package:paycool/views/red_packet/red_packet_viewmodel.dart';
import 'package:stacked/stacked.dart';

class RedPacketReceive extends StatelessWidget {
  const RedPacketReceive({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<RedPacketViewModel>.reactive(
        viewModelBuilder: () => RedPacketViewModel(),
        onViewModelReady: (model) => model.init(),
        builder: (context, model, child) => Scaffold(
            appBar: AppBar(
              title: const Text('Lucky Money'),
            ),
            body: ListView(
              children: <Widget>[
                //2 pill shape buttons in a row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    TextButton(
                      child: Text('Receive'),
                      onPressed: () {
                        model.setSendOrReceive(false);
                      },
                    ),
                    TextButton(
                      child: Text('Send'),
                      onPressed: () {
                        model.setSendOrReceive(true);
                      },
                    ),
                  ],
                ),
                //send or receive red packet widget
                model.isSend ? RedPacketSent() : RedPacketReceive(),
              ],
            )));
  }
}
