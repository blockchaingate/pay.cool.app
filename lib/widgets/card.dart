import 'package:flutter/material.dart';

class ExgCard extends StatelessWidget {
  // final Map cardInfo;
  // final String lang;
  // // const ExgNewsList({Key key, @required this.cardInfo, @required this.lang})
  // const ExgCard({Key key, @required this.cardInfo, @required this.lang})
  //     : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      elevation: 10,
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.width * 0.4,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
            // color: Color(mainColor4),
            borderRadius: BorderRadius.circular(20),
            image: const DecorationImage(
                image: AssetImage("assets/img/qixing-Banner.png"),
                fit: BoxFit.cover)),
        // child: Column(
        //     mainAxisAlignment: MainAxisAlignment.start,
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: <Widget>[
        //       Container(
        //         constraints: BoxConstraints(
        //             maxWidth: MediaQuery.of(context).size.width / 2),
        //         child: Text(
        //           cardInfo['text'][lang],
        //           maxLines: 2,
        //           overflow: TextOverflow.ellipsis,
        //           style: TextStyle(
        //               color: Colors.PaycoolColors.white,
        //               fontSize: 25,
        //               fontWeight: FontWeight.bold),
        //         ),
        //       ),
        //       // Text(
        //       //   "Plan",
        //       //   style: TextStyle(
        //       //       color: Colors.PaycoolColors.white,
        //       //       fontSize: 25,
        //       //       fontWeight: FontWeight.bold),
        //       // ),
        //     ])
      ),
    );
  }
}
