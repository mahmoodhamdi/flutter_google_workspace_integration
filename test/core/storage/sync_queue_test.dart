import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_apis_flutter/core/storage/sync_queue.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _MockConnectivity extends Mock implements Connectivity {}

class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.tempDir);
  final String tempDir;
  @override
  Future<String?> getApplicationDocumentsPath() async => tempDir;
  @override
  Future<String?> getTemporaryPath() async => tempDir;
  @override
  Future<String?> getApplicationSupportPath() async => tempDir;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final tmp = Directory.systemTemp.createTempSync('hive_test_').path;
    PathProviderPlatform.instance = _FakePathProvider(tmp);
    Hive.init(tmp);
    await Hive.openBox<String>('app.queue.outbox');
  });

  setUp(() async {
    await Hive.box<String>('app.queue.outbox').clear();
  });

  group('SyncQueue', () {
    test('enqueue then handler runs on flush', () async {
      final conn = _MockConnectivity();
      when(() => conn.checkConnectivity())
          .thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.wifi]);
      when(() => conn.onConnectivityChanged).thenAnswer(
        (_) => const Stream<List<ConnectivityResult>>.empty(),
      );

      final queue = SyncQueue(connectivity: conn);
      final ranOps = <String>[];
      queue.register('calendar', (op, payload) async {
        ranOps.add('$op:${payload['id']}');
      });
      await queue.enqueue(
        feature: 'calendar',
        operation: 'create',
        payload: <String, dynamic>{'id': 'evt-1'},
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(ranOps, <String>['create:evt-1']);
      expect(queue.pendingCount, 0);
    });

    test('entry persists when handler throws and is retried later', () async {
      final conn = _MockConnectivity();
      when(() => conn.checkConnectivity())
          .thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.wifi]);
      when(() => conn.onConnectivityChanged).thenAnswer(
        (_) => const Stream<List<ConnectivityResult>>.empty(),
      );

      final queue = SyncQueue(connectivity: conn);
      int attempts = 0;
      queue.register('drive', (op, payload) async {
        attempts++;
        if (attempts < 2) throw Exception('boom');
      });
      await queue.enqueue(
        feature: 'drive',
        operation: 'upload',
        payload: <String, dynamic>{'name': 'a.pdf'},
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(queue.pendingCount, 1);
      await queue.tryFlush();
      expect(queue.pendingCount, 0);
      expect(attempts, 2);
    });

    test('offline state means no flush', () async {
      final conn = _MockConnectivity();
      when(() => conn.checkConnectivity())
          .thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.none]);
      when(() => conn.onConnectivityChanged).thenAnswer(
        (_) => const Stream<List<ConnectivityResult>>.empty(),
      );
      final queue = SyncQueue(connectivity: conn);
      int ran = 0;
      queue.register('contacts', (op, payload) async {
        ran++;
      });
      await queue.enqueue(
        feature: 'contacts',
        operation: 'create',
        payload: <String, dynamic>{},
      );
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(ran, 0);
      expect(queue.pendingCount, 1);
    });
  });
}
