import 'package:google_apis_flutter/core/auth/domain/entities/account.dart';
import 'package:google_apis_flutter/core/errors/result.dart';

/// Authentication repository — the only contract the presentation layer uses.
///
/// Implementations: `AuthRepositoryImpl` (data layer) wraps Google Sign-In,
/// Firebase Auth, and the secure token store.
abstract class AuthRepository {
  /// Stream of the currently-active account (null when signed out).
  Stream<Account?> watchActiveAccount();

  /// Stream of all signed-in accounts (multi-account).
  Stream<List<Account>> watchAccounts();

  /// Sign in interactively with Google. Requests [scopes] in addition to
  /// the baseline `userinfo.email|profile`.
  Future<Result<Account>> signInWithGoogle({
    required List<String> scopes,
    String? hint,
  });

  /// Sign in with Firebase email/password.
  Future<Result<Account>> signInWithEmailPassword({
    required String email,
    required String password,
  });

  /// Register a new email/password account in Firebase.
  Future<Result<Account>> registerWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  });

  /// Send a password reset email via Firebase.
  Future<Result<void>> sendPasswordResetEmail(String email);

  /// Switch the active account. The new account must already be signed in.
  Future<Result<Account>> switchAccount(String accountId);

  /// Request additional scopes for the active account. May trigger an
  /// interactive consent flow if scopes haven't been granted yet.
  Future<Result<Account>> requestAdditionalScopes(List<String> scopes);

  /// Sign out the active account. If no account is active, no-op.
  Future<Result<void>> signOutActive();

  /// Sign out all accounts.
  Future<Result<void>> signOutAll();

  /// Force-refresh the access token of the active account.
  Future<Result<void>> refreshActiveToken({bool force = false});
}
