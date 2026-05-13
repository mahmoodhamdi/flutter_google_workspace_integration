import 'dart:async';
import 'dart:convert';

import 'package:hive/hive.dart';

/// Cache-first read pattern: emits cached value first (if present), then
/// kicks off a network fetch and emits the fresh value when it completes.
///
/// Repositories use this to give the UI an "instant" first paint with
/// stale data, then update to fresh data when available.
class CachedRead<T> {
  CachedRead({
    required this.box,
    required this.key,
    required this.fetcher,
    required this.parser,
    required this.serializer,
    this.staleness = const Duration(minutes: 5),
  });

  final Box<String> box;
  final String key;
  final Future<T> Function() fetcher;
  final T Function(Map<String, dynamic>) parser;
  final Map<String, dynamic> Function(T) serializer;
  final Duration staleness;

  Stream<T> stream() async* {
    final cached = _readCache();
    if (cached != null) yield cached.$1;
    final isFresh = cached != null &&
        DateTime.now().difference(cached.$2) < staleness;
    if (!isFresh) {
      final fresh = await fetcher();
      await _writeCache(fresh);
      yield fresh;
    }
  }

  Future<T> fetch({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _readCache();
      if (cached != null &&
          DateTime.now().difference(cached.$2) < staleness) {
        return cached.$1;
      }
    }
    final fresh = await fetcher();
    await _writeCache(fresh);
    return fresh;
  }

  (T, DateTime)? _readCache() {
    final raw = box.get(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final cachedAt = DateTime.parse(decoded['_cached_at'] as String);
      final value = parser(decoded['value'] as Map<String, dynamic>);
      return (value, cachedAt);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(T value) async {
    await box.put(
      key,
      jsonEncode(<String, dynamic>{
        '_cached_at': DateTime.now().toIso8601String(),
        'value': serializer(value),
      }),
    );
  }

  Future<void> invalidate() async {
    await box.delete(key);
  }
}
