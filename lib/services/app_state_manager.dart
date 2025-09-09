import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:yokai_quiz_app/api/api_prefetch_service.dart';
import 'package:yokai_quiz_app/api/ultra_fast_api_service.dart';
import 'package:yokai_quiz_app/api/cache_service.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/api/local_storage.dart';
import 'package:yokai_quiz_app/main.dart';

/// Comprehensive app state manager for handling global state,
/// data flow between screens, and progressive loading states
class AppStateManager extends GetxController {
  static AppStateManager get instance => Get.find<AppStateManager>();
  
  final ApiPrefetchService _prefetchService = ApiPrefetchService();
  final UltraFastApiService _ultraFastService = UltraFastApiService();
  final CacheService _cacheService = CacheService();
  final Connectivity _connectivity = Connectivity();

  // App State Observables
  final RxBool _isAppInitialized = false.obs;
  final RxBool _isUserLoggedIn = false.obs;
  final RxBool _hasInternetConnection = true.obs;
  final RxString _appVersion = ''.obs;
  
  // Loading States
  final RxBool _isSplashScreenVisible = true.obs;
  final RxBool _isPrefetchingData = false.obs;
  final RxBool _isHomeScreenLoading = true.obs;
  final RxBool _isRetryingFailedCalls = false.obs;
  
  // Progressive Loading States for Home Screen Components
  final RxMap<String, bool> _componentLoadingStates = <String, bool>{
    'user_profile': true,
    'trending_stories': true,
    'characters': true,
    'last_read_chapter': true,
    'challenges': true,
    'device_info': true,
  }.obs;
  
  // Data States
  final RxMap<String, dynamic> _appData = <String, dynamic>{}.obs;
  final RxMap<String, String> _dataErrors = <String, String>{}.obs;
  final RxInt _dataLoadedCount = 0.obs;
  final RxInt _totalDataComponents = 6.obs;
  
  // Performance Metrics
  final RxMap<String, int> _performanceMetrics = <String, int>{
    'splash_duration': 0,
    'prefetch_duration': 0,
    'home_load_duration': 0,
    'total_startup_duration': 0,
  }.obs;
  
  // Timers for tracking
  DateTime? _appStartTime;
  DateTime? _splashStartTime;
  DateTime? _prefetchStartTime;
  DateTime? _homeLoadStartTime;
  
  // Stream subscriptions
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Getters for external access
  bool get isAppInitialized => _isAppInitialized.value;
  bool get isUserLoggedIn => _isUserLoggedIn.value;
  bool get hasInternetConnection => _hasInternetConnection.value;
  bool get isSplashScreenVisible => _isSplashScreenVisible.value;
  bool get isPrefetchingData => _isPrefetchingData.value;
  bool get isHomeScreenLoading => _isHomeScreenLoading.value;
  bool get isRetryingFailedCalls => _isRetryingFailedCalls.value;
  
  Map<String, bool> get componentLoadingStates => Map.from(_componentLoadingStates);
  Map<String, dynamic> get appData => Map.from(_appData);
  Map<String, String> get dataErrors => Map.from(_dataErrors);
  double get dataLoadProgress => _totalDataComponents.value > 0 
      ? _dataLoadedCount.value / _totalDataComponents.value : 0.0;
  Map<String, int> get performanceMetrics => Map.from(_performanceMetrics);

