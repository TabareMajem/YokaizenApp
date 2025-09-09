import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yokai_quiz_app/api/database_api.dart';
import 'package:yokai_quiz_app/api/local_storage.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/main.dart';
import 'package:yokai_quiz_app/models/get_all_characters.dart';
import 'package:yokai_quiz_app/models/get_all_stories.dart';
import 'package:yokai_quiz_app/models/get_last_read_chapter.dart';
import 'package:yokai_quiz_app/screens/challenge/controller/challenge_controller.dart';
import 'package:yokai_quiz_app/util/constants.dart';
import 'cache_service.dart';

/// Enhanced API prefetch service that loads critical data during splash screen
/// with intelligent caching, error handling, and retry mechanisms
class ApiPrefetchService {
  static final ApiPrefetchService _instance = ApiPrefetchService._internal();
  factory ApiPrefetchService() => _instance;
  ApiPrefetchService._internal();

  final CacheService _cacheService = CacheService();
  final Connectivity _connectivity = Connectivity();
  
  // Performance tracking
  final Map<String, DateTime> _apiStartTimes = {};
  final Map<String, Duration> _apiDurations = {};
  
  // Data storage for prefetched content
  final RxMap<String, dynamic> _prefetchedData = <String, dynamic>{}.obs;
  final RxBool _isPrefetching = false.obs;
  final RxBool _prefetchComplete = false.obs;
  final RxMap<String, String> _prefetchErrors = <String, String>{}.obs;
  
  // Priority-based API configuration
  final Map<String, Map<String, dynamic>> _apiConfig = {
    'user_profile': {
      'priority': 1,
      'endpoint': DatabaseApi.getProfile,
      'cache_key': 'user_profile',
      'ttl': Duration(hours: 1),
      'retry_count': 3,
      'critical': true,
    },
    'all_stories': {
      'priority': 2,
      'endpoint': DatabaseApi.getStories,
      'cache_key': 'all_stories',
      'ttl': Duration(minutes: 30),
      'retry_count': 2,
      'critical': true,
    },
    'all_characters': {
      'priority': 3,
      'endpoint': DatabaseApi.getAllCharacters,
      'cache_key': 'all_characters',
      'ttl': Duration(minutes: 30),
      'retry_count': 2,
      'critical': true,
    },
    'last_read_chapter': {
      'priority': 4,
      'endpoint': DatabaseApi.getLastReadChapter,
      'cache_key': 'last_read_chapter',
      'ttl': Duration(minutes: 15),
      'retry_count': 2,
      'critical': false,
    },
    'all_challenges': {
      'priority': 5,
      'endpoint': DatabaseApi.getAllChallenge,
      'cache_key': 'all_challenges',
      'ttl': Duration(hours: 2),
      'retry_count': 1,
      'critical': false,
    },
  };

  // Getters for external access
  bool get isPrefetching => _isPrefetching.value;
  bool get prefetchComplete => _prefetchComplete.value;
  Map<String, dynamic> get prefetchedData => Map.from(_prefetchedData);
  Map<String, String> get prefetchErrors => Map.from(_prefetchErrors);

