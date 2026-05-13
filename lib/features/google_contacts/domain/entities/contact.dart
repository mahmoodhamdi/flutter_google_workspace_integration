import 'package:freezed_annotation/freezed_annotation.dart';

part 'contact.freezed.dart';
part 'contact.g.dart';

@freezed
class Contact with _$Contact {
  const Contact._();

  const factory Contact({
    required String resourceName,
    required String displayName,
    String? givenName,
    String? familyName,
    @Default(<ContactEmail>[]) List<ContactEmail> emails,
    @Default(<ContactPhone>[]) List<ContactPhone> phones,
    @Default(<ContactAddress>[]) List<ContactAddress> addresses,
    @Default(<ContactOrganization>[]) List<ContactOrganization> organizations,
    String? photoUrl,
    String? etag,
  }) = _Contact;

  factory Contact.fromJson(Map<String, dynamic> json) =>
      _$ContactFromJson(json);

  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.isEmpty
          ? '?'
          : parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  String? get primaryEmail =>
      emails.firstWhere((e) => e.primary, orElse: () => emails.firstOrNull ?? const ContactEmail(value: '')).value;
}

@freezed
class ContactEmail with _$ContactEmail {
  const factory ContactEmail({
    required String value,
    String? label,
    @Default(false) bool primary,
  }) = _ContactEmail;

  factory ContactEmail.fromJson(Map<String, dynamic> json) =>
      _$ContactEmailFromJson(json);
}

@freezed
class ContactPhone with _$ContactPhone {
  const factory ContactPhone({
    required String value,
    String? label,
    @Default(false) bool primary,
  }) = _ContactPhone;

  factory ContactPhone.fromJson(Map<String, dynamic> json) =>
      _$ContactPhoneFromJson(json);
}

@freezed
class ContactAddress with _$ContactAddress {
  const factory ContactAddress({
    required String formatted,
    String? city,
    String? region,
    String? country,
    String? label,
  }) = _ContactAddress;

  factory ContactAddress.fromJson(Map<String, dynamic> json) =>
      _$ContactAddressFromJson(json);
}

@freezed
class ContactOrganization with _$ContactOrganization {
  const factory ContactOrganization({
    String? name,
    String? title,
    String? department,
  }) = _ContactOrganization;

  factory ContactOrganization.fromJson(Map<String, dynamic> json) =>
      _$ContactOrganizationFromJson(json);
}

extension _FirstOrNullX<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
