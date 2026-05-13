import 'package:freezed_annotation/freezed_annotation.dart';

part 'spreadsheet.freezed.dart';
part 'spreadsheet.g.dart';

@freezed
class Spreadsheet with _$Spreadsheet {
  const factory Spreadsheet({
    required String id,
    required String title,
    String? url,
    @Default(<Sheet>[]) List<Sheet> sheets,
    String? locale,
    String? timeZone,
  }) = _Spreadsheet;

  factory Spreadsheet.fromJson(Map<String, dynamic> json) =>
      _$SpreadsheetFromJson(json);
}

@freezed
class Sheet with _$Sheet {
  const factory Sheet({
    required int id,
    required String title,
    @Default(0) int index,
    int? rowCount,
    int? columnCount,
    @Default(false) bool hidden,
    String? colorHex,
  }) = _Sheet;

  factory Sheet.fromJson(Map<String, dynamic> json) => _$SheetFromJson(json);
}

@freezed
class SheetRange with _$SheetRange {
  const SheetRange._();

  const factory SheetRange({
    required String a1,
    required List<List<dynamic>> values,
    @Default('ROWS') String majorDimension,
  }) = _SheetRange;

  factory SheetRange.fromJson(Map<String, dynamic> json) =>
      _$SheetRangeFromJson(json);

  int get rowCount => values.length;
  int get columnCount =>
      values.fold<int>(0, (m, row) => row.length > m ? row.length : m);

  String? cell(int row, int col) {
    if (row >= values.length) return null;
    final r = values[row];
    if (col >= r.length) return null;
    return r[col]?.toString();
  }
}

@freezed
class SheetUpdateResult with _$SheetUpdateResult {
  const factory SheetUpdateResult({
    required String spreadsheetId,
    required String updatedRange,
    @Default(0) int updatedRows,
    @Default(0) int updatedColumns,
    @Default(0) int updatedCells,
  }) = _SheetUpdateResult;

  factory SheetUpdateResult.fromJson(Map<String, dynamic> json) =>
      _$SheetUpdateResultFromJson(json);
}
