/// Unity Game Management Service for VoiceBridge Games
/// Handles communication between Flutter and Unity games

import 'dart:async';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:get/get.dart';

enum GameType {
  voiceBridge,
  voiceBridgePolished,
}

enum GameState {
  loading,
  ready,
  playing,
  paused,
  completed,
  error,
}

class UnityGameService extends GetxController {
  static UnityGameService get instance => Get.find<UnityGameService>();
  
  // Unity Widget Controllers
  UnityWidgetController? _voiceBridgeController;
  UnityWidgetController? _voiceBridgePolishedController;
  
  // Game State Management
  final Rx<GameState> _gameState = GameState.loading.obs;
  final RxString _currentGame = ''.obs;
  final RxMap<String, dynamic> _gameData = <String, dynamic>{}.obs;
  final RxBool _isUnityReady = false.obs;
  
  // Getters
  GameState get gameState => _gameState.value;
  String get currentGame => _currentGame.value;
  Map<String, dynamic> get gameData => _gameData;
  bool get isUnityReady => _isUnityReady.value;
  
  // Streams
  Stream<GameState> get gameStateStream => _gameState.stream;
  Stream<Map<String, dynamic>> get gameDataStream => _gameData.stream;
  
  @override
  void onInit() {
    super.onInit();
    _initializeService();
  }
  
  void _initializeService() {
    customPrint('🎮 Unity Game Service initialized');
    _resetGameState();
  }
  
  void _resetGameState() {
    _gameState.value = GameState.loading;
    _currentGame.value = '';
    _gameData.clear();
    _isUnityReady.value = false;
  }
  
  /// Initialize specific game
  Future<bool> initializeGame(GameType gameType) async {
    try {
      _resetGameState();
      _currentGame.value = _getGameName(gameType);
      
      customPrint('🎮 Initializing ${_currentGame.value}...');
      
      // Set game as ready after initialization
      await Future.delayed(const Duration(seconds: 1));
      _gameState.value = GameState.ready;
      _isUnityReady.value = true;
      
      customPrint('✅ ${_currentGame.value} initialized successfully');
      return true;
    } catch (e) {
      customPrint('❌ Error initializing game: $e');
      _gameState.value = GameState.error;
      return false;
    }
  }
  
  /// Handle Unity widget creation
  void onUnityCreated(GameType gameType, UnityWidgetController controller) {
    customPrint('🎮 Unity widget created for ${_getGameName(gameType)}');
    
    switch (gameType) {
      case GameType.voiceBridge:
        _voiceBridgeController = controller;
        break;
      case GameType.voiceBridgePolished:
        _voiceBridgePolishedController = controller;
        break;
    }
    
    _setupUnityMessageHandlers(controller);
    _isUnityReady.value = true;
    _gameState.value = GameState.ready;
  }
  
  /// Setup message handlers between Flutter and Unity
  void _setupUnityMessageHandlers(UnityWidgetController controller) {
    // Listen for messages from Unity
    controller.onUnityMessage.listen((message) {
      _handleUnityMessage(message);
    });
    
    // Send initial data to Unity
    _sendInitialDataToUnity(controller);
  }
  
  /// Handle messages received from Unity
  void _handleUnityMessage(dynamic message) {
    try {
      customPrint('📨 Received message from Unity: $message');
      
      if (message is Map<String, dynamic>) {
        final messageType = message['type'] as String?;
        final data = message['data'] as Map<String, dynamic>?;
        
        switch (messageType) {
          case 'game_started':
            _gameState.value = GameState.playing;
            break;
          case 'game_paused':
            _gameState.value = GameState.paused;
            break;
          case 'game_completed':
            _gameState.value = GameState.completed;
            if (data != null) {
              _gameData.addAll(data);
            }
            break;
          case 'score_updated':
            if (data != null) {
              _gameData['score'] = data['score'];
              _gameData['lastUpdated'] = DateTime.now().toIso8601String();
            }
            break;
          case 'level_completed':
            if (data != null) {
              _gameData['level'] = data['level'];
              _gameData['completion_time'] = data['completion_time'];
            }
            break;
          default:
            customPrint('🤷 Unknown message type: $messageType');
        }
      }
    } catch (e) {
      customPrint('❌ Error handling Unity message: $e');
    }
  }
  
