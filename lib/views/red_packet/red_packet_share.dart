import 'package:flutter/material.dart';
import 'package:paycool/views/red_packet/red_packet_share_viewmodel.dart';
import 'package:stacked/stacked.dart';

class RedPacketShare extends StatelessWidget {
  const RedPacketShare({required this.giftCode, super.key});
  final String giftCode; // Declare the giftCode property

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<RedPacketShareViewModel>.reactive(
        viewModelBuilder: () => RedPacketShareViewModel(),
        onViewModelReady: (model) => model.init(context, giftCode),
        builder: (context, model, child) => Scaffold(
              appBar: AppBar(
                  // iconTheme: IconThemeData(
                  //   color: Colors.black, //change your color here
                  // ),
                  centerTitle: true,
                  //scrollable

                  backgroundColor: Color(0xffFF4848),
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
                          // color: Color(0xFF000000),
                        ),
                      )),
                  actions: <Widget>[
                    Container(
                        width: 20,
                        height: 20,
                        margin: EdgeInsets.only(right: 10),
                        child: Image.network(
                          "https://lanhu.oss-cn-beijing.aliyuncs.com/FigmaDDSSlicePNG3c56e1f52f88041570262df27bf07ced.png",
                          fit: BoxFit.fill,
                          color: Colors.white,
                        )),
                  ]),
              body: Container(
                color: Color(0xffF7F8FA),
                child: Stack(
                  children: [
                    Positioned(child: LineAndArcWidget()),
                    ListView(
                      children: [
                        Container(
                          margin: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color(0xffFFFCF3)),
                          child: RepaintBoundary(
                            key: model.captureKey,
                            child: Column(
                              children: [
                                // AssetImage('assets/images/red-packet/skin1-L.png'),

                                Container(
                                  // width: MediaQuery.of(context).size.width * 0.7,
                                  // height: MediaQuery.of(context).size.width * 1,
                                  // padding:
                                  //     EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                                  margin: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.width *
                                          0.15,
                                      left: 20,
                                      right: 20,
                                      bottom: 20),
                                  // decoration: BoxDecoration(
                                  //   image: DecorationImage(
                                  //     image:

                                  //     fit: BoxFit.fill,
                                  //   ),
                                  // ),
                                  child: Image.asset(
                                    'assets/images/red-packet/skin1-L.png',
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    // height: MediaQuery.of(context).size.width * 1,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                // SizedBox(
                                //   height: MediaQuery.of(context).size.width * 0.5,
                                // ),
                                Text("Gift Code",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.red,
                                    )),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                  child: Wrap(
                                    alignment: WrapAlignment.center,
                                    // mainAxisAlignment:
                                    //     MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      for (int i = 0; i < giftCode.length; i++)
                                        Container(
                                          width: 30,
                                          height: 30,
                                          margin: EdgeInsets.all(1),
                                          decoration: BoxDecoration(
                                            color: Color(0xffFF5757),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Center(
                                            child: Text(giftCode[i].toString(),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xffffffff),
                                                )),
                                          ),
                                        )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Center(
                                  child: InkWell(
                                    onTap: () {
                                      model.copyGiftCode(context);
                                    },
                                    child: model.showCopy
                                        ? Text("Copy code",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xff333FEA),
                                            ))
                                        : Container(),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                height: 40,
                              ),
                              // 2 btns in a row, save image and share image
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        backgroundColor: Colors.white,
                                        foregroundColor: Color(0xff333FEA),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          side: BorderSide(
                                            color: Color(0xff333FEA),
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        model.saveImageToGallery(context);
                                      },
                                      child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3,
                                          child: Center(
                                              child: Text('Save Image')))),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: Color(0xff333FEA),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    onPressed: () {
                                      model.shareImageToSocialMedia(context);
                                    },
                                    child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child:
                                            Center(child: Text('Share Image'))),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ));
  }
}

class LineAndArcWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(MediaQuery.of(context).size.width, 100), // 设置Widget的大小
      painter: LineAndArcPainter(), // 使用自定义的绘制器
    );
  }
}

class LineAndArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 10 // 线宽
      // ..color = Colors.blue // 填充颜色为蓝色
      //fill gradient colors
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          //top red, bottom blue
          Color(0xffFF4848),
          Color(0xffFD7236),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill; // 使用填充样式

    // Draw a rectangle
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: size.width,
            height: size.height),
        paint);

    // draw bottom arc
    canvas.drawArc(
        Rect.fromCenter(
            center: Offset(size.width / 2, size.height),
            width: size.width + 20,
            height: 50),
        -2,
        5.14,
        true,
        paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
