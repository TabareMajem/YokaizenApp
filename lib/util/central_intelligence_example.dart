import 'package:flutter/material.dart';
import '../central_intelligence.dart';
import 'central_intelligence_core.dart';

/// Example integration of Central Intelligence with existing app components
/// This file demonstrates how to connect the central intelligence system
/// with your existing quiz, story, and mood tracking features

class CentralIntelligenceExample {
  
  /// Example: Integrate with Quiz System
  /// Call this when a quiz is completed
  static Future<void> integrateQuizCompletion({
    required String quizId,
    required int score,
    required List<String> answers,
    required String quizType,
  }) async {
    try {
      // Initialize central intelligence if not already done
      if (!yokaizenCentralIntelligence.isInitialized) {
        await yokaizenCentralIntelligence.initialize('user_123');
      }
      
      // Report quiz completion to central intelligence
      await yokaizenCentralIntelligence.onQuizCompleted(
        quizId,
        score,
        answers,
        quizType,
      );
      
      debugPrint('✅ Quiz completion integrated with Central Intelligence');
    } catch (e) {
      debugPrint('❌ Error integrating quiz completion: $e');
    }
  }

  /// Example: Integrate with Story/Video System
  /// Call this when user makes a choice in interactive content
  static Future<void> integrateVideoChoice({
    required String videoId,
    required String segmentId,
    required String choiceId,
    required int emotionalImpact, // -3 to +3 scale
  }) async {
    try {
      if (!yokaizenCentralIntelligence.isInitialized) {
        await yokaizenCentralIntelligence.initialize('user_123');
      }
      
      await yokaizenCentralIntelligence.onVideoChoice(
        videoId,
        segmentId,
        choiceId,
        emotionalImpact,
      );
      
      debugPrint('✅ Video choice integrated with Central Intelligence');
    } catch (e) {
      debugPrint('❌ Error integrating video choice: $e');
    }
  }

  /// Example: Integrate with Achievement System
  /// Call this when user unlocks an achievement
  static Future<void> integrateAchievementUnlock({
    required String achievementId,
    required String achievementName,
  }) async {
    try {
      if (!yokaizenCentralIntelligence.isInitialized) {
        await yokaizenCentralIntelligence.initialize('user_123');
      }
      
      await yokaizenCentralIntelligence.onAchievementUnlocked(
        achievementId,
        achievementName,
      );
      
      debugPrint('✅ Achievement unlock integrated with Central Intelligence');
    } catch (e) {
      debugPrint('❌ Error integrating achievement unlock: $e');
    }
  }

  /// Example: Integrate with Story Completion
  /// Call this when user completes a story chapter
  static Future<void> integrateStoryCompletion({
    required String storyId,
    required String chapterId,
    required int completionTimeInSeconds,
  }) async {
    try {
      if (!yokaizenCentralIntelligence.isInitialized) {
        await yokaizenCentralIntelligence.initialize('user_123');
      }
      
      await yokaizenCentralIntelligence.onStoryCompleted(
        storyId,
        chapterId,
        completionTimeInSeconds,
      );
      
      debugPrint('✅ Story completion integrated with Central Intelligence');
    } catch (e) {
      debugPrint('❌ Error integrating story completion: $e');
    }
  }

  /// Example: Integrate with Breathing Exercise
  /// Call this when user completes a breathing exercise
  static Future<void> integrateBreathingExercise({
    required String exerciseType,
    required int durationInSeconds,
    bool withBiometricFeedback = false,
  }) async {
    try {
      if (!yokaizenCentralIntelligence.isInitialized) {
        await yokaizenCentralIntelligence.initialize('user_123');
      }
      
      await yokaizenCentralIntelligence.onBreathingExerciseCompleted(
        exerciseType,
        durationInSeconds,
        withBiometricFeedback,
      );
      
      debugPrint('✅ Breathing exercise integrated with Central Intelligence');
    } catch (e) {
      debugPrint('❌ Error integrating breathing exercise: $e');
    }
  }

  /// Example: Integrate with Mood Tracking
  /// Call this when user tracks their mood
  static Future<void> integrateMoodTracking({
    required String moodType, // 'happy', 'sad', 'anxious', 'calm', etc.
    required int intensity, // 1-10 scale
    String? notes,
  }) async {
    try {
      if (!yokaizenCentralIntelligence.isInitialized) {
        await yokaizenCentralIntelligence.initialize('user_123');
      }
      
      await yokaizenCentralIntelligence.onMoodTracked(
        moodType,
        intensity,
        notes,
      );
      
      debugPrint('✅ Mood tracking integrated with Central Intelligence');
    } catch (e) {
      debugPrint('❌ Error integrating mood tracking: $e');
    }
  }

  /// Example: Get Personalized Recommendations
  /// Call this to get AI-suggested content for the user
  static List<Map<String, dynamic>> getRecommendations() {
    try {
      if (!yokaizenCentralIntelligence.isInitialized) {
        return [];
      }
      
      final recommendations = yokaizenCentralIntelligence.getPersonalizedRecommendations();
      debugPrint('✅ Retrieved ${recommendations.length} personalized recommendations');
      return recommendations;
    } catch (e) {
      debugPrint('❌ Error getting recommendations: $e');
      return [];
    }
  }

