import 'package:flutter_test/flutter_test.dart';
import 'package:google_apis_flutter/features/google_drive/data/models/drive_file_mapper.dart';
import 'package:google_apis_flutter/features/google_drive/domain/entities/drive_file.dart';
import 'package:googleapis/drive/v3.dart' as gdrive;

void main() {
  group('DriveFile.isFolder', () {
    test('detects folder mime type', () {
      const f = DriveFile(
        id: 'f',
        name: 'docs',
        mimeType: 'application/vnd.google-apps.folder',
      );
      expect(f.isFolder, true);
    });

    test('non-folder file', () {
      const f = DriveFile(
        id: 'f',
        name: 'doc.pdf',
        mimeType: 'application/pdf',
      );
      expect(f.isFolder, false);
    });

    test('detects google-apps mime as google doc', () {
      const f = DriveFile(
        id: 'f',
        name: 'spreadsheet',
        mimeType: 'application/vnd.google-apps.spreadsheet',
      );
      expect(f.isGoogleDoc, true);
      expect(f.isFolder, false);
    });
  });

  group('DriveFile.formattedSize', () {
    test('returns em dash when sizeBytes null', () {
      const f = DriveFile(id: 'f', name: 'n', mimeType: 'm');
      expect(f.formattedSize, '—');
    });

    test('bytes', () {
      const f =
          DriveFile(id: 'f', name: 'n', mimeType: 'm', sizeBytes: 512);
      expect(f.formattedSize, '512 B');
    });

    test('kilobytes', () {
      const f =
          DriveFile(id: 'f', name: 'n', mimeType: 'm', sizeBytes: 2048);
      expect(f.formattedSize, '2.0 KB');
    });

    test('megabytes', () {
      const f = DriveFile(
        id: 'f',
        name: 'n',
        mimeType: 'm',
        sizeBytes: 5 * 1024 * 1024,
      );
      expect(f.formattedSize, '5.0 MB');
    });

    test('gigabytes', () {
      const f = DriveFile(
        id: 'f',
        name: 'n',
        mimeType: 'm',
        sizeBytes: 3 * 1024 * 1024 * 1024,
      );
      expect(f.formattedSize, '3.0 GB');
    });
  });

  group('DriveFileMapper.toDomain', () {
    test('maps a regular file', () {
      final api = gdrive.File(
        id: 'fid',
        name: 'foo.pdf',
        mimeType: 'application/pdf',
        size: '12345',
        modifiedTime: DateTime.utc(2026, 5, 13),
        webViewLink: 'http://x',
      );
      final f = DriveFileMapper.toDomain(api);
      expect(f.id, 'fid');
      expect(f.name, 'foo.pdf');
      expect(f.sizeBytes, 12345);
      expect(f.webViewLink, 'http://x');
    });

    test('maps a folder', () {
      final api = gdrive.File(
        id: 'fld',
        name: 'Docs',
        mimeType: 'application/vnd.google-apps.folder',
      );
      final f = DriveFileMapper.toDomain(api);
      expect(f.isFolder, true);
      expect(f.sizeBytes, null);
    });

    test('maps permissions', () {
      final api = gdrive.File(
        id: 'f',
        name: 'shared',
        mimeType: 'image/png',
        permissions: <gdrive.Permission>[
          gdrive.Permission(
            id: 'p1',
            role: 'writer',
            type: 'user',
            emailAddress: 'a@example.com',
          ),
          gdrive.Permission(
            id: 'p2',
            role: 'reader',
            type: 'anyone',
          ),
        ],
      );
      final f = DriveFileMapper.toDomain(api);
      expect(f.permissions.length, 2);
      expect(f.permissions[0].role, PermissionRole.writer);
      expect(f.permissions[0].type, PermissionType.user);
      expect(f.permissions[1].type, PermissionType.anyone);
    });

    test('handles missing/null fields gracefully', () {
      final api = gdrive.File();
      final f = DriveFileMapper.toDomain(api);
      expect(f.id, '');
      expect(f.name, '(untitled)');
      expect(f.mimeType, 'application/octet-stream');
    });
  });

  group('DriveFileMapper role/type API mapping', () {
    test('roleToApi -> string', () {
      expect(DriveFileMapper.roleToApi(PermissionRole.writer), 'writer');
      expect(DriveFileMapper.roleToApi(PermissionRole.reader), 'reader');
      expect(DriveFileMapper.roleToApi(PermissionRole.commenter), 'commenter');
      expect(DriveFileMapper.roleToApi(PermissionRole.owner), 'owner');
    });

    test('typeToApi -> string', () {
      expect(DriveFileMapper.typeToApi(PermissionType.user), 'user');
      expect(DriveFileMapper.typeToApi(PermissionType.group), 'group');
      expect(DriveFileMapper.typeToApi(PermissionType.domain), 'domain');
      expect(DriveFileMapper.typeToApi(PermissionType.anyone), 'anyone');
    });
  });

  group('DriveStorageQuota.usagePercent', () {
    test('returns 0 when no limit', () {
      const q = DriveStorageQuota(usageBytes: 1000);
      expect(q.usagePercent, 0);
    });

    test('computes ratio', () {
      const q =
          DriveStorageQuota(usageBytes: 500, limitBytes: 1000);
      expect(q.usagePercent, 0.5);
    });
  });
}
