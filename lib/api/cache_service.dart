import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/main.dart';

/// Enhanced caching service with TTL, memory/disk storage, and background refresh
/// Optimized for performance with intelligent data management
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  // Memory cache for frequently accessed data (faster access)
  final Map<String, _CacheItem> _memoryCache = {};
  
  // Disk cache configuration
  static const String _cacheDir = 'yokai_cache';
  static const int _maxMemoryCacheSize = 50; // Maximum items in memory
  static const int _maxDiskCacheSize = 200; // Maximum files on disk
  
  // Performance tracking
  int _memoryHits = 0;
  int _diskHits = 0;
  int _misses = 0;

  /// Initialize cache service - call this during app startup
  Future<void> initialize() async {
    try {
      await _cleanupExpiredCache();
      _startBackgroundCleanup();
      customPrint('📦 Cache service initialized');
    } catch (e) {
      customPrint('❌ Cache service initialization failed: $e');
    }
  }

  /// Store data in cache with TTL (Time To Live)
  /// [key] - unique identifier for the cached data
  /// [data] - data to cache (will be JSON encoded)
  /// [ttl] - time to live duration
  /// [memoryOnly] - if true, only store in memory cache (for frequently accessed data)
  Future<void> set(String key, dynamic data, Duration ttl, {bool memoryOnly = false}) async {
    try {
      final expiresAt = DateTime.now().add(ttl);
      final cacheItem = _CacheItem(
        data: data,
        expiresAt: expiresAt,
        createdAt: DateTime.now(),
        accessCount: 0,
      );

      // Always store in memory for fast access
      _memoryCache[key] = cacheItem;

      // Manage memory cache size
      if (_memoryCache.length > _maxMemoryCacheSize) {
        _evictLeastUsedFromMemory();
      }

      // Store on disk unless memoryOnly is true
      if (!memoryOnly) {
        await _setDiskCache(key, cacheItem);
      }

      customPrint('💾 Cached $key (TTL: ${ttl.inMinutes}min, Memory: ${memoryOnly ? "only" : "yes"}, Disk: ${memoryOnly ? "no" : "yes"})');
    } catch (e) {
      customPrint('❌ Failed to cache $key: $e');
    }
  }

  /// Retrieve data from cache
  /// Returns null if not found or expired
  Future<T?> get<T>(String key) async {
    try {
      // Check memory cache first (fastest)
      if (_memoryCache.containsKey(key)) {
        final item = _memoryCache[key]!;
        if (!item.isExpired) {
          item.accessCount++;
          item.lastAccessedAt = DateTime.now();
          _memoryHits++;
          customPrint('🎯 Memory cache hit for $key');
          return item.data as T?;
        } else {
          // Remove expired item from memory
          _memoryCache.remove(key);
        }
      }

      // Check disk cache (slower but persistent)
      final diskItem = await _getDiskCache(key);
      if (diskItem != null && !diskItem.isExpired) {
        // Move back to memory cache for future fast access
        _memoryCache[key] = diskItem;
        diskItem.accessCount++;
        diskItem.lastAccessedAt = DateTime.now();
        _diskHits++;
        customPrint('💿 Disk cache hit for $key');
        return diskItem.data as T?;
      }

      _misses++;
      customPrint('❌ Cache miss for $key');
      return null;
    } catch (e) {
      customPrint('❌ Failed to get cache $key: $e');
      return null;
    }
  }

  /// Get stale data (expired but still available)
  /// Useful as fallback when API calls fail
  Future<T?> getStale<T>(String key) async {
    try {
      // Check memory first
      if (_memoryCache.containsKey(key)) {
        final item = _memoryCache[key]!;
        customPrint('⚠️ Using stale memory cache for $key');
        return item.data as T?;
      }

      // Check disk
      final diskItem = await _getDiskCache(key);
      if (diskItem != null) {
        customPrint('⚠️ Using stale disk cache for $key');
        return diskItem.data as T?;
      }

      return null;
    } catch (e) {
      customPrint('❌ Failed to get stale cache $key: $e');
      return null;
    }
  }

  /// Check if cached data exists and is not expired
  Future<bool> has(String key) async {
    final data = await get(key);
    return data != null;
  }

  /// Check if cached data is expired
  Future<bool> isExpired(String key) async {
    try {
      // Check memory first
      if (_memoryCache.containsKey(key)) {
        return _memoryCache[key]!.isExpired;
      }

      // Check disk
      final diskItem = await _getDiskCache(key);
      if (diskItem != null) {
        return diskItem.isExpired;
      }

      return true; // Not found = considered expired
    } catch (e) {
      return true;
    }
  }

  /// Remove specific cached item
  Future<void> remove(String key) async {
    try {
      _memoryCache.remove(key);
      await _removeDiskCache(key);
      customPrint('🗑️ Removed cache for $key');
    } catch (e) {
      customPrint('❌ Failed to remove cache $key: $e');
    }
  }

  /// Clear all cached data
  Future<void> clear() async {
    try {
      _memoryCache.clear();
      await _clearDiskCache();
      customPrint('🧹 Cleared all cache');
    } catch (e) {
      customPrint('❌ Failed to clear cache: $e');
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getStats() {
    final totalRequests = _memoryHits + _diskHits + _misses;
    final hitRate = totalRequests > 0 ? ((_memoryHits + _diskHits) / totalRequests * 100) : 0;

    return {
      'memoryHits': _memoryHits,
      'diskHits': _diskHits,
      'misses': _misses,
      'hitRate': hitRate.toStringAsFixed(1),
      'memoryCacheSize': _memoryCache.length,
      'memoryCacheMaxSize': _maxMemoryCacheSize,
    };
  }

  /// Store data on disk
  Future<void> _setDiskCache(String key, _CacheItem item) async {
    try {
      final file = await _getCacheFile(key);
      final cacheData = {
        'data': item.data,
        'expiresAt': item.expiresAt.millisecondsSinceEpoch,
        'createdAt': item.createdAt.millisecondsSinceEpoch,
        'accessCount': item.accessCount,
      };
      await file.writeAsString(json.encode(cacheData));
    } catch (e) {
      customPrint('❌ Failed to write disk cache for $key: $e');
    }
  }

  /// Retrieve data from disk
  Future<_CacheItem?> _getDiskCache(String key) async {
    try {
      final file = await _getCacheFile(key);
      if (!await file.exists()) return null;

      final content = await file.readAsString();
      final cacheData = json.decode(content);

      return _CacheItem(
        data: cacheData['data'],
        expiresAt: DateTime.fromMillisecondsSinceEpoch(cacheData['expiresAt']),
        createdAt: DateTime.fromMillisecondsSinceEpoch(cacheData['createdAt']),
        accessCount: cacheData['accessCount'] ?? 0,
      );
    } catch (e) {
      customPrint('❌ Failed to read disk cache for $key: $e');
      return null;
    }
  }

  /// Remove data from disk
  Future<void> _removeDiskCache(String key) async {
    try {
      final file = await _getCacheFile(key);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      customPrint('❌ Failed to remove disk cache for $key: $e');
    }
  }

  /// Clear all disk cache
  Future<void> _clearDiskCache() async {
    try {
      final directory = await _getCacheDirectory();
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    } catch (e) {
      customPrint('❌ Failed to clear disk cache: $e');
    }
  }

  /// Get cache file for a specific key
  Future<File> _getCacheFile(String key) async {
    final directory = await _getCacheDirectory();
    final safeKey = _sanitizeKey(key);
    return File('${directory.path}/$safeKey.json');
  }

  /// Get cache directory
  Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/$_cacheDir');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  /// Sanitize cache key for safe file naming
  String _sanitizeKey(String key) {
    return key.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  }

  /// Evict least recently used items from memory cache
  void _evictLeastUsedFromMemory() {
    if (_memoryCache.isEmpty) return;

    // Sort by last accessed time and remove the oldest
    final sortedEntries = _memoryCache.entries.toList()
      ..sort((a, b) => (a.value.lastAccessedAt ?? a.value.createdAt)
          .compareTo(b.value.lastAccessedAt ?? b.value.createdAt));

    // Remove oldest 20% of items
    final itemsToRemove = (sortedEntries.length * 0.2).ceil();
    for (int i = 0; i < itemsToRemove && i < sortedEntries.length; i++) {
      _memoryCache.remove(sortedEntries[i].key);
    }

    customPrint('🧹 Evicted $itemsToRemove items from memory cache');
  }

  /// Clean up expired cache items
  Future<void> _cleanupExpiredCache() async {
    try {
      // Clean memory cache
      final expiredMemoryKeys = _memoryCache.entries
          .where((entry) => entry.value.isExpired)
          .map((entry) => entry.key)
          .toList();

      for (final key in expiredMemoryKeys) {
        _memoryCache.remove(key);
      }

      // Clean disk cache
      final directory = await _getCacheDirectory();
      if (await directory.exists()) {
        final files = directory.listSync().whereType<File>();
        int deletedCount = 0;

        for (final file in files) {
          try {
            final content = await file.readAsString();
            final cacheData = json.decode(content);
            final expiresAt = DateTime.fromMillisecondsSinceEpoch(cacheData['expiresAt']);

            if (DateTime.now().isAfter(expiresAt)) {
              await file.delete();
              deletedCount++;
            }
          } catch (e) {
            // If we can't read the file, delete it
            await file.delete();
            deletedCount++;
          }
        }

        if (deletedCount > 0) {
          customPrint('🧹 Cleaned up $deletedCount expired cache files');
        }
      }
    } catch (e) {
      customPrint('❌ Failed to cleanup expired cache: $e');
    }
  }

  /// Start background cleanup timer
  void _startBackgroundCleanup() {
    Timer.periodic(Duration(hours: 1), (timer) async {
      await _cleanupExpiredCache();
    });
  }

  /// Get cache size information
  Future<Map<String, dynamic>> getCacheSize() async {
    try {
      final directory = await _getCacheDirectory();
      int fileCount = 0;
      int totalSize = 0;

      if (await directory.exists()) {
        final files = directory.listSync().whereType<File>();
        fileCount = files.length;
        
        for (final file in files) {
          totalSize += await file.length();
        }
      }

      return {
        'memoryItems': _memoryCache.length,
        'diskFiles': fileCount,
        'diskSizeBytes': totalSize,
        'diskSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Preload frequently used cache into memory
  Future<void> preloadFrequentCache() async {
    try {
      final directory = await _getCacheDirectory();
      if (!await directory.exists()) return;

      final files = directory.listSync().whereType<File>();
      final cacheItems = <String, _CacheItem>{};

      // Load all cache items and check access count
      for (final file in files) {
        try {
          final key = file.path.split('/').last.replaceAll('.json', '');
          final item = await _getDiskCache(key);
          if (item != null && !item.isExpired) {
            cacheItems[key] = item;
          }
        } catch (e) {
          // Skip corrupted files
        }
      }

      // Sort by access count and load top items into memory
      final sortedItems = cacheItems.entries.toList()
        ..sort((a, b) => b.value.accessCount.compareTo(a.value.accessCount));

      final itemsToPreload = sortedItems.take(_maxMemoryCacheSize ~/ 2);
      for (final entry in itemsToPreload) {
        _memoryCache[entry.key] = entry.value;
      }

      customPrint('🚀 Preloaded ${itemsToPreload.length} frequently used cache items');
    } catch (e) {
      customPrint('❌ Failed to preload cache: $e');
    }
  }
}

/// Internal cache item representation
class _CacheItem {
  final dynamic data;
  final DateTime expiresAt;
  final DateTime createdAt;
  int accessCount;
  DateTime? lastAccessedAt;

  _CacheItem({
    required this.data,
    required this.expiresAt,
    required this.createdAt,
    this.accessCount = 0,
    this.lastAccessedAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
} 