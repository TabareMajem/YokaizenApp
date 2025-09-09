// This file contains additional methods needed for the AdminState class
// to support all the content creation modules

import 'package:flutter/material.dart';
import 'story_module.dart';
import 'game_module.dart';
import 'cbt_exercise.dart';
import 'quiz_module.dart';

// Add these methods to your existing AdminState class

class AdminState extends ChangeNotifier {
  // Existing fields from the original implementation
  StoryModule? _storyModule;
  GameModule? _gameModule;
  CBTExercise? _cbtExercise;
  QuizModule? _quizModule;
  
  // Current active module type
  ContentModuleType _activeModuleType = ContentModuleType.storyModule;
  
  // Getters
  StoryModule? get storyModule => _storyModule;
  GameModule? get gameModule => _gameModule;
  CBTExercise? get cbtExercise => _cbtExercise;
  QuizModule? get quizModule => _quizModule;
  ContentModuleType get activeModuleType => _activeModuleType;
  
  // Set active module type
  void setActiveModuleType(ContentModuleType type) {
    _activeModuleType = type;
    notifyListeners();
  }
  
  // Game Module Methods
  void initializeGameModule(GameType type) {
    _gameModule = GameModule.createDefault(type);
    notifyListeners();
  }
  
  void updateGameModule(GameModule updatedModule) {
    _gameModule = updatedModule;
    notifyListeners();
  }
  
  void addGameElement(GameElementType type, Offset position) {
    if (_gameModule == null) return;
    
    const uuid = Uuid();
    
    // Default size based on element type
    Size size;
    switch (type) {
      case GameElementType.platform:
        size = const Size(100, 20);
        break;
      case GameElementType.obstacle:
        size = const Size(40, 40);
        break;
      case GameElementType.collectible:
        size = const Size(30, 30);
        break;
      default:
        size = const Size(50, 50);
    }
    
    final newElement = GameElement(
      id: uuid.v4(),
      type: type,
      position: position,
      size: size,
      properties: {},
    );
    
    final updatedElements = List<GameElement>.from(_gameModule!.gameElements)..add(newElement);
    
    _gameModule = _gameModule!.copyWith(gameElements: updatedElements);
    notifyListeners();
  }
  
  void updateGameElementPosition(String elementId, Offset newPosition) {
    if (_gameModule == null) return;
    
    final elementIndex = _gameModule!.gameElements.indexWhere((e) => e.id == elementId);
    if (elementIndex == -1) return;
    
    final updatedElement = _gameModule!.gameElements[elementIndex].copyWith(position: newPosition);
    final updatedElements = List<GameElement>.from(_gameModule!.gameElements);
    updatedElements[elementIndex] = updatedElement;
    
    _gameModule = _gameModule!.copyWith(gameElements: updatedElements);
    notifyListeners();
  }
  
  // CBT Exercise Methods
  void initializeCBTExercise(CBTExerciseType type) {
    _cbtExercise = CBTExercise.createDefault(type);
    notifyListeners();
  }
  
  void updateCBTExercise(CBTExercise updatedExercise) {
    _cbtExercise = updatedExercise;
    notifyListeners();
  }
  
  // Quiz Module Methods
  void initializeQuizModule(QuizType type) {
    _quizModule = QuizModule.createDefault(type);
    notifyListeners();
  }
  
  void updateQuizModule(QuizModule updatedQuiz) {
    _quizModule = updatedQuiz;
    notifyListeners();
  }
  
  // Module Selection Methods
  void createNewModule(ContentModuleType type) {
    switch (type) {
      case ContentModuleType.storyModule:
        // Initialize a new story module with default values
        _storyModule = StoryModule(
          id: '',
          title: '',
          description: '',
          author: '',
          version: '1.0.0',
          category: 'self_esteem',
          difficulty: 'medium',
          estimatedDuration: 20,
          characters: [],
          scenes: [],
          nodes: [],
          stats: [
            Stat(id: 'authenticity', name: 'Authenticity', icon: 'heart'),
            Stat(id: 'confidence', name: 'Confidence', icon: 'star'),
            Stat(id: 'resilience', name: 'Resilience', icon: 'shield'),
            Stat(id: 'selfEsteem', name: 'Self-Esteem', icon: 'trending_up'),
          ],
        );
        break;
      case ContentModuleType.gameModule:
        initializeGameModule(GameType.taskDash);
        break;
      case ContentModuleType.cbtExercise:
        initializeCBTExercise(CBTExerciseType.innerCriticCut);
        break;
      case ContentModuleType.quizModule:
        initializeQuizModule(QuizType.multipleChoice);
        break;
    }
    
    _activeModuleType = type;
    notifyListeners();
  }
  
  // Deployment Methods
  Future<bool> deployCurrentModule() async {
    try {
      switch (_activeModuleType) {
        case ContentModuleType.storyModule:
          if (_storyModule != null) {
            // Deploy story module
            // This would call your API service
          }
          break;
        case ContentModuleType.gameModule:
          if (_gameModule != null) {
            // Deploy game module
            // This would call your API service
          }
          break;
        case ContentModuleType.cbtExercise:
          if (_cbtExercise != null) {
            // Deploy CBT exercise
            // This would call your API service
          }
          break;
        case ContentModuleType.quizModule:
          if (_quizModule != null) {
            // Deploy quiz module
            // This would call your API service
          }
          break;
      }
      
      return true;
    } catch (e) {
      print('Error deploying module: $e');
      return false;
    }
  }
}

enum ContentModuleType {
  storyModule,
  gameModule,
  cbtExercise,
  quizModule,
}
