import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yokai_quiz_app/api/database_api.dart';
import 'package:yokai_quiz_app/api/local_storage.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/main.dart';
import 'package:yokai_quiz_app/util/constants.dart';
import 'cache_service.dart';

/// Netflix-Style Ultra Fast API Service
/// Implements advanced optimization techniques for lightning-fast performance
class UltraFastApiService {
  static final UltraFastApiService _instance = UltraFastApiService._internal();
  factory UltraFastApiService() => _instance;
  UltraFastApiService._internal();

  final CacheService _cacheService = CacheService();
  final Connectivity _connectivity = Connectivity();
  
  // HTTP Client with connection pooling (simulated)
  final http.Client _httpClient = http.Client();
  
  // Request deduplication and batching
  final Map<String, Future<dynamic>> _ongoingRequests = {};
  final Map<String, List<Completer<dynamic>>> _requestQueue = {};
  final Map<String, Timer> _batchTimers = {};
  
  // Performance tracking
  final Map<String, DateTime> _requestStartTimes = {};
  final Map<String, List<int>> _requestDurations = {};
  
  // Predictive loading
  final Set<String> _predictivelyLoaded = {};
  final Map<String, int> _accessPatterns = {};
  
  // Image/Asset prefetching
  final Map<String, Future<void>> _assetPrefetchingQueue = {};
  
  // Netflix-style API configuration with ultra-fast settings
  final Map<String, Map<String, dynamic>> _ultraFastApiConfig = {
         // CRITICAL - Load immediately (0ms delay) - EXTENDED CACHE
     'user_profile': {
       'priority': 1,
       'endpoint': DatabaseApi.getProfile,
       'cache_key': 'user_profile',
       'ttl': Duration(hours: 6), // Extended cache for better performance
       'retry_count': 2,
       'critical': true,
       'batch_delay': 0, // Immediate
       'prefetch_images': false,
       'predictive_score': 10,
     },
     
     // CRITICAL - Load immediately in parallel (0ms delay) - EXTENDED CACHE
     'all_stories': {
       'priority': 1, // Same priority = parallel execution
       'endpoint': DatabaseApi.getStories,
       'cache_key': 'all_stories',
       'ttl': Duration(hours: 2), // Extended cache
       'retry_count': 2,
       'critical': true,
       'batch_delay': 0, // Immediate
       'prefetch_images': true,
       'predictive_score': 10,
     },
     
     'all_characters': {
       'priority': 1, // Parallel with above
       'endpoint': DatabaseApi.getAllCharacters,
       'cache_key': 'all_characters', 
       'ttl': Duration(hours: 2), // Extended cache
       'retry_count': 2,
       'critical': true,
       'batch_delay': 0, // Immediate
       'prefetch_images': true,
       'predictive_score': 9,
     },
    
         'last_read_chapter': {
       'priority': 1, // Make critical for aggressive loading
       'endpoint': DatabaseApi.getLastReadChapter,
       'cache_key': 'last_read_chapter',
       'ttl': Duration(hours: 1), // Longer cache
       'retry_count': 2,
       'critical': true, // Make critical
       'batch_delay': 0, // No delay
       'prefetch_images': true,
       'predictive_score': 8,
     },
     
     'all_challenges': {
       'priority': 1, // Make critical for aggressive loading
       'endpoint': DatabaseApi.getAllChallenge,
       'cache_key': 'all_challenges',
       'ttl': Duration(hours: 6), // Much longer cache
       'retry_count': 2,
       'critical': true, // Make critical
       'batch_delay': 0, // No delay
       'prefetch_images': true,
       'predictive_score': 7,
     },
     
     // MAKE ALL APIS CRITICAL for 6-second window
     'trending_stories': {
       'priority': 1, // Make critical
       'endpoint': DatabaseApi.getStories,
       'cache_key': 'trending_stories',
       'ttl': Duration(hours: 1), // Longer cache
       'retry_count': 2,
       'critical': true, // Make critical
       'batch_delay': 0,
       'prefetch_images': true,
       'predictive_score': 6,
     },
    
    'user_badges': {
      'priority': 4,
      'endpoint': '', // Add your badges endpoint
      'cache_key': 'user_badges',
      'ttl': Duration(hours: 1),
      'retry_count': 1,
      'critical': false,
      'batch_delay': 500,
      'prefetch_images': false,
      'predictive_score': 5,
    },
  };

  // Data storage with ultra-fast access
  final RxMap<String, dynamic> _ultraFastData = <String, dynamic>{}.obs;
  final RxBool _isUltraFastLoading = false.obs;
  final RxBool _ultraFastComplete = false.obs;
  final RxMap<String, String> _ultraFastErrors = <String, String>{}.obs;

