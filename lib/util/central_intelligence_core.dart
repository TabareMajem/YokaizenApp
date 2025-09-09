import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core Data Models for Central Intelligence
class EmotionalState {
  final double valence;        // -1.0 to 1.0 (negative to positive mood)
  final double arousal;        // -1.0 to 1.0 (low to high energy)
  final double stress;         // 0.0 to 1.0 (no stress to high stress)
  final double confidence;     // 0.0 to 1.0 (low to high confidence)
  final String context;        // Current activity context
  final DateTime timestamp;
  final Map<String, double>? biometricData;

  EmotionalState({
    required this.valence,
    required this.arousal,
    required this.stress,
    required this.confidence,
    required this.context,
    required this.timestamp,
    this.biometricData,
  });

  factory EmotionalState.fromJson(Map<String, dynamic> json) {
    return EmotionalState(
      valence: json['valence']?.toDouble() ?? 0.0,
      arousal: json['arousal']?.toDouble() ?? 0.0,
      stress: json['stress']?.toDouble() ?? 0.0,
      confidence: json['confidence']?.toDouble() ?? 0.0,
      context: json['context'] ?? 'unknown',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      biometricData: json['biometric_data'] != null 
          ? Map<String, double>.from(json['biometric_data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'valence': valence,
      'arousal': arousal,
      'stress': stress,
      'confidence': confidence,
      'context': context,
      'timestamp': timestamp.toIso8601String(),
      'biometric_data': biometricData,
    };
  }

  EmotionalState copyWith({
    double? valence,
    double? arousal,
    double? stress,
    double? confidence,
    String? context,
    DateTime? timestamp,
    Map<String, double>? biometricData,
  }) {
    return EmotionalState(
      valence: valence ?? this.valence,
      arousal: arousal ?? this.arousal,
      stress: stress ?? this.stress,
      confidence: confidence ?? this.confidence,
      context: context ?? this.context,
      timestamp: timestamp ?? this.timestamp,
      biometricData: biometricData ?? this.biometricData,
    );
  }
}

class AIIntervention {
  final String id;
  final String type;
  final Map<String, dynamic> content;
  final String deliveryMethod;
  final DateTime timestamp;
  final double priority;
  final String? triggerReason;

  AIIntervention({
    required this.id,
    required this.type,
    required this.content,
    required this.deliveryMethod,
    required this.timestamp,
    this.priority = 0.5,
    this.triggerReason,
  });

  factory AIIntervention.fromJson(Map<String, dynamic> json) {
    return AIIntervention(
      id: json['intervention_id'] ?? json['id'] ?? '',
      type: json['content']?['type'] ?? json['type'] ?? '',
      content: json['content'] ?? {},
      deliveryMethod: json['delivery_method'] ?? 'notification',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      priority: json['priority']?.toDouble() ?? 0.5,
      triggerReason: json['trigger_reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'intervention_id': id,
      'type': type,
      'content': content,
      'delivery_method': deliveryMethod,
      'timestamp': timestamp.toIso8601String(),
      'priority': priority,
      'trigger_reason': triggerReason,
    };
  }
}

class UserProgress {
  final double resilience;
  final double selfEsteem;
  final double emotionalRegulation;
  final double socialConnection;
  final double mindfulness;
  final DateTime lastUpdated;
  final Map<String, double>? detailedScores;

  UserProgress({
    required this.resilience,
    required this.selfEsteem,
    required this.emotionalRegulation,
    required this.socialConnection,
    required this.mindfulness,
    required this.lastUpdated,
    this.detailedScores,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      resilience: json['resilience']?.toDouble() ?? 0.5,
      selfEsteem: json['self_esteem']?.toDouble() ?? 0.5,
      emotionalRegulation: json['emotional_regulation']?.toDouble() ?? 0.5,
      socialConnection: json['social_connection']?.toDouble() ?? 0.5,
      mindfulness: json['mindfulness']?.toDouble() ?? 0.5,
      lastUpdated: DateTime.parse(json['last_updated'] ?? DateTime.now().toIso8601String()),
      detailedScores: json['detailed_scores'] != null 
          ? Map<String, double>.from(json['detailed_scores'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resilience': resilience,
      'self_esteem': selfEsteem,
      'emotional_regulation': emotionalRegulation,
      'social_connection': socialConnection,
      'mindfulness': mindfulness,
      'last_updated': lastUpdated.toIso8601String(),
      'detailed_scores': detailedScores,
    };
  }

  double get overallScore {
    return (resilience + selfEsteem + emotionalRegulation + socialConnection + mindfulness) / 5.0;
  }

  UserProgress copyWith({
    double? resilience,
    double? selfEsteem,
    double? emotionalRegulation,
    double? socialConnection,
    double? mindfulness,
    DateTime? lastUpdated,
    Map<String, double>? detailedScores,
  }) {
    return UserProgress(
      resilience: resilience ?? this.resilience,
      selfEsteem: selfEsteem ?? this.selfEsteem,
      emotionalRegulation: emotionalRegulation ?? this.emotionalRegulation,
      socialConnection: socialConnection ?? this.socialConnection,
      mindfulness: mindfulness ?? this.mindfulness,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      detailedScores: detailedScores ?? this.detailedScores,
    );
  }
}

class UserMemory {
  final String id;
  final String type;
  final Map<String, dynamic> content;
  final double emotionalWeight;    // -1.0 to 1.0
  final double importance;         // 0.0 to 1.0
  final DateTime timestamp;
  final DateTime? lastAccessed;
  final int accessCount;
  final double? decayRate;

  UserMemory({
    required this.id,
    required this.type,
    required this.content,
    required this.emotionalWeight,
    required this.importance,
    required this.timestamp,
    this.lastAccessed,
    this.accessCount = 0,
    this.decayRate,
  });

  factory UserMemory.fromJson(Map<String, dynamic> json) {
    return UserMemory(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      content: json['content'] ?? {},
      emotionalWeight: json['emotional_weight']?.toDouble() ?? 0.0,
      importance: json['importance']?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      lastAccessed: json['last_accessed'] != null 
          ? DateTime.parse(json['last_accessed'])
          : null,
      accessCount: json['access_count'] ?? 0,
      decayRate: json['decay_rate']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'content': content,
      'emotional_weight': emotionalWeight,
      'importance': importance,
      'timestamp': timestamp.toIso8601String(),
      'last_accessed': lastAccessed?.toIso8601String(),
      'access_count': accessCount,
      'decay_rate': decayRate,
    };
  }

  // Calculate memory strength based on time and access patterns
  double get memoryStrength {
    final now = DateTime.now();
    final timeSinceCreation = now.difference(timestamp).inDays;
    final timeSinceLastAccess = lastAccessed != null 
        ? now.difference(lastAccessed!).inDays 
        : timeSinceCreation;
    
    // Base strength from importance and emotional weight
    double baseStrength = (importance + (emotionalWeight.abs() * 0.5)) / 2.0;
    
    // Time decay (memories fade over time)
    double timeDecay = 1.0 / (1.0 + (timeSinceCreation * 0.1));
    
    // Access reinforcement (frequently accessed memories are stronger)
    double accessReinforcement = 1.0 + (accessCount * 0.1);
    
    return (baseStrength * timeDecay * accessReinforcement).clamp(0.0, 1.0);
  }
}

class BiometricData {
  final double heartRate;
  final double heartRateVariability;
  final double galvanicSkinResponse;
  final double temperature;
  final double movementIntensity;
  final DateTime timestamp;
  final String? context;

  BiometricData({
    required this.heartRate,
    required this.heartRateVariability,
    required this.galvanicSkinResponse,
    required this.temperature,
    required this.movementIntensity,
    required this.timestamp,
    this.context,
  });

  factory BiometricData.fromJson(Map<String, dynamic> json) {
    return BiometricData(
      heartRate: json['heart_rate']?.toDouble() ?? 0.0,
      heartRateVariability: json['heart_rate_variability']?.toDouble() ?? 0.0,
      galvanicSkinResponse: json['galvanic_skin_response']?.toDouble() ?? 0.0,
      temperature: json['temperature']?.toDouble() ?? 0.0,
      movementIntensity: json['movement_intensity']?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      context: json['context'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'heart_rate': heartRate,
      'heart_rate_variability': heartRateVariability,
      'galvanic_skin_response': galvanicSkinResponse,
      'temperature': temperature,
      'movement_intensity': movementIntensity,
      'timestamp': timestamp.toIso8601String(),
      'context': context,
    };
  }

  // Convert biometric data to emotional indicators
  Map<String, double> toEmotionalIndicators() {
    return {
      'stress': _calculateStressLevel(),
      'arousal': _calculateArousalLevel(),
      'confidence': _calculateConfidenceLevel(),
    };
  }

  double _calculateStressLevel() {
    // Higher HRV = lower stress, higher GSR = higher stress
    double hrvStress = (1.0 - heartRateVariability).clamp(0.0, 1.0);
    double gsrStress = galvanicSkinResponse.clamp(0.0, 1.0);
    return (hrvStress + gsrStress) / 2.0;
  }

  double _calculateArousalLevel() {
    // Higher heart rate and movement = higher arousal
    double hrArousal = (heartRate - 60) / (100 - 60); // Normalize to 0-1
    double movementArousal = movementIntensity;
    return ((hrArousal + movementArousal) / 2.0).clamp(0.0, 1.0);
  }

  double _calculateConfidenceLevel() {
    // Lower stress and moderate arousal = higher confidence
    double stressFactor = 1.0 - _calculateStressLevel();
    double arousalFactor = 1.0 - (_calculateArousalLevel() - 0.5).abs() * 2;
    return (stressFactor + arousalFactor) / 2.0;
  }
}

// Central Intelligence Core Service
class CentralIntelligenceCore {
  static final CentralIntelligenceCore _instance = CentralIntelligenceCore._internal();
  factory CentralIntelligenceCore() => _instance;
  CentralIntelligenceCore._internal();

  // Stream controllers for real-time updates
  final StreamController<EmotionalState> _emotionalStateController = StreamController<EmotionalState>.broadcast();
  final StreamController<AIIntervention> _interventionController = StreamController<AIIntervention>.broadcast();
  final StreamController<UserProgress> _progressController = StreamController<UserProgress>.broadcast();
  final StreamController<UserMemory> _memoryController = StreamController<UserMemory>.broadcast();

  // Public streams
  Stream<EmotionalState> get emotionalStateStream => _emotionalStateController.stream;
  Stream<AIIntervention> get interventionStream => _interventionController.stream;
  Stream<UserProgress> get progressStream => _progressController.stream;
  Stream<UserMemory> get memoryStream => _memoryController.stream;

  // Internal state
  EmotionalState? _currentEmotionalState;
  UserProgress? _currentUserProgress;
  List<UserMemory> _userMemories = [];
  List<BiometricData> _biometricHistory = [];
  
  // Configuration
  bool _isInitialized = false;
  String? _currentUserId;
  SharedPreferences? _prefs;

  // Getters
  EmotionalState? get currentEmotionalState => _currentEmotionalState;
  UserProgress? get currentUserProgress => _currentUserProgress;
  List<UserMemory> get userMemories => List.unmodifiable(_userMemories);
  bool get isInitialized => _isInitialized;

  // Initialize the central intelligence system
  Future<void> initialize(String userId) async {
    if (_isInitialized) return;

    try {
      _currentUserId = userId;
      _prefs = await SharedPreferences.getInstance();
      
      // Load existing data
      await _loadUserData();
      
      // Initialize with default values if no data exists
      if (_currentUserProgress == null) {
        _currentUserProgress = UserProgress(
          resilience: 0.5,
          selfEsteem: 0.5,
          emotionalRegulation: 0.5,
          socialConnection: 0.5,
          mindfulness: 0.5,
          lastUpdated: DateTime.now(),
        );
      }

      _isInitialized = true;
      debugPrint('Central Intelligence initialized for user: $userId');
    } catch (e) {
      debugPrint('Error initializing Central Intelligence: $e');
      rethrow;
    }
  }

  // Process biometric data and update emotional state
  Future<void> processBiometricData(BiometricData biometricData) async {
    if (!_isInitialized) return;

    try {
      // Add to history
      _biometricHistory.add(biometricData);
      
      // Keep only last 100 readings
      if (_biometricHistory.length > 100) {
        _biometricHistory.removeAt(0);
      }

      // Convert to emotional indicators
      final emotionalIndicators = biometricData.toEmotionalIndicators();
      
      // Calculate valence based on context and historical patterns
      double valence = _calculateValenceFromContext(biometricData.context);
      
      // Create new emotional state
      final newEmotionalState = EmotionalState(
        valence: valence,
        arousal: emotionalIndicators['arousal']!,
        stress: emotionalIndicators['stress']!,
        confidence: emotionalIndicators['confidence']!,
        context: biometricData.context ?? 'unknown',
        timestamp: biometricData.timestamp,
        biometricData: {
          'heart_rate': biometricData.heartRate,
          'heart_rate_variability': biometricData.heartRateVariability,
          'galvanic_skin_response': biometricData.galvanicSkinResponse,
          'temperature': biometricData.temperature,
          'movement_intensity': biometricData.movementIntensity,
        },
      );

      // Update current state
      _currentEmotionalState = newEmotionalState;
      
      // Emit new state
      _emotionalStateController.add(newEmotionalState);
      
      // Check for intervention triggers
      await _checkForInterventions(newEmotionalState);
      
      // Save data
      await _saveUserData();
      
      debugPrint('Processed biometric data: ${newEmotionalState.toJson()}');
    } catch (e) {
      debugPrint('Error processing biometric data: $e');
    }
  }

  // Store important memory
  Future<void> storeMemory(String memoryType, Map<String, dynamic> content, {
    double emotionalWeight = 0.0,
    double importance = 0.5,
  }) async {
    if (!_isInitialized) return;

    try {
      final memory = UserMemory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: memoryType,
        content: content,
        emotionalWeight: emotionalWeight.clamp(-1.0, 1.0),
        importance: importance.clamp(0.0, 1.0),
        timestamp: DateTime.now(),
        lastAccessed: DateTime.now(),
        accessCount: 1,
      );

      _userMemories.add(memory);
      
      // Emit memory update
      _memoryController.add(memory);
      
      // Save data
      await _saveUserData();
      
      debugPrint('Stored memory: $memoryType with weight: $emotionalWeight');
    } catch (e) {
      debugPrint('Error storing memory: $e');
    }
  }

  // Update user progress based on activities
  Future<void> updateProgress(String progressType, double value, {
    String? context,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isInitialized || _currentUserProgress == null) return;

    try {
      final oldProgress = _currentUserProgress!;
      UserProgress newProgress;

      switch (progressType.toLowerCase()) {
        case 'resilience':
          newProgress = oldProgress.copyWith(
            resilience: value.clamp(0.0, 1.0),
            lastUpdated: DateTime.now(),
          );
          break;
        case 'self_esteem':
          newProgress = oldProgress.copyWith(
            selfEsteem: value.clamp(0.0, 1.0),
            lastUpdated: DateTime.now(),
          );
          break;
        case 'emotional_regulation':
          newProgress = oldProgress.copyWith(
            emotionalRegulation: value.clamp(0.0, 1.0),
            lastUpdated: DateTime.now(),
          );
          break;
        case 'social_connection':
          newProgress = oldProgress.copyWith(
            socialConnection: value.clamp(0.0, 1.0),
            lastUpdated: DateTime.now(),
          );
          break;
        case 'mindfulness':
          newProgress = oldProgress.copyWith(
            mindfulness: value.clamp(0.0, 1.0),
            lastUpdated: DateTime.now(),
          );
          break;
        default:
          // Update detailed scores
          final detailedScores = Map<String, double>.from(oldProgress.detailedScores ?? {});
          detailedScores[progressType] = value.clamp(0.0, 1.0);
          
          newProgress = oldProgress.copyWith(
            detailedScores: detailedScores,
            lastUpdated: DateTime.now(),
          );
      }

      _currentUserProgress = newProgress;
      
      // Emit progress update
      _progressController.add(newProgress);
      
      // Save data
      await _saveUserData();
      
      debugPrint('Updated progress: $progressType = $value');
    } catch (e) {
      debugPrint('Error updating progress: $progressType: $e');
    }
  }

  // Get relevant memories for current context
  List<UserMemory> getRelevantMemories(String context, {int limit = 5}) {
    if (!_isInitialized) return [];

    // Filter memories by context and sort by relevance
    final relevantMemories = _userMemories
        .where((memory) => 
            memory.content['context'] == context || 
            memory.type == context)
        .toList();

    // Sort by memory strength and recency
    relevantMemories.sort((a, b) {
      final strengthComparison = b.memoryStrength.compareTo(a.memoryStrength);
      if (strengthComparison != 0) return strengthComparison;
      return b.timestamp.compareTo(a.timestamp);
    });

    return relevantMemories.take(limit).toList();
  }

  // Get emotional state history
  List<EmotionalState> getEmotionalStateHistory({int limit = 50}) {
    // This would typically come from persistent storage
    // For now, return current state if available
    if (_currentEmotionalState != null) {
      return [_currentEmotionalState!];
    }
    return [];
  }

  // Private methods
  double _calculateValenceFromContext(String? context) {
    if (context == null) return 0.0;
    
    // Context-based valence calculation
    switch (context.toLowerCase()) {
      case 'meditation':
      case 'breathing':
      case 'achievement':
        return 0.7;
      case 'quiz_completion':
      case 'story_completion':
        return 0.5;
      case 'stress':
      case 'anxiety':
        return -0.3;
      default:
        return 0.0;
    }
  }

  Future<void> _checkForInterventions(EmotionalState emotionalState) async {
    // High stress intervention
    if (emotionalState.stress > 0.7) {
      final intervention = AIIntervention(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'stress_relief',
        content: {
          'message_en': 'I notice you might be feeling stressed. Let\'s try a breathing exercise together.',
          'message_ja': 'ストレスを感じているようですね。一緒に呼吸法を試してみましょう。',
          'suggested_action': 'breathing_exercise',
          'priority': 0.9,
        },
        deliveryMethod: 'notification',
        timestamp: DateTime.now(),
        priority: 0.9,
        triggerReason: 'high_stress_detected',
      );
      
      _interventionController.add(intervention);
    }

    // Low mood intervention
    if (emotionalState.valence < -0.5) {
      final intervention = AIIntervention(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'mood_boost',
        content: {
          'message_en': 'Feeling down? Let me share a positive memory with you.',
          'message_ja': '気分が落ち込んでいますか？ポジティブな記憶を共有させてください。',
          'suggested_action': 'memory_recall',
          'priority': 0.8,
        },
        deliveryMethod: 'avatar',
        timestamp: DateTime.now(),
        priority: 0.8,
        triggerReason: 'low_mood_detected',
      );
      
      _interventionController.add(intervention);
    }

    // Low energy intervention
    if (emotionalState.arousal < 0.3) {
      final intervention = AIIntervention(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'energy_boost',
        content: {
          'message_en': 'Low energy detected. How about some energizing content?',
          'message_ja': 'エネルギーが低いようです。元気が出るコンテンツはいかがですか？',
          'suggested_action': 'energizing_content',
          'priority': 0.6,
        },
        deliveryMethod: 'suggestion',
        timestamp: DateTime.now(),
        priority: 0.6,
        triggerReason: 'low_energy_detected',
      );
      
      _interventionController.add(intervention);
    }
  }

  // Data persistence
  Future<void> _saveUserData() async {
    if (_prefs == null) return;

    try {
      // Save emotional state
      if (_currentEmotionalState != null) {
        await _prefs!.setString('emotional_state', jsonEncode(_currentEmotionalState!.toJson()));
      }

      // Save user progress
      if (_currentUserProgress != null) {
        await _prefs!.setString('user_progress', jsonEncode(_currentUserProgress!.toJson()));
      }

      // Save memories
      final memoriesJson = _userMemories.map((m) => m.toJson()).toList();
      await _prefs!.setString('user_memories', jsonEncode(memoriesJson));

      // Save biometric history
      final biometricJson = _biometricHistory.map((b) => b.toJson()).toList();
      await _prefs!.setString('biometric_history', jsonEncode(biometricJson));
    } catch (e) {
      debugPrint('Error saving user data: $e');
    }
  }

  Future<void> _loadUserData() async {
    if (_prefs == null) return;

    try {
      // Load emotional state
      final emotionalStateStr = _prefs!.getString('emotional_state');
      if (emotionalStateStr != null) {
        _currentEmotionalState = EmotionalState.fromJson(jsonDecode(emotionalStateStr));
      }

      // Load user progress
      final progressStr = _prefs!.getString('user_progress');
      if (progressStr != null) {
        _currentUserProgress = UserProgress.fromJson(jsonDecode(progressStr));
      }

      // Load memories
      final memoriesStr = _prefs!.getString('user_memories');
      if (memoriesStr != null) {
        final memoriesList = jsonDecode(memoriesStr) as List;
        _userMemories = memoriesList
            .map((m) => UserMemory.fromJson(m))
            .toList();
      }

      // Load biometric history
      final biometricStr = _prefs!.getString('biometric_history');
      if (biometricStr != null) {
        final biometricList = jsonDecode(biometricStr) as List;
        _biometricHistory = biometricList
            .map((b) => BiometricData.fromJson(b))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  // Cleanup
  void dispose() {
    _emotionalStateController.close();
    _interventionController.close();
    _progressController.close();
    _memoryController.close();
  }
}
