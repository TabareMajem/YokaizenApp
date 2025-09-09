import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'util/central_intelligence_integration.dart';
import 'util/central_intelligence_core.dart';
import 'util/colors.dart';
import 'util/text_styles.dart';

/// 🎯 YOKAIZEN CENTRAL INTELLIGENCE SYSTEM
/// 
/// This is the ULTIMATE inner strength booster that unifies everything into one 
/// proactive, emotionally-intelligent ecosystem:
/// 
/// 🧠 Central Intelligence Features:
/// 1. Real-Time Biometric Processing
///    * YōkaiZen Ring data → Emotional state detection
///    * ML models for mood recognition
///    * Stress/anxiety early warning system
/// 
/// 2. Adaptive Memory System
///    * Stores important user interactions
///    * Emotional weight and importance scoring
///    * Memory decay simulation (like human memory)
///    * Context-aware recall
/// 
/// 3. Proactive AI Interventions
///    * Triggers based on emotional patterns
///    * Personalized therapeutic content
///    * Real-time avatar responses
///    * Effectiveness tracking & learning
/// 
/// 4. Progress Tracking
///    * Resilience scoring
///    * Self-esteem index
///    * Emotional regulation improvement
///    * Social connection metrics
/// 
/// 🔄 Integration Points:
/// 1. Quiz System → Stores achievements & learning patterns
/// 2. Interactive Videos → Tracks choices & emotional impact
/// 3. YōkaiZen Ring → Real-time biometric feedback
/// 4. AI Avatar → Proactive companion responses
/// 5. User Progress → Therapeutic outcome measurement
/// 
/// 🚀 Key Innovations:
/// 1. Predictive Interventions: AI predicts when users need support BEFORE they ask
/// 2. Emotional Journey Mapping: Tracks long-term emotional growth patterns
/// 3. Personalized Therapeutic Content: Adapts based on user's Japanese cultural context
/// 4. Real-Time Avatar Responses: 3D Yokai characters react to biometric data
/// 5. Memory-Enhanced Relationships: AI remembers important user moments for deeper bonds
/// 
/// 📊 Data Flow:
/// YōkaiZen Ring → Central Intelligence → Real-time Analysis → Proactive Intervention → User Response → Learning & Adaptation
/// 
/// 🎭 Therapeutic Integration:
/// * Morita Therapy: "Acting with" anxiety rather than against it
/// * Naikan Therapy: Gratitude and relational reflection
/// * Amae Theory: Healthy interdependence support
/// 
/// This Central Intelligence makes YōkaiZen the most advanced emotional support platform ever created - 
/// combining cutting-edge AI, Japanese therapeutic wisdom, and real-time biometric feedback into one seamless, proactive experience!

/// Main Central Intelligence Controller
/// This class manages the entire central intelligence system and provides
/// a unified interface for all app components
class YokaizenCentralIntelligence {
  static final YokaizenCentralIntelligence _instance = YokaizenCentralIntelligence._internal();
  factory YokaizenCentralIntelligence() => _instance;
  YokaizenCentralIntelligence._internal();

  final CentralIntelligenceIntegration _integration = CentralIntelligenceIntegration();
  
  // Stream getters for easy access
  Stream<EmotionalState> get emotionalStateStream => _integration.emotionalStateStream;
  Stream<AIIntervention> get interventionStream => _integration.interventionStream;
  Stream<UserProgress> get progressStream => _integration.progressStream;
  Stream<UserMemory> get memoryStream => _integration.memoryStream;
  Stream<Map<String, dynamic>> get appEventStream => _integration.appEventStream;
  Stream<String> get notificationStream => _integration.notificationStream;
  
  // State getters
  EmotionalState? get currentEmotionalState => _integration.currentEmotionalState;
  UserProgress? get currentUserProgress => _integration.currentUserProgress;
  List<UserMemory> get userMemories => _integration.userMemories;
  bool get isInitialized => _integration.isInitialized;