  // Getters
  bool get isLoading => _isUltraFastLoading.value;
  bool get isComplete => _ultraFastComplete.value;
  Map<String, dynamic> get data => Map.from(_ultraFastData);
  Map<String, String> get errors => Map.from(_ultraFastErrors);

  /// Netflix-Style Ultra Fast Loading - Enhanced for 6-second splash window
  Future<void> startUltraFastLoading() async {
    if (_isUltraFastLoading.value) return;
    
    _isUltraFastLoading(true);
    _ultraFastComplete(false);
    _ultraFastErrors.clear();
    
    final startTime = DateTime.now();
    customPrint('🚀 ULTRA FAST: Starting aggressive 6-second loading window');
    
    try {
      // Quick connectivity check (25ms max)
      final connectivityFuture = _connectivity.checkConnectivity()
          .timeout(Duration(milliseconds: 25), onTimeout: () => [ConnectivityResult.wifi]);
      final connectivityResult = await connectivityFuture;
      
      if (connectivityResult.every((result) => result == ConnectivityResult.none)) {
        await _loadFromUltraFastCache();
        return;
      }

      // AGGRESSIVE 6-SECOND STRATEGY
      // PHASE 1: ALL CRITICAL DATA IMMEDIATELY (0-100ms)
      final criticalFuture = _loadCriticalDataUltraFast();
      
      // PHASE 2: START ALL OTHER APIS IMMEDIATELY (0ms delay - aggressive)
      final allDataFuture = _loadAllDataAggressively();
      
      // PHASE 3: ASSET PREFETCHING (parallel with APIs)
      _prefetchAssetsBackground();
      
      // Wait for critical data first (essential for home screen)
      await criticalFuture;
      customPrint('⚡ ULTRA FAST: Critical data loaded, starting aggressive loading');
      
      // Continue loading everything else with generous timeout (5.5 seconds)
      await allDataFuture.timeout(
        Duration(milliseconds: 5500), // Use most of the 6-second window
        onTimeout: () {
          customPrint('⚡ ULTRA FAST: 5.5s timeout reached, proceeding with loaded data');
        },
      );
      
    } catch (e) {
      customPrint('❌ ULTRA FAST: Error during loading: $e');
      await _loadFromUltraFastCache();
    } finally {
      final totalTime = DateTime.now().difference(startTime);
      customPrint('⚡ ULTRA FAST: Completed in ${totalTime.inMilliseconds}ms');
      
      _isUltraFastLoading(false);
      _ultraFastComplete(true);
      _logUltraFastPerformance();
    }
  }

  /// Load critical data with maximum parallelization (Netflix-style)
  Future<void> _loadCriticalDataUltraFast() async {
    final criticalApis = _ultraFastApiConfig.entries
        .where((entry) => entry.value['critical'] == true)
        .toList();

    // Group by priority for parallel execution
    final priorityGroups = <int, List<MapEntry<String, Map<String, dynamic>>>>{};
    for (final entry in criticalApis) {
      final priority = entry.value['priority'] as int;
      priorityGroups.putIfAbsent(priority, () => []).add(entry);
    }

    // Execute each priority group in parallel (Netflix approach)
    for (final priority in priorityGroups.keys.toList()..sort()) {
      final group = priorityGroups[priority]!;
      customPrint('⚡ ULTRA FAST: Loading priority $priority (${group.length} APIs in parallel)');
      
      // Execute all APIs in this priority group simultaneously
      final futures = group.map((entry) => _executeUltraFastApiCall(entry.key, entry.value));
      
      // Wait for this priority group with timeout
      await Future.wait(futures, eagerError: false)
          .timeout(Duration(milliseconds: priority == 1 ? 300 : 500));
    }
  }

