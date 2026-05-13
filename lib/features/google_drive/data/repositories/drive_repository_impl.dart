import 'dart:io';

import 'package:google_apis_flutter/core/errors/guard.dart';
import 'package:google_apis_flutter/core/errors/result.dart';
import 'package:google_apis_flutter/features/google_drive/data/datasources/drive_remote_datasource.dart';
import 'package:google_apis_flutter/features/google_drive/data/models/drive_file_mapper.dart';
import 'package:google_apis_flutter/features/google_drive/domain/entities/drive_file.dart';
import 'package:google_apis_flutter/features/google_drive/domain/repositories/drive_repository.dart';
import 'package:googleapis/drive/v3.dart' as gdrive;

class DriveRepositoryImpl implements DriveRepository {
  DriveRepositoryImpl(this._remote);
  final DriveRemoteDataSource _remote;

  @override
  Future<Result<DriveFileList>> listFiles({
    String? folderId,
    String? query,
    String? pageToken,
    int pageSize = 50,
    DriveSortField sortBy = DriveSortField.modifiedTime,
    bool sortDescending = true,
  }) =>
      guardWithRetry<DriveFileList>(() async {
        final orderBy = '${sortBy.apiValue}${sortDescending ? ' desc' : ''}';
        final r = await _remote.listFiles(
          folderId: folderId,
          query: query,
          pageToken: pageToken,
          pageSize: pageSize,
          orderBy: orderBy,
        );
        final files = r.files ?? const <gdrive.File>[];
        return DriveFileList(
          files: files
              .map<DriveFile>(DriveFileMapper.toDomain)
              .toList(growable: false),
          nextPageToken: r.nextPageToken,
        );
      }, operation: 'drive.listFiles');

  @override
  Future<Result<DriveFile>> getFile(String fileId) => guardWithRetry<DriveFile>(
        () async => DriveFileMapper.toDomain(await _remote.getFile(fileId)),
        operation: 'drive.getFile',
      );

  @override
  Future<Result<DriveFile>> uploadFile({
    required File file,
    required String name,
    String? mimeType,
    String? parentFolderId,
    void Function(DriveUploadProgress)? onProgress,
  }) =>
      guard<DriveFile>(() async {
        final raw = await _remote.uploadFile(
          file: file,
          name: name,
          mimeType: mimeType,
          parentFolderId: parentFolderId,
          onProgress: onProgress == null
              ? null
              : (sent, total) => onProgress(
                    DriveUploadProgress(
                      bytesUploaded: sent,
                      totalBytes: total,
                      completed: sent >= total,
                    ),
                  ),
        );
        return DriveFileMapper.toDomain(raw);
      }, operation: 'drive.uploadFile');

  @override
  Future<Result<File>> downloadFile({
    required String fileId,
    required File destination,
    void Function(DriveUploadProgress)? onProgress,
  }) =>
      guard<File>(() => _remote.downloadFile(
            fileId: fileId,
            destination: destination,
            onProgress: onProgress == null
                ? null
                : (sent, total) => onProgress(
                      DriveUploadProgress(
                        bytesUploaded: sent,
                        totalBytes: total,
                        completed: sent >= total,
                      ),
                    ),
          ),
          operation: 'drive.downloadFile');

  @override
  Future<Result<void>> deleteFile(String fileId) =>
      guard<void>(() => _remote.deleteFile(fileId), operation: 'drive.deleteFile');

  @override
  Future<Result<DriveFile>> createFolder({
    required String name,
    String? parentFolderId,
  }) =>
      guard<DriveFile>(() async {
        final raw = await _remote.createFolder(
          name: name,
          parentFolderId: parentFolderId,
        );
        return DriveFileMapper.toDomain(raw);
      }, operation: 'drive.createFolder');

  @override
  Future<Result<DrivePermission>> shareFile({
    required String fileId,
    required PermissionRole role,
    required PermissionType type,
    String? emailAddress,
    String? domain,
    bool sendNotificationEmail = true,
  }) =>
      guard<DrivePermission>(() async {
        final raw = await _remote.shareFile(
          fileId: fileId,
          role: DriveFileMapper.roleToApi(role),
          type: DriveFileMapper.typeToApi(type),
          emailAddress: emailAddress,
          domain: domain,
          sendNotificationEmail: sendNotificationEmail,
        );
        return DriveFileMapper.toPermission(raw);
      }, operation: 'drive.shareFile');

  @override
  Future<Result<void>> unshareFile({
    required String fileId,
    required String permissionId,
  }) =>
      guard<void>(
          () => _remote.unshareFile(fileId: fileId, permissionId: permissionId),
          operation: 'drive.unshareFile');

  @override
  Future<Result<DriveFile>> renameFile({
    required String fileId,
    required String newName,
  }) =>
      guard<DriveFile>(() async {
        final raw =
            await _remote.renameFile(fileId: fileId, newName: newName);
        return DriveFileMapper.toDomain(raw);
      }, operation: 'drive.renameFile');

  @override
  Future<Result<DriveStorageQuota>> getStorageQuota() =>
      guardWithRetry<DriveStorageQuota>(() async {
        final about = await _remote.getAbout();
        return DriveFileMapper.toQuota(about.storageQuota);
      }, operation: 'drive.getStorageQuota');

}
