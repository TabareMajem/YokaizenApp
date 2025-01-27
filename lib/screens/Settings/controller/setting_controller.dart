import 'package:get/get.dart';

class SettingController {
  static RxBool isGeneralNotificatonActive = true.obs;
  static RxBool isSoundNotification = false.obs;
  static RxBool isVibrateNotification = true.obs;
  static RxBool isMarkedOffline = true.obs;
  static RxBool isLoading = false.obs;

  static RxString prilmaryLanguage = "English(UK)".obs;

  static List suggestedLanguages = [
    "English (UK)".tr,
  ];
  static List otherLanguages = [
    "Japanese".tr,
    "Korean".tr,
  ];

  static RxString userName = "test".obs;
  static RxString userEmail = "loremipsum@gmail.com".obs;
  static RxString userPhoneNumber = "1234567890".obs;
}
