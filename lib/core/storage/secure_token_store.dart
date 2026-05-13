import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_apis_flutter/core/utils/logger/logger.dart';

/// Stores OAuth tokens and other secrets using platform-native keystores.
///
/// - Android: AES encryption backed by Android Keystore.
/// - iOS / macOS: Keychain.
/// - Web / Linux / Windows: file-based with encryption (less robust;
///   acceptable for desktop because the OS user account is the trust boundary).
class SecureTokenStore {
  SecureTokenStore(this._storage);

  final FlutterSecureStorage _storage;

  static const AndroidOptions _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
    resetOnError: true,
  );
  static const IOSOptions _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  factory SecureTokenStore.create() {
    return SecureTokenStore(
      const FlutterSecureStorage(
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      ),
    );
  }

  // Single-account legacy keys
  static const String _kAccessToken = 'gws.access_token';
  static const String _kRefreshToken = 'gws.refresh_token';
  static const String _kIdToken = 'gws.id_token';
  static const String _kExpiry = 'gws.expiry_iso';

  // Multi-account index
  static const String _kAccountsIndex = 'gws.accounts.index';

  String _accountKey(String accountId, String field) =>
      'gws.account.$accountId.$field';

  Future<void> writeAccountTokens({
    required String accountId,
    required AccountTokens tokens,
  }) async {
    await _storage.write(
      key: _accountKey(accountId, 'tokens'),
      value: jsonEncode(tokens.toJson()),
    );
    await _appendToIndex(accountId);
    appLog.t('SecureTokenStore: stored tokens for ${redactEmail(accountId)}');
  }

  Future<AccountTokens?> readAccountTokens(String accountId) async {
    final raw = await _storage.read(key: _accountKey(accountId, 'tokens'));
    if (raw == null) {
      return null;
    }
    try {
      return AccountTokens.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e, st) {
      appLog.w('SecureTokenStore: corrupted token blob — purging', error: e, stackTrace: st);
      await deleteAccount(accountId);
      return null;
    }
  }

  Future<List<String>> listAccountIds() async {
    final raw = await _storage.read(key: _kAccountsIndex);
    if (raw == null) {
      return <String>[];
    }
    final list = (jsonDecode(raw) as List<dynamic>).cast<String>();
    return list;
  }

  Future<void> deleteAccount(String accountId) async {
    await _storage.delete(key: _accountKey(accountId, 'tokens'));
    final ids = await listAccountIds();
    ids.remove(accountId);
    await _storage.write(key: _kAccountsIndex, value: jsonEncode(ids));
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
    appLog.w('SecureTokenStore: cleared all stored secrets');
  }

  Future<void> _appendToIndex(String accountId) async {
    final ids = await listAccountIds();
    if (!ids.contains(accountId)) {
      ids.add(accountId);
      await _storage.write(key: _kAccountsIndex, value: jsonEncode(ids));
    }
  }

  // --- Legacy single-account compatibility (rarely used) ---

  Future<void> writeSingle({
    required String accessToken,
    String? refreshToken,
    String? idToken,
    required DateTime expiry,
  }) async {
    await _storage.write(key: _kAccessToken, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _kRefreshToken, value: refreshToken);
    }
    if (idToken != null) {
      await _storage.write(key: _kIdToken, value: idToken);
    }
    await _storage.write(key: _kExpiry, value: expiry.toIso8601String());
  }

  Future<String?> readAccessToken() => _storage.read(key: _kAccessToken);
  Future<String?> readRefreshToken() => _storage.read(key: _kRefreshToken);
  Future<String?> readIdToken() => _storage.read(key: _kIdToken);

  Future<DateTime?> readExpiry() async {
    final iso = await _storage.read(key: _kExpiry);
    return iso == null ? null : DateTime.tryParse(iso);
  }
}

/// Tokens for a single Google account.
class AccountTokens {
  const AccountTokens({
    required this.email,
    required this.accessToken,
    required this.expiry,
    this.refreshToken,
    this.idToken,
    this.scopes = const <String>[],
    this.displayName,
    this.photoUrl,
  });

  factory AccountTokens.fromJson(Map<String, dynamic> json) {
    return AccountTokens(
      email: json['email'] as String,
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      idToken: json['id_token'] as String?,
      expiry: DateTime.parse(json['expiry'] as String),
      scopes: (json['scopes'] as List<dynamic>?)?.cast<String>() ??
          const <String>[],
      displayName: json['display_name'] as String?,
      photoUrl: json['photo_url'] as String?,
    );
  }

  final String email;
  final String accessToken;
  final String? refreshToken;
  final String? idToken;
  final DateTime expiry;
  final List<String> scopes;
  final String? displayName;
  final String? photoUrl;

  /// True if the token has expired or is within 60 seconds of expiry.
  bool get isExpired =>
      DateTime.now().add(const Duration(seconds: 60)).isAfter(expiry);

  bool get isValid => accessToken.isNotEmpty && !isExpired;

  AccountTokens copyWith({
    String? email,
    String? accessToken,
    String? refreshToken,
    String? idToken,
    DateTime? expiry,
    List<String>? scopes,
    String? displayName,
    String? photoUrl,
  }) {
    return AccountTokens(
      email: email ?? this.email,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      idToken: idToken ?? this.idToken,
      expiry: expiry ?? this.expiry,
      scopes: scopes ?? this.scopes,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'email': email,
        'access_token': accessToken,
        if (refreshToken != null) 'refresh_token': refreshToken,
        if (idToken != null) 'id_token': idToken,
        'expiry': expiry.toIso8601String(),
        'scopes': scopes,
        if (displayName != null) 'display_name': displayName,
        if (photoUrl != null) 'photo_url': photoUrl,
      };
}

/// Riverpod provider for the secure store.
final Provider<SecureTokenStore> secureTokenStoreProvider =
    Provider<SecureTokenStore>(
  (Ref ref) => SecureTokenStore.create(),
  name: 'secureTokenStoreProvider',
);
