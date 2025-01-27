import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yokai_quiz_app/screens/Authentication/controller/auth_screen_controller.dart';
import 'package:yokai_quiz_app/screens/Authentication/login_screen.dart';

// import 'package:shared_preferences/shared_preferences.dart';
import 'api/local_storage.dart';
import 'main.dart';
import 'util/colors.dart';

class GlobalApi {
  static int? WhichScreen;
// static SharedPreferences? prefs;
}

final RxList<String> subjects = RxList<String>.of(["Select"]);
final RxList<String> mysubjects = RxList<String>();

RxBool isShowSearch = false.obs;
RxMap<String, String> subjectWithId = RxMap<String, String>();
RxMap<String, String> subjectWithStandard = RxMap<String, String>();

void showSnackbar(String message, Color color, [int duration = 4000]) {
  final snackBar = GetSnackBar(
    // behavior: SnackBarBehavior.floating,
    //  margin: const EdgeInsets.all(Constants.defaultPadding),
    backgroundColor: color,
    borderRadius: 4,
    message: message,
    duration: Duration(milliseconds: duration),
    // content: Text(message),
  );
  Get.showSnackbar(snackBar);
}

///theme mode

bool debugMode = false;
int selectedButtonIndex = 1;

checkDebugMode() {
  assert(() {
    debugMode = true;
    return true;
  }());
}

void customPrint(text) {
  if (debugMode) {
    log(text.toString());
  }
}
/*
.toLowerCase()
                                .contains(searchcontroller.text
                                    .trim()
                                    .toLowerCase())) 
*/
// void customLog(text) {
//   if (debugMode) {
//     if (kDebugMode) {
//       print(text);
//     }
//   }
// }

Future<void> delay(int time) async {
  await Future.delayed(Duration(milliseconds: time), () {});
}

// void showErrorMessage(BuildContext context, String message) {
//   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//     duration: Duration(milliseconds: 1000),
//     backgroundColor: const Color(0xffFFD5D6),
//     padding: const EdgeInsets.all(25),
//     content: Text(
//       message,
//       style: GoogleFonts.dmSans(
//         fontSize: 14,
//         color: const Color(0xff900F0F),
//       ),
//     ),
//   ));
// }
void showErrorMessage(String message, Color color) {
  if (message != 'Invalid token' && message != 'User not found') {
    if (message.contains("An error occurred: (pymysql.err.OperationalError)")) {
      message = "Server is not responding";
    }
    final snackBar = GetSnackBar(
      // behavior: SnackBarBehavior.floating,
      //  margin: const EdgeInsets.all(Constants.defaultPadding),
      backgroundColor: const Color(0xffFFD5D6),
      padding: const EdgeInsets.all(25),
      borderRadius: 4,
      // message: message,
      messageText: Text(
        message,
        style: GoogleFonts.dmSans(
          fontSize: 14,
          color: const Color(0xff900F0F),
        ),
      ),
      duration: const Duration(milliseconds: 1000),
      // content: Text(message),
    );
    Get.showSnackbar(snackBar);
  } else {
    // prefs.setBool(LocalStorage.isLogin, false);
    // prefs.clear();
    // navigator?.pushAndRemoveUntil(MaterialPageRoute(
    //   builder: (context) {
    //     return LoginScreen();
    //   },
    // ), (route) => false);
    ///updated with firebase
    AuthScreenController.signOutWithFirebase().then(
      (value) {
        if (value) {
          prefs.clear();
          navigator?.pushAndRemoveUntil(MaterialPageRoute(
            builder: (context) {
              return LoginScreen();
            },
          ), (route) => false);
        } else {
          return;
        }
      },
    );
  }
}

// void showSucessMessage(BuildContext context, String message) {
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//         padding: const EdgeInsets.all(25),
//         // margin: const EdgeInsets.all(10),
//         backgroundColor: const Color(0xffD1FFE1),
//         content: Text(
//           message,
//           style: GoogleFonts.dmSans(
//             fontSize: 14,
//             color: const Color(0xff0B8233),
//           ),
//         )),
//   );
// }
void showSucessMessage(String message, Color color) {
  final snackBar = GetSnackBar(
    // behavior: SnackBarBehavior.floating,
    //  margin: const EdgeInsets.all(Constants.defaultPadding),
    backgroundColor: const Color(0xffD1FFE1),
    padding: const EdgeInsets.all(25),
    borderRadius: 4,
    // message: message,
    messageText: Text(
      message,
      style: GoogleFonts.dmSans(
        fontSize: 14,
        color: const Color(0xff0B8233),
      ),
    ),
    duration: Duration(milliseconds: 1000),
    // content: Text(message),
  );
  Get.showSnackbar(snackBar);
}
////   Navigation
// Future? nextPageReplace(context, Widget page) {
//   return Get.offAll(page);
// }

Future? nextPage(Widget page) {
  return Get.to(page, transition: Transition.rightToLeft);
}

Future? nextPageOff(context, Widget page) {
  return Get.off(page, transition: Transition.leftToRight);
}