  /// Load ALL data aggressively within 6-second window
  Future<void> _loadAllDataAggressively() async {
    customPrint('⚡ ULTRA FAST: Starting aggressive loading of ALL APIs');
    
    // Get ALL APIs (critical + non-critical)
    final allApis = _ultraFastApiConfig.entries.toList();
    
    // Remove delay from ALL APIs for aggressive loading
    final aggressiveConfig = <String, Map<String, dynamic>>{};
    for (final entry in allApis) {
      aggressiveConfig[entry.key] = Map.from(entry.value);
      aggressiveConfig[entry.key]!['batch_delay'] = 0; // No delays
      aggressiveConfig[entry.key]!['retry_count'] = 1; // Fast retries only
    }
    
    // Group APIs by priority but execute with staggered timing for server kindness
    final priorityGroups = <int, List<MapEntry<String, Map<String, dynamic>>>>{};
    for (final entry in aggressiveConfig.entries) {
      final priority = entry.value['priority'] as int;
      priorityGroups.putIfAbsent(priority, () => []).add(MapEntry(entry.key, entry.value));
    }
    
    // Execute all priority groups with minimal delays
    final allFutures = <Future<void>>[];
    
    for (final priority in priorityGroups.keys.toList()..sort()) {
      final group = priorityGroups[priority]!;
      
      // Add small stagger only for server kindness (not blocking)
      final delayMs = (priority - 1) * 50; // 0ms, 50ms, 100ms, etc.
      
      for (final entry in group) {
        final future = Future.delayed(Duration(milliseconds: delayMs), () async {
          await _executeUltraFastApiCall(entry.key, entry.value);
        });
        allFutures.add(future);
      }
    }
    
    customPrint('⚡ ULTRA FAST: Executing ${allFutures.length} APIs with aggressive parallelization');
    
    // Wait for ALL APIs to complete (or timeout)
    await Future.wait(allFutures, eagerError: false);
    
    customPrint('⚡ ULTRA FAST: Aggressive loading completed');
  }

  /// Execute single API call with Netflix-level optimization
  Future<void> _executeUltraFastApiCall(String apiKey, Map<String, dynamic> config) async {
    final String cacheKey = config['cache_key'];
    final Duration ttl = config['ttl'];
    final int retryCount = config['retry_count'];
    final int batchDelay = config['batch_delay'] ?? 0;

    _requestStartTimes[apiKey] = DateTime.now();

    try {
      // STEP 1: Immediate cache check (< 1ms)
      final cachedData = await _cacheService.get(cacheKey);
      if (cachedData != null) {
        _ultraFastData[apiKey] = cachedData;
        customPrint('⚡ ULTRA FAST: Cache hit for $apiKey (${DateTime.now().difference(_requestStartTimes[apiKey]!).inMilliseconds}ms)');
        _recordRequestDuration(apiKey);
        
        // Start background refresh if cache is getting stale
        _backgroundRefreshIfNeeded(apiKey, config);
        return;
      }

      // STEP 2: Request deduplication
      if (_ongoingRequests.containsKey(apiKey)) {
        customPrint('⚡ ULTRA FAST: Deduplicating request for $apiKey');
        final result = await _ongoingRequests[apiKey]!;
        _ultraFastData[apiKey] = result;
        return;
      }

      // STEP 3: Batch small requests (if configured)
      if (batchDelay > 0) {
        await _addToBatch(apiKey, config);
        return;
      }

      // STEP 4: Execute immediately with connection reuse
      _ongoingRequests[apiKey] = _makeUltraFastApiCall(apiKey, config);
      final responseData = await _ongoingRequests[apiKey]!;
      
      if (responseData != null) {
        // Cache with background persistence
        _cacheService.set(cacheKey, responseData, ttl);
        _ultraFastData[apiKey] = responseData;
        customPrint('⚡ ULTRA FAST: API success for $apiKey (${DateTime.now().difference(_requestStartTimes[apiKey]!).inMilliseconds}ms)');
        
        // Prefetch related images if configured
        if (config['prefetch_images'] == true) {
          _prefetchImagesForData(apiKey, responseData);
        }
      }

    } catch (e) {
      customPrint('❌ ULTRA FAST: Error for $apiKey: $e');
      _ultraFastErrors[apiKey] = e.toString();
      
      // Try stale cache as fallback
      final staleData = await _cacheService.getStale(cacheKey);
      if (staleData != null) {
        _ultraFastData[apiKey] = staleData;
        customPrint('⚠️ ULTRA FAST: Using stale cache for $apiKey');
      }
    } finally {
      _ongoingRequests.remove(apiKey);
      _recordRequestDuration(apiKey);
    }
  }

