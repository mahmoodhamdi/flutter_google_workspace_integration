import 'package:google_apis_flutter/core/errors/result.dart';
import 'package:google_apis_flutter/features/google_sheets/domain/entities/spreadsheet.dart';

abstract class SheetsRepository {
  /// List the user's spreadsheets via Drive API.
  /// Uses `mimeType = application/vnd.google-apps.spreadsheet`.
  Future<Result<List<Spreadsheet>>> listSpreadsheets({String? query});

  Future<Result<Spreadsheet>> getSpreadsheet(String spreadsheetId);

  Future<Result<SheetRange>> readRange({
    required String spreadsheetId,
    required String range,
    String majorDimension = 'ROWS',
    String valueRenderOption = 'FORMATTED_VALUE',
  });

  Future<Result<SheetUpdateResult>> writeRange({
    required String spreadsheetId,
    required String range,
    required List<List<Object?>> values,
    String valueInputOption = 'USER_ENTERED',
  });

  Future<Result<SheetUpdateResult>> appendRows({
    required String spreadsheetId,
    required String range,
    required List<List<Object?>> values,
    String valueInputOption = 'USER_ENTERED',
  });

  Future<Result<List<SheetUpdateResult>>> batchUpdate({
    required String spreadsheetId,
    required Map<String, List<List<Object?>>> rangeToValues,
    String valueInputOption = 'USER_ENTERED',
  });

  Future<Result<Spreadsheet>> createSpreadsheet({
    required String title,
    List<String> sheetTitles,
  });

  Future<Result<void>> clearRange({
    required String spreadsheetId,
    required String range,
  });
}
