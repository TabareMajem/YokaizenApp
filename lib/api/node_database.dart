import 'package:yokai_quiz_app/main.dart';

class NodeDatabaseApi {
  static String mainUrl = "https://companionapi.yokaizen.com/api/v1";
  static String mainUrlImage = "https://companionapi.yokaizen.com/";
  static String login = "$mainUrl/user/login";
  static String createAccount = "$mainUrl/user/register";
  static String sendMessage = "$mainUrl/companion/interact";
  static String getChatMessage = "$mainUrl/companion/sessions/";
  static String loginGoogle = "$mainUrl/user/signin-google/";
  static String loginApple = "$mainUrl/user/signin-apple/";


  //Exercise
  // static String getAllExercise = "$mainUrl/exercises";
  static String getAllExercise = "$mainUrl/exercises";

  static String getAllProgress = "$mainUrl/progress/detailed-progress";

  static String voiceToVoice = "$mainUrl/companion/interact/voice";
}