  /// Send initial data to Unity when game starts
  void _sendInitialDataToUnity(UnityWidgetController controller) {
    final initialData = {
      'user_id': 'flutter_user_123', // Replace with actual user ID
      'app_version': '1.0.0',
      'language': Get.locale?.languageCode ?? 'en',
      'settings': {
        'sound_enabled': true,
        'haptic_feedback': true,
        'difficulty': 'normal',
      }
    };
    
    sendMessageToUnity(controller, 'initialize_game', initialData);
  }
  
  /// Send message to Unity
  void sendMessageToUnity(UnityWidgetController controller, String method, [dynamic data]) {
    try {
      controller.postMessage(
        'GameManager', // Unity GameObject name
        method,
        data?.toString() ?? '',
      );
      
      customPrint('📤 Sent message to Unity: $method');
    } catch (e) {
      customPrint('❌ Error sending message to Unity: $e');
    }
  }
  
  /// Game control methods
  void startGame() {
    final controller = _getCurrentController();
    if (controller != null) {
      sendMessageToUnity(controller, 'start_game');
      _gameState.value = GameState.playing;
    }
  }
  
  void pauseGame() {
    final controller = _getCurrentController();
    if (controller != null) {
      sendMessageToUnity(controller, 'pause_game');
      _gameState.value = GameState.paused;
    }
  }
  
  void resumeGame() {
    final controller = _getCurrentController();
    if (controller != null) {
      sendMessageToUnity(controller, 'resume_game');
      _gameState.value = GameState.playing;
    }
  }
  
  void restartGame() {
    final controller = _getCurrentController();
    if (controller != null) {
      sendMessageToUnity(controller, 'restart_game');
      _gameData.clear();
      _gameState.value = GameState.playing;
    }
  }
  
  void exitGame() {
    final controller = _getCurrentController();
    if (controller != null) {
      sendMessageToUnity(controller, 'exit_game');
    }
    _resetGameState();
  }
  
  /// Get current active controller
  UnityWidgetController? _getCurrentController() {
    switch (_currentGame.value) {
      case 'VoiceBridge':
        return _voiceBridgeController;
      case 'VoiceBridge Polished':
        return _voiceBridgePolishedController;
      default:
        return null;
    }
  }
  
  /// Helper methods
  String _getGameName(GameType gameType) {
    switch (gameType) {
      case GameType.voiceBridge:
        return 'VoiceBridge';
      case GameType.voiceBridgePolished:
        return 'VoiceBridge Polished';
    }
  }
  
  String getGameDescription(GameType gameType) {
    switch (gameType) {
      case GameType.voiceBridge:
        return 'Connect spirits through the power of voice in this rhythmic bridge-building adventure.';
      case GameType.voiceBridgePolished:
        return 'Enhanced version with improved graphics and new mechanics for voice-based gameplay.';
    }
  }
  
  String getGameImagePath(GameType gameType) {
    switch (gameType) {
      case GameType.voiceBridge:
        return 'games/game1/VoiceBridge/Art/koe_chan.png';
      case GameType.voiceBridgePolished:
        return 'games/game2/VoiceBridgePolished/Art/koe_chan.png';
    }
  }
  
  /// Get game progress data
  Map<String, dynamic> getGameProgress(GameType gameType) {
    return {
      'game_name': _getGameName(gameType),
      'current_level': _gameData['level'] ?? 1,
      'high_score': _gameData['high_score'] ?? 0,
      'total_playtime': _gameData['total_playtime'] ?? 0,
      'achievements': _gameData['achievements'] ?? [],
      'last_played': _gameData['last_played'],
    };
  }
  
  /// Save game progress
  void saveGameProgress(Map<String, dynamic> progressData) {
    _gameData.addAll(progressData);
    _gameData['last_saved'] = DateTime.now().toIso8601String();
    
    // Here you could also save to SharedPreferences or your backend
    customPrint('💾 Game progress saved: ${progressData.keys}');
  }
  
  @override
  void onClose() {
    _voiceBridgeController?.dispose();
    _voiceBridgePolishedController?.dispose();
    super.onClose();
  }
}

extension on UnityWidgetController {
  get onUnityMessage => null;
}

// Extension for custom print
extension CustomPrint on UnityGameService {
  void customPrint(String message) {
    print('🎮 [UnityGameService] $message');
  }
}
