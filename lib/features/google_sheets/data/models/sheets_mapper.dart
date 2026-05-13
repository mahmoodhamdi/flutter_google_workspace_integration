import 'package:google_apis_flutter/features/google_sheets/domain/entities/spreadsheet.dart';
import 'package:googleapis/drive/v3.dart' as gdrive;
import 'package:googleapis/sheets/v4.dart' as gsheets;

class SheetsMapper {
  const SheetsMapper._();

  static Spreadsheet toDomainFromDrive(gdrive.File f) {
    return Spreadsheet(
      id: f.id ?? '',
      title: f.name ?? '(untitled)',
      url: 'https://docs.google.com/spreadsheets/d/${f.id}',
    );
  }

  static Spreadsheet toDomain(gsheets.Spreadsheet s) {
    return Spreadsheet(
      id: s.spreadsheetId ?? '',
      title: s.properties?.title ?? '(untitled)',
      url: s.spreadsheetUrl,
      locale: s.properties?.locale,
      timeZone: s.properties?.timeZone,
      sheets: (s.sheets ?? <gsheets.Sheet>[])
          .map<Sheet>((sh) => Sheet(
                id: sh.properties?.sheetId ?? 0,
                title: sh.properties?.title ?? '',
                index: sh.properties?.index ?? 0,
                rowCount: sh.properties?.gridProperties?.rowCount,
                columnCount: sh.properties?.gridProperties?.columnCount,
                hidden: sh.properties?.hidden ?? false,
              ))
          .toList(growable: false),
    );
  }

  static SheetRange toRange(gsheets.ValueRange v) {
    return SheetRange(
      a1: v.range ?? '',
      values: (v.values ?? <List<Object?>>[])
          .map<List<dynamic>>(
              (row) => row.map((c) => c).toList(growable: false))
          .toList(growable: false),
      majorDimension: v.majorDimension ?? 'ROWS',
    );
  }

  static SheetUpdateResult toUpdateResult(
    gsheets.UpdateValuesResponse v,
    String spreadsheetId,
  ) {
    return SheetUpdateResult(
      spreadsheetId: spreadsheetId,
      updatedRange: v.updatedRange ?? '',
      updatedRows: v.updatedRows ?? 0,
      updatedColumns: v.updatedColumns ?? 0,
      updatedCells: v.updatedCells ?? 0,
    );
  }

  static SheetUpdateResult fromAppend(
    gsheets.AppendValuesResponse v,
    String spreadsheetId,
  ) {
    final u = v.updates;
    return SheetUpdateResult(
      spreadsheetId: spreadsheetId,
      updatedRange: u?.updatedRange ?? '',
      updatedRows: u?.updatedRows ?? 0,
      updatedColumns: u?.updatedColumns ?? 0,
      updatedCells: u?.updatedCells ?? 0,
    );
  }
}
