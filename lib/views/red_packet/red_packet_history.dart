import 'package:flutter/material.dart';

class RedPacketReceive extends StatelessWidget {
  const RedPacketReceive({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //2 text buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            TextButton(
              child: Text('Receive'),
              onPressed: () {
                // model.setSendOrReceive(false);
              },
            ),
            TextButton(
              child: Text('Send'),
              onPressed: () {
                // model.setSendOrReceive(true);
              },
            ),
          ],
        ),
        ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Icon(Icons.monetization_on),
              title: Text('Red Packet $index'),
              subtitle: Text('From: xxx'),
              trailing: Text('Amount: 100'),
            );
          },
        )
      ],
    );
  }
}
