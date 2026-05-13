import 'dart:io';

import 'package:google_apis_flutter/core/errors/result.dart';
import 'package:google_apis_flutter/features/google_drive/domain/entities/drive_file.dart';

abstract class DriveRepository {
  /// List files visible to the app under [folderId] (or root if null).
  /// Limited to the `drive.file` scope semantics: only files the app
  /// created, opened, or were shared with it.
  Future<Result<DriveFileList>> listFiles({
    String? folderId,
    String? query,
    String? pageToken,
    int pageSize,
    DriveSortField sortBy,
    bool sortDescending,
  });

  Future<Result<DriveFile>> getFile(String fileId);

  /// Upload a file from local storage. Reports progress via [onProgress].
  Future<Result<DriveFile>> uploadFile({
    required File file,
    required String name,
    String? mimeType,
    String? parentFolderId,
    void Function(DriveUploadProgress)? onProgress,
  });

  Future<Result<File>> downloadFile({
    required String fileId,
    required File destination,
    void Function(DriveUploadProgress)? onProgress,
  });

  Future<Result<void>> deleteFile(String fileId);

  Future<Result<DriveFile>> createFolder({
    required String name,
    String? parentFolderId,
  });

  Future<Result<DrivePermission>> shareFile({
    required String fileId,
    required PermissionRole role,
    required PermissionType type,
    String? emailAddress,
    String? domain,
    bool sendNotificationEmail = true,
  });

  Future<Result<void>> unshareFile({
    required String fileId,
    required String permissionId,
  });

  Future<Result<DriveFile>> renameFile({
    required String fileId,
    required String newName,
  });

  Future<Result<DriveStorageQuota>> getStorageQuota();
}

class DriveFileList {
  const DriveFileList({
    required this.files,
    this.nextPageToken,
  });

  final List<DriveFile> files;
  final String? nextPageToken;
}

enum DriveSortField {
  name,
  modifiedTime,
  createdTime,
  quotaBytesUsed;

  String get apiValue => switch (this) {
        DriveSortField.name => 'name',
        DriveSortField.modifiedTime => 'modifiedTime',
        DriveSortField.createdTime => 'createdTime',
        DriveSortField.quotaBytesUsed => 'quotaBytesUsed',
      };
}
