import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_apis_flutter/core/storage/hive_init.dart';
import 'package:google_apis_flutter/core/utils/logger/logger.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart' as uuid_pkg;

/// Queue of pending mutations that need to be flushed to the network when
/// connectivity returns.
///
/// Each entry is opaque JSON; the feature-specific handler interprets it
/// and performs the network call. The queue itself is feature-agnostic.
class SyncQueue {
  SyncQueue({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  final Map<String, _Handler> _handlers = <String, _Handler>{};
  StreamSubscription<List<ConnectivityResult>>? _connSub;

  Box<String> get _box => outboxBox();

  /// Register a handler for a [feature]. The handler is invoked when the
  /// queue flushes; if it throws, the entry stays in the queue and is
  /// retried later.
  void register(String feature, _Handler handler) {
    _handlers[feature] = handler;
  }

  Future<String> enqueue({
    required String feature,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    final id = const _UuidWrapper().v4();
    final entry = _Entry(
      id: id,
      feature: feature,
      operation: operation,
      payload: payload,
      createdAt: DateTime.now().toUtc(),
    );
    await _box.put(id, jsonEncode(entry.toJson()));
    appLog.t('SyncQueue: enqueued $feature/$operation ($id)');
    unawaited(tryFlush());
    return id;
  }

  Future<void> tryFlush() async {
    final conn = await _connectivity.checkConnectivity();
    if (conn.every((r) => r == ConnectivityResult.none)) {
      return;
    }
    final keys = _box.keys.cast<String>().toList();
    for (final key in keys) {
      final raw = _box.get(key);
      if (raw == null) continue;
      final entry =
          _Entry.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      final handler = _handlers[entry.feature];
      if (handler == null) {
        appLog.w('SyncQueue: no handler for ${entry.feature} — skipping');
        continue;
      }
      try {
        await handler(entry.operation, entry.payload);
        await _box.delete(key);
      } catch (e, st) {
        appLog.w(
          'SyncQueue: flush failed for ${entry.feature}/${entry.operation} — will retry',
          error: e,
          stackTrace: st,
        );
        // entry stays in the queue
      }
    }
  }

  /// Start watching connectivity changes and auto-flush when we come back online.
  void start() {
    _connSub ??= _connectivity.onConnectivityChanged.listen(
      (results) {
        if (results.any((r) => r != ConnectivityResult.none)) {
          unawaited(tryFlush());
        }
      },
    );
  }

  Future<void> stop() async {
    await _connSub?.cancel();
    _connSub = null;
  }

  int get pendingCount => _box.length;

  List<_Entry> get pending => _box.values
      .map((raw) => _Entry.fromJson(jsonDecode(raw) as Map<String, dynamic>))
      .toList(growable: false);
}

typedef _Handler = Future<void> Function(
  String operation,
  Map<String, dynamic> payload,
);

class _Entry {
  _Entry({
    required this.id,
    required this.feature,
    required this.operation,
    required this.payload,
    required this.createdAt,
  });

  factory _Entry.fromJson(Map<String, dynamic> json) {
    return _Entry(
      id: json['id'] as String,
      feature: json['feature'] as String,
      operation: json['operation'] as String,
      payload: json['payload'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final String id;
  final String feature;
  final String operation;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'feature': feature,
        'operation': operation,
        'payload': payload,
        'created_at': createdAt.toIso8601String(),
      };
}

/// Simple UUID generator — avoids adding the `uuid` dependency if it's not
/// already present.
class _UuidWrapper {
  const _UuidWrapper();
  String v4() {
    try {
      return const uuid_pkg.Uuid().v4();
    } catch (_) {
      return DateTime.now().microsecondsSinceEpoch.toString();
    }
  }
}

final Provider<SyncQueue> syncQueueProvider = Provider<SyncQueue>((Ref ref) {
  final queue = SyncQueue()..start();
  ref.onDispose(() => unawaited(queue.stop()));
  return queue;
});
