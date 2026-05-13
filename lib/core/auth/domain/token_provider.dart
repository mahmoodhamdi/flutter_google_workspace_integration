/// Token provider — abstracts over the auth repository for the network layer.
///
/// The Dio [AuthInterceptor] depends on this rather than on AuthRepository
/// directly to avoid an import cycle (network <-> auth).
abstract class TokenProvider {
  /// Returns a currently-valid access token, refreshing transparently if
  /// the cached one is within 60s of expiry. Returns null if there is no
  /// signed-in account.
  Future<String?> getValidAccessToken();

  /// Forces a token refresh. Returns the new access token, or null if
  /// refresh failed.
  Future<String?> refresh({bool force = false});

  /// The account id (email) the current token belongs to.
  String? get activeAccountId;
}
