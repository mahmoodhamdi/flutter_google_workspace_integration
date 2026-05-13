import 'dart:async';
import 'dart:io';

import 'package:google_apis_flutter/core/auth/data/google_sign_in_service.dart';
import 'package:google_apis_flutter/core/errors/app_error.dart';
import 'package:google_apis_flutter/core/utils/constants/api_constants.dart';
import 'package:googleapis/drive/v3.dart' as gdrive;

class DriveRemoteDataSource {
  DriveRemoteDataSource(this._signIn);

  final GoogleSignInService _signIn;

  Future<gdrive.DriveApi> _api() async {
    final client = await _signIn.authClient(scopes: ApiConstants.driveScopes);
    if (client == null) {
      throw const AppError.unauthorized(message: 'Not signed in');
    }
    return gdrive.DriveApi(client);
  }

  static const String _fileFields =
      'id, name, mimeType, size, modifiedTime, createdTime, '
      'iconLink, thumbnailLink, webViewLink, webContentLink, '
      'parents, starred, trashed, shared, ownedByMe, md5Checksum, '
      'permissions(id, role, type, emailAddress, domain, displayName, deleted)';

  Future<gdrive.FileList> listFiles({
    String? folderId,
    String? query,
    String? pageToken,
    int pageSize = 50,
    String orderBy = 'modifiedTime desc',
  }) async {
    final api = await _api();
    final qParts = <String>['trashed = false'];
    if (folderId != null) {
      qParts.add("'$folderId' in parents");
    } else {
      qParts.add("'root' in parents");
    }
    if (query != null && query.isNotEmpty) {
      final escaped = query.replaceAll("'", r"\'");
      qParts.add("name contains '$escaped'");
    }
    return api.files.list(
      q: qParts.join(' and '),
      pageSize: pageSize,
      pageToken: pageToken,
      orderBy: orderBy,
      $fields: 'nextPageToken, files($_fileFields)',
      spaces: 'drive',
    );
  }

  Future<gdrive.File> getFile(String fileId) async {
    final api = await _api();
    return api.files.get(
      fileId,
      $fields: _fileFields,
    ) as gdrive.File;
  }

  Future<gdrive.File> createFolder({
    required String name,
    String? parentFolderId,
  }) async {
    final api = await _api();
    return api.files.create(
      gdrive.File(
        name: name,
        mimeType: 'application/vnd.google-apps.folder',
        parents: parentFolderId == null ? null : <String>[parentFolderId],
      ),
      $fields: _fileFields,
    );
  }

  Future<gdrive.File> uploadFile({
    required File file,
    required String name,
    String? mimeType,
    String? parentFolderId,
    void Function(int bytes, int total)? onProgress,
  }) async {
    final api = await _api();
    final length = await file.length();
    final stream = file.openRead();
    int sent = 0;
    final tracked = stream.map((chunk) {
      sent += chunk.length;
      onProgress?.call(sent, length);
      return chunk;
    });
    final media = gdrive.Media(tracked, length, contentType: mimeType);
    return api.files.create(
      gdrive.File(
        name: name,
        parents: parentFolderId == null ? null : <String>[parentFolderId],
      ),
      uploadMedia: media,
      $fields: _fileFields,
    );
  }

  Future<File> downloadFile({
    required String fileId,
    required File destination,
    void Function(int bytes, int total)? onProgress,
  }) async {
    final api = await _api();
    final meta = await getFile(fileId);
    final media = await api.files.get(
      fileId,
      downloadOptions: gdrive.DownloadOptions.fullMedia,
    ) as gdrive.Media;
    final total = meta.size == null ? 0 : int.tryParse(meta.size!) ?? 0;

    final sink = destination.openWrite();
    int received = 0;
    final completer = Completer<void>();
    media.stream.listen(
      (chunk) {
        sink.add(chunk);
        received += chunk.length;
        onProgress?.call(received, total);
      },
      onError: completer.completeError,
      onDone: () async {
        await sink.flush();
        await sink.close();
        completer.complete();
      },
      cancelOnError: true,
    );
    await completer.future;
    return destination;
  }

  Future<void> deleteFile(String fileId) async {
    final api = await _api();
    await api.files.delete(fileId);
  }

  Future<gdrive.File> renameFile({
    required String fileId,
    required String newName,
  }) async {
    final api = await _api();
    return api.files.update(
      gdrive.File(name: newName),
      fileId,
      $fields: _fileFields,
    );
  }

  Future<gdrive.Permission> shareFile({
    required String fileId,
    required String role,
    required String type,
    String? emailAddress,
    String? domain,
    bool sendNotificationEmail = true,
  }) async {
    final api = await _api();
    return api.permissions.create(
      gdrive.Permission(
        role: role,
        type: type,
        emailAddress: emailAddress,
        domain: domain,
      ),
      fileId,
      sendNotificationEmail: sendNotificationEmail,
      $fields: 'id, role, type, emailAddress, domain, displayName, deleted',
    );
  }

  Future<void> unshareFile({
    required String fileId,
    required String permissionId,
  }) async {
    final api = await _api();
    await api.permissions.delete(fileId, permissionId);
  }

  Future<gdrive.About> getAbout() async {
    final api = await _api();
    return api.about.get($fields: 'storageQuota');
  }
}
