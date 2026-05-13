import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_apis_flutter/core/auth/domain/entities/account.dart';

/// Wraps Firebase Auth — used solely for email/password fallback. Buyers who
/// want pure Google-only sign-in can simply not call these methods (the
/// Firebase SDK still must be present in pubspec).
class FirebaseAuthService {
  FirebaseAuthService([FirebaseAuth? auth]) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<Account> signIn({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return _accountOf(cred.user!);
  }

  Future<Account> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    if (displayName != null && displayName.isNotEmpty) {
      await cred.user!.updateDisplayName(displayName);
    }
    await cred.user!.sendEmailVerification();
    return _accountOf(cred.user!);
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  Future<void> signOut() => _auth.signOut();

  Account _accountOf(User u) => Account(
        id: u.email ?? u.uid,
        email: u.email ?? '',
        displayName: u.displayName,
        photoUrl: u.photoURL,
        grantedScopes: const <String>[],
        isActive: true,
        lastUsed: DateTime.now(),
      );
}
