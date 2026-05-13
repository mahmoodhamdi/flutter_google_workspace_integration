import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_apis_flutter/core/errors/app_error.dart';
import 'package:google_apis_flutter/core/errors/error_mapper.dart';
import 'package:google_apis_flutter/core/storage/secure_token_store.dart';
import 'package:google_apis_flutter/core/utils/constants/api_constants.dart';
import 'package:google_apis_flutter/core/utils/logger/logger.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as gauth;

/// Thin wrapper around `google_sign_in` + the `extension_google_sign_in_as_googleapis_auth`
/// adapter. Yields [AccountTokens] suitable for [SecureTokenStore].
class GoogleSignInService {
  GoogleSignInService({
    GoogleSignIn? googleSignIn,
  }) : _signIn = googleSignIn ??
            GoogleSignIn(
              scopes: <String>[...ApiConstants.baselineScopes],
            );

  final GoogleSignIn _signIn;

  /// Interactive sign-in. Returns null if user cancelled.
  Future<AccountTokens?> signIn({
    required List<String> scopes,
    String? hint,
  }) async {
    final union = <String>{...ApiConstants.baselineScopes, ...scopes}.toList();
    final signIn = GoogleSignIn(scopes: union, hostedDomain: null);
    final GoogleSignInAccount? account = await signIn.signIn();
    if (account == null) {
      appLog.i('GoogleSignInService: user cancelled');
      return null;
    }
    return _resolveTokens(account, union);
  }

  /// Silent sign-in (uses cached credentials). Returns null if nothing cached.
  Future<AccountTokens?> signInSilently({
    required List<String> scopes,
  }) async {
    final union = <String>{...ApiConstants.baselineScopes, ...scopes}.toList();
    final signIn = GoogleSignIn(scopes: union);
    final GoogleSignInAccount? account = await signIn.signInSilently();
    if (account == null) {
      return null;
    }
    return _resolveTokens(account, union);
  }

  /// Request additional scopes for a currently-signed-in account. May open
  /// the consent UI for the new scopes only.
  Future<AccountTokens?> requestScopes({
    required GoogleSignInAccount account,
    required List<String> scopes,
  }) async {
    final granted = await _signIn.requestScopes(scopes);
    if (!granted) {
      throw const AppError.forbidden(
        message: 'User declined to grant additional scopes',
      );
    }
    return _resolveTokens(account, scopes);
  }

  Future<void> signOut() => _signIn.signOut();
  Future<void> disconnect() => _signIn.disconnect();

  GoogleSignIn get rawClient => _signIn;

  Future<AccountTokens> _resolveTokens(
    GoogleSignInAccount account,
    List<String> requestedScopes,
  ) async {
    try {
      final auth = await account.authentication;
      final accessToken = auth.accessToken;
      if (accessToken == null) {
        throw const AppError.unauthorized(message: 'No access token returned');
      }
      // The token usually expires in 3600s; we use a defensive 50min.
      final expiry = DateTime.now().add(const Duration(minutes: 50));
      return AccountTokens(
        email: account.email,
        accessToken: accessToken,
        idToken: auth.idToken,
        expiry: expiry,
        scopes: requestedScopes,
        displayName: account.displayName,
        photoUrl: account.photoUrl,
      );
    } catch (e, st) {
      throw mapError(e, st);
    }
  }

  /// Produce a googleapis-compatible auth client for the given account.
  /// Used by the `googleapis` package datasources.
  Future<gauth.AuthClient?> authClient({
    required List<String> scopes,
  }) async {
    return _signIn.authenticatedClient();
  }
}
