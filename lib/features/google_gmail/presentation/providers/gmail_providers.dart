import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_apis_flutter/core/auth/providers/auth_providers.dart';
import 'package:google_apis_flutter/core/errors/result.dart';
import 'package:google_apis_flutter/features/google_gmail/data/datasources/gmail_remote_datasource.dart';
import 'package:google_apis_flutter/features/google_gmail/data/repositories/gmail_repository_impl.dart';
import 'package:google_apis_flutter/features/google_gmail/domain/entities/gmail_message.dart';
import 'package:google_apis_flutter/features/google_gmail/domain/repositories/gmail_repository.dart';

final Provider<GmailRemoteDataSource> gmailRemoteDataSourceProvider =
    Provider<GmailRemoteDataSource>(
  (Ref ref) => GmailRemoteDataSource(ref.watch(googleSignInServiceProvider)),
);

final Provider<GmailRepository> gmailRepositoryProvider =
    Provider<GmailRepository>(
  (Ref ref) => GmailRepositoryImpl(ref.watch(gmailRemoteDataSourceProvider)),
);

final AutoDisposeFutureProvider<Result<List<SentMessageReceipt>>>
    sentLogProvider =
    FutureProvider.autoDispose<Result<List<SentMessageReceipt>>>(
        (Ref ref) => ref.watch(gmailRepositoryProvider).listSentLocal());
