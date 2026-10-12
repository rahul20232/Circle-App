// lib/services/core/api_cache.dart
class CacheEntry {
  final dynamic data;
  final DateTime timestamp;

  CacheEntry(this.data, this.timestamp);
}

class ApiCache {
  static final Map<String, CacheEntry> _cache = {};

  /// Check if cached data is still valid
  static bool isValid(String key, Duration maxAge) {
    final entry = _cache[key];
    if (entry == null) return false;
    return DateTime.now().difference(entry.timestamp) < maxAge;
  }

  /// Get cached data if valid
  static T? get<T>(String key, Duration maxAge) {
    if (!isValid(key, maxAge)) return null;
    return _cache[key]?.data as T?;
  }

  /// Store data in cache
  static void set(String key, dynamic data) {
    _cache[key] = CacheEntry(data, DateTime.now());
  }

  /// Clear specific cache entry
  static void clear(String key) {
    _cache.remove(key);
  }

  /// Clear all cache
  static void clearAll() {
    _cache.clear();
  }

  /// Get cache info (for debugging)
  static Map<String, String> getCacheInfo() {
    return _cache.map((key, value) => MapEntry(key,
        'Cached ${DateTime.now().difference(value.timestamp).inSeconds}s ago'));
  }
}
