import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:pagination_widget/pagination_widget.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/utils/string_util.dart';
import 'package:paycool/views/multisig/multisig_util.dart';
import 'package:paycool/views/multisig/transactions/history_queue_viewmodel.dart';
import 'package:stacked/stacked.dart';

class MultisigHistoryQueueView extends StatelessWidget {
  final String address;
  const MultisigHistoryQueueView({Key? key, required this.address})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MultisigHistoryQueueViewModel>.reactive(
      viewModelBuilder: () => MultisigHistoryQueueViewModel(address: address),
      builder: (
        BuildContext context,
        MultisigHistoryQueueViewModel model,
        Widget? child,
      ) {
        return Scaffold(
            appBar: customAppBarWithTitleNB('',
                trailing: !model.dataReady
                    ? Container()
                    : IconButton(
                        onPressed: () => model.getQueueTransactions(),
                        icon: Icon(
                          Icons.refresh,
                          color: black,
                        ))),
            body: SingleChildScrollView(
              child: Container(
                // create 2 tabs History and Queue
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      Container(
                        constraints: BoxConstraints.expand(height: 50),
                        child: TabBar(
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Colors.black,
                          onTap: (value) => model.onTap(value),
                          tabs: [
                            Tab(
                              text: FlutterI18n.translate(context, 'history'),
                            ),
                            Tab(
                              text: FlutterI18n.translate(context, 'history'),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.85,
                        margin: EdgeInsets.all(20),
                        child: model.isBusy || !model.dataReady
                            ? model.sharedService.loadingIndicator()
                            : TabBarView(
                                children: [
                                  Container(
                                      margin: EdgeInsets.only(top: 20),
                                      child: ListView.builder(
                                          itemCount: model.history.length,
                                          itemBuilder: (context, index) {
                                            return ListTile(
                                              leading: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    convertTimeStampToDate(
                                                            model.history[index]
                                                                ['timestamp'])
                                                        .toString()
                                                        .split('.')[0]
                                                        .split(' ')[0]
                                                        .toString(),
                                                    style: headText5.copyWith(
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                  Text(
                                                    convertTimeStampToDate(
                                                            model.history[index]
                                                                ['timestamp'])
                                                        .toString()
                                                        .split('.')[0]
                                                        .split(' ')[1]
                                                        .toString(),
                                                    style: headText6.copyWith(
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                ],
                                              ),
                                              title: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: Text(
                                                  model.history[index]['type']
                                                      .toString(),
                                                  style: headText4.copyWith(
                                                      color: black,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ),
                                              titleAlignment:
                                                  ListTileTitleAlignment.center,
                                              trailing: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    model.history[index]['memo']
                                                        .toString(),
                                                    style: headText5,
                                                    textAlign: TextAlign.start,
                                                  ),
                                                  model.history[index]
                                                              ['status'] ==
                                                          '0x0'
                                                      ? Text(
                                                          FlutterI18n.translate(
                                                              context,
                                                              'failed'),
                                                          style: headText6
                                                              .copyWith(
                                                                  color: red),
                                                        )
                                                      : Text(
                                                          FlutterI18n.translate(
                                                              context,
                                                              'sucess'),
                                                          style: headText6
                                                              .copyWith(
                                                                  color: green),
                                                        ),
                                                ],
                                              ),
                                            );
                                          })),
                                  Container(
                                      margin: EdgeInsets.only(top: 20),
                                      child: model.queue.isEmpty
                                          ? Center(
                                              child: Text(
                                                FlutterI18n.translate(
                                                    context, 'noData'),
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          : ListView.builder(
                                              itemCount: model.queue.length,
                                              itemBuilder: (context, index) {
                                                return Column(
                                                  children: [
                                                    ListTile(
                                                      contentPadding:
                                                          EdgeInsets.all(10),
                                                      title: Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                FlutterI18n
                                                                    .translate(
                                                                        context,
                                                                        'history'),
                                                                style:
                                                                    headText5,
                                                              ),
                                                              Text(
                                                                formatStringDateV3(
                                                                        model.queue[index]
                                                                            [
                                                                            'dateCreated'])
                                                                    .toString(),
                                                                style:
                                                                    headText5,
                                                              )
                                                            ],
                                                          ),
                                                          UIHelper
                                                              .verticalSpaceMedium,
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                model.queue[
                                                                        index][
                                                                        'request']
                                                                        ['type']
                                                                    .toString(),
                                                                style: headText4
                                                                    .copyWith(
                                                                        color:
                                                                            black),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            8.0,
                                                                        right:
                                                                            2.0),
                                                                child: Text(
                                                                  model.queue[
                                                                          index]
                                                                          [
                                                                          'request']
                                                                          [
                                                                          'amount']
                                                                      .toString(),
                                                                  style: headText4
                                                                      .copyWith(
                                                                          color:
                                                                              black),
                                                                ),
                                                              ),
                                                              Text(
                                                                model.queue[
                                                                        index][
                                                                        'request']
                                                                        [
                                                                        'tokenName']
                                                                    .toString(),
                                                                style: headText4
                                                                    .copyWith(
                                                                        color:
                                                                            black),
                                                              )
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      subtitle: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: const [
                                                              UIHelper
                                                                  .horizontalSpaceLarge,
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top:
                                                                            8.0),
                                                                child: Icon(
                                                                  Icons
                                                                      .arrow_downward_rounded,
                                                                  color: black,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                StringUtils.showPartialData(
                                                                    data: MultisigUtil.exgToBinpdpayAddress(model.queue[index]['request']
                                                                            [
                                                                            'to'])
                                                                        .toString()),
                                                                style: headText4
                                                                    .copyWith(
                                                                        color:
                                                                            black),
                                                              ),
                                                              IconButton(
                                                                  onPressed: () => model
                                                                      .sharedService
                                                                      .copyAddress(
                                                                          context,
                                                                          model
                                                                              .queue[index]['request']['to']
                                                                              .toString()),
                                                                  icon: Icon(
                                                                    Icons.copy,
                                                                    color:
                                                                        primaryColor,
                                                                    size: 18,
                                                                  ))
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      trailing: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      bottom:
                                                                          5),
                                                              width: 120,
                                                              child: Text(
                                                                StringUtils.showPartialData(
                                                                    data: model
                                                                        .queue[
                                                                            index]
                                                                            [
                                                                            'transactionHash']
                                                                        .toString()),
                                                                style: headText5
                                                                    .copyWith(
                                                                        color:
                                                                            black),
                                                              )),
                                                          model.hasConfirmedByMe(
                                                                  model.queue[
                                                                      index])
                                                              ? SizedBox(
                                                                  width: 110,
                                                                  height: 36,
                                                                  child: model
                                                                          .pendingExecution
                                                                      ? ElevatedButton(
                                                                          style:
                                                                              ButtonStyle(backgroundColor: MaterialStateProperty.all(yellow)),
                                                                          onPressed:
                                                                              () {
                                                                            model.approveTransaction(model.queue[index],
                                                                                context,
                                                                                requiredExecution: true);
                                                                          },
                                                                          child:
                                                                              Text(
                                                                            FlutterI18n.translate(context,
                                                                                'execute'),
                                                                            style:
                                                                                headText5.copyWith(color: black),
                                                                          ),
                                                                        )
                                                                      : Text(
                                                                          FlutterI18n.translate(
                                                                              context,
                                                                              'confirmedByCurrentWallet'),
                                                                          style: headText5.copyWith(
                                                                              color: green,
                                                                              fontWeight: FontWeight.w400,
                                                                              letterSpacing: 0.1,
                                                                              wordSpacing: 0.5),
                                                                          maxLines:
                                                                              4,
                                                                        ),
                                                                )
                                                              : model.isShowApproveButton(
                                                                      model.queue[
                                                                          index])
                                                                  ? SizedBox(
                                                                      height:
                                                                          36,
                                                                      child:
                                                                          ElevatedButton(
                                                                        style: ButtonStyle(
                                                                            backgroundColor:
                                                                                MaterialStateProperty.all(primaryColor)),
                                                                        onPressed:
                                                                            () {
                                                                          model.approveTransaction(
                                                                              model.queue[index],
                                                                              context);
                                                                        },
                                                                        child: Text(FlutterI18n.translate(
                                                                            context,
                                                                            'approve')),
                                                                      ),
                                                                    )
                                                                  : SizedBox(
                                                                      height:
                                                                          36,
                                                                      child:
                                                                          ElevatedButton(
                                                                        style: ButtonStyle(
                                                                            backgroundColor:
                                                                                MaterialStateProperty.all(grey)),
                                                                        onPressed:
                                                                            () {},
                                                                        child: Text(FlutterI18n.translate(
                                                                            context,
                                                                            'approve')),
                                                                      ),
                                                                    ),
                                                        ],
                                                      ),
                                                    ),
                                                    UIHelper.divider,
                                                    UIHelper.verticalSpaceLarge,
                                                  ],
                                                );
                                              })),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: model.paginationModel.totalPages == 0
                ? Container()
                : PaginationWidget(
                    paginationModel: model.paginationModel,
                    pageCallback: model.paginationData));
      },
    );
  }
}