  @override
  void onInit() {
    super.onInit();
    _initializeAppState();
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  /// Initialize app state and start the optimization process
  Future<void> _initializeAppState() async {
    _appStartTime = DateTime.now();
    _splashStartTime = DateTime.now();
    
    customPrint('🚀 Initializing app state manager');
    
    // Initialize services
    await _cacheService.initialize();
    
    // Setup connectivity monitoring
    _setupConnectivityMonitoring();
    
    // Check initial login state
    _updateLoginState();
    
    // Start prefetching during splash
    await startSplashScreenPrefetch();
  }

    /// Start ULTRA FAST data prefetching during splash screen (Netflix-style)
  Future<void> startSplashScreenPrefetch() async {
    if (_isPrefetchingData.value) return;

    _isPrefetchingData(true);
    _prefetchStartTime = DateTime.now();

    customPrint('🚀 ULTRA FAST: Starting Netflix-style splash screen prefetching');

    try {
      // Start ULTRA FAST Netflix-style loading
      final ultraFastFuture = _ultraFastService.startUltraFastLoading();

      // Monitor ultra-fast progress
      _monitorUltraFastProgress();

      // Wait for ultra-fast loading with full 6-second window (5.8 seconds)
      await ultraFastFuture.timeout(
        Duration(milliseconds: 5800), // Use almost full 6-second splash window
        onTimeout: () {
          customPrint('⚡ ULTRA FAST: 5.8s timeout - proceeding with loaded data');
        },
      );

      // Also run traditional prefetch as backup (in parallel)
      _prefetchService.startPrefetching().catchError((e) {
        customPrint('⚠️ Backup prefetch error: $e');
      });

    } catch (e) {
      customPrint('❌ ULTRA FAST: Error during splash prefetch: $e');
      // Fallback to traditional prefetch
      await _prefetchService.startPrefetching().catchError((e) => customPrint('Fallback error: $e'));
    } finally {
      _isPrefetchingData(false);
      _recordPrefetchDuration();
    }
  }

    /// Monitor prefetch progress and update component states
  void _monitorPrefetchProgress() {
    Timer.periodic(Duration(milliseconds: 200), (timer) {
      if (!_isPrefetchingData.value) {
        timer.cancel();
        return;
      }

      _updateComponentStatesFromPrefetch();
    });
  }

  /// Monitor ULTRA FAST progress and update component states (Netflix-style)
  void _monitorUltraFastProgress() {
    Timer.periodic(Duration(milliseconds: 50), (timer) { // Much faster monitoring
      if (!_isPrefetchingData.value) {
        timer.cancel();
        return;
      }

      _updateComponentStatesFromUltraFast();
    });
  }

  /// Update component loading states based on prefetch results
  void _updateComponentStatesFromPrefetch() {
    final prefetchedData = _prefetchService.prefetchedData;
    final errors = _prefetchService.prefetchErrors;
    int loadedCount = 0;
    
    // Update component states based on prefetched data
    _componentLoadingStates.forEach((component, isLoading) {
      if (isLoading) {
        String apiKey = _getApiKeyForComponent(component);
        
        if (prefetchedData.containsKey(apiKey)) {
          _componentLoadingStates[component] = false;
          _appData[component] = prefetchedData[apiKey];
          loadedCount++;
          customPrint('✅ $component data loaded');
        } else if (errors.containsKey(apiKey)) {
          _componentLoadingStates[component] = false;
          _dataErrors[component] = errors[apiKey]!;
          loadedCount++;
          customPrint('❌ $component failed: ${errors[apiKey]}');
        }
      } else {
        loadedCount++;
      }
    });
    
    _dataLoadedCount(loadedCount);
  }

  /// Update component states from ULTRA FAST service (Netflix-style)
  void _updateComponentStatesFromUltraFast() {
    final ultraFastData = _ultraFastService.data;
    final errors = _ultraFastService.errors;
    int loadedCount = 0;

    // Update component states based on ultra-fast data
    _componentLoadingStates.forEach((component, isLoading) {
      if (isLoading) {
        String apiKey = _getApiKeyForComponent(component);

        if (ultraFastData.containsKey(apiKey)) {
          _componentLoadingStates[component] = false;
          _appData[component] = ultraFastData[apiKey];
          loadedCount++;
          customPrint('⚡ ULTRA FAST: $component data loaded');
        } else if (errors.containsKey(apiKey)) {
          _componentLoadingStates[component] = false;
          _dataErrors[component] = errors[apiKey]!;
          loadedCount++;
          customPrint('❌ ULTRA FAST: $component failed: ${errors[apiKey]}');
        }
      } else {
        loadedCount++;
      }
    });

    _dataLoadedCount(loadedCount);
  }

  /// Get API key for component name mapping
  String _getApiKeyForComponent(String component) {
    switch (component) {
      case 'user_profile': return 'user_profile';
      case 'trending_stories': return 'all_stories';
      case 'characters': return 'all_characters';
      case 'last_read_chapter': return 'last_read_chapter';
      case 'challenges': return 'all_challenges';
      case 'device_info': return 'device_info';
      default: return component;
    }
  }

  /// Complete splash screen and transition to main app
  Future<void> completeSplashScreen() async {
    _recordSplashDuration();
    _isSplashScreenVisible(false);
    
    // Finalize any remaining prefetch operations
    await _finalizePrefetchData();
    
    customPrint('🎯 Splash screen completed, transitioning to main app');
  }

  /// Finalize prefetch data and update app state
  Future<void> _finalizePrefetchData() async {
    // Get any remaining prefetched data
    final prefetchedData = _prefetchService.prefetchedData;
    final errors = _prefetchService.prefetchErrors;
    
    // Update app data with prefetched results
    _appData.addAll(prefetchedData);
    _dataErrors.addAll(errors);
    
    // Update final component states
    _updateComponentStatesFromPrefetch();
    
    customPrint('📊 Prefetch completed: ${prefetchedData.length} successful, ${errors.length} failed');
  }

    /// Start home screen loading process
  void startHomeScreenLoading() {
    _homeLoadStartTime = DateTime.now();
    
    customPrint('🏠 Starting home screen loading');

    // Defer state update to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      customPrint('🔄 Starting home screen loading (post frame callback)');
      _isHomeScreenLoading(true);
      
      // Start progressive loading of remaining components
      _loadRemainingComponents();
    });
  }

  /// Load any remaining components that weren't prefetched
  void _loadRemainingComponents() {
    Timer(Duration(milliseconds: 100), () async {
      final componentsToLoad = _componentLoadingStates.entries
          .where((entry) => entry.value == true)
          .map((entry) => entry.key)
          .toList();
      
      if (componentsToLoad.isNotEmpty) {
        customPrint('🔄 Loading remaining components: $componentsToLoad');
        
        // Try to retry failed API calls
        if (_prefetchService.prefetchErrors.isNotEmpty) {
          await retryFailedApiCalls();
        }
      }
      
      // Complete home screen loading
      await _completeHomeScreenLoading();
    });
  }

  /// Complete home screen loading
  Future<void> _completeHomeScreenLoading() async {
    _isHomeScreenLoading(false);
    _recordHomeLoadDuration();
    _recordTotalStartupDuration();
    
    customPrint('✅ Home screen loading completed');
    _logPerformanceMetrics();
  }

  /// Retry failed API calls
  Future<void> retryFailedApiCalls() async {
    if (_isRetryingFailedCalls.value) return;
    
    _isRetryingFailedCalls(true);
    customPrint('🔄 Retrying failed API calls');
    
    try {
      await _prefetchService.retryFailedCalls();
      
      // Update component states after retry
      Timer(Duration(milliseconds: 500), () {
        _updateComponentStatesFromPrefetch();
        _isRetryingFailedCalls(false);
      });
      
    } catch (e) {
      customPrint('❌ Failed to retry API calls: $e');
      _isRetryingFailedCalls(false);
    }
  }

  /// Get data for specific component
  T? getComponentData<T>(String component) {
    return _appData[component] as T?;
  }

  /// Check if component has data
  bool hasComponentData(String component) {
    return _appData.containsKey(component) && _appData[component] != null;
  }

  /// Check if component has error
  bool hasComponentError(String component) {
    return _dataErrors.containsKey(component);
  }

  /// Get component error message
  String? getComponentError(String component) {
    return _dataErrors[component];
  }

  /// Check if component is loading
  bool isComponentLoading(String component) {
    return _componentLoadingStates[component] ?? false;
  }

  /// Update login state
  void _updateLoginState() {
    final isLoggedIn = prefs.getBool(LocalStorage.isLogin) ?? false;
    _isUserLoggedIn(isLoggedIn);
    customPrint('👤 User login state: $isLoggedIn');
  }

  /// Setup connectivity monitoring
  void _setupConnectivityMonitoring() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final hasConnection = results.any((result) => result != ConnectivityResult.none);
        _hasInternetConnection(hasConnection);
        
        customPrint('📶 Connectivity changed: ${hasConnection ? "Connected" : "Disconnected"}');
        
        // If connection restored, retry failed calls
        if (hasConnection && _dataErrors.isNotEmpty) {
          Timer(Duration(seconds: 1), () => retryFailedApiCalls());
        }
      },
    );
  }

  /// Record performance metrics
  void _recordSplashDuration() {
    if (_splashStartTime != null) {
      final duration = DateTime.now().difference(_splashStartTime!);
      _performanceMetrics['splash_duration'] = duration.inMilliseconds;
    }
  }

  void _recordPrefetchDuration() {
    if (_prefetchStartTime != null) {
      final duration = DateTime.now().difference(_prefetchStartTime!);
      _performanceMetrics['prefetch_duration'] = duration.inMilliseconds;
    }
  }

  void _recordHomeLoadDuration() {
    if (_homeLoadStartTime != null) {
      final duration = DateTime.now().difference(_homeLoadStartTime!);
      _performanceMetrics['home_load_duration'] = duration.inMilliseconds;
    }
  }

  void _recordTotalStartupDuration() {
    if (_appStartTime != null) {
      final duration = DateTime.now().difference(_appStartTime!);
      _performanceMetrics['total_startup_duration'] = duration.inMilliseconds;
    }
  }

  /// Log performance metrics
  void _logPerformanceMetrics() {
    customPrint('📊 App Performance Metrics:');
    customPrint('   Splash Duration: ${_performanceMetrics['splash_duration']}ms');
    customPrint('   Prefetch Duration: ${_performanceMetrics['prefetch_duration']}ms');
    customPrint('   Home Load Duration: ${_performanceMetrics['home_load_duration']}ms');
    customPrint('   Total Startup Duration: ${_performanceMetrics['total_startup_duration']}ms');
    customPrint('   Data Load Progress: ${(_dataLoadedCount.value / _totalDataComponents.value * 100).toStringAsFixed(1)}%');
    customPrint('   Components Loaded: ${_dataLoadedCount.value}/${_totalDataComponents.value}');
  }

  /// Get app status summary
  Map<String, dynamic> getAppStatus() {
    return {
      'isAppInitialized': _isAppInitialized.value,
      'isUserLoggedIn': _isUserLoggedIn.value,
      'hasInternetConnection': _hasInternetConnection.value,
      'isSplashScreenVisible': _isSplashScreenVisible.value,
      'isPrefetchingData': _isPrefetchingData.value,
      'isHomeScreenLoading': _isHomeScreenLoading.value,
      'dataLoadProgress': dataLoadProgress,
      'componentsLoaded': _dataLoadedCount.value,
      'totalComponents': _totalDataComponents.value,
      'performanceMetrics': Map.from(_performanceMetrics),
      'prefetchStatus': _prefetchService.getPrefetchStatus(),
    };
  }

  /// Force refresh all data
  Future<void> forceRefreshData() async {
    customPrint('🔄 Force refreshing all app data');
    
    // Reset states
    _componentLoadingStates.forEach((key, value) {
      _componentLoadingStates[key] = true;
    });
    _dataLoadedCount(0);
    _appData.clear();
    _dataErrors.clear();
    
    // Clear cache and restart prefetch
    _prefetchService.clearPrefetchedData();
    await _prefetchService.startPrefetching();
    
    // Update states
    Timer.periodic(Duration(milliseconds: 200), (timer) {
      _updateComponentStatesFromPrefetch();
      if (_dataLoadedCount.value >= _totalDataComponents.value) {
        timer.cancel();
      }
    });
  }

  /// Set component loading state manually (for external use)
  void setComponentLoading(String component, bool isLoading) {
    _componentLoadingStates[component] = isLoading;
    if (!isLoading) {
      _dataLoadedCount(_dataLoadedCount.value + 1);
    }
  }

  /// Set component data manually (for external use)
  void setComponentData(String component, dynamic data) {
    _appData[component] = data;
    setComponentLoading(component, false);
  }

  /// Set component error manually (for external use)
  void setComponentError(String component, String error) {
    _dataErrors[component] = error;
    setComponentLoading(component, false);
  }
} 