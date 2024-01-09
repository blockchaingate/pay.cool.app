import 'package:flutter/material.dart';

class RedPacketReceive extends StatelessWidget {
const RedPacketReceive({ super.key });

  @override
  Widget build(BuildContext context){
    return ListView(
      children: [
        //image 
        Image.asset('assets/images/red_packet.png'),

        //label and input field
        Container(
          width: MediaQuery.of(context).size.width,
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Input the code',
            ),
          ),
        ),

        //button
        ElevatedButton(
          onPressed: () {},
          child: Text('Share and Claim'),
        ),

        //label
        Text('History'),

      ],
    );
  }
}