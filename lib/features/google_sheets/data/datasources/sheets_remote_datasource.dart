import 'package:google_apis_flutter/core/auth/data/google_sign_in_service.dart';
import 'package:google_apis_flutter/core/errors/app_error.dart';
import 'package:google_apis_flutter/core/utils/constants/api_constants.dart';
import 'package:googleapis/drive/v3.dart' as gdrive;
import 'package:googleapis/sheets/v4.dart' as gsheets;

class SheetsRemoteDataSource {
  SheetsRemoteDataSource(this._signIn);
  final GoogleSignInService _signIn;

  Future<gsheets.SheetsApi> _sheets() async {
    final client = await _signIn.authClient(scopes: ApiConstants.sheetsScopes);
    if (client == null) {
      throw const AppError.unauthorized(message: 'Not signed in');
    }
    return gsheets.SheetsApi(client);
  }

  Future<gdrive.DriveApi> _drive() async {
    final client = await _signIn.authClient(
      scopes: <String>[ApiConstants.scopeDriveMetaReadonly],
    );
    if (client == null) {
      throw const AppError.unauthorized(message: 'Not signed in');
    }
    return gdrive.DriveApi(client);
  }

  Future<gdrive.FileList> listSpreadsheetsViaDrive({String? query}) async {
    final api = await _drive();
    final qParts = <String>[
      "mimeType = 'application/vnd.google-apps.spreadsheet'",
      'trashed = false',
    ];
    if (query != null && query.isNotEmpty) {
      final escaped = query.replaceAll("'", r"\'");
      qParts.add("name contains '$escaped'");
    }
    return api.files.list(
      q: qParts.join(' and '),
      pageSize: 100,
      orderBy: 'modifiedTime desc',
      $fields: 'files(id, name, modifiedTime)',
      spaces: 'drive',
    );
  }

  Future<gsheets.Spreadsheet> getSpreadsheet(String id) async {
    final api = await _sheets();
    return api.spreadsheets.get(
      id,
      includeGridData: false,
      $fields: 'spreadsheetId,properties(title,locale,timeZone),'
          'sheets(properties(sheetId,title,index,hidden,gridProperties)),'
          'spreadsheetUrl',
    );
  }

  Future<gsheets.ValueRange> readRange({
    required String spreadsheetId,
    required String range,
    String majorDimension = 'ROWS',
    String valueRenderOption = 'FORMATTED_VALUE',
  }) async {
    final api = await _sheets();
    return api.spreadsheets.values.get(
      spreadsheetId,
      range,
      majorDimension: majorDimension,
      valueRenderOption: valueRenderOption,
    );
  }

  Future<gsheets.UpdateValuesResponse> writeRange({
    required String spreadsheetId,
    required String range,
    required List<List<Object?>> values,
    String valueInputOption = 'USER_ENTERED',
  }) async {
    final api = await _sheets();
    return api.spreadsheets.values.update(
      gsheets.ValueRange(values: values),
      spreadsheetId,
      range,
      valueInputOption: valueInputOption,
    );
  }

  Future<gsheets.AppendValuesResponse> appendRows({
    required String spreadsheetId,
    required String range,
    required List<List<Object?>> values,
    String valueInputOption = 'USER_ENTERED',
  }) async {
    final api = await _sheets();
    return api.spreadsheets.values.append(
      gsheets.ValueRange(values: values),
      spreadsheetId,
      range,
      valueInputOption: valueInputOption,
    );
  }

  Future<gsheets.BatchUpdateValuesResponse> batchUpdate({
    required String spreadsheetId,
    required Map<String, List<List<Object?>>> rangeToValues,
    String valueInputOption = 'USER_ENTERED',
  }) async {
    final api = await _sheets();
    return api.spreadsheets.values.batchUpdate(
      gsheets.BatchUpdateValuesRequest(
        valueInputOption: valueInputOption,
        data: rangeToValues.entries
            .map((e) => gsheets.ValueRange(
                  range: e.key,
                  values: e.value,
                ))
            .toList(),
      ),
      spreadsheetId,
    );
  }

  Future<gsheets.Spreadsheet> createSpreadsheet({
    required String title,
    List<String> sheetTitles = const <String>[],
  }) async {
    final api = await _sheets();
    return api.spreadsheets.create(
      gsheets.Spreadsheet(
        properties: gsheets.SpreadsheetProperties(title: title),
        sheets: sheetTitles.isEmpty
            ? null
            : sheetTitles
                .map((t) => gsheets.Sheet(
                      properties: gsheets.SheetProperties(title: t),
                    ))
                .toList(),
      ),
    );
  }

  Future<void> clearRange({
    required String spreadsheetId,
    required String range,
  }) async {
    final api = await _sheets();
    await api.spreadsheets.values
        .clear(gsheets.ClearValuesRequest(), spreadsheetId, range);
  }
}
