import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:google_apis_flutter/core/auth/data/firebase_auth_service.dart';
import 'package:google_apis_flutter/core/auth/data/google_sign_in_service.dart';
import 'package:google_apis_flutter/core/auth/domain/entities/account.dart';
import 'package:google_apis_flutter/core/auth/domain/repositories/auth_repository.dart';
import 'package:google_apis_flutter/core/auth/domain/token_provider.dart';
import 'package:google_apis_flutter/core/errors/app_error.dart';
import 'package:google_apis_flutter/core/errors/guard.dart';
import 'package:google_apis_flutter/core/errors/result.dart';
import 'package:google_apis_flutter/core/storage/secure_token_store.dart';
import 'package:google_apis_flutter/core/utils/logger/logger.dart';

class AuthRepositoryImpl implements AuthRepository, TokenProvider {
  AuthRepositoryImpl({
    required GoogleSignInService google,
    required FirebaseAuthService firebase,
    required SecureTokenStore store,
  })  : _google = google,
        _firebase = firebase,
        _store = store {
    // Hydrate on construction.
    unawaited(_rehydrate());
  }

  final GoogleSignInService _google;
  final FirebaseAuthService _firebase;
  final SecureTokenStore _store;

  final StreamController<Account?> _activeCtrl =
      StreamController<Account?>.broadcast();
  final StreamController<List<Account>> _accountsCtrl =
      StreamController<List<Account>>.broadcast();

  String? _activeId;
  final Map<String, Account> _accounts = <String, Account>{};

  @override
  String? get activeAccountId => _activeId;

  @override
  Stream<Account?> watchActiveAccount() => _activeCtrl.stream;

  @override
  Stream<List<Account>> watchAccounts() => _accountsCtrl.stream;

  Future<void> _rehydrate() async {
    try {
      final ids = await _store.listAccountIds();
      for (final id in ids) {
        final t = await _store.readAccountTokens(id);
        if (t != null) {
          _accounts[id] = Account(
            id: id,
            email: t.email,
            displayName: t.displayName,
            photoUrl: t.photoUrl,
            grantedScopes: t.scopes,
            isActive: false,
          );
        }
      }
      // Try to silent-sign-in the most-recent account.
      final lastKnown = _accounts.keys.firstOrNull;
      if (lastKnown != null) {
        _activeId = lastKnown;
        _accounts[lastKnown] = _accounts[lastKnown]!.copyWith(isActive: true);
      }
      _emit();
    } catch (e, st) {
      appLog.w('Auth rehydrate failed', error: e, stackTrace: st);
    }
  }

  void _emit() {
    _accountsCtrl.add(_accounts.values.toList(growable: false));
    _activeCtrl.add(_activeId == null ? null : _accounts[_activeId]);
  }

  @override
  Future<Result<Account>> signInWithGoogle({
    required List<String> scopes,
    String? hint,
  }) =>
      guard<Account>(() async {
        final tokens = await _google.signIn(scopes: scopes, hint: hint);
        if (tokens == null) {
          throw const AppError.cancelled(message: 'Sign-in cancelled');
        }
        await _store.writeAccountTokens(
          accountId: tokens.email,
          tokens: tokens,
        );
        final acc = Account(
          id: tokens.email,
          email: tokens.email,
          displayName: tokens.displayName,
          photoUrl: tokens.photoUrl,
          grantedScopes: tokens.scopes,
          isActive: true,
          lastUsed: DateTime.now(),
        );
        _accounts[acc.id] = acc;
        _activeId = acc.id;
        _emit();
        appLog.i('Auth: signed in as ${redactEmail(acc.email)}');
        return acc;
      }, operation: 'signInWithGoogle');

  @override
  Future<Result<Account>> signInWithEmailPassword({
    required String email,
    required String password,
  }) =>
      guard<Account>(() async {
        final acc = await _firebase.signIn(email: email, password: password);
        _accounts[acc.id] = acc;
        _activeId = acc.id;
        _emit();
        return acc;
      }, operation: 'signInWithEmailPassword');

