import 'package:google_apis_flutter/features/google_drive/domain/entities/drive_file.dart';
import 'package:googleapis/drive/v3.dart' as gdrive;

class DriveFileMapper {
  const DriveFileMapper._();

  static DriveFile toDomain(gdrive.File f) {
    return DriveFile(
      id: f.id ?? '',
      name: f.name ?? '(untitled)',
      mimeType: f.mimeType ?? 'application/octet-stream',
      sizeBytes: f.size == null ? null : int.tryParse(f.size!),
      modifiedTime: f.modifiedTime,
      createdTime: f.createdTime,
      iconLink: f.iconLink,
      thumbnailLink: f.thumbnailLink,
      webViewLink: f.webViewLink,
      webContentLink: f.webContentLink,
      parents: f.parents ?? const <String>[],
      starred: f.starred ?? false,
      trashed: f.trashed ?? false,
      shared: f.shared ?? false,
      ownedByMe: f.ownedByMe?.toString(),
      permissions: (f.permissions ?? <gdrive.Permission>[])
          .map<DrivePermission>(_toPermission)
          .toList(growable: false),
      md5Checksum: f.md5Checksum,
    );
  }

  static DrivePermission toPermission(gdrive.Permission p) {
    return DrivePermission(
      id: p.id ?? '',
      role: _parseRole(p.role),
      type: _parseType(p.type),
      emailAddress: p.emailAddress,
      domain: p.domain,
      displayName: p.displayName,
      deleted: p.deleted ?? false,
    );
  }

  static DrivePermission _toPermission(gdrive.Permission p) => toPermission(p);

  static PermissionRole _parseRole(String? r) => switch (r) {
        'owner' => PermissionRole.owner,
        'organizer' => PermissionRole.organizer,
        'fileOrganizer' => PermissionRole.fileOrganizer,
        'writer' => PermissionRole.writer,
        'commenter' => PermissionRole.commenter,
        'reader' => PermissionRole.reader,
        _ => PermissionRole.reader,
      };

  static String roleToApi(PermissionRole r) => switch (r) {
        PermissionRole.owner => 'owner',
        PermissionRole.organizer => 'organizer',
        PermissionRole.fileOrganizer => 'fileOrganizer',
        PermissionRole.writer => 'writer',
        PermissionRole.commenter => 'commenter',
        PermissionRole.reader => 'reader',
      };

  static PermissionType _parseType(String? t) => switch (t) {
        'user' => PermissionType.user,
        'group' => PermissionType.group,
        'domain' => PermissionType.domain,
        'anyone' => PermissionType.anyone,
        _ => PermissionType.user,
      };

  static String typeToApi(PermissionType t) => switch (t) {
        PermissionType.user => 'user',
        PermissionType.group => 'group',
        PermissionType.domain => 'domain',
        PermissionType.anyone => 'anyone',
      };

  static DriveStorageQuota toQuota(gdrive.AboutStorageQuota? q) {
    if (q == null) {
      return const DriveStorageQuota(usageBytes: 0);
    }
    return DriveStorageQuota(
      usageBytes: int.tryParse(q.usage ?? '0') ?? 0,
      limitBytes: q.limit == null ? null : int.tryParse(q.limit!),
      usageInDriveBytes:
          q.usageInDrive == null ? null : int.tryParse(q.usageInDrive!),
      usageInDriveTrashBytes: q.usageInDriveTrash == null
          ? null
          : int.tryParse(q.usageInDriveTrash!),
    );
  }
}
