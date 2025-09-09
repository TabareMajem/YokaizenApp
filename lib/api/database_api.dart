class DatabaseApi {
  static String mainUrl = "https://api.yokaizen.com/v1";
  static String mainUrlImage = "https://api.yokaizen.com/";
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
  static String unlockCharacter = '$mainUrl/character/unlock';

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
      "$mainUrl/character_chat/create-user-character-chat";
  static String getChatFromApi =
      "$mainUrl/character_chat/get-user-character-chat?character_id=";
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
  static String getAllChallenge = '$mainUrl/challenge/challenges';

  // Add these new endpoints

  static String getAllBadges = "$mainUrl/badges/get-all-user-badges";
  static String getAssessments = "$mainUrl/quiz/quizzes";
  static String submitAssessments = "$mainUrl/quiz/submit-assessment";
  static String getPersonalityResult = "$mainUrl/quiz/assessments/averages";

  // User validation endpoint
  static String checkUser = "$mainUrl/user-profile/validate-user";

  static String checkLineUser = "$mainUrl/user-profile/check-line-user/";  // Append line_id
  static String lineLogin = "$mainUrl/user-profile/line-login";
  static String lineCreate = "$mainUrl/user-profile/line-create";

  static String deleteUser = "$mainUrl/user-profile/deleteUser";

  // Smart Ring API
  static final String registerSmartRing = "$mainUrl/smart-ring/register-device";
  static final String getDeviceDetails = "$mainUrl/smart-ring/get-device-details";

  // New Smart Ring API Endpoints
  static final String getUserDevices = "$mainUrl/smart-ring/get-user-devices";
  static final String deleteSmartRingDevice = "$mainUrl/smart-ring/delete-device"; // Renamed to avoid conflict. Base, deviceId will be appended
  static final String updateConnectionStatus = "$mainUrl/smart-ring/update-connection-status"; // Base, deviceId and status will be appended
  static final String syncHealthData = "$mainUrl/smart-ring/sync-health-data";
  static final String getHealthData = "$mainUrl/smart-ring/get-health-data"; // Base, deviceId and params will be appended
  static final String getHealthSummary = "$mainUrl/smart-ring/get-health-summary"; // Base, deviceId and period will be appended
  static final String updateBatteryLevel = "$mainUrl/smart-ring/update-battery-level"; // Base, deviceId and battery_level will be appended
  static final String updateFirmwareVersion = "$mainUrl/smart-ring/update-firmware"; // Base, deviceId and firmware_version will be appended
  static final String predictEmotion = "$mainUrl/smart-ring/predict-emotion"; // Base, deviceId will be appended
  static final String predictEmotionFromValue = "$mainUrl/smart-ring/predict-emotion-from-value"; // Base, deviceId and heart_rate will be appended
  static final String getEmotionHistory = "$mainUrl/smart-ring/get-emotion-history"; // Base, deviceId and days will be appended
  static final String updateDevice = "$mainUrl/smart-ring/update-device"; // Already added in previous step, base, deviceId will be appended

  static final String getUserProfile = "$mainUrl/get-user-profile";
  static final String updateUserProfile = "$mainUrl/update-user-profile";

  static final String sendOtp = "$mainUrl/send-otp";
  static final String verifyOtp = "$mainUrl/verify-otp";
}
