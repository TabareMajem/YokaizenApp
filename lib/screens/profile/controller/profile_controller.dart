import 'package:get/get_rx/src/rx_types/rx_types.dart';

class ProfileController {
  static RxBool isMoodTrackerTapped = false.obs;
  static RxBool isLoading = false.obs;
  static Rx<String> userName = "".obs;
  static Rx<int> userId = 1.obs;
}
