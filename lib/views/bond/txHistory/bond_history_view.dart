import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/bond/txHistory/bond_history_viewmodel.dart';
import 'package:stacked/stacked.dart';

class BondHistoryView extends StatefulWidget with WidgetsBindingObserver {
  const BondHistoryView({super.key});

  @override
  State<BondHistoryView> createState() => _BondHistoryViewState();
}

class _BondHistoryViewState extends State<BondHistoryView> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ViewModelBuilder<BondHistoryViewModel>.reactive(
        onViewModelReady: (model) async {
          model.context = context;
          await model.init();
        },
        viewModelBuilder: () => BondHistoryViewModel(),
        builder: (context, model, _) {
          model.txHistoryListWidgets = model.bondHistoryVm
              .map(
                (item) => Card(
                  elevation: 4,
                  child: Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        UIHelper.verticalSpaceMedium,
                        Expanded(
                          flex: 1,
                          child: Text(item.bondId!.symbol!,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 11, color: Colors.white)),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(item.quantity!.toString(),
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 11, color: Colors.white)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                              item.paymentChain == null
                                  ? ""
                                  : item.paymentChain!,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 11, color: Colors.white)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                              item.paymentCoin == null ? "" : item.paymentCoin!,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 11, color: Colors.white)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            item.createdAt!.toString().substring(0, 10),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, color: Colors.white),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            alignment: Alignment.center,
                            child: AutoSizeText(
                              item.status.toString(),
                              textAlign: TextAlign.center,
                              minFontSize: 8,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        UIHelper.verticalSpaceMedium,
                      ],
                    ),
                  ),
                ),
              )
              .toList();

          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              systemOverlayStyle: SystemUiOverlayStyle.light,
              elevation: 0,
            ),
            body: model.isBusy
                ? Center(child: CircularProgressIndicator())
                : Container(
                    width: size.width,
                    height: size.height,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/images/bgImage.png"),
                          fit: BoxFit.cover),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          size.width * 0.05,
                          size.height * 0.1,
                          size.width * 0.05,
                          size.height * 0.05),
                      child: SizedBox(
                        height: size.height,
                        child: Column(
                          children: [
                            UIHelper.verticalSpaceMedium,
                            Row(children: const [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  "Bond Id",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  "Quantity",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  "Chain",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  "Coin",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  "Date",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  "Status",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ]),
                            UIHelper.verticalSpaceMedium,
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: model.getRequest,
                                child: Scrollbar(
                                  child: SingleChildScrollView(
                                    physics: AlwaysScrollableScrollPhysics(),
                                    child: Column(
                                      children: model.txHistoryListWidgets,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: size.width,
                              height: 40,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (model.page != 0)
                                    IconButton(
                                      icon: Icon(Icons.arrow_back_ios),
                                      onPressed: () async {
                                        setState(() {
                                          model.page--;
                                        });
                                        await model.getRequest(
                                            isForward: false);
                                      },
                                    ),
                                  Text(
                                    (model.page + 1).toString(),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.arrow_forward_ios),
                                    onPressed: () async {
                                      setState(() {
                                        model.page++;
                                      });
                                      await model.getRequest(isForward: true);
                                    },
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
          );
        });
  }
}
