import 'package:exchangily_core/exchangily_core.dart';
import 'package:exchangily_ui/exchangily_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:paycool/constants/paycool_styles.dart';

import '../../services/local_storage_service.dart';

class HomeViewModel extends IndexTrackingViewModel {
  final storageService = locator<LocalStorageService>();

  Color setIconColor(int index) {
    return currentIndex == index ? PaycoolColors.primaryColor : grey;
  }
}
