import 'package:paycool/service_locator.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/views/paycool_club/club_dashboard_model.dart';

class PaycoolUtil {
  static String localizedProjectData(Project project) {
    final storageService = locator<LocalStorageService>();

    if (storageService.language == 'en') {
      return project.en;
    } else {
      return project.sc;
    }
  }
}
