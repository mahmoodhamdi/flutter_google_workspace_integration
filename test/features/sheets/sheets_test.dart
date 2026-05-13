import 'package:flutter_test/flutter_test.dart';
import 'package:google_apis_flutter/features/google_sheets/data/models/sheets_mapper.dart';
import 'package:google_apis_flutter/features/google_sheets/domain/entities/spreadsheet.dart';
import 'package:googleapis/drive/v3.dart' as gdrive;
import 'package:googleapis/sheets/v4.dart' as gsheets;

void main() {
  group('SheetRange', () {
    test('rowCount and columnCount', () {
      const r = SheetRange(
        a1: 'A1:C2',
        values: <List<dynamic>>[
          <dynamic>['a', 'b', 'c'],
          <dynamic>['d', 'e'],
        ],
      );
      expect(r.rowCount, 2);
      expect(r.columnCount, 3);
    });

    test('cell accessor returns value or null', () {
      const r = SheetRange(
        a1: 'A1:B2',
        values: <List<dynamic>>[
          <dynamic>['1', '2'],
          <dynamic>['3'],
        ],
      );
      expect(r.cell(0, 0), '1');
      expect(r.cell(0, 1), '2');
      expect(r.cell(1, 0), '3');
      expect(r.cell(1, 1), null);
      expect(r.cell(2, 0), null);
    });
  });

  group('SheetsMapper.toDomainFromDrive', () {
    test('maps drive File to Spreadsheet stub', () {
      final f = gdrive.File(id: 's1', name: 'Budget');
      final s = SheetsMapper.toDomainFromDrive(f);
      expect(s.id, 's1');
      expect(s.title, 'Budget');
      expect(s.url, contains('s1'));
    });

    test('handles missing name', () {
      final f = gdrive.File(id: 's2');
      final s = SheetsMapper.toDomainFromDrive(f);
      expect(s.title, '(untitled)');
    });
  });

  group('SheetsMapper.toDomain', () {
    test('maps full Spreadsheet with multiple Sheets', () {
      final api = gsheets.Spreadsheet(
        spreadsheetId: 'ssid',
        spreadsheetUrl: 'https://example.com',
        properties: gsheets.SpreadsheetProperties(
          title: 'Q1 Plan',
          locale: 'en_US',
          timeZone: 'UTC',
        ),
        sheets: <gsheets.Sheet>[
          gsheets.Sheet(
            properties: gsheets.SheetProperties(
              sheetId: 0,
              title: 'Sheet1',
              index: 0,
              gridProperties:
                  gsheets.GridProperties(rowCount: 100, columnCount: 26),
            ),
          ),
          gsheets.Sheet(
            properties: gsheets.SheetProperties(
              sheetId: 1,
              title: 'Sheet2',
              index: 1,
              hidden: true,
            ),
          ),
        ],
      );
      final s = SheetsMapper.toDomain(api);
      expect(s.id, 'ssid');
      expect(s.title, 'Q1 Plan');
      expect(s.locale, 'en_US');
      expect(s.timeZone, 'UTC');
      expect(s.sheets.length, 2);
      expect(s.sheets[0].rowCount, 100);
      expect(s.sheets[0].columnCount, 26);
      expect(s.sheets[1].hidden, true);
    });
  });

  group('SheetsMapper.toRange', () {
    test('extracts values and dimension', () {
      final v = gsheets.ValueRange(
        range: "'Sheet1'!A1:B3",
        majorDimension: 'ROWS',
        values: <List<Object?>>[
          <Object?>['x', 1],
          <Object?>['y', 2],
        ],
      );
      final r = SheetsMapper.toRange(v);
      expect(r.a1, "'Sheet1'!A1:B3");
      expect(r.majorDimension, 'ROWS');
      expect(r.values, hasLength(2));
    });

    test('empty value range', () {
      final v = gsheets.ValueRange(range: 'Sheet1');
      final r = SheetsMapper.toRange(v);
      expect(r.values, isEmpty);
    });
  });

  group('SheetsMapper update results', () {
    test('toUpdateResult fields', () {
      final v = gsheets.UpdateValuesResponse(
        updatedRange: 'A1:B2',
        updatedRows: 2,
        updatedColumns: 2,
        updatedCells: 4,
      );
      final r = SheetsMapper.toUpdateResult(v, 'sid');
      expect(r.spreadsheetId, 'sid');
      expect(r.updatedRows, 2);
      expect(r.updatedColumns, 2);
      expect(r.updatedCells, 4);
    });

    test('fromAppend reads nested updates', () {
      final v = gsheets.AppendValuesResponse(
        updates: gsheets.UpdateValuesResponse(
          updatedRange: 'A10:B10',
          updatedRows: 1,
          updatedCells: 2,
        ),
      );
      final r = SheetsMapper.fromAppend(v, 'sid');
      expect(r.updatedRange, 'A10:B10');
      expect(r.updatedRows, 1);
      expect(r.updatedCells, 2);
    });
  });
}