  /// Initialize the central intelligence system
  Future<void> initialize(String userId) async {
    try {
      await _integration.initialize(userId);
      debugPrint('🎯 Yokaizen Central Intelligence initialized for user: $userId');
    } catch (e) {
      debugPrint('❌ Error initializing Yokaizen Central Intelligence: $e');
      rethrow;
    }
  }

  /// Process biometric data from YōkaiZen Ring
  Future<void> processRingData(Map<String, dynamic> ringData) async {
    await _integration.processRingData(ringData);
  }

  /// Handle quiz completion events
  Future<void> onQuizCompleted(String quizId, int score, List<String> answers, String quizType) async {
    await _integration.onQuizCompleted(quizId, score, answers, quizType);
  }

  /// Handle interactive video choice events
  Future<void> onVideoChoice(String videoId, String segmentId, String choiceId, int emotionalImpact) async {
    await _integration.onVideoChoice(videoId, segmentId, choiceId, emotionalImpact);
  }

  /// Handle achievement unlock events
  Future<void> onAchievementUnlocked(String achievementId, String achievementName) async {
    await _integration.onAchievementUnlocked(achievementId, achievementName);
  }

  /// Handle story/chapter completion events
  Future<void> onStoryCompleted(String storyId, String chapterId, int completionTime) async {
    await _integration.onStoryCompleted(storyId, chapterId, completionTime);
  }

  /// Handle breathing exercise completion
  Future<void> onBreathingExerciseCompleted(String exerciseType, int duration, bool withBiometricFeedback) async {
    await _integration.onBreathingExerciseCompleted(exerciseType, duration, withBiometricFeedback);
  }

  /// Handle mood tracking events
  Future<void> onMoodTracked(String moodType, int intensity, String? notes) async {
    await _integration.onMoodTracked(moodType, intensity, notes);
  }

  /// Get personalized content recommendations
  List<Map<String, dynamic>> getPersonalizedRecommendations() {
    return _integration.getPersonalizedRecommendations();
  }

  /// Get user insights and analytics
  Map<String, dynamic> getUserInsights() {
    return _integration.getUserInsights();
  }

  /// Get relevant memories for current context
  List<UserMemory> getRelevantMemories(String context, {int limit = 5}) {
    return _integration.getRelevantMemories(context, limit: limit);
  }

  /// Cleanup resources
  void dispose() {
    _integration.dispose();
  }
}

/// Central Intelligence Dashboard Widget
/// This widget provides a comprehensive view of the user's emotional state,
/// progress, and AI recommendations
class CentralIntelligenceDashboard extends StatefulWidget {
  const CentralIntelligenceDashboard({Key? key}) : super(key: key);

  @override
  State<CentralIntelligenceDashboard> createState() => _CentralIntelligenceDashboardState();
}

class _CentralIntelligenceDashboardState extends State<CentralIntelligenceDashboard> {
  final YokaizenCentralIntelligence _centralIntelligence = YokaizenCentralIntelligence();
  EmotionalState? _currentEmotionalState;
  UserProgress? _currentUserProgress;
  List<Map<String, dynamic>> _recommendations = [];
  Map<String, dynamic> _userInsights = {};

  @override
  void initState() {
    super.initState();
    _setupListeners();
    _loadData();
  }

  void _setupListeners() {
    _centralIntelligence.emotionalStateStream.listen((state) {
      setState(() {
        _currentEmotionalState = state;
      });
    });

    _centralIntelligence.progressStream.listen((progress) {
      setState(() {
        _currentUserProgress = progress;
      });
    });

    _centralIntelligence.appEventStream.listen((event) {
      debugPrint('App event: ${event['type']}');
      // Handle different event types
      switch (event['type']) {
        case 'quiz_completed':
          _showQuizCompletionNotification(event);
          break;
        case 'achievement_unlocked':
          _showAchievementNotification(event);
          break;
        case 'intervention_triggered':
          _showInterventionNotification(event);
          break;
      }
    });
  }