  @override
  Future<Result<Account>> registerWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) =>
      guard<Account>(() async {
        final acc = await _firebase.register(
          email: email,
          password: password,
          displayName: displayName,
        );
        _accounts[acc.id] = acc;
        _activeId = acc.id;
        _emit();
        return acc;
      }, operation: 'registerWithEmailPassword');

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) =>
      guard<void>(() => _firebase.sendPasswordReset(email),
          operation: 'sendPasswordResetEmail');

  @override
  Future<Result<Account>> switchAccount(String accountId) =>
      guard<Account>(() async {
        final existing = _accounts[accountId];
        if (existing == null) {
          throw AppError.notFound(
            message: 'Account not signed in',
            resourceId: accountId,
          );
        }
        _activeId = accountId;
        for (final id in _accounts.keys) {
          _accounts[id] = _accounts[id]!.copyWith(isActive: id == accountId);
        }
        _emit();
        return _accounts[accountId]!;
      }, operation: 'switchAccount');

  @override
  Future<Result<Account>> requestAdditionalScopes(List<String> scopes) =>
      guard<Account>(() async {
        if (_activeId == null) {
          throw const AppError.unauthorized(message: 'No active account');
        }
        final current = _accounts[_activeId];
        if (current == null) {
          throw const AppError.unauthorized(message: 'Active account missing');
        }
        final union = <String>{...current.grantedScopes, ...scopes}.toList();
        final tokens = await _google.signIn(scopes: union);
        if (tokens == null) {
          throw const AppError.forbidden(
            message: 'User declined additional scopes',
          );
        }
        await _store.writeAccountTokens(
          accountId: tokens.email,
          tokens: tokens,
        );
        final updated = current.copyWith(grantedScopes: tokens.scopes);
        _accounts[updated.id] = updated;
        _emit();
        return updated;
      }, operation: 'requestAdditionalScopes');

  @override
  Future<Result<void>> signOutActive() => guard<void>(() async {
        if (_activeId == null) {
          return;
        }
        await _store.deleteAccount(_activeId!);
        _accounts.remove(_activeId);
        await _google.signOut();
        // Fall back to another account if any remain.
        _activeId = _accounts.keys.firstOrNull;
        if (_activeId != null) {
          _accounts[_activeId!] =
              _accounts[_activeId!]!.copyWith(isActive: true);
        }
        _emit();
      }, operation: 'signOutActive');

  @override
  Future<Result<void>> signOutAll() => guard<void>(() async {
        await _google.disconnect();
        await _firebase.signOut();
        await _store.clearAll();
        _accounts.clear();
        _activeId = null;
        _emit();
      }, operation: 'signOutAll');

  @override
  Future<Result<void>> refreshActiveToken({bool force = false}) =>
      guard<void>(() async {
        final id = _activeId;
        if (id == null) {
          throw const AppError.unauthorized(message: 'No active account');
        }
        await refresh(force: force);
      }, operation: 'refreshActiveToken');

  // --- TokenProvider implementation ---

  @override
  Future<String?> getValidAccessToken() async {
    final id = _activeId;
    if (id == null) {
      return null;
    }
    final tokens = await _store.readAccountTokens(id);
    if (tokens == null) {
      return null;
    }
    if (tokens.isValid) {
      return tokens.accessToken;
    }
    return refresh();
  }

  @override
  Future<String?> refresh({bool force = false}) async {
    final id = _activeId;
    if (id == null) {
      return null;
    }
    try {
      final tokens = await _google.signInSilently(
        scopes: _accounts[id]?.grantedScopes ?? const <String>[],
      );
      if (tokens == null) {
        appLog.w('Auth: silent refresh failed for ${redactEmail(id)}');
        return null;
      }
      await _store.writeAccountTokens(accountId: id, tokens: tokens);
      return tokens.accessToken;
    } catch (e, st) {
      appLog.e('Auth: refresh threw', error: e, stackTrace: st);
      return null;
    }
  }

  Future<void> dispose() async {
    await _activeCtrl.close();
    await _accountsCtrl.close();
  }
}
