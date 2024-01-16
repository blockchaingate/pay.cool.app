import 'package:flutter/material.dart';
import 'package:paycool/views/red_packet/red_packet_share.dart';

class RedPacketSent extends StatelessWidget {
  const RedPacketSent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(10),
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      children: <Widget>[
        titleWidget("Number of gifts"),
        //label and input field
        input("Enter Number"),
        titleWidget("Total Amount"),
        input("Total Amount"),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            titleWidget("Gift Code"),
            TextButton(
              child: Text('Customize',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xff333FEA),
                  )),
              onPressed: () {
                // model.setSendOrReceive(true);
              },
            ),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            for (int i = 0; i < 8; i++)
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Color(0xffFF5757),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text((i + 1).toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xffffffff),
                      )),
                ),
              )
          ],
        ),
        SizedBox(height: 10),
        titleWidget("Who can claim?"),
        //dropdown
        Container(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          decoration: BoxDecoration(
            color: Color(0xffffffff),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<String>(
            value: 'Everyone',
            iconSize: 24,
            elevation: 16,
            style: const TextStyle(color: Colors.black),
            underline: Container(
              height: 0,
              color: Colors.transparent,
            ),
            isExpanded: true,
            onChanged: (String? newValue) {
              // model.whoCanClaim(newValue);
            },
            items: <String>['Everyone', 'Only me', 'Only friends']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(value),
                    Icon(Icons.arrow_drop_down, color: Colors.black),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        titleWidget("Select Packaging"),
        //3 images in a row
        Container(
          // height: 100,
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Flexible(
                flex: 1,
                child: Image.asset(
                  'assets/images/red-packet/skin1.png',
                  width: MediaQuery.of(context).size.width / 3,
                  height: MediaQuery.of(context).size.width / 2.6,
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                flex: 1,
                child: Image.asset(
                  'assets/images/red-packet/skin2.png',
                  width: MediaQuery.of(context).size.width / 3,
                  height: MediaQuery.of(context).size.width / 2.6,
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                flex: 1,
                child: Image.asset(
                  'assets/images/red-packet/skin3.png',
                  width: MediaQuery.of(context).size.width / 3,
                  height: MediaQuery.of(context).size.width / 2.6,
                  fit: BoxFit.fill,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Color(0xff333FEA),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: Text('Confirm',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xffffffff),
              )),
          onPressed: () {
            //goto RedPacketShare widget
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RedPacketShare()),
            );
          },
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

StatelessWidget titleWidget(String title) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 10),
    child: Text(title,
        style: TextStyle(
          fontSize: 14,
          color: Color(0xff000000),
        )),
  );
}

StatelessWidget input(String hint) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
    decoration: BoxDecoration(
      color: Color(0xffffffff),
      borderRadius: BorderRadius.circular(10),
    ),
    // width: MediaQuery.of(context).size.width,
    child: TextField(
      decoration: InputDecoration(
        border: InputBorder.none,
        labelText: hint,
        labelStyle: TextStyle(
          fontSize: 14,
          color: Color(0xff9CA1B3),
        ),
      ),
    ),
  );
}
