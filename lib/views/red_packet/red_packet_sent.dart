import 'package:flutter/material.dart';

class RedPacketSent extends StatelessWidget {
  const RedPacketSent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        //2 pill shape buttons in a row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            //label and input field
            Container(
              width: MediaQuery.of(context).size.width,
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Number of gifts',
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Total Amount',
                ),
              ),
            ),
            Text("Gift Code"),
            Row(
              children: <Widget>[],
            ),

            Text("Who can claim?"),
            //dropdown
            DropdownButton<String>(
              value: 'Everyone',
              icon: const Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(color: Colors.deepPurple),
              underline: Container(
                height: 2,
                color: Colors.deepPurple,
              ),
              //items
              onChanged: (String? newValue) {
                // model.whoCanClaim(newValue);
              },
              items: <String>['Everyone', 'Only me', 'Only friends']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Text("Select Packaging"),
            //3 images in a row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Image.asset(
                  'assets/images/red_packet/red_packet_1.png',
                  width: 100,
                  height: 100,
                ),
                Image.asset(
                  'assets/images/red_packet/red_packet_2.png',
                  width: 100,
                  height: 100,
                ),
                Image.asset(
                  'assets/images/red_packet/red_packet_3.png',
                  width: 100,
                  height: 100,
                ),
              ],
            ),

            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                // model.setSendOrReceive(true);
              },
            ),
          ],
        ),
      ],
    );

    // Container(
    //   child: Text(
    //     'RedPacketSent',
    //     style: TextStyle(
    //       fontSize: 20,
    //       color: Colors.red,

    // );
  }
}
