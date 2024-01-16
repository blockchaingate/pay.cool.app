import 'package:flutter/material.dart';

class RedPacketShare extends StatelessWidget {
  const RedPacketShare({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.width * 1,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.15,
                  vertical: 20),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/red-packet/skin1-L.png'),
                  fit: BoxFit.fill,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image.asset(
                  //   'assets/images/red-packet/skin1-L.png',
                  //   width: 220,
                  //   height: 320,
                  // ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width * 0.5,
                  ),
                  Text("Gift Code",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      for (int i = 0; i < 8; i++)
                        Container(
                          width: 30,
                          height: 30,
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
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Gift Code",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      for (int i = 0; i < 8; i++)
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color(0xff9CA1B3),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text((i + 1).toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xff000000),
                                )),
                          ),
                        )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Text("Copy code",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xff333FEA),
                        )),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  // 2 btns in a row, save image and share image
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.white,
                            foregroundColor: Color(0xff333FEA),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: BorderSide(
                                color: Color(0xff333FEA),
                              ),
                            ),
                          ),
                          onPressed: () {},
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: Center(child: Text('Save Image')))),
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
                        child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: Center(child: Text('Share Image'))),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