  /// Make HTTP call with ultra-fast optimizations
  Future<dynamic> _makeUltraFastApiCall(String apiKey, Map<String, dynamic> config) async {
    final headers = {
      "Content-Type": "application/json",
      "Accept-Language": constants.deviceLanguage,
      "Connection": "keep-alive", // Reuse connections
      "Accept-Encoding": "gzip, deflate", // Compression
    };

    // Add auth token if available
    if (prefs.getBool(LocalStorage.isLogin) == true) {
      headers["UserToken"] = prefs.getString(LocalStorage.token) ?? '';
    }

         final timeout = Duration(milliseconds: 4000); // 4 second timeout for aggressive loading

    switch (apiKey) {
      case 'user_profile':
        if (prefs.getBool(LocalStorage.isLogin) != true) return null;
        final response = await _httpClient.get(
          Uri.parse(DatabaseApi.getProfile),
          headers: headers,
        ).timeout(timeout);
        return json.decode(response.body);

      case 'all_stories':
        final response = await _httpClient.get(
          Uri.parse(DatabaseApi.getStories),
          headers: headers,
        ).timeout(timeout);
        return json.decode(response.body);

      case 'all_characters':
        final response = await _httpClient.get(
          Uri.parse(DatabaseApi.getAllCharacters),
          headers: headers,
        ).timeout(timeout);
        return json.decode(response.body);

      case 'last_read_chapter':
        if (prefs.getBool(LocalStorage.isLogin) != true) return null;
        final response = await _httpClient.get(
          Uri.parse(DatabaseApi.getLastReadChapter),
          headers: headers,
        ).timeout(timeout);
        return json.decode(response.body);

      case 'all_challenges':
        final response = await _httpClient.get(
          Uri.parse(DatabaseApi.getAllChallenge),
          headers: headers,
        ).timeout(timeout);
        return json.decode(response.body);

      default:
        throw Exception('Unknown API key: $apiKey');
    }
  }

  /// Netflix-style request batching for small requests
  Future<void> _addToBatch(String apiKey, Map<String, dynamic> config) async {
    final completer = Completer<dynamic>();
    
    if (!_requestQueue.containsKey(apiKey)) {
      _requestQueue[apiKey] = [];
      
      // Set timer to execute batch
      _batchTimers[apiKey] = Timer(Duration(milliseconds: config['batch_delay']), () async {
        final completers = _requestQueue.remove(apiKey) ?? [];
        _batchTimers.remove(apiKey);
        
        try {
          final result = await _makeUltraFastApiCall(apiKey, config);
          for (final completer in completers) {
            completer.complete(result);
          }
        } catch (e) {
          for (final completer in completers) {
            completer.completeError(e);
          }
        }
      });
    }
    
    _requestQueue[apiKey]!.add(completer);
    final result = await completer.future;
    _ultraFastData[apiKey] = result;
  }

  /// Background refresh for near-stale cache
  void _backgroundRefreshIfNeeded(String apiKey, Map<String, dynamic> config) {
    Timer(Duration(milliseconds: 100), () async {
      final cacheKey = config['cache_key'];
      final isNearExpiry = await _cacheService.isExpired(cacheKey);
      
      if (isNearExpiry) {
        customPrint('🔄 ULTRA FAST: Background refresh for $apiKey');
        try {
          final freshData = await _makeUltraFastApiCall(apiKey, config);
          if (freshData != null) {
            await _cacheService.set(cacheKey, freshData, config['ttl']);
            _ultraFastData[apiKey] = freshData;
          }
        } catch (e) {
          // Silent fail for background refresh
        }
      }
    });
  }

  /// Load predictive data in background (Netflix recommendation style)
  void _loadPredictiveDataBackground() {
    Timer(Duration(milliseconds: 150), () async {
      final predictiveApis = _ultraFastApiConfig.entries
          .where((entry) => entry.value['critical'] == false)
          .toList()
        ..sort((a, b) => (b.value['predictive_score'] as int)
            .compareTo(a.value['predictive_score'] as int));

      for (final entry in predictiveApis) {
        if (!_ultraFastData.containsKey(entry.key)) {
          Timer(Duration(milliseconds: entry.value['predictive_score'] * 10), () {
            _executeUltraFastApiCall(entry.key, entry.value);
          });
        }
      }
    });
  }

  /// Prefetch images and assets in background
  void _prefetchAssetsBackground() {
    Timer(Duration(milliseconds: 200), () {
      for (final entry in _ultraFastData.entries) {
        final data = entry.value;
        if (data is Map && data['data'] is List) {
          _prefetchImagesForData(entry.key, data);
        }
      }
    });
  }

  /// Prefetch images from API response data
  void _prefetchImagesForData(String apiKey, dynamic data) {
    if (data is! Map || data['data'] is! List) return;
    
    final items = data['data'] as List;
    for (int i = 0; i < (items.length > 10 ? 10 : items.length); i++) {
      final item = items[i];
      if (item is Map) {
        // Prefetch story images
        if (item['stories_image'] != null) {
          final imageUrl = "${DatabaseApi.mainUrlImage}${item['stories_image']}";
          _prefetchSingleAsset(imageUrl);
        }
        
        // Prefetch character images
        if (item['character_image'] != null) {
          final imageUrl = "${DatabaseApi.mainUrlImage}${item['character_image']}";
          _prefetchSingleAsset(imageUrl);
        }
        
        // Prefetch challenge images
        if (item['image'] != null) {
          final imageUrl = "${DatabaseApi.mainUrlImage}${item['image']}";
          _prefetchSingleAsset(imageUrl);
        }
      }
    }
  }