Future? nextPageNewCustom(Widget page) {
  return Get.to(page, transition: Transition.rightToLeft);
}

Future? nextPageFade(Widget page) {
  return Get.to(page,
      transition: Transition.downToUp, duration: Duration(seconds: 1));
}

// void routePage(context, String page) {
//   Get.toNamed(page);
// }
void routePage(BuildContext context, String query) {
  Navigator.of(context).pushNamed(query);
  customPrint("Route :: $query");
}

bool validateMyFields(BuildContext context,
    List<TextEditingController> controllerList, List<String> fieldsName) {
  print('snackbar');
  for (int i = 0; i < controllerList.length; i++) {
    if (controllerList[i].text.trim().isEmpty) {
      showErrorMessage("${fieldsName[i]} Can't be empty", errorColor);
      i = controllerList.length + 1;
      return false;
    }
  }
  return true;
}

String addZero(int sec) {
  if (sec < 10) {
    return "0$sec";
  }
  return "$sec";
}

List<String> stringToList(String str, [String delim = ","]) {
  String removedBrackets = str.replaceAll("[", "");
  removedBrackets = removedBrackets.replaceAll("]", "");
  List<String> parts = removedBrackets.split(delim);
  parts.remove("");
  // customPrint("parts :: $parts");
  return parts;
}
// String? validatePassword(String? value) {
//   RegExp regex = RegExp(r'^(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
//   var passNonNullValue = value ?? "";
//   if (passNonNullValue.isEmpty) {
//     return ("Password is required");
//   } else if (!regex.hasMatch(passNonNullValue)) {
//     return ("Password must contain at least one uppercase,\nnumber and special characters");
//   } else if (passNonNullValue.length < 8) {
//     return ("Password must be at least 8 characters long");
//   } else {
//     return null;
//   }
// }

showConfirmDialog(BuildContext context, String messageKey, Function onYes,
    [String title = "NA"]) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title == "NA" ? messageKey : title),
        content: Text("Do you really want to ${messageKey.toLowerCase()}?"),
        actions: [
          TextButton(
            child: Text(
              "Yes",
              style: TextStyle(color: primaryColor),
            ),
            onPressed: () async {
              Navigator.pop(context);
              onYes();
            },
          ),
          TextButton(
            child: Text(
              "No",
              style: TextStyle(color: primaryColor),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      );
    },
  );
}

List<String> categoris = [
  'St. Thomas',
  'Portland',
  'St. Andrew',
  'St. Mary',
  'St. Catherine',
  'St. Ann',
  'Clarendon',
  'Manchester',
  'Trelawny',
  'St. James',
  'St. Elizabeth',
  'Westmoreland',
  'Hanover',
  'Endgame',
];
List<String> images = [
  "images/n1.png",
  "images/n2.png",
  "images/n3.png",
  "images/n4.png",
  "images/n5.png",
  "images/n6.png",
  "images/n7.png",
  "images/n8.png",
  "images/n9.png",
  "images/n10.png",
  "images/n11.png",
  "images/n12.png",
  "images/n13.png",
  "images/n14.png",
];

List answers = [
  'obesity',
  'a quiet library',
  'The materials should all be of the same thickness',
  'material A and material C',
  'Material D was transparent and cast no shadow.',
  'diagram II.',
  'area IV.',
  'only 23,000 lions remaining in the wild',
  'eating organic meat',
  'Take their trash home to reuse containers, recycle packages, and dispose of the rest.',
  'the people and everything in their surroundings',
  'Temperatures around 20 C will encourage seedling growth.',
  'major changes in all weather patterns that occur over several decades or longer',
  'the digestive system',
  'III.',
  'Both the skin and the lungs excrete waste from the body.',
  'III.',
  'The length of the ruler will affect the pitch of the sound made.',
  'because the pitch of a sound depends on how fast an object vibrates',
  'The ruler should be plucked with equal force each time.',
  'The loud sounds mask communication and navigation sounds of marine life.',
  'Give the workers hearing protection such as earplugs and earmuffs.',
  'II.',
  'refraction',
  'a drinking straw in a glass of water',
  'IV.',
  'II.',
  'by causing an increase in water erosion, leading to desertification',
  'reforestation',
  'the respiratory system and the circulatory system',
  'because new materials are made by burning',
  'the sieve',
  'the filter and the water',
  'the time taken for the sugar to dissolve at 50 C during test 3',
  'a solution',
  'solid I.',
  'solid II.',
  'The water will evaporate, leaving crystals in the dish.'
];
List answersByUser = [];
List<Map> ansIndex = [];
List<bool> isExplanation = [];
List<String?> userSelectedOptions = [];
List<Color> ansColors = [];
List<String> question = [];
//
List<String> questions = [];
List<List<String>> options = [];
List<String> correctAnswers = [];
List<String?> userSelectedAnswer = [];

List image = [
  'images/question1.png',
  'images/question2.png',
  'images/question3.png'
];
