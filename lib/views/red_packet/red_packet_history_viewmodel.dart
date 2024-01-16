import 'package:flutter/material.dart';
import 'package:paycool/logger.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../services/local_dialog_service.dart';

class RedPacketHistoryViewModel extends BaseViewModel {
  final log = getLogger('RedPacketViewModel');
  bool isSend = false;

  // Create a controller for the TabBar
  late TabController _tabController;

  @override
  void initState(context) {
    // _tabController =
    //     TabController(length: 3); // Change the length as per your tabs count
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  init() {
    print('RedPacketViewModel init');
  }

  void setSendOrReceive(bool value) {
    isSend = value;
    notifyListeners();
  }
}