  /// Example: Get User Insights
  /// Call this to get analytics and insights about the user
  static Map<String, dynamic> getUserInsights() {
    try {
      if (!yokaizenCentralIntelligence.isInitialized) {
        return {};
      }
      
      final insights = yokaizenCentralIntelligence.getUserInsights();
      debugPrint('✅ Retrieved user insights');
      return insights;
    } catch (e) {
      debugPrint('❌ Error getting user insights: $e');
      return {};
    }
  }

  /// Example: Process Ring Data
  /// Call this when receiving data from YōkaiZen Ring
  static Future<void> processRingData(Map<String, dynamic> ringData) async {
    try {
      if (!yokaizenCentralIntelligence.isInitialized) {
        await yokaizenCentralIntelligence.initialize('user_123');
      }
      
      await yokaizenCentralIntelligence.processRingData(ringData);
      debugPrint('✅ Ring data processed by Central Intelligence');
    } catch (e) {
      debugPrint('❌ Error processing ring data: $e');
    }
  }
}

/// Example Widget: Central Intelligence Status
/// This widget shows the current status of the central intelligence system
class CentralIntelligenceStatusWidget extends StatefulWidget {
  const CentralIntelligenceStatusWidget({Key? key}) : super(key: key);

  @override
  State<CentralIntelligenceStatusWidget> createState() => _CentralIntelligenceStatusWidgetState();
}

class _CentralIntelligenceStatusWidgetState extends State<CentralIntelligenceStatusWidget> {
  bool _isInitialized = false;
  EmotionalState? _currentEmotionalState;
  UserProgress? _currentUserProgress;

  @override
  void initState() {
    super.initState();
    _setupListeners();
    _checkInitialization();
  }

  void _setupListeners() {
    yokaizenCentralIntelligence.emotionalStateStream.listen((state) {
      setState(() {
        _currentEmotionalState = state;
      });
    });

    yokaizenCentralIntelligence.progressStream.listen((progress) {
      setState(() {
        _currentUserProgress = progress;
      });
    });
  }

  void _checkInitialization() {
    setState(() {
      _isInitialized = yokaizenCentralIntelligence.isInitialized;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isInitialized ? Icons.check_circle : Icons.error,
                  color: _isInitialized ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  'Central Intelligence Status',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Text(
              'Status: ${_isInitialized ? "Active" : "Inactive"}',
              style: TextStyle(
                color: _isInitialized ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            if (_isInitialized) ...[
              const SizedBox(height: 8),
              if (_currentEmotionalState != null) ...[
                Text('Mood: ${_getMoodText(_currentEmotionalState!.valence)}'),
                Text('Energy: ${_getEnergyText(_currentEmotionalState!.arousal)}'),
                Text('Stress: ${_getStressText(_currentEmotionalState!.stress)}'),
              ],
              if (_currentUserProgress != null) ...[
                const SizedBox(height: 8),
                Text('Overall Progress: ${(_currentUserProgress!.overallScore * 100).round()}%'),
              ],
            ],
            
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: _isInitialized ? null : () async {
                await yokaizenCentralIntelligence.initialize('user_123');
                _checkInitialization();
              },
              child: Text(_isInitialized ? 'System Active' : 'Initialize System'),
            ),
          ],
        ),
      ),
    );
  }

  String _getMoodText(double valence) {
    if (valence >= 0.7) return '😊 Very Positive';
    if (valence >= 0.3) return '🙂 Positive';
    if (valence >= -0.3) return '😐 Neutral';
    if (valence >= -0.7) return '😔 Negative';
    return '😢 Very Negative';
  }

  String _getEnergyText(double arousal) {
    if (arousal >= 0.7) return '⚡ Very High';
    if (arousal >= 0.3) return '🔥 High';
    if (arousal >= -0.3) return '🔄 Moderate';
    if (arousal >= -0.7) return '🐌 Low';
    return '😴 Very Low';
  }

  String _getStressText(double stress) {
    if (stress >= 0.8) return '😰 Very High';
    if (stress >= 0.6) return '😟 High';
    if (stress >= 0.4) return '😐 Moderate';
    if (stress >= 0.2) return '😌 Low';
    return '😊 Very Low';
  }
}

/// Example: How to integrate with existing Assessment Screen
/// 
/// In your assessments_screen.dart, add this to the submitAssessment method:
/// 
/// ```dart
/// Future<void> submitAssessment() async {
///   // ... existing code ...
///   
///   if (result) {
///     // Integrate with Central Intelligence
///     await CentralIntelligenceExample.integrateQuizCompletion(
///       quizId: widget.quizType,
///       score: calculateScore(), // Your score calculation method
///       answers: userAnswersForSubmission,
///       quizType: widget.quizType,
///     );
///     
///     showCompletionDialog();
///   }
/// }
/// ```
/// 
/// Example: How to integrate with existing Story/Video content:
/// 
/// ```dart
/// void onChoiceMade(String choiceId, int emotionalImpact) {
///   // ... existing code ...
///   
///   // Integrate with Central Intelligence
///   CentralIntelligenceExample.integrateVideoChoice(
///     videoId: currentVideoId,
///     segmentId: currentSegmentId,
///     choiceId: choiceId,
///     emotionalImpact: emotionalImpact,
///   );
/// }
/// ```
/// 
/// Example: How to integrate with Ring data:
/// 
/// ```dart
/// void onRingDataReceived(Map<String, dynamic> ringData) {
///   // ... existing code ...
///   
///   // Process with Central Intelligence
///   CentralIntelligenceExample.processRingData(ringData);
/// }
/// ```
