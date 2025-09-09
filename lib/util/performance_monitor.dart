import 'dart:async';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/services/app_state_manager.dart';
import 'package:yokai_quiz_app/api/cache_service.dart';

/// Performance monitoring utility for tracking app performance metrics
/// Helps optimize user experience and identify bottlenecks
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  // Timing data
  final Map<String, DateTime> _startTimes = {};
  final Map<String, List<int>> _durations = {};
  final Map<String, int> _counters = {};
  
  // Performance thresholds (in milliseconds)
  static const int _slowApiThreshold = 3000;
  static const int _slowRenderThreshold = 100;
  static const int _slowCacheThreshold = 50;
  
  // Performance metrics
  final Map<String, PerformanceMetric> _metrics = {};

  /// Start timing an operation
  void startTiming(String operation) {
    _startTimes[operation] = DateTime.now();
    customPrint('⏱️ Started timing: $operation');
  }

  /// End timing an operation and record duration
  int endTiming(String operation) {
    final startTime = _startTimes[operation];
    if (startTime == null) {
      customPrint('⚠️ No start time found for operation: $operation');
      return 0;
    }

    final duration = DateTime.now().difference(startTime).inMilliseconds;
    _recordDuration(operation, duration);
    _startTimes.remove(operation);

    // Log slow operations
    _checkForSlowOperation(operation, duration);

    customPrint('✅ Finished timing: $operation (${duration}ms)');
    return duration;
  }

  /// Record a duration for an operation
  void _recordDuration(String operation, int duration) {
    if (!_durations.containsKey(operation)) {
      _durations[operation] = [];
    }
    _durations[operation]!.add(duration);

    // Update performance metric
    _updateMetric(operation, duration);
  }

  /// Update performance metric
  void _updateMetric(String operation, int duration) {
    if (!_metrics.containsKey(operation)) {
      _metrics[operation] = PerformanceMetric(operation);
    }
    _metrics[operation]!.addDuration(duration);
  }

  /// Check if operation is slow and log warning
  void _checkForSlowOperation(String operation, int duration) {
    int threshold = _slowApiThreshold;
    
    if (operation.contains('render') || operation.contains('build')) {
      threshold = _slowRenderThreshold;
    } else if (operation.contains('cache')) {
      threshold = _slowCacheThreshold;
    }

    if (duration > threshold) {
      customPrint('🐌 SLOW OPERATION: $operation took ${duration}ms (threshold: ${threshold}ms)');
    }
  }

  /// Increment a counter
  void incrementCounter(String counterName) {
    _counters[counterName] = (_counters[counterName] ?? 0) + 1;
  }

  /// Get counter value
  int getCounter(String counterName) {
    return _counters[counterName] ?? 0;
  }

  /// Get average duration for an operation
  double getAverageDuration(String operation) {
    final durations = _durations[operation];
    if (durations == null || durations.isEmpty) return 0.0;
    
    final sum = durations.reduce((a, b) => a + b);
    return sum / durations.length;
  }

  /// Get performance summary
  Map<String, dynamic> getPerformanceSummary() {
    final summary = <String, dynamic>{};
    
    // App state metrics
    if (AppStateManager.instance != null) {
      final appStatus = AppStateManager.instance.getAppStatus();
      summary['app_state'] = appStatus;
    }

    // Cache metrics
    final cacheStats = CacheService().getStats();
    summary['cache'] = cacheStats;

    // Operation metrics
    final operationMetrics = <String, dynamic>{};
    for (final entry in _metrics.entries) {
      operationMetrics[entry.key] = entry.value.toMap();
    }
    summary['operations'] = operationMetrics;

    // Counters
    summary['counters'] = Map.from(_counters);

    // Performance indicators
    summary['performance_indicators'] = _getPerformanceIndicators();

    return summary;
  }

  /// Get performance indicators
  Map<String, dynamic> _getPerformanceIndicators() {
    return {
      'startup_performance': _getStartupPerformance(),
      'api_performance': _getApiPerformance(),
      'ui_performance': _getUiPerformance(),
      'cache_performance': _getCachePerformance(),
    };
  }

  /// Get startup performance rating
  String _getStartupPerformance() {
    final totalStartup = getAverageDuration('total_startup_duration');
    if (totalStartup == 0) return 'unknown';
    
    if (totalStartup < 3000) return 'excellent';
    if (totalStartup < 5000) return 'good';
    if (totalStartup < 8000) return 'fair';
    return 'poor';
  }

  /// Get API performance rating
  String _getApiPerformance() {
    final apiOperations = _metrics.keys.where((k) => k.contains('api')).toList();
    if (apiOperations.isEmpty) return 'unknown';
    
    final avgApiTime = apiOperations
        .map((op) => _metrics[op]!.averageDuration)
        .reduce((a, b) => a + b) / apiOperations.length;
    
    if (avgApiTime < 1000) return 'excellent';
    if (avgApiTime < 2000) return 'good';
    if (avgApiTime < 3000) return 'fair';
    return 'poor';
  }

  /// Get UI performance rating
  String _getUiPerformance() {
    final renderOperations = _metrics.keys.where((k) => 
        k.contains('render') || k.contains('build')).toList();
    if (renderOperations.isEmpty) return 'unknown';
    
    final avgRenderTime = renderOperations
        .map((op) => _metrics[op]!.averageDuration)
        .reduce((a, b) => a + b) / renderOperations.length;
    
    if (avgRenderTime < 50) return 'excellent';
    if (avgRenderTime < 100) return 'good';
    if (avgRenderTime < 200) return 'fair';
    return 'poor';
  }

  /// Get cache performance rating
  String _getCachePerformance() {
    final cacheStats = CacheService().getStats();
    final hitRate = double.tryParse(cacheStats['hitRate'] ?? '0') ?? 0;
    
    if (hitRate > 80) return 'excellent';
    if (hitRate > 60) return 'good';
    if (hitRate > 40) return 'fair';
    return 'poor';
  }

  /// Log performance summary
  void logPerformanceSummary() {
    customPrint('📊 === PERFORMANCE SUMMARY ===');
    
    final summary = getPerformanceSummary();
    final indicators = summary['performance_indicators'] as Map<String, dynamic>;
    
    customPrint('🚀 Startup Performance: ${indicators['startup_performance']}');
    customPrint('🌐 API Performance: ${indicators['api_performance']}');
    customPrint('🎨 UI Performance: ${indicators['ui_performance']}');
    customPrint('💾 Cache Performance: ${indicators['cache_performance']}');
    
    // Top slow operations
    final slowOperations = _getTopSlowOperations(5);
    if (slowOperations.isNotEmpty) {
      customPrint('🐌 Top Slow Operations:');
      for (final op in slowOperations) {
        customPrint('   ${op.name}: ${op.averageDuration.toStringAsFixed(1)}ms');
      }
    }
    
    // Cache statistics
    final cacheStats = summary['cache'] as Map<String, dynamic>;
    customPrint('💾 Cache Hit Rate: ${cacheStats['hitRate']}%');
    customPrint('💾 Memory Cache: ${cacheStats['memoryCacheSize']}/${cacheStats['memoryCacheMaxSize']}');
    
    customPrint('📊 === END PERFORMANCE SUMMARY ===');
  }

  /// Get top slow operations
  List<PerformanceMetric> _getTopSlowOperations(int count) {
    final sortedMetrics = _metrics.values.toList()
      ..sort((a, b) => b.averageDuration.compareTo(a.averageDuration));
    
    return sortedMetrics.take(count).toList();
  }

  /// Monitor specific app events
  void monitorAppEvent(String event, Map<String, dynamic>? metadata) {
    incrementCounter('app_event_$event');
    customPrint('📱 App Event: $event ${metadata != null ? metadata : ''}');
  }

  /// Monitor user interactions
  void monitorUserInteraction(String interaction, String screen) {
    incrementCounter('user_interaction_$interaction');
    incrementCounter('screen_interaction_$screen');
    customPrint('👆 User Interaction: $interaction on $screen');
  }

  /// Monitor errors
  void monitorError(String type, String context, dynamic error) {
    incrementCounter('error_$type');
    incrementCounter('error_context_$context');
    customPrint('❌ Error Monitored: $type in $context - $error');
  }

  /// Get performance recommendations
  List<String> getPerformanceRecommendations() {
    final recommendations = <String>[];
    final indicators = _getPerformanceIndicators();
    
    // Startup recommendations
    if (indicators['startup_performance'] == 'poor' || 
        indicators['startup_performance'] == 'fair') {
      recommendations.add('Consider optimizing app initialization sequence');
      recommendations.add('Implement more aggressive API prefetching');
    }
    
    // API recommendations
    if (indicators['api_performance'] == 'poor' || 
        indicators['api_performance'] == 'fair') {
      recommendations.add('Optimize API response sizes');
      recommendations.add('Implement request batching');
      recommendations.add('Consider using GraphQL for better data fetching');
    }
    
    // UI recommendations
    if (indicators['ui_performance'] == 'poor' || 
        indicators['ui_performance'] == 'fair') {
      recommendations.add('Optimize widget build methods');
      recommendations.add('Use const constructors where possible');
      recommendations.add('Implement widget caching for complex layouts');
    }
    
    // Cache recommendations
    if (indicators['cache_performance'] == 'poor' || 
        indicators['cache_performance'] == 'fair') {
      recommendations.add('Increase cache TTL for stable data');
      recommendations.add('Implement smarter cache eviction policies');
      recommendations.add('Consider pre-warming cache with common data');
    }
    
    return recommendations;
  }

  /// Clear all performance data
  void clearData() {
    _startTimes.clear();
    _durations.clear();
    _counters.clear();
    _metrics.clear();
    customPrint('🧹 Performance data cleared');
  }

  /// Export performance data for analysis
  Map<String, dynamic> exportData() {
    return {
      'durations': _durations,
      'counters': _counters,
      'metrics': _metrics.map((key, value) => MapEntry(key, value.toMap())),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }
}

/// Performance metric class for tracking operation statistics
class PerformanceMetric {
  final String name;
  final List<int> _durations = [];
  int _totalDuration = 0;
  int _count = 0;
  int _minDuration = 0;
  int _maxDuration = 0;

  PerformanceMetric(this.name);

  void addDuration(int duration) {
    _durations.add(duration);
    _totalDuration += duration;
    _count++;
    
    if (_minDuration == 0 || duration < _minDuration) {
      _minDuration = duration;
    }
    if (duration > _maxDuration) {
      _maxDuration = duration;
    }
  }

  double get averageDuration => _count > 0 ? _totalDuration / _count : 0.0;
  int get totalDuration => _totalDuration;
  int get count => _count;
  int get minDuration => _minDuration;
  int get maxDuration => _maxDuration;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'average_duration': averageDuration,
      'total_duration': totalDuration,
      'count': count,
      'min_duration': minDuration,
      'max_duration': maxDuration,
    };
  }
} 