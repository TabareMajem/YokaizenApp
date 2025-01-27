class DatabaseApi {
  static String mainUrl = "https://api.yokai.jp/v1";
  static String mainUrlImage = "https://api.yokai.jp/";
//   static String mainUrl = "http://13.201.36.204/v1";
//   static String mainUrlImage = "http://13.201.36.204/";
  static String login = "$mainUrl/user-profile/userLogin";
  static String create = "$mainUrl/user-profile/createUser";
  static String updatePassword =
      "$mainUrl/user-profile/update-password-by-email/";
  static String getProfile = "$mainUrl/user-profile/getUserByToken";
  static String checkEmail = "$mainUrl/user-profile/getuserbyemail/";
  static String updateProfile = "$mainUrl/user-profile/updateUser";

  //
  static String getStoriesByStoryId = "$mainUrl/stories/get-stories-By-Token/";
  static String getStories = "$mainUrl/stories/get-all-stories-By-user-Token";
//

  ///chapter read unread changes in api
//   static String getAllChapterByStoryId = '${mainUrl}/chapter/get-chapter-by-stories';
  static String getAllChapterByStoryId =
      '$mainUrl/chapter/get-chapter-by-stories';
  static String updateChapterReadStatus =
      '$mainUrl/chapter-wise-user/update-read-status/';
  static String updateCharacterUnlock =
      '$mainUrl/user-character/create-user-character';

  ///

  //
  static String getAllChapterByChapterId =
      '$mainUrl/chapter/get-chapter-By-Token/';
  //

  static String getActivityByChapterId =
      '$mainUrl/activity_details/get-activities-by-chapter-id/';

  //
  static String getAllCharacters =
      "$mainUrl/character/get-all-character-by-user?search=";
  static String getCharactersById = "$mainUrl/character/get-character-by-user/";
  //
  static String getAllUnlockCharacters =
      "$mainUrl/character/get-unlocked-character-by-user?search=";
  //
  static String getLastReadChapter =
      "$mainUrl/chapter-wise-user/get-latest-read-chapter-by-user";
  //
  static String sendChatToApi =
      "$mainUrl/character-chat/create-user-character-chat";
  static String getChatFromApi =
      "$mainUrl/character-chat/get-user-character-chat?character_id=";
  // static String updateCharacterSummary = '${mainUrl}/user_character/update-summary-by-user?character_id=';
  static String updateCharacterSummary =
      '$mainUrl/character-summary/create-user-summary';

  static String createOrUpdateMood = "$mainUrl/mood_tracker/moods";
  static String getMoodByUserId = "$mainUrl/mood_tracker/moods/user";
  static String getMoodSummeryByUserId = "$mainUrl/mood_tracker/moods/summary";

  static String getChallenges = "$mainUrl/challenge/challenges";
  static String getUserLogs = "$mainUrl/logs/get-user-logs/?user_id=";

  static String getAllTasks = "$mainUrl/todo/todo-types/";

  static String createReferalCode = "$mainUrl/referral/referral-code/?user_id=";
  static String getReferalCodeByUserId = "$mainUrl/referral/referral-code";

  static String incrementUserLog = "$mainUrl/logs/create-user-log";

  static String recordDevice = "$mainUrl/devices/create-or-update-device";
  static String getDeviceByUserId = "$mainUrl/devices/get-user-devices";
  static String deleteDevice = "$mainUrl/devices/delete-device";

  static String getComplaints = "$mainUrl/compliment/get-all-compliments";
  static String getPersonalityResult = "$mainUrl/quiz/assessments";
  //
  static String getAllChallenge = '$mainUrl/challenge/challenges';


//
}