  /// Prefetch single asset (image)
  void _prefetchSingleAsset(String url) {
    if (_assetPrefetchingQueue.containsKey(url)) return;
    
    _assetPrefetchingQueue[url] = _httpClient.get(Uri.parse(url))
        .timeout(Duration(seconds: 5))
        .then((_) {
      customPrint('📸 ULTRA FAST: Prefetched asset: ${url.split('/').last}');
    }).catchError((e) {
      // Silent fail for asset prefetching
    }).whenComplete(() {
      _assetPrefetchingQueue.remove(url);
    });
  }

  /// Load from ultra-fast cache when offline
  Future<void> _loadFromUltraFastCache() async {
    customPrint('📱 ULTRA FAST: Loading from cache (offline mode)');
    
    final futures = _ultraFastApiConfig.entries.map((entry) async {
      try {
        final cachedData = await _cacheService.getStale(entry.value['cache_key']);
        if (cachedData != null) {
          _ultraFastData[entry.key] = cachedData;
          customPrint('✅ ULTRA FAST: Cache loaded ${entry.key}');
        }
      } catch (e) {
        customPrint('❌ ULTRA FAST: Cache error ${entry.key}: $e');
      }
    });
    
    await Future.wait(futures, eagerError: false);
  }

  /// Get specific data with ultra-fast access
  T? getUltraFastData<T>(String apiKey) {
    final data = _ultraFastData[apiKey];
    if (data != null && data is T) {
      // Update access pattern for predictive loading
      _accessPatterns[apiKey] = (_accessPatterns[apiKey] ?? 0) + 1;
      return data;
    }
    return null;
  }

  /// Check if data is available
  bool hasUltraFastData(String apiKey) {
    return _ultraFastData.containsKey(apiKey) && _ultraFastData[apiKey] != null;
  }

  /// Record request duration for performance monitoring
  void _recordRequestDuration(String apiKey) {
    final startTime = _requestStartTimes[apiKey];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      if (!_requestDurations.containsKey(apiKey)) {
        _requestDurations[apiKey] = [];
      }
      _requestDurations[apiKey]!.add(duration);
    }
  }

  /// Log ultra-fast performance metrics
  void _logUltraFastPerformance() {
    customPrint('⚡ ULTRA FAST Performance Metrics:');
    
    for (final entry in _requestDurations.entries) {
      final durations = entry.value;
      if (durations.isNotEmpty) {
        final avg = durations.reduce((a, b) => a + b) / durations.length;
        final min = durations.reduce((a, b) => a < b ? a : b);
        final max = durations.reduce((a, b) => a > b ? a : b);
        
        customPrint('   ${entry.key}: avg=${avg.toStringAsFixed(0)}ms, min=${min}ms, max=${max}ms');
      }
    }
    
    final successCount = _ultraFastData.length;
    final errorCount = _ultraFastErrors.length;
    final totalCount = _ultraFastApiConfig.length;
    
    customPrint('   Success: $successCount/$totalCount (${(successCount/totalCount*100).toStringAsFixed(1)}%)');
    customPrint('   Errors: $errorCount');
    customPrint('   Prefetched assets: ${_assetPrefetchingQueue.length}');
  }

  /// Get performance summary (for monitoring)
  Map<String, dynamic> getUltraFastPerformanceSummary() {
    final avgDurations = <String, double>{};
    for (final entry in _requestDurations.entries) {
      if (entry.value.isNotEmpty) {
        avgDurations[entry.key] = entry.value.reduce((a, b) => a + b) / entry.value.length;
      }
    }
    
    return {
      'isLoading': _isUltraFastLoading.value,
      'isComplete': _ultraFastComplete.value,
      'successCount': _ultraFastData.length,
      'errorCount': _ultraFastErrors.length,
      'totalApis': _ultraFastApiConfig.length,
      'averageDurations': avgDurations,
      'errors': Map.from(_ultraFastErrors),
      'accessPatterns': Map.from(_accessPatterns),
      'prefetchedAssets': _assetPrefetchingQueue.length,
    };
  }

  /// Clear all data
  void clearUltraFastData() {
    _ultraFastData.clear();
    _ultraFastErrors.clear();
    _ultraFastComplete(false);
    _ongoingRequests.clear();
    _requestQueue.clear();
    _batchTimers.values.forEach((timer) => timer.cancel());
    _batchTimers.clear();
  }

  /// Dispose resources
  void dispose() {
    _httpClient.close();
    clearUltraFastData();
  }
} 