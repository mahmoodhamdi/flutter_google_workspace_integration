import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_apis_flutter/core/auth/providers/auth_providers.dart';
import 'package:google_apis_flutter/core/errors/result.dart';
import 'package:google_apis_flutter/features/google_drive/data/datasources/drive_remote_datasource.dart';
import 'package:google_apis_flutter/features/google_drive/data/repositories/drive_repository_impl.dart';
import 'package:google_apis_flutter/features/google_drive/domain/entities/drive_file.dart';
import 'package:google_apis_flutter/features/google_drive/domain/repositories/drive_repository.dart';

final Provider<DriveRemoteDataSource> driveRemoteDataSourceProvider =
    Provider<DriveRemoteDataSource>(
  (Ref ref) => DriveRemoteDataSource(ref.watch(googleSignInServiceProvider)),
);

final Provider<DriveRepository> driveRepositoryProvider =
    Provider<DriveRepository>(
  (Ref ref) => DriveRepositoryImpl(ref.watch(driveRemoteDataSourceProvider)),
);

final AutoDisposeFutureProviderFamily<Result<DriveFileList>, String?>
    driveListProvider = FutureProvider.family.autoDispose<Result<DriveFileList>, String?>(
  (Ref ref, String? folderId) =>
      ref.watch(driveRepositoryProvider).listFiles(folderId: folderId),
);

final AutoDisposeFutureProvider<Result<DriveStorageQuota>>
    driveQuotaProvider =
    FutureProvider.autoDispose<Result<DriveStorageQuota>>(
        (Ref ref) => ref.watch(driveRepositoryProvider).getStorageQuota());
