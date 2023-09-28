import 'package:flutter/material.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/utils/string_util.dart';
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
            appBar: customAppBarWithTitleNB(
              '',
            ),
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
                        tabs: const [
                          Tab(
                            text: 'History',
                          ),
                          Tab(
                            text: 'Queue',
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 500,
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
                                            leading: Text(dateFromMilliseconds(
                                                    model.history[index]
                                                        ['timestamp'])
                                                .toString()
                                                .split(' ')[0]),
                                            title: Text(
                                              model.history[index]['type']
                                                  .toString(),
                                              style: headText4.copyWith(
                                                  color: black),
                                            ),
                                            titleAlignment:
                                                ListTileTitleAlignment.center,
                                            trailing: Text(model.history[index]
                                                    ['memo']
                                                .toString()),
                                          );
                                        })),
                                Container(
                                    margin: EdgeInsets.only(top: 20),
                                    child: ListView.builder(
                                        itemCount: model.queue.length,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                            contentPadding: EdgeInsets.all(0),
                                            title: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Created on ',
                                                      style: headText5,
                                                    ),
                                                    Text(
                                                      formatStringDateV3(model
                                                                  .queue[index]
                                                              ['dateCreated'])
                                                          .toString(),
                                                      style: headText5,
                                                    )
                                                  ],
                                                ),
                                                UIHelper.verticalSpaceMedium,
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      model.queue[index]
                                                              ['request']
                                                              ['type']
                                                          .toString(),
                                                      style: headText4.copyWith(
                                                          color: black),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8.0,
                                                              right: 2.0),
                                                      child: Text(
                                                        model.queue[index]
                                                                ['request']
                                                                ['amount']
                                                            .toString(),
                                                        style:
                                                            headText4.copyWith(
                                                                color: black),
                                                      ),
                                                    ),
                                                    Text(
                                                      model.queue[index]
                                                              ['request']
                                                              ['tokenName']
                                                          .toString(),
                                                      style: headText4.copyWith(
                                                          color: black),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: const [
                                                    UIHelper
                                                        .horizontalSpaceLarge,
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 8.0),
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
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      StringUtils
                                                          .showPartialAddress(
                                                              address: model
                                                                  .queue[index][
                                                                      'request']
                                                                      ['to']
                                                                  .toString()),
                                                      style: headText4.copyWith(
                                                          color: black),
                                                    ),
                                                    IconButton(
                                                        onPressed: () => model
                                                            .sharedService
                                                            .copyAddress(
                                                                context,
                                                                model.queue[
                                                                        index][
                                                                        'request']
                                                                        ['to']
                                                                    .toString()),
                                                        icon: Icon(
                                                          Icons.copy,
                                                          color: primaryColor,
                                                          size: 18,
                                                        ))
                                                  ],
                                                ),
                                              ],
                                            ),
                                            trailing: model.hasConfirmedByMe(
                                                    model.queue[index])
                                                ? Text('Confirmed by me')
                                                : model.isShowApproveButton(
                                                        model.queue[index])
                                                    ? ElevatedButton(
                                                        onPressed: () {
                                                          model
                                                              .approveTransaction(
                                                                  '');
                                                        },
                                                        child: Text('Approve'),
                                                      )
                                                    : ElevatedButton(
                                                        style: ButtonStyle(
                                                            backgroundColor:
                                                                MaterialStateProperty
                                                                    .all(grey)),
                                                        onPressed: () {},
                                                        child: Text('Approve'),
                                                      ),
                                          );
                                        })),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            )));
      },
    );
  }
}