  void _loadData() {
    _recommendations = _centralIntelligence.getPersonalizedRecommendations();
    _userInsights = _centralIntelligence.getUserInsights();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          '🎯 Central Intelligence',
          style: AppTextStyle.normalBold20.copyWith(color: Colors.white),
        ),
        backgroundColor: coral500,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emotional State Card
            _buildEmotionalStateCard(),
            const SizedBox(height: 16),
            
            // Progress Overview Card
            _buildProgressOverviewCard(),
            const SizedBox(height: 16),
            
            // AI Recommendations Card
            _buildRecommendationsCard(),
            const SizedBox(height: 16),
            
            // User Insights Card
            _buildUserInsightsCard(),
            const SizedBox(height: 16),
            
            // Recent Activities Card
            _buildRecentActivitiesCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionalStateCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              coral500.withOpacity(0.1),
              indigo500.withOpacity(0.1),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: coral500, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Current Emotional State',
                  style: AppTextStyle.normalBold18.copyWith(color: coral500),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            if (_currentEmotionalState != null) ...[
              _buildEmotionalIndicator('Mood', _currentEmotionalState!.valence, Colors.blue),
              const SizedBox(height: 12),
              _buildEmotionalIndicator('Energy', _currentEmotionalState!.arousal, Colors.green),
              const SizedBox(height: 12),
              _buildEmotionalIndicator('Stress', _currentEmotionalState!.stress, Colors.red),
              const SizedBox(height: 12),
              _buildEmotionalIndicator('Confidence', _currentEmotionalState!.confidence, Colors.orange),
            ] else ...[
              const Center(
                child: Text(
                  'No emotional state data available',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressOverviewCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              indigo500.withOpacity(0.1),
              purple500.withOpacity(0.1),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: indigo500, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Growth Progress',
                  style: AppTextStyle.normalBold18.copyWith(color: indigo500),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            if (_currentUserProgress != null) ...[
              _buildProgressIndicator('Resilience', _currentUserProgress!.resilience),
              const SizedBox(height: 12),
              _buildProgressIndicator('Self-Esteem', _currentUserProgress!.selfEsteem),
              const SizedBox(height: 12),
              _buildProgressIndicator('Emotional Regulation', _currentUserProgress!.emotionalRegulation),
              const SizedBox(height: 12),
              _buildProgressIndicator('Social Connection', _currentUserProgress!.socialConnection),
              const SizedBox(height: 12),
              _buildProgressIndicator('Mindfulness', _currentUserProgress!.mindfulness),
              
              const SizedBox(height: 16),
              Divider(color: Colors.grey[300]),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Overall Score',
                    style: AppTextStyle.normalBold16.copyWith(color: indigo500),
                  ),
                  Text(
                    '${(_currentUserProgress!.overallScore * 100).round()}%',
                    style: AppTextStyle.normalBold20.copyWith(color: indigo500),
                  ),
                ],
              ),
            ] else ...[
              const Center(
                child: Text(
                  'No progress data available',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              green500.withOpacity(0.1),
              teal500.withOpacity(0.1),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: green500, size: 28),
                const SizedBox(width: 12),
                Text(
                  'AI Recommendations',
                  style: AppTextStyle.normalBold18.copyWith(color: green500),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            if (_recommendations.isNotEmpty) ...[
              ..._recommendations.take(3).map((recommendation) => 
                _buildRecommendationItem(recommendation)
              ),
            ] else ...[
              const Center(
                child: Text(
                  'No recommendations available',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserInsightsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              purple500.withOpacity(0.1),
              pink500.withOpacity(0.1),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: purple500, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Your Insights',
                  style: AppTextStyle.normalBold18.copyWith(color: purple500),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            if (_userInsights.isNotEmpty) ...[
              if (_userInsights['progress_summary'] != null) ...[
                _buildInsightItem(
                  'Overall Score',
                  '${_userInsights['progress_summary']['overall_score']}%',
                  Icons.score,
                ),
                const SizedBox(height: 12),
                _buildInsightItem(
                  'Strongest Area',
                  _userInsights['progress_summary']['strongest_area'] ?? 'N/A',
                  Icons.star,
                ),
                const SizedBox(height: 12),
                _buildInsightItem(
                  'Area for Improvement',
                  _userInsights['progress_summary']['area_for_improvement'] ?? 'N/A',
                  Icons.trending_up,
                ),
              ],
            ] else ...[
              const Center(
                child: Text(
                  'No insights available',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitiesCard() {
    final recentActivities = _userInsights['recent_activities'] as List? ?? [];
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              orange500.withOpacity(0.1),
              amber500.withOpacity(0.1),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: orange500, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Recent Activities',
                  style: AppTextStyle.normalBold18.copyWith(color: orange500),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            if (recentActivities.isNotEmpty) ...[
              ...recentActivities.take(5).map((activity) => 
                _buildActivityItem(activity)
              ),
            ] else ...[
              const Center(
                child: Text(
                  'No recent activities',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionalIndicator(String label, double value, Color color) {
    // Convert -1 to 1 range to 0 to 1 for progress bar
    final normalizedValue = (value + 1) / 2;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyle.normalRegular14),
            Text(
              '${(normalizedValue * 100).round()}%',
              style: AppTextStyle.normalBold14.copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: normalizedValue,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyle.normalRegular14),
            Text(
              '${(value * 100).round()}%',
              style: AppTextStyle.normalBold14.copyWith(color: indigo500),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value,
          backgroundColor: indigo500.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(indigo500),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildRecommendationItem(Map<String, dynamic> recommendation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: green500.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            recommendation['icon'] ?? '💡',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation['title_en'] ?? 'Recommendation',
                  style: AppTextStyle.normalBold14.copyWith(color: green500),
                ),
                const SizedBox(height: 4),
                Text(
                  recommendation['description_en'] ?? 'Try this activity',
                  style: AppTextStyle.normalRegular12.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: green500.withOpacity(0.6),
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: purple500, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyle.normalRegular14,
          ),
        ),
        Text(
          value,
          style: AppTextStyle.normalBold14.copyWith(color: purple500),
        ),
      ],
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _getActivityIcon(activity['type']),
            color: orange500,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['summary'] ?? 'Activity completed',
                  style: AppTextStyle.normalRegular14,
                ),
                Text(
                  _formatTimestamp(activity['timestamp']),
                  style: AppTextStyle.normalRegular12.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getEmotionalImpactColor(activity['emotional_impact']),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getEmotionalImpactText(activity['emotional_impact']),
              style: AppTextStyle.normalRegular10.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'quiz_completion':
        return Icons.quiz;
      case 'achievement_unlocked':
        return Icons.emoji_events;
      case 'story_completion':
        return Icons.book;
      case 'breathing_exercise':
        return Icons.air;
      case 'mood_tracking':
        return Icons.mood;
      default:
        return Icons.check_circle;
    }
  }

  Color _getEmotionalImpactColor(double impact) {
    if (impact > 0.5) return Colors.green;
    if (impact > 0) return Colors.blue;
    if (impact > -0.5) return Colors.orange;
    return Colors.red;
  }

  String _getEmotionalImpactText(double impact) {
    if (impact > 0.5) return 'Very +';
    if (impact > 0) return '+';
    if (impact > -0.5) return '-';
    return 'Very -';
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown time';
    }
  }

  void _showQuizCompletionNotification(Map<String, dynamic> event) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Quiz completed! Score: ${event['score']}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showAchievementNotification(Map<String, dynamic> event) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Achievement unlocked: ${event['achievement_name']}'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showInterventionNotification(Map<String, dynamic> event) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(event['message'] ?? 'AI intervention suggested'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // Navigate to intervention details
          },
        ),
      ),
    );
  }
}

/// Extension to provide easy access to central intelligence throughout the app
extension CentralIntelligenceExtension on BuildContext {
  YokaizenCentralIntelligence get centralIntelligence => YokaizenCentralIntelligence();
}

/// Global instance for easy access
final yokaizenCentralIntelligence = YokaizenCentralIntelligence();
