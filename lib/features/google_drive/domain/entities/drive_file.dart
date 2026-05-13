import 'package:freezed_annotation/freezed_annotation.dart';

part 'drive_file.freezed.dart';
part 'drive_file.g.dart';

@freezed
class DriveFile with _$DriveFile {
  const DriveFile._();

  const factory DriveFile({
    required String id,
    required String name,
    required String mimeType,
    int? sizeBytes,
    DateTime? modifiedTime,
    DateTime? createdTime,
    String? iconLink,
    String? thumbnailLink,
    String? webViewLink,
    String? webContentLink,
    @Default(<String>[]) List<String> parents,
    @Default(false) bool starred,
    @Default(false) bool trashed,
    @Default(false) bool shared,
    String? ownedByMe,
    @Default(<DrivePermission>[]) List<DrivePermission> permissions,
    String? md5Checksum,
  }) = _DriveFile;

  factory DriveFile.fromJson(Map<String, dynamic> json) =>
      _$DriveFileFromJson(json);

  bool get isFolder => mimeType == 'application/vnd.google-apps.folder';
  bool get isGoogleDoc => mimeType.startsWith('application/vnd.google-apps.');

  String get formattedSize {
    if (sizeBytes == null) return '—';
    const units = <String>['B', 'KB', 'MB', 'GB', 'TB'];
    double s = sizeBytes!.toDouble();
    int u = 0;
    while (s >= 1024 && u < units.length - 1) {
      s /= 1024;
      u++;
    }
    return '${s.toStringAsFixed(s < 10 ? 1 : 0)} ${units[u]}';
  }
}

@freezed
class DrivePermission with _$DrivePermission {
  const factory DrivePermission({
    required String id,
    required PermissionRole role,
    required PermissionType type,
    String? emailAddress,
    String? domain,
    String? displayName,
    @Default(false) bool deleted,
  }) = _DrivePermission;

  factory DrivePermission.fromJson(Map<String, dynamic> json) =>
      _$DrivePermissionFromJson(json);
}

enum PermissionRole { owner, organizer, fileOrganizer, writer, commenter, reader }
enum PermissionType { user, group, domain, anyone }

@freezed
class DriveUploadProgress with _$DriveUploadProgress {
  const factory DriveUploadProgress({
    required int bytesUploaded,
    required int totalBytes,
    @Default(false) bool completed,
  }) = _DriveUploadProgress;

  factory DriveUploadProgress.fromJson(Map<String, dynamic> json) =>
      _$DriveUploadProgressFromJson(json);
}

@freezed
class DriveStorageQuota with _$DriveStorageQuota {
  const DriveStorageQuota._();

  const factory DriveStorageQuota({
    required int usageBytes,
    int? limitBytes,
    int? usageInDriveBytes,
    int? usageInDriveTrashBytes,
  }) = _DriveStorageQuota;

  factory DriveStorageQuota.fromJson(Map<String, dynamic> json) =>
      _$DriveStorageQuotaFromJson(json);

  double get usagePercent =>
      limitBytes != null && limitBytes! > 0 ? usageBytes / limitBytes! : 0;
}
