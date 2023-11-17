import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ExgList extends StatefulWidget {
  @override
  _ExgListState createState() => _ExgListState();
}

class _ExgListState extends State<ExgList> {
  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          children: const [
            // IconButton(
            //   icon: FaIcon(
            //     FontAwesomeIcons.coins,
            //     color:Color(0xFF7F00FF)
            //   ),
            //   onPressed: () {},
            // ),
            FaIcon(FontAwesomeIcons.coins, color: Color(0xFF7F00FF)),
            SizedBox(
              width: 20,
            ),
            Text("活动收益",
                style: TextStyle(
                    color: Color(0xff333333),
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