  /// Main prefetch method - starts during splash screen
  Future<void> startPrefetching() async {
    if (_isPrefetching.value) return;
    
    _isPrefetching(true);
    _prefetchComplete(false);
    _prefetchErrors.clear();
    
    customPrint('🚀 Starting API prefetching during splash screen');
    
    try {
      // Check connectivity first
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        await _loadFromCacheOnly();
        return;
      }

      // Load critical data first (parallel execution for better performance)
      await _prefetchCriticalData();
      
      // Load non-critical data (can be loaded progressively)
      _prefetchNonCriticalData(); // Fire and forget for non-blocking
      
    } catch (e) {
      customPrint('❌ Error during prefetching: $e');
      await _loadFromCacheOnly();
    } finally {
      _isPrefetching(false);
      _prefetchComplete(true);
      _logPerformanceMetrics();
    }
  }

  /// Load critical data that blocks home screen rendering
  Future<void> _prefetchCriticalData() async {
    final criticalApis = _apiConfig.entries
        .where((entry) => entry.value['critical'] == true)
        .toList()
      ..sort((a, b) => a.value['priority'].compareTo(b.value['priority']));

    // Execute critical APIs in parallel for faster loading
    final futures = criticalApis.map((entry) => 
        _executeApiCall(entry.key, entry.value));
    
    await Future.wait(futures, eagerError: false);
  }

  /// Load non-critical data in background
  void _prefetchNonCriticalData() {
    final nonCriticalApis = _apiConfig.entries
        .where((entry) => entry.value['critical'] == false)
        .toList()
      ..sort((a, b) => a.value['priority'].compareTo(b.value['priority']));

    // Execute non-critical APIs with delay to not overwhelm the system
    for (int i = 0; i < nonCriticalApis.length; i++) {
      final entry = nonCriticalApis[i];
      Timer(Duration(milliseconds: i * 500), () {
        _executeApiCall(entry.key, entry.value);
      });
    }
  }

  /// Execute individual API call with retry logic and caching
  Future<void> _executeApiCall(String apiKey, Map<String, dynamic> config) async {
    final String cacheKey = config['cache_key'];
    final Duration ttl = config['ttl'];
    final int retryCount = config['retry_count'];
    
    _apiStartTimes[apiKey] = DateTime.now();
    
    try {
      // Try cache first (with TTL check)
      final cachedData = await _cacheService.get(cacheKey);
      if (cachedData != null) {
        _prefetchedData[apiKey] = cachedData;
        customPrint('✅ Loaded $apiKey from cache');
        _recordApiDuration(apiKey);
        return;
      }

      // Make API call with retry logic
      dynamic responseData;
      Exception? lastException;
      
      for (int attempt = 0; attempt < retryCount; attempt++) {
        try {
          responseData = await _makeApiCall(apiKey, config);
          break; // Success, exit retry loop
        } catch (e) {
          lastException = e as Exception;
          if (attempt < retryCount - 1) {
            // Exponential backoff for retries
            await Future.delayed(Duration(milliseconds: 1000 * (attempt + 1)));
            customPrint('🔄 Retrying $apiKey (attempt ${attempt + 2}/$retryCount)');
          }
        }
      }

      if (responseData != null) {
        // Cache successful response
        await _cacheService.set(cacheKey, responseData, ttl);
        _prefetchedData[apiKey] = responseData;
        customPrint('✅ Successfully prefetched $apiKey');
      } else {
        throw lastException ?? Exception('Failed to fetch $apiKey');
      }
      
    } catch (e) {
      customPrint('❌ Failed to prefetch $apiKey: $e');
      _prefetchErrors[apiKey] = e.toString();
      
      // Try to load stale cache as fallback
      final staleData = await _cacheService.getStale(cacheKey);
      if (staleData != null) {
        _prefetchedData[apiKey] = staleData;
        customPrint('⚠️ Using stale cache for $apiKey');
      }
    } finally {
      _recordApiDuration(apiKey);
    }
  }

  /// Make actual HTTP API call based on API key
  Future<dynamic> _makeApiCall(String apiKey, Map<String, dynamic> config) async {
    final headers = {
      "Content-Type": "application/json",
      "Accept-Language": constants.deviceLanguage,
    };

    // Add auth token if user is logged in
    if (prefs.getBool(LocalStorage.isLogin) == true) {
      headers["UserToken"] = prefs.getString(LocalStorage.token) ?? '';
    }

    switch (apiKey) {
      case 'user_profile':
        if (prefs.getBool(LocalStorage.isLogin) != true) return null;
        final response = await http.get(
          Uri.parse(DatabaseApi.getProfile),
          headers: headers,
        ).timeout(Duration(seconds: 10));
        return json.decode(response.body);

      case 'all_stories':
        final response = await http.get(
          Uri.parse(DatabaseApi.getStories),
          headers: headers,
        ).timeout(Duration(seconds: 10));
        return json.decode(response.body);

      case 'all_characters':
        final response = await http.get(
          Uri.parse("${DatabaseApi.getAllCharacters}"),
          headers: headers,
        ).timeout(Duration(seconds: 10));
        return json.decode(response.body);

      case 'last_read_chapter':
        if (prefs.getBool(LocalStorage.isLogin) != true) return null;
        final response = await http.get(
          Uri.parse(DatabaseApi.getLastReadChapter),
          headers: headers,
        ).timeout(Duration(seconds: 10));
        return json.decode(response.body);

      case 'all_challenges':
        final response = await http.get(
          Uri.parse(DatabaseApi.getAllChallenge),
          headers: headers,
        ).timeout(Duration(seconds: 10));
        return json.decode(response.body);

      default:
        throw Exception('Unknown API key: $apiKey');
    }
  }

  /// Load only from cache when offline
  Future<void> _loadFromCacheOnly() async {
    customPrint('📱 Loading from cache only (offline mode)');
    
    for (final entry in _apiConfig.entries) {
      try {
        final cachedData = await _cacheService.getStale(entry.value['cache_key']);
        if (cachedData != null) {
          _prefetchedData[entry.key] = cachedData;
          customPrint('✅ Loaded ${entry.key} from cache (offline)');
        }
      } catch (e) {
        customPrint('❌ Failed to load ${entry.key} from cache: $e');
      }
    }
  }

  /// Get specific prefetched data
  T? getPrefetchedData<T>(String apiKey) {
    final data = _prefetchedData[apiKey];
    if (data != null && data is T) {
      return data;
    }
    return null;
  }

  /// Check if specific API data is available
  bool hasData(String apiKey) {
    return _prefetchedData.containsKey(apiKey) && _prefetchedData[apiKey] != null;
  }

  /// Check if specific API failed
  bool hasError(String apiKey) {
    return _prefetchErrors.containsKey(apiKey);
  }

  /// Get error message for specific API
  String? getError(String apiKey) {
    return _prefetchErrors[apiKey];
  }

  /// Retry failed API calls
  Future<void> retryFailedCalls() async {
    final failedApis = _prefetchErrors.keys.toList();
    _prefetchErrors.clear();
    
    for (final apiKey in failedApis) {
      final config = _apiConfig[apiKey];
      if (config != null) {
        await _executeApiCall(apiKey, config);
      }
    }
  }

  /// Background refresh for cached data
  void startBackgroundRefresh() {
    Timer.periodic(Duration(minutes: 5), (timer) async {
      if (!_isPrefetching.value) {
        final connectivityResult = await _connectivity.checkConnectivity();
        if (connectivityResult != ConnectivityResult.none) {
          _refreshExpiredCache();
        }
      }
    });
  }

  /// Refresh expired cache in background
  Future<void> _refreshExpiredCache() async {
    for (final entry in _apiConfig.entries) {
      final cacheKey = entry.value['cache_key'];
      final isExpired = await _cacheService.isExpired(cacheKey);
      
      if (isExpired && _prefetchedData.containsKey(entry.key)) {
        // Refresh expired data in background
        Timer(Duration(milliseconds: 100), () {
          _executeApiCall(entry.key, entry.value);
        });
      }
    }
  }

  /// Record API call duration for performance monitoring
  void _recordApiDuration(String apiKey) {
    final startTime = _apiStartTimes[apiKey];
    if (startTime != null) {
      _apiDurations[apiKey] = DateTime.now().difference(startTime);
    }
  }

  /// Log performance metrics
  void _logPerformanceMetrics() {
    customPrint('📊 API Prefetch Performance Metrics:');
    for (final entry in _apiDurations.entries) {
      customPrint('   ${entry.key}: ${entry.value.inMilliseconds}ms');
    }
    
    final totalDuration = _apiDurations.values
        .fold(Duration.zero, (sum, duration) => sum + duration);
    customPrint('   Total prefetch time: ${totalDuration.inMilliseconds}ms');
    
    final successCount = _prefetchedData.length;
    final errorCount = _prefetchErrors.length;
    customPrint('   Success: $successCount, Errors: $errorCount');
  }

  /// Clear all prefetched data
  void clearPrefetchedData() {
    _prefetchedData.clear();
    _prefetchErrors.clear();
    _prefetchComplete(false);
  }

  /// Get prefetch status summary
  Map<String, dynamic> getPrefetchStatus() {
    return {
      'isPrefetching': _isPrefetching.value,
      'prefetchComplete': _prefetchComplete.value,
      'successCount': _prefetchedData.length,
      'errorCount': _prefetchErrors.length,
      'errors': Map.from(_prefetchErrors),
      'apiDurations': _apiDurations.map((key, value) => MapEntry(key, value.inMilliseconds)),
    };
  }
} 