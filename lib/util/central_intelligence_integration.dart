import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'central_intelligence_core.dart';

/// Central Intelligence Integration Service
/// This service acts as a bridge between the app components and the central intelligence system
class CentralIntelligenceIntegration {
  static final CentralIntelligenceIntegration _instance = CentralIntelligenceIntegration._internal();
  factory CentralIntelligenceIntegration() => _instance;
  CentralIntelligenceIntegration._internal();

  final CentralIntelligenceCore _core = CentralIntelligenceCore();
  
  // Stream controllers for app-specific events
  final StreamController<Map<String, dynamic>> _appEventController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<String> _notificationController = StreamController<String>.broadcast();
  
  // Public streams
  Stream<Map<String, dynamic>> get appEventStream => _appEventController.stream;
  Stream<String> get notificationStream => _notificationController.stream;
  
  // Getters for core streams
  Stream<EmotionalState> get emotionalStateStream => _core.emotionalStateStream;
  Stream<AIIntervention> get interventionStream => _core.interventionStream;
  Stream<UserProgress> get progressStream => _core.progressStream;
  Stream<UserMemory> get memoryStream => _core.memoryStream;
  
  // Current state getters
  EmotionalState? get currentEmotionalState => _core.currentEmotionalState;
  UserProgress? get currentUserProgress => _core.currentUserProgress;
  List<UserMemory> get userMemories => _core.userMemories;
  bool get isInitialized => _core.isInitialized;

  /// Initialize the central intelligence system
  Future<void> initialize(String userId) async {
    try {
      await _core.initialize(userId);
      
      // Set up intervention listeners
      _setupInterventionListeners();
      
      // Set up progress listeners
      _setupProgressListeners();
      
      debugPrint('Central Intelligence Integration initialized for user: $userId');
    } catch (e) {
      debugPrint('Error initializing Central Intelligence Integration: $e');
      rethrow;
    }
  }

  /// Process biometric data from YōkaiZen Ring
  Future<void> processRingData(Map<String, dynamic> ringData) async {
    try {
      final biometricData = BiometricData(
        heartRate: ringData['heart_rate']?.toDouble() ?? 0.0,
        heartRateVariability: ringData['heart_rate_variability']?.toDouble() ?? 0.0,
        galvanicSkinResponse: ringData['galvanic_skin_response']?.toDouble() ?? 0.0,
        temperature: ringData['temperature']?.toDouble() ?? 0.0,
        movementIntensity: ringData['movement_intensity']?.toDouble() ?? 0.0,
        timestamp: DateTime.now(),
        context: ringData['context'] ?? 'ring_data',
      );

      await _core.processBiometricData(biometricData);
      
      // Emit app event
      _appEventController.add({
        'type': 'ring_data_processed',
        'data': biometricData.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error processing ring data: $e');
    }
  }

  /// Handle quiz completion events
  Future<void> onQuizCompleted(String quizId, int score, List<String> answers, String quizType) async {
    try {
      // Calculate emotional weight based on score
      double emotionalWeight = _calculateQuizEmotionalWeight(score);
      
      // Store memory of quiz completion
      await _core.storeMemory(
        'quiz_completion',
        {
          'quiz_id': quizId,
          'quiz_type': quizType,
          'score': score,
          'answers': answers,
          'completion_time': DateTime.now().toIso8601String(),
          'summary_ja': 'クイズを完了しました！スコア: $score',
          'summary_en': 'Completed quiz! Score: $score',
          'context': 'quiz_completion',
        },
        emotionalWeight: emotionalWeight,
        importance: 0.7,
      );

      // Update progress based on quiz performance
      await _updateProgressFromQuiz(quizType, score);
      
      // Emit app event
      _appEventController.add({
        'type': 'quiz_completed',
        'quiz_id': quizId,
        'score': score,
        'emotional_weight': emotionalWeight,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      debugPrint('Quiz completed: $quizType with score: $score');
    } catch (e) {
      debugPrint('Error handling quiz completion: $e');
    }
  }

  /// Handle interactive video choice events
  Future<void> onVideoChoice(String videoId, String segmentId, String choiceId, int emotionalImpact) async {
    try {
      // Convert emotional impact (-3 to +3) to weight (-1 to +1)
      double emotionalWeight = (emotionalImpact / 3.0).clamp(-1.0, 1.0);
      
      // Store memory of choice
      await _core.storeMemory(
        'video_choice',
        {
          'video_id': videoId,
          'segment_id': segmentId,
          'choice_id': choiceId,
          'emotional_impact': emotionalImpact,
          'timestamp': DateTime.now().toIso8601String(),
          'summary_ja': '重要な選択をしました',
          'summary_en': 'Made an important choice',
          'context': 'video_interaction',
        },
        emotionalWeight: emotionalWeight,
        importance: 0.8,
      );

      // Update progress based on choice
      await _updateProgressFromVideoChoice(choiceId, emotionalImpact);
      
      // Emit app event
      _appEventController.add({
        'type': 'video_choice_made',
        'video_id': videoId,
        'choice_id': choiceId,
        'emotional_impact': emotionalImpact,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      debugPrint('Video choice made: $choiceId with impact: $emotionalImpact');
    } catch (e) {
      debugPrint('Error handling video choice: $e');
    }
  }

  /// Handle achievement unlock events
  Future<void> onAchievementUnlocked(String achievementId, String achievementName) async {
    try {
      // Store memory of achievement
      await _core.storeMemory(
        'achievement_unlocked',
        {
          'achievement_id': achievementId,
          'achievement_name': achievementName,
          'unlock_time': DateTime.now().toIso8601String(),
          'summary_ja': '新しい達成を解除しました: $achievementName',
          'summary_en': 'Unlocked new achievement: $achievementName',
          'context': 'achievement',
        },
        emotionalWeight: 0.8, // Achievements are always positive
        importance: 0.9,
      );

      // Update progress
      await _core.updateProgress('achievements', 1.0, context: 'achievement_unlock');
      
      // Emit app event
      _appEventController.add({
        'type': 'achievement_unlocked',
        'achievement_id': achievementId,
        'achievement_name': achievementName,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      debugPrint('Achievement unlocked: $achievementName');
    } catch (e) {
      debugPrint('Error handling achievement unlock: $e');
    }
  }

  /// Handle story/chapter completion events
  Future<void> onStoryCompleted(String storyId, String chapterId, int completionTime) async {
    try {
      // Calculate emotional weight based on completion time and story type
      double emotionalWeight = _calculateStoryEmotionalWeight(completionTime);
      
      // Store memory of story completion
      await _core.storeMemory(
        'story_completion',
        {
          'story_id': storyId,
          'chapter_id': chapterId,
          'completion_time': completionTime,
          'timestamp': DateTime.now().toIso8601String(),
          'summary_ja': 'ストーリーを完了しました',
          'summary_en': 'Completed story chapter',
          'context': 'story_completion',
        },
        emotionalWeight: emotionalWeight,
        importance: 0.6,
      );

      // Update progress
      await _core.updateProgress('story_completion', 1.0, context: 'story_completed');
      
      // Emit app event
      _appEventController.add({
        'type': 'story_completed',
        'story_id': storyId,
        'chapter_id': chapterId,
        'completion_time': completionTime,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      debugPrint('Story completed: $storyId chapter $chapterId');
    } catch (e) {
      debugPrint('Error handling story completion: $e');
    }
  }

  /// Handle breathing exercise completion
  Future<void> onBreathingExerciseCompleted(String exerciseType, int duration, bool withBiometricFeedback) async {
    try {
      // Calculate emotional weight based on exercise type and duration
      double emotionalWeight = _calculateBreathingEmotionalWeight(exerciseType, duration);
      
      // Store memory of exercise
      await _core.storeMemory(
        'breathing_exercise',
        {
          'exercise_type': exerciseType,
          'duration': duration,
          'biometric_feedback': withBiometricFeedback,
          'timestamp': DateTime.now().toIso8601String(),
          'summary_ja': '呼吸法を完了しました',
          'summary_en': 'Completed breathing exercise',
          'context': 'breathing_exercise',
        },
        emotionalWeight: emotionalWeight,
        importance: 0.7,
      );

      // Update mindfulness progress
      await _core.updateProgress('mindfulness', 0.1, context: 'breathing_exercise');
      
      // Emit app event
      _appEventController.add({
        'type': 'breathing_exercise_completed',
        'exercise_type': exerciseType,
        'duration': duration,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      debugPrint('Breathing exercise completed: $exerciseType for $duration seconds');
    } catch (e) {
      debugPrint('Error handling breathing exercise completion: $e');
    }
  }

  /// Handle mood tracking events
  Future<void> onMoodTracked(String moodType, int intensity, String? notes) async {
    try {
      // Convert mood type and intensity to emotional weight
      double emotionalWeight = _calculateMoodEmotionalWeight(moodType, intensity);
      
      // Store memory of mood
      await _core.storeMemory(
        'mood_tracking',
        {
          'mood_type': moodType,
          'intensity': intensity,
          'notes': notes,
          'timestamp': DateTime.now().toIso8601String(),
          'summary_ja': '気分を記録しました: $moodType',
          'summary_en': 'Tracked mood: $moodType',
          'context': 'mood_tracking',
        },
        emotionalWeight: emotionalWeight,
        importance: 0.5,
      );

      // Update emotional regulation progress
      await _core.updateProgress('emotional_regulation', 0.05, context: 'mood_tracking');
      
      // Emit app event
      _appEventController.add({
        'type': 'mood_tracked',
        'mood_type': moodType,
        'intensity': intensity,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      debugPrint('Mood tracked: $moodType with intensity: $intensity');
    } catch (e) {
      debugPrint('Error handling mood tracking: $e');
    }
  }

  /// Get personalized content recommendations
  List<Map<String, dynamic>> getPersonalizedRecommendations() {
    if (!isInitialized) return [];

    final recommendations = <Map<String, dynamic>>[];
    final currentState = currentEmotionalState;
    final currentProgress = currentUserProgress;

    if (currentState != null) {
      // High stress recommendation
      if (currentState.stress > 0.7) {
        recommendations.add({
          'type': 'breathing_exercise',
          'title_en': 'Stress Relief Breathing',
          'title_ja': 'ストレス解消呼吸法',
          'description_en': 'Try this 4-7-8 breathing technique to reduce stress',
          'description_ja': 'ストレスを軽減する4-7-8呼吸法を試してみてください',
          'priority': 0.9,
          'icon': '🧘',
        });
      }

      // Low mood recommendation
      if (currentState.valence < -0.5) {
        recommendations.add({
          'type': 'positive_content',
          'title_en': 'Mood Boosting Story',
          'title_ja': '気分向上ストーリー',
          'description_en': 'Read an uplifting story to improve your mood',
          'description_ja': '気分を向上させる心温まるストーリーを読んでみてください',
          'priority': 0.8,
          'icon': '📖',
        });
      }

      // Low energy recommendation
      if (currentState.arousal < 0.3) {
        recommendations.add({
          'type': 'energizing_quiz',
          'title_en': 'Energy Boost Quiz',
          'title_ja': 'エネルギー向上クイズ',
          'description_en': 'Take a quick quiz to boost your energy',
          'description_ja': 'エネルギーを向上させるクイズに挑戦してみてください',
          'priority': 0.7,
          'icon': '⚡',
        });
      }
    }

    if (currentProgress != null) {
      // Progress-based recommendations
      if (currentProgress.resilience < 0.6) {
        recommendations.add({
          'type': 'resilience_building',
          'title_en': 'Build Resilience',
          'title_ja': 'レジリエンスを構築',
          'description_en': 'Complete challenges to build your resilience',
          'description_ja': 'チャレンジを完了してレジリエンスを構築しましょう',
          'priority': 0.8,
          'icon': '💪',
        });
      }

      if (currentProgress.mindfulness < 0.6) {
        recommendations.add({
          'type': 'mindfulness_practice',
          'title_en': 'Mindfulness Practice',
          'title_ja': 'マインドフルネス練習',
          'description_en': 'Practice mindfulness with guided exercises',
          'description_ja': 'ガイド付きエクササイズでマインドフルネスを練習しましょう',
          'priority': 0.7,
          'icon': '🧘',
        });
      }
    }

    // Sort by priority
    recommendations.sort((a, b) => (b['priority'] as double).compareTo(a['priority'] as double));
    
    return recommendations;
  }

  /// Get user insights and analytics
  Map<String, dynamic> getUserInsights() {
    if (!isInitialized) return {};

    final insights = <String, dynamic>{};
    final currentState = currentEmotionalState;
    final currentProgress = currentUserProgress;
    final memories = userMemories;

    if (currentState != null) {
      insights['current_emotional_state'] = {
        'mood': _getMoodDescription(currentState.valence),
        'energy': _getEnergyDescription(currentState.arousal),
        'stress_level': _getStressDescription(currentState.stress),
        'confidence': _getConfidenceDescription(currentState.confidence),
      };
    }

    if (currentProgress != null) {
      insights['progress_summary'] = {
        'overall_score': (currentProgress.overallScore * 100).round(),
        'strongest_area': _getStrongestArea(currentProgress),
        'area_for_improvement': _getWeakestArea(currentProgress),
        'growth_rate': _calculateGrowthRate(currentProgress),
      };
    }

    if (memories.isNotEmpty) {
      insights['recent_activities'] = memories
          .take(5)
          .map((memory) => {
                'type': memory.type,
                'summary': memory.content['summary_en'] ?? 'Activity completed',
                'emotional_impact': memory.emotionalWeight,
                'timestamp': memory.timestamp.toIso8601String(),
              })
          .toList();
    }

    return insights;
  }

  // Private helper methods
  void _setupInterventionListeners() {
    _core.interventionStream.listen((intervention) {
      debugPrint('AI Intervention triggered: ${intervention.type}');
      
      // Handle different intervention types
      switch (intervention.type) {
        case 'stress_relief':
          _handleStressReliefIntervention(intervention);
          break;
        case 'mood_boost':
          _handleMoodBoostIntervention(intervention);
          break;
        case 'energy_boost':
          _handleEnergyBoostIntervention(intervention);
          break;
        default:
          debugPrint('Unknown intervention type: ${intervention.type}');
      }
    });
  }

  void _setupProgressListeners() {
    _core.progressStream.listen((progress) {
      debugPrint('Progress updated: Overall score: ${(progress.overallScore * 100).round()}%');
      
      // Emit progress update event
      _appEventController.add({
        'type': 'progress_updated',
        'overall_score': progress.overallScore,
        'timestamp': DateTime.now().toIso8601String(),
      });
    });
  }

  void _handleStressReliefIntervention(AIIntervention intervention) {
    // Send notification for stress relief
    _notificationController.add(intervention.content['message_en'] ?? 'Stress relief suggested');
    
    // Emit intervention event
    _appEventController.add({
      'type': 'intervention_triggered',
      'intervention_type': 'stress_relief',
      'message': intervention.content['message_en'],
      'suggested_action': intervention.content['suggested_action'],
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void _handleMoodBoostIntervention(AIIntervention intervention) {
    // Send notification for mood boost
    _notificationController.add(intervention.content['message_en'] ?? 'Mood boost suggested');
    
    // Emit intervention event
    _appEventController.add({
      'type': 'intervention_triggered',
      'intervention_type': 'mood_boost',
      'message': intervention.content['message_en'],
      'suggested_action': intervention.content['suggested_action'],
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void _handleEnergyBoostIntervention(AIIntervention intervention) {
    // Send notification for energy boost
    _notificationController.add(intervention.content['message_en'] ?? 'Energy boost suggested');
    
    // Emit intervention event
    _appEventController.add({
      'type': 'intervention_triggered',
      'intervention_type': 'energy_boost',
      'message': intervention.content['message_en'],
      'suggested_action': intervention.content['suggested_action'],
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  double _calculateQuizEmotionalWeight(int score) {
    if (score >= 90) return 0.8;
    if (score >= 80) return 0.6;
    if (score >= 70) return 0.4;
    if (score >= 60) return 0.2;
    if (score >= 50) return 0.0;
    if (score >= 40) return -0.2;
    if (score >= 30) return -0.4;
    return -0.6;
  }

  double _calculateStoryEmotionalWeight(int completionTime) {
    // Shorter completion time might indicate higher engagement
    if (completionTime < 300) return 0.6; // Less than 5 minutes
    if (completionTime < 600) return 0.4; // Less than 10 minutes
    if (completionTime < 900) return 0.2; // Less than 15 minutes
    return 0.0;
  }

  double _calculateBreathingEmotionalWeight(String exerciseType, int duration) {
    // Longer exercises and specific types get higher emotional weight
    double durationWeight = (duration / 300.0).clamp(0.0, 1.0); // Max 5 minutes
    double typeWeight = exerciseType.contains('stress') ? 0.8 : 0.5;
    return (durationWeight + typeWeight) / 2.0;
  }

  double _calculateMoodEmotionalWeight(String moodType, int intensity) {
    // Convert mood type and intensity to emotional weight
    double baseWeight = 0.0;
    switch (moodType.toLowerCase()) {
      case 'happy':
      case 'excited':
      case 'joyful':
        baseWeight = 0.8;
        break;
      case 'calm':
      case 'peaceful':
      case 'content':
        baseWeight = 0.6;
        break;
      case 'neutral':
        baseWeight = 0.0;
        break;
      case 'sad':
      case 'anxious':
      case 'angry':
        baseWeight = -0.6;
        break;
      default:
        baseWeight = 0.0;
    }
    
    // Adjust by intensity (1-10 scale)
    double intensityFactor = (intensity / 10.0).clamp(0.0, 1.0);
    return baseWeight * intensityFactor;
  }

  Future<void> _updateProgressFromQuiz(String quizType, int score) async {
    // Update different progress areas based on quiz type and performance
    switch (quizType.toLowerCase()) {
      case 'mindfulness':
      case 'meditation':
        await _core.updateProgress('mindfulness', score / 100.0, context: 'quiz_completion');
        break;
      case 'emotional_regulation':
      case 'stress_management':
        await _core.updateProgress('emotional_regulation', score / 100.0, context: 'quiz_completion');
        break;
      case 'social_skills':
      case 'communication':
        await _core.updateProgress('social_connection', score / 100.0, context: 'quiz_completion');
        break;
      case 'resilience':
      case 'coping':
        await _core.updateProgress('resilience', score / 100.0, context: 'quiz_completion');
        break;
      default:
        // General knowledge quiz
        await _core.updateProgress('mindfulness', score / 100.0, context: 'quiz_completion');
    }
  }

  Future<void> _updateProgressFromVideoChoice(String choiceId, int emotionalImpact) async {
    // Update progress based on the type of choice made
    if (choiceId.contains('empathy') || choiceId.contains('compassion')) {
      await _core.updateProgress('social_connection', 0.1, context: 'video_choice');
    } else if (choiceId.contains('courage') || choiceId.contains('perseverance')) {
      await _core.updateProgress('resilience', 0.1, context: 'video_choice');
    } else if (choiceId.contains('mindfulness') || choiceId.contains('awareness')) {
      await _core.updateProgress('mindfulness', 0.1, context: 'video_choice');
    }
  }

  String _getMoodDescription(double valence) {
    if (valence >= 0.7) return 'Very Positive';
    if (valence >= 0.3) return 'Positive';
    if (valence >= -0.3) return 'Neutral';
    if (valence >= -0.7) return 'Negative';
    return 'Very Negative';
  }

  String _getEnergyDescription(double arousal) {
    if (arousal >= 0.7) return 'Very High';
    if (arousal >= 0.3) return 'High';
    if (arousal >= -0.3) return 'Moderate';
    if (arousal >= -0.7) return 'Low';
    return 'Very Low';
  }

  String _getStressDescription(double stress) {
    if (stress >= 0.8) return 'Very High';
    if (stress >= 0.6) return 'High';
    if (stress >= 0.4) return 'Moderate';
    if (stress >= 0.2) return 'Low';
    return 'Very Low';
  }

  String _getConfidenceDescription(double confidence) {
    if (confidence >= 0.8) return 'Very High';
    if (confidence >= 0.6) return 'High';
    if (confidence >= 0.4) return 'Moderate';
    if (confidence >= 0.2) return 'Low';
    return 'Very Low';
  }

  String _getStrongestArea(UserProgress progress) {
    final areas = {
      'Resilience': progress.resilience,
      'Self-Esteem': progress.selfEsteem,
      'Emotional Regulation': progress.emotionalRegulation,
      'Social Connection': progress.socialConnection,
      'Mindfulness': progress.mindfulness,
    };
    
    final strongest = areas.entries.reduce((a, b) => a.value > b.value ? a : b);
    return strongest.key;
  }

  String _getWeakestArea(UserProgress progress) {
    final areas = {
      'Resilience': progress.resilience,
      'Self-Esteem': progress.selfEsteem,
      'Emotional Regulation': progress.emotionalRegulation,
      'Social Connection': progress.socialConnection,
      'Mindfulness': progress.mindfulness,
    };
    
    final weakest = areas.entries.reduce((a, b) => a.value < b.value ? a : b);
    return weakest.key;
  }

  double _calculateGrowthRate(UserProgress progress) {
    // This would typically compare current progress with historical data
    // For now, return a placeholder value
    return 0.15; // 15% growth rate
  }

  /// Get relevant memories for current context
  List<UserMemory> getRelevantMemories(String context, {int limit = 5}) {
    return _core.getRelevantMemories(context, limit: limit);
  }

  /// Cleanup resources
  void dispose() {
    _appEventController.close();
    _notificationController.close();
    _core.dispose();
  }
}
