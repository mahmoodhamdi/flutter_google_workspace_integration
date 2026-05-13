import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_apis_flutter/core/storage/secure_token_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock the FlutterSecureStorage method channel — its plugin is unavailable
  // in unit tests. We back the channel with an in-memory map.
  final Map<String, String> storage = <String, String>{};
  const MethodChannel channel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'write':
          storage[call.arguments['key'] as String] =
              call.arguments['value'] as String;
          return null;
        case 'read':
          return storage[call.arguments['key']];
        case 'readAll':
          return Map<String, String>.from(storage);
        case 'delete':
          storage.remove(call.arguments['key']);
          return null;
        case 'deleteAll':
          storage.clear();
          return null;
        case 'containsKey':
          return storage.containsKey(call.arguments['key']);
      }
      return null;
    });
  });

  setUp(() {
    storage.clear();
  });

  group('SecureTokenStore.AccountTokens', () {
    test('isValid true within expiry window', () {
      final tokens = AccountTokens(
        email: 'a@example.com',
        accessToken: 'token',
        expiry: DateTime.now().add(const Duration(minutes: 30)),
      );
      expect(tokens.isValid, true);
      expect(tokens.isExpired, false);
    });

    test('isExpired when within 60s of expiry', () {
      final tokens = AccountTokens(
        email: 'a@example.com',
        accessToken: 't',
        expiry: DateTime.now().add(const Duration(seconds: 30)),
      );
      expect(tokens.isExpired, true);
    });

    test('isExpired when past expiry', () {
      final tokens = AccountTokens(
        email: 'a@example.com',
        accessToken: 't',
        expiry: DateTime.now().subtract(const Duration(minutes: 5)),
      );
      expect(tokens.isExpired, true);
    });

    test('copyWith updates fields', () {
      final tokens = AccountTokens(
        email: 'a@example.com',
        accessToken: 't',
        expiry: DateTime.now(),
      );
      final updated = tokens.copyWith(accessToken: 't2');
      expect(updated.accessToken, 't2');
      expect(updated.email, tokens.email);
    });

    test('toJson roundtrips through fromJson', () {
      final now = DateTime.now();
      final tokens = AccountTokens(
        email: 'a@example.com',
        accessToken: 'access',
        refreshToken: 'r',
        idToken: 'id',
        expiry: now,
        scopes: const <String>['scope1', 'scope2'],
        displayName: 'A',
        photoUrl: 'http://example.com/p.png',
      );
      final j = tokens.toJson();
      final back = AccountTokens.fromJson(j);
      expect(back.email, tokens.email);
      expect(back.accessToken, tokens.accessToken);
      expect(back.refreshToken, tokens.refreshToken);
      expect(back.scopes, tokens.scopes);
    });
  });

  group('SecureTokenStore CRUD', () {
    test('writeAccountTokens persists and readAccountTokens retrieves', () async {
      final store = SecureTokenStore.create();
      final tokens = AccountTokens(
        email: 'b@example.com',
        accessToken: 'tok',
        expiry: DateTime.now().add(const Duration(hours: 1)),
      );
      await store.writeAccountTokens(accountId: tokens.email, tokens: tokens);
      final read = await store.readAccountTokens(tokens.email);
      expect(read, isNotNull);
      expect(read!.email, tokens.email);
      expect(read.accessToken, tokens.accessToken);
    });

    test('listAccountIds returns inserted ids', () async {
      final store = SecureTokenStore.create();
      for (final email in <String>['x@example.com', 'y@example.com']) {
        await store.writeAccountTokens(
          accountId: email,
          tokens: AccountTokens(
            email: email,
            accessToken: 't',
            expiry: DateTime.now().add(const Duration(hours: 1)),
          ),
        );
      }
      final ids = await store.listAccountIds();
      expect(ids.length, 2);
      expect(ids, containsAll(<String>['x@example.com', 'y@example.com']));
    });

    test('deleteAccount removes tokens and index entry', () async {
      final store = SecureTokenStore.create();
      await store.writeAccountTokens(
        accountId: 'z@example.com',
        tokens: AccountTokens(
          email: 'z@example.com',
          accessToken: 't',
          expiry: DateTime.now().add(const Duration(hours: 1)),
        ),
      );
      await store.deleteAccount('z@example.com');
      final ids = await store.listAccountIds();
      expect(ids, isEmpty);
      expect(await store.readAccountTokens('z@example.com'), null);
    });

    test('clearAll wipes everything', () async {
      final store = SecureTokenStore.create();
      await store.writeAccountTokens(
        accountId: 'a@b.com',
        tokens: AccountTokens(
          email: 'a@b.com',
          accessToken: 't',
          expiry: DateTime.now().add(const Duration(hours: 1)),
        ),
      );
      await store.clearAll();
      expect(await store.listAccountIds(), isEmpty);
    });

    test('readAccountTokens returns null for corrupted blob', () async {
      // Manually inject garbage into the storage so the read path can
      // exercise its catch branch.
      storage['gws.account.corrupt@example.com.tokens'] = '{not-json}';
      storage['gws.accounts.index'] = '["corrupt@example.com"]';
      final store = SecureTokenStore.create();
      final read = await store.readAccountTokens('corrupt@example.com');
      expect(read, null);
    });
  });
}
