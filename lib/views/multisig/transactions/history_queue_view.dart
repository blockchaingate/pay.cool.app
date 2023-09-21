import 'package:flutter/material.dart';
import 'package:paycool/views/multisig/transactions/history_queue_viewmodel.dart';
import 'package:stacked/stacked.dart';

class HistoryQueueView extends StatelessWidget {
  final String address;
  const HistoryQueueView({Key? key, required this.address}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HistoryQueueViewModel>.reactive(
      viewModelBuilder: () => HistoryQueueViewModel(address: address),
      builder: (
        BuildContext context,
        HistoryQueueViewModel model,
        Widget? child,
      ) {
        return Scaffold(
          body: Center(
            child: Text(
              'HistoryQueueView $address',
            ),
          ),
        );
      },
    );
  }
}
