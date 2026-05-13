import 'package:google_apis_flutter/core/errors/guard.dart';
import 'package:google_apis_flutter/core/errors/result.dart';
import 'package:google_apis_flutter/features/google_sheets/data/datasources/sheets_remote_datasource.dart';
import 'package:google_apis_flutter/features/google_sheets/data/models/sheets_mapper.dart';
import 'package:google_apis_flutter/features/google_sheets/domain/entities/spreadsheet.dart';
import 'package:google_apis_flutter/features/google_sheets/domain/repositories/sheets_repository.dart';
import 'package:googleapis/drive/v3.dart' as gdrive;
import 'package:googleapis/sheets/v4.dart' as gsheets;

class SheetsRepositoryImpl implements SheetsRepository {
  SheetsRepositoryImpl(this._remote);
  final SheetsRemoteDataSource _remote;

  @override
  Future<Result<List<Spreadsheet>>> listSpreadsheets({String? query}) =>
      guardWithRetry<List<Spreadsheet>>(() async {
        final list = await _remote.listSpreadsheetsViaDrive(query: query);
        final files = list.files ?? const <gdrive.File>[];
        return files
            .map<Spreadsheet>(SheetsMapper.toDomainFromDrive)
            .toList(growable: false);
      }, operation: 'sheets.list');

  @override
  Future<Result<Spreadsheet>> getSpreadsheet(String spreadsheetId) =>
      guardWithRetry<Spreadsheet>(() async {
        final raw = await _remote.getSpreadsheet(spreadsheetId);
        return SheetsMapper.toDomain(raw);
      }, operation: 'sheets.get');

  @override
  Future<Result<SheetRange>> readRange({
    required String spreadsheetId,
    required String range,
    String majorDimension = 'ROWS',
    String valueRenderOption = 'FORMATTED_VALUE',
  }) =>
      guardWithRetry<SheetRange>(() async {
        final v = await _remote.readRange(
          spreadsheetId: spreadsheetId,
          range: range,
          majorDimension: majorDimension,
          valueRenderOption: valueRenderOption,
        );
        return SheetsMapper.toRange(v);
      }, operation: 'sheets.read');

  @override
  Future<Result<SheetUpdateResult>> writeRange({
    required String spreadsheetId,
    required String range,
    required List<List<Object?>> values,
    String valueInputOption = 'USER_ENTERED',
  }) =>
      guard<SheetUpdateResult>(() async {
        final v = await _remote.writeRange(
          spreadsheetId: spreadsheetId,
          range: range,
          values: values,
          valueInputOption: valueInputOption,
        );
        return SheetsMapper.toUpdateResult(v, spreadsheetId);
      }, operation: 'sheets.write');

  @override
  Future<Result<SheetUpdateResult>> appendRows({
    required String spreadsheetId,
    required String range,
    required List<List<Object?>> values,
    String valueInputOption = 'USER_ENTERED',
  }) =>
      guard<SheetUpdateResult>(() async {
        final v = await _remote.appendRows(
          spreadsheetId: spreadsheetId,
          range: range,
          values: values,
          valueInputOption: valueInputOption,
        );
        return SheetsMapper.fromAppend(v, spreadsheetId);
      }, operation: 'sheets.append');

  @override
  Future<Result<List<SheetUpdateResult>>> batchUpdate({
    required String spreadsheetId,
    required Map<String, List<List<Object?>>> rangeToValues,
    String valueInputOption = 'USER_ENTERED',
  }) =>
      guard<List<SheetUpdateResult>>(() async {
        final v = await _remote.batchUpdate(
          spreadsheetId: spreadsheetId,
          rangeToValues: rangeToValues,
          valueInputOption: valueInputOption,
        );
        final responses = v.responses ?? const <gsheets.UpdateValuesResponse>[];
        return responses
            .map<SheetUpdateResult>(
                (r) => SheetsMapper.toUpdateResult(r, spreadsheetId))
            .toList(growable: false);
      }, operation: 'sheets.batchUpdate');

  @override
  Future<Result<Spreadsheet>> createSpreadsheet({
    required String title,
    List<String> sheetTitles = const <String>[],
  }) =>
      guard<Spreadsheet>(() async {
        final raw = await _remote.createSpreadsheet(
          title: title,
          sheetTitles: sheetTitles,
        );
        return SheetsMapper.toDomain(raw);
      }, operation: 'sheets.create');

  @override
  Future<Result<void>> clearRange({
    required String spreadsheetId,
    required String range,
  }) =>
      guard<void>(
          () => _remote.clearRange(spreadsheetId: spreadsheetId, range: range),
          operation: 'sheets.clear');
}
