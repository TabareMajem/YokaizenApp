/// state/game-state.dart

import 'dart:convert';
import '../../../main.dart';

class GameState {
  // Basic state tracking
  String currentNode;
  String currentChapter;
  String currentBackground;
  Map<String, dynamic> variables;
  List<String> seenDialogue;
  
  // Character states
  Map<String, CharacterState> characters;
  
  // Progress tracking
  Map<String, bool> achievements;
  Map<String, bool> flags;
  List<String> completedChapters;
  
  // Audio states
  String currentMusic;
  String currentAmbient;
  bool isMuted;
  double musicVolume;
  double sfxVolume;

  GameState._({
    required this.currentNode,
    required this.currentChapter,
    required this.currentBackground,
    required this.variables,
    required this.seenDialogue,
    required this.characters,
    required this.achievements,
    required this.flags,
    required this.completedChapters,
    required this.currentMusic,
    required this.currentAmbient,
    required this.isMuted,
    required this.musicVolume,
    required this.sfxVolume,
  });

  // Initialize new game state
  static Future<GameState> initialize() async {
    return GameState._(
      currentNode: 'Start',
      currentChapter: 'chapter1',
      currentBackground: 'school_entrance_morning',
      variables: {},
      seenDialogue: [],
      characters: {},
      achievements: {},
      flags: {},
      completedChapters: [],
      currentMusic: '',
      currentAmbient: '',
      isMuted: false,
      musicVolume: 0.7,
      sfxVolume: 1.0,
    );
  }

  // Save game state
  Future<void> saveGame(String slotId) async {
    final saveData = {
      'currentNode': currentNode,
      'currentChapter': currentChapter,
      'currentBackground': currentBackground,
      'variables': variables,
      'seenDialogue': seenDialogue,
      'characters': characters.map((key, value) => MapEntry(key, value.toJson())),
      'achievements': achievements,
      'flags': flags,
      'completedChapters': completedChapters,
      'currentMusic': currentMusic,
      'currentAmbient': currentAmbient,
      'isMuted': isMuted,
      'musicVolume': musicVolume,
      'sfxVolume': sfxVolume,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await prefs.setString('save_$slotId', jsonEncode(saveData));
  }

  // Load game state
  static Future<GameState> loadGame(String slotId) async {
    final saveDataString = prefs.getString('save_$slotId');
    
    if (saveDataString == null) {
      throw Exception('No save data found for slot $slotId');
    }

    final saveData = jsonDecode(saveDataString);
    
    return GameState._(
      currentNode: saveData['currentNode'],
      currentChapter: saveData['currentChapter'],
      currentBackground: saveData['currentBackground'],
      variables: Map<String, dynamic>.from(saveData['variables']),
      seenDialogue: List<String>.from(saveData['seenDialogue']),
      characters: (saveData['characters'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, CharacterState.fromJson(value))
      ),
      achievements: Map<String, bool>.from(saveData['achievements']),
      flags: Map<String, bool>.from(saveData['flags']),
      completedChapters: List<String>.from(saveData['completedChapters']),
      currentMusic: saveData['currentMusic'],
      currentAmbient: saveData['currentAmbient'],
      isMuted: saveData['isMuted'],
      musicVolume: saveData['musicVolume'],
      sfxVolume: saveData['sfxVolume'],
    );
  }

  // Game state update methods
  void updateNode(String newNode) {
    currentNode = newNode;
    seenDialogue.add(newNode);
  }

  void updateChapter(String newChapter) {
    if (currentChapter != newChapter) {
      completedChapters.add(currentChapter);
      currentChapter = newChapter;
    }
  }

  void setFlag(String flag) {
    flags[flag] = true;
  }

  bool checkFlag(String flag) {
    return flags[flag] ?? false;
  }

  void addAchievement(String achievement) {
    achievements[achievement] = true;
  }

  // Character management
  void updateCharacter(String characterId, CharacterState state) {
    characters[characterId] = state;
  }

  void removeCharacter(String characterId) {
    characters.remove(characterId);
  }

  // Audio management
  void updateMusic(String musicId) {
    currentMusic = musicId;
  }

  void updateAmbient(String ambientId) {
    currentAmbient = ambientId;
  }

  void toggleMute() {
    isMuted = !isMuted;
  }

  void setMusicVolume(double volume) {
    musicVolume = volume.clamp(0.0, 1.0);
  }

  void setSfxVolume(double volume) {
    sfxVolume = volume.clamp(0.0, 1.0);
  }

  // Quick save/load methods
  Future<void> quickSave() async {
    await saveGame('quick');
  }

  static Future<GameState> quickLoad() async {
    return loadGame('quick');
  }

  // Auto save
  Future<void> autoSave() async {
    await saveGame('auto');
  }
}

// Character state management
class CharacterState {
  String expression;
  String position;
  bool isVisible;
  double scale;
  Map<String, int> relationships;

  CharacterState({
    required this.expression,
    required this.position,
    required this.isVisible,
    required this.scale,
    required this.relationships,
  });

  Map<String, dynamic> toJson() {
    return {
      'expression': expression,
      'position': position,
      'isVisible': isVisible,
      'scale': scale,
      'relationships': relationships,
    };
  }

  static CharacterState fromJson(Map<String, dynamic> json) {
    return CharacterState(
      expression: json['expression'],
      position: json['position'],
      isVisible: json['isVisible'],
      scale: json['scale'],
      relationships: Map<String, int>.from(json['relationships']),
    );
  }

  void updateExpression(String newExpression) {
    expression = newExpression;
  }

  void updatePosition(String newPosition) {
    position = newPosition;
  }

  void setVisibility(bool visible) {
    isVisible = visible;
  }

  void updateScale(double newScale) {
    scale = newScale;
  }

  void updateRelationship(String characterId, int value) {
    relationships[characterId] = (relationships[characterId] ?? 0) + value;
  }
}
