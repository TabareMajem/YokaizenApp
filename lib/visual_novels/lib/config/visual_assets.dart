class VisualAssets {
  // Base paths
  static const String _basePath = 'visualassets';
  static const String _background = '$_basePath/background';
  static const String _characters = '$_basePath/characters';
  static const String _audio = '$_basePath/audio';
  static const String _ui = '$_basePath/ui';
  static const String _config = '$_basePath/config';
  static const String _dialogue = '$_basePath/dialogue';

  // Background images
  static const String backgroundSchoolEntrance = '$_background/school_entrance_morning.png';
  static const String backgroundClassroom = '$_background/classroom_day.png';
  static const String backgroundCorridor = '$_background/school_corridor.png';
  static const String backgroundStorageRoom = '$_background/storage_room.png';

  // Character base paths
  static const String _hana = '$_characters/hana';
  static const String _mei = '$_characters/mei';
  static const String _yuto = '$_characters/yuto';
  static const String _akira = '$_characters/akira';
  static const String _kenji = '$_characters/kenji';

  // Character base sprites
  static const String hanaBase = '$_hana/base.png';
  static const String meiBase = '$_mei/base.png';
  static const String yutoBase = '$_yuto/base.png';
  static const String akiraBase = '$_akira/base.png';
  static const String kenjiBase = '$_kenji/base.png';

  // Character expressions paths
  static const String _hanaExpressions = '$_hana/expressions';
  static const String _meiExpressions = '$_mei/expressions';
  static const String _yutoExpressions = '$_yuto/expressions';
  static const String _akiraExpressions = '$_akira/expressions';
  static const String _kenjiExpressions = '$_kenji/expressions';

  // Hana expressions
  static const String hanaHappy = '$_hanaExpressions/happy.png';
  static const String hanaNeutral = '$_hanaExpressions/neutral.png';
  static const String hanaSurprise = '$_hanaExpressions/surprise.png';
  static const String hanaWorried = '$_hanaExpressions/worried.png';

  // Mei expressions
  static const String meiHappy = '$_meiExpressions/happy.png';
  static const String meiNeutral = '$_meiExpressions/neutral.png';
  static const String meiSurprise = '$_meiExpressions/surprise.png';
  static const String meiWorried = '$_meiExpressions/worried.png';

  // Audio paths
  static const String _music = '$_audio/music';
  static const String _ambient = '$_audio/ambient';
  static const String _sfx = '$_audio/sfx';
  static const String _effects = '$_sfx/effects';
  static const String _environment = '$_sfx/environment';
  static const String _uiSounds = '$_sfx/ui';

  // Music files
  static const String musicSchoolTheme = '$_music/school_theme.mp3';
  static const String musicMysteryTheme = '$_music/mystery_theme.wav';

  // Ambient sounds
  static const String ambientClassroom = '$_ambient/classroom.mp3';
  static const String ambientSchoolMorning = '$_ambient/school_morning.mp3';
  static const String ambientStorageRoom = '$_ambient/storage_room.mp3';

  // Sound effects
  static const String sfxArtifactGlow = '$_effects/artifact_glow.mp3';
  static const String sfxMirrorReveal = '$_effects/mirror_reveal.mp3';
  static const String sfxTimeShard = '$_effects/time_shard.mp3';
  static const String sfxDoorOpen = '$_environment/door_open.mp3';
  static const String sfxFootsteps = '$_environment/footsteps.mp3';
  static const String sfxSchoolBell = '$_environment/school_bell.mp3';
  static const String sfxClick = '$_uiSounds/click.mp3';
  static const String sfxHover = '$_uiSounds/hover.mp3';
  static const String sfxTransition = '$_uiSounds/transition.mp3';

  // UI elements
  static const String uiDialogueBox = '$_ui/dialogue/text_box.png';
  static const String uiNamePlate = '$_ui/dialogue/name_plate.png';
  static const String uiNextButton = '$_ui/dialogue/next_button.png';
  static const String uiEffectGlow = '$_ui/effects/artifacts_glow.png';
  static const String uiTransition = '$_ui/effects/transition.png';
  static const String uiLoadButton = '$_ui/menu/load_button.png';
  static const String uiSaveButton = '$_ui/menu/save_button.png';
  static const String uiSettingsButton = '$_ui/menu/settings_button.png';

  // Configuration files
  static const String configAudio = '$_config/audio-config.json';
  static const String configChapters = '$_config/chapter-config.json';
  static const String configCharacters = '$_config/characters-config.json';
  static const String configDialogue = '$_config/dialogue-config.json';
  static const String configEffects = '$_config/effects-config.json';
  static const String configScenes = '$_config/scenes-config.json';

  // Dialogue files
  static const String dialogueCommon = '$_dialogue/common-dialogue.txt';
  static const String dialogueChapter1 = '$_dialogue/chapter1-dialogue.txt';
  static const String dialogueChapter2 = '$_dialogue/chapter2-dialogue.txt';
  static const String dialogueChapter3 = '$_dialogue/chapter3-dialogue.txt';

  // Helper method to get character expression path
  static String getCharacterExpression(String character, String expression) {
    switch (character.toLowerCase()) {
      case 'hana':
        return '$_hanaExpressions/$expression.png';
      case 'mei':
        return '$_meiExpressions/$expression.png';
      case 'yuto':
        return '$_yutoExpressions/$expression.png';
      case 'akira':
        return '$_akiraExpressions/$expression.png';
      case 'kenji':
        return '$_kenjiExpressions/$expression.png';
      default:
        return hanaBase; // Default fallback
    }
  }

  // Helper method to get background path by name
  static String getBackground(String name) {
    switch (name.toLowerCase()) {
      case 'school_entrance_morning':
        return backgroundSchoolEntrance;
      case 'classroom_day':
        return backgroundClassroom;
      case 'school_corridor':
        return backgroundCorridor;
      case 'storage_room':
        return backgroundStorageRoom;
      default:
        return backgroundSchoolEntrance; // Default fallback
    }
  }

  // Helper method to get music path by name
  static String getMusic(String name) {
    switch (name.toLowerCase()) {
      case 'school_theme':
        return musicSchoolTheme;
      case 'mystery_theme':
        return musicMysteryTheme;
      default:
        return musicSchoolTheme; // Default fallback
    }
  }

  // Helper method to get ambient sound path by name
  static String getAmbient(String name) {
    switch (name.toLowerCase()) {
      case 'classroom':
        return ambientClassroom;
      case 'school_morning':
        return ambientSchoolMorning;
      case 'storage_room':
        return ambientStorageRoom;
      default:
        return ambientSchoolMorning; // Default fallback
    }
  }

  // Helper method to get sound effect path by name
  static String getSoundEffect(String name) {
    switch (name.toLowerCase()) {
      case 'artifact_glow':
        return sfxArtifactGlow;
      case 'mirror_reveal':
        return sfxMirrorReveal;
      case 'time_shard':
        return sfxTimeShard;
      case 'door_open':
        return sfxDoorOpen;
      case 'footsteps':
        return sfxFootsteps;
      case 'school_bell':
        return sfxSchoolBell;
      case 'click':
        return sfxClick;
      case 'hover':
        return sfxHover;
      case 'transition':
        return sfxTransition;
      default:
        return sfxClick; // Default fallback
    }
  }
}