import 'dart:convert';
import 'package:flutter/services.dart';

class AssetsManager {
  // Configuration files
  final Map<String, dynamic> characters;
  final Map<String, dynamic> backgrounds;
  final Map<String, dynamic> dialogueConfig;
  final Map<String, dynamic> chaptersConfig;
  final Map<String, dynamic> effectsConfig;
  final Map<String, dynamic> audioConfig;

  // Cache for loaded assets
  final Map<String, dynamic> _assetCache = {};

  AssetsManager._({
    required this.characters,
    required this.backgrounds,
    required this.dialogueConfig,
    required this.chaptersConfig,
    required this.effectsConfig,
    required this.audioConfig,
  });

  static Future<AssetsManager> initialize() async {
    try {
      // Load configuration files
      final characters = await _loadJson('visualassets/config/characters-config.json');
      final backgrounds = await _loadJson('visualassets/config/scenes-config.json');
      final dialogueConfig = await _loadJson('visualassets/config/dialogue-config.json');
      final chaptersConfig = await _loadJson('visualassets/config/chapters-config.json');
      final effectsConfig = await _loadJson('visualassets/config/effects-config.json');
      final audioConfig = await _loadJson('visualassets/config/audio-config.json');

      return AssetsManager._(
        characters: characters,
        backgrounds: backgrounds,
        dialogueConfig: dialogueConfig,
        chaptersConfig: chaptersConfig,
        effectsConfig: effectsConfig,
        audioConfig: audioConfig,
      );
    } catch (e) {
      print('Error initializing AssetsManager: $e');
      // Return with empty maps to prevent null errors
      return AssetsManager._(
        characters: {},
        backgrounds: {},
        dialogueConfig: {},
        chaptersConfig: {},
        effectsConfig: {},
        audioConfig: {},
      );
    }
  }

  static Future<Map<String, dynamic>> _loadJson(String path) async {
    try {
      final content = await rootBundle.loadString(path);
      return jsonDecode(content);
    } catch (e) {
      print('Error loading JSON file $path: $e');
      return {};
    }
  }

  Future<void> changeBackground(String backgroundId) async {
    // Implementation for background changing logic
    final scene = backgrounds['scenes'][backgroundId];
    if (scene == null) {
      throw Exception('Background not found: $backgroundId');
    }

    // In a real implementation, this would update the background in the UI
    print('Changing background to: $backgroundId');

    // Preload the background image
    await precacheImage(backgroundId);
  }

  Future<void> precacheImage(String backgroundId) async {
    try {
      final scene = backgrounds['scenes'][backgroundId];
      if (scene != null && scene['background'] != null) {
        final imagePath = scene['background'];

        // Add to asset cache if not already there
        if (!_assetCache.containsKey(imagePath)) {
          _assetCache[imagePath] = true;
        }
      }
    } catch (e) {
      print('Error precaching image: $e');
    }
  }

  Future<void> loadCharacter(String characterId, String expression) async {
    try {
      final character = characters['characters'][characterId];
      if (character == null) {
        throw Exception('Character not found: $characterId');
      }

      // Get the sprite path
      String spritePath;
      if (expression == 'base' || character['sprites']['expressions'][expression] == null) {
        spritePath = character['sprites']['base'];
      } else {
        spritePath = character['sprites']['expressions'][expression];
      }

      // Add to asset cache if not already there
      if (!_assetCache.containsKey(spritePath)) {
        _assetCache[spritePath] = true;
      }
    } catch (e) {
      print('Error loading character: $e');
    }
  }

  String getBackgroundMusic(String backgroundId) {
    try {
      final scene = backgrounds['scenes'][backgroundId];
      return scene?['music'] ?? '';
    } catch (e) {
      print('Error getting background music: $e');
      return '';
    }
  }

  String getAmbientSound(String backgroundId) {
    try {
      final scene = backgrounds['scenes'][backgroundId];
      return scene?['ambient'] ?? '';
    } catch (e) {
      print('Error getting ambient sound: $e');
      return '';
    }
  }

  Future<String> loadString(String path) async {
    try {
      return await rootBundle.loadString(path);
    } catch (e) {
      print('Error loading string from $path: $e');
      return '';
    }
  }

  // Loading dialogue files
  Future<Map<String, String>> loadDialogueFiles() async {
    final Map<String, String> dialogueContent = {};

    try {
      // Common dialogue
      dialogueContent['common'] = await loadString('visualassets/dialogue/common-dialogue.txt');

      // Chapter dialogues
      dialogueContent['chapter1'] = await loadString('visualassets/dialogue/chapter1-dialogue.txt');
      dialogueContent['chapter2'] = await loadString('visualassets/dialogue/chapter2-dialogue.txt');
      dialogueContent['chapter3'] = await loadString('visualassets/dialogue/chapter3-dialogue.txt');
    } catch (e) {
      print('Error loading dialogue files: $e');
    }

    return dialogueContent;
  }

  // Get character name from ID
  String getCharacterName(String characterId) {
    try {
      final character = characters['characters'][characterId];
      return character?['fullName'] ?? characterId;
    } catch (e) {
      print('Error getting character name: $e');
      return characterId;
    }
  }

  // Get effect configuration
  Map<String, dynamic>? getEffectConfig(String effectId) {
    try {
      return effectsConfig['effects'][effectId];
    } catch (e) {
      print('Error getting effect config: $e');
      return null;
    }
  }

  // Get chapter information
  Map<String, dynamic>? getChapterInfo(String chapterId) {
    try {
      return chaptersConfig['chapters'][chapterId];
    } catch (e) {
      print('Error getting chapter info: $e');
      return null;
    }
  }

  // Get text speed from dialogue config
  int getTextSpeed() {
    try {
      return dialogueConfig['textSpeed'] ?? 30;
    } catch (e) {
      print('Error getting text speed: $e');
      return 30;
    }
  }

  // Get auto play delay from dialogue config
  int getAutoPlayDelay() {
    try {
      return dialogueConfig['autoPlayDelay'] ?? 2000;
    } catch (e) {
      print('Error getting auto play delay: $e');
      return 2000;
    }
  }

  // Get dialogue box opacity
  double getDialogueBoxOpacity() {
    try {
      return dialogueConfig['ui']['textBox']['opacity'] ?? 0.85;
    } catch (e) {
      print('Error getting dialogue box opacity: $e');
      return 0.85;
    }
  }

  // Get audio configuration
  Map<String, dynamic>? getAudioConfig(String category, String id) {
    try {
      if (category == 'music') {
        return audioConfig['music'][id];
      } else if (category == 'ambient') {
        return audioConfig['ambient'][id];
      } else if (category == 'sfx') {
        // For SFX, need to look in subcategories
        for (var subCategory in audioConfig['sfx'].keys) {
          final categoryMap = audioConfig['sfx'][subCategory];
          if (categoryMap.containsKey(id)) {
            return categoryMap[id];
          }
        }
      }
      return null;
    } catch (e) {
      print('Error getting audio config: $e');
      return null;
    }
  }

  // Preload assets for a chapter
  Future<void> preloadChapterAssets(String chapterId) async {
    try {
      final chapterInfo = chaptersConfig['chapters'][chapterId];
      if (chapterInfo == null) {
        throw Exception('Chapter not found: $chapterId');
      }

      final requiredAssets = chapterInfo['requiredAssets'];

      // Preload backgrounds
      for (final backgroundId in requiredAssets['background']) {
        await precacheImage(backgroundId);
      }

      // Preload characters
      for (final characterId in requiredAssets['characters']) {
        await loadCharacter(characterId, 'neutral');
      }

      print('Preloaded assets for chapter: $chapterId');
    } catch (e) {
      print('Error preloading chapter assets: $e');
    }
  }

  // Get transition configuration
  Map<String, dynamic> getTransitionConfig(String type) {
    try {
      if (type == 'chapter') {
        return dialogueConfig['transitions']['chapter'];
      }
      return dialogueConfig['transitions']['default'];
    } catch (e) {
      print('Error getting transition config: $e');
      return {'type': 'fade', 'duration': 500};
    }
  }
}