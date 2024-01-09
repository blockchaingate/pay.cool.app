import 'package:paycool/logger.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../services/local_dialog_service.dart';


class RedPacketViewModel extends BaseViewModel {

  final log = getLogger('RedPacketViewModel');
  bool isSend = false;

  init(){
    print('RedPacketViewModel init');
  }

  void setSendOrReceive(bool value){
    isSend = value;
    notifyListeners();
  }

}