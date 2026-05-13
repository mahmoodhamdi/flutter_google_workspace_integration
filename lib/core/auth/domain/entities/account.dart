import 'package:freezed_annotation/freezed_annotation.dart';

part 'account.freezed.dart';
part 'account.g.dart';

/// Represents a signed-in Google Workspace account.
@freezed
class Account with _$Account {
  const factory Account({
    required String id,
    required String email,
    String? displayName,
    String? photoUrl,
    @Default(<String>[]) List<String> grantedScopes,
    @Default(false) bool isActive,
    DateTime? lastUsed,
  }) = _Account;

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);
}

/// Profile fetched from `userinfo` endpoint (or Firebase if email/pw auth).
@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String email,
    String? displayName,
    String? photoUrl,
    @Default(false) bool emailVerified,
    @Default(AuthProvider.google) AuthProvider provider,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

enum AuthProvider {
  google,
  emailPassword,
  anonymous;
}
