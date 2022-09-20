import 'package:exchangily_core/exchangily_core.dart';
import 'package:exchangily_ui/exchangily_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:paycool/constants/paycool_styles.dart';

import '../../services/local_storage_service.dart';

class HomeViewModel extends IndexTrackingViewModel {
  final storageService = locator<LocalStorageService>();
  int customIndex = 0;
  int baseIndex = 0;

  Color setIconColor(int index) {
    return currentIndex == index ? PaycoolColors.primaryColor : grey;
  }

  init() {
    baseIndex = isShowClub() ? 1 : 0;

    int payCoolTabIndex = isShowClub() ? 2 : 1;
    if (customIndex != null) {
      int idx = baseIndex + customIndex;

      setIndex(idx);
    } else {
      setIndex(payCoolTabIndex);
    }
  }

  bool isShowClub() {
    return storageService.showPaycoolClub;
  }
}
