import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_apis_flutter/core/auth/providers/auth_providers.dart';
import 'package:google_apis_flutter/core/errors/result.dart';
import 'package:google_apis_flutter/features/google_sheets/data/datasources/sheets_remote_datasource.dart';
import 'package:google_apis_flutter/features/google_sheets/data/repositories/sheets_repository_impl.dart';
import 'package:google_apis_flutter/features/google_sheets/domain/entities/spreadsheet.dart';
import 'package:google_apis_flutter/features/google_sheets/domain/repositories/sheets_repository.dart';

final Provider<SheetsRemoteDataSource> sheetsRemoteDataSourceProvider =
    Provider<SheetsRemoteDataSource>(
  (Ref ref) => SheetsRemoteDataSource(ref.watch(googleSignInServiceProvider)),
);

final Provider<SheetsRepository> sheetsRepositoryProvider =
    Provider<SheetsRepository>(
  (Ref ref) => SheetsRepositoryImpl(ref.watch(sheetsRemoteDataSourceProvider)),
);

final AutoDisposeFutureProvider<Result<List<Spreadsheet>>>
    spreadsheetsListProvider =
    FutureProvider.autoDispose<Result<List<Spreadsheet>>>(
        (Ref ref) => ref.watch(sheetsRepositoryProvider).listSpreadsheets());

final AutoDisposeFutureProviderFamily<Result<Spreadsheet>, String>
    spreadsheetByIdProvider =
    FutureProvider.family.autoDispose<Result<Spreadsheet>, String>(
  (Ref ref, String id) =>
      ref.watch(sheetsRepositoryProvider).getSpreadsheet(id),
);

class SheetRangeKey {
  const SheetRangeKey({required this.spreadsheetId, required this.range});
  final String spreadsheetId;
  final String range;

  @override
  bool operator ==(Object other) =>
      other is SheetRangeKey &&
      other.spreadsheetId == spreadsheetId &&
      other.range == range;

  @override
  int get hashCode => Object.hash(spreadsheetId, range);
}

final AutoDisposeFutureProviderFamily<Result<SheetRange>, SheetRangeKey>
    sheetRangeProvider =
    FutureProvider.family.autoDispose<Result<SheetRange>, SheetRangeKey>(
  (Ref ref, SheetRangeKey key) =>
      ref.watch(sheetsRepositoryProvider).readRange(
            spreadsheetId: key.spreadsheetId,
            range: key.range,
          ),
);
