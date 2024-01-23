import 'package:flutter/material.dart';
import 'package:paycool/views/red_packet/red_packet_sent_viewmodel.dart';
import 'package:paycool/views/red_packet/red_packet_share.dart';
import 'package:stacked/stacked.dart';

class RedPacketSent extends StatelessWidget {
  const RedPacketSent({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<RedPacketSentViewModel>.reactive(
      viewModelBuilder: () => RedPacketSentViewModel(),
      onViewModelReady: (model) => model.init(context),
      builder: (context, model, child) => ListView(
        padding: EdgeInsets.all(10),
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        children: <Widget>[
          titleWidget("Number of gifts"),
          //label and input field

          Container(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            decoration: BoxDecoration(
              color: Color(0xffffffff),
              borderRadius: BorderRadius.circular(10),
            ),
            // width: MediaQuery.of(context).size.width,
            child: input("Enter Number", controller: model.numberController),
          ),
          titleWidget("Total Amount"),

          Container(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            decoration: BoxDecoration(
              color: Color(0xffffffff),
              borderRadius: BorderRadius.circular(10),
            ),
            // width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child:
                      input("Total Amount", controller: model.amountController),
                ),
                Container(
                  // color: Colors.red,
                  width: 80,
                  height: 50,
                  child: DropdownButton<String>(
                    iconEnabledColor: Colors.black,
                    value: model.selectedCoin,
                    iconSize: 24,
                    elevation: 16,
                    style: const TextStyle(color: Colors.black),
                    underline: Container(
                      height: 0,
                      color: Colors.transparent,
                    ),
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      model.selectCoin(newValue!);
                    },
                    items: model.coinList
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(value,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xff000000),
                                )),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

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
              for (int i = 0; i < model.giftCode.length; i++)
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Color(0xffFF5757),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(model.giftCode[i].toString(),
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
              model.getNumber();

              //goto RedPacketShare widget
            },
          ),
        ],
      ),
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

TextField input(String hint, {TextEditingController? controller}) {
  return TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    style: TextStyle(
      fontSize: 14,
      color: Color(0xff000000),
    ),
    decoration: InputDecoration(
      border: InputBorder.none,
      labelText: hint,
      labelStyle: TextStyle(
        fontSize: 14,
        color: Color(0xff9CA1B3),
      ),
    ),
  );
}
