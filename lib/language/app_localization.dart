import 'package:get/get.dart';
import 'package:yokai_quiz_app/language/en.dart';
import 'package:yokai_quiz_app/language/ja.dart';
import 'package:yokai_quiz_app/language/ko.dart';

class AppLocalization extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        "en": en,        // Fixed: en_US -> en
        'ja': ja,        // Fixed: ja_JA -> ja  
        'ko': ko,        // Fixed: ko_KO -> ko
      };
}
