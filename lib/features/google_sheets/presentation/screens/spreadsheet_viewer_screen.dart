import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_apis_flutter/features/google_sheets/presentation/providers/sheets_providers.dart';

class SpreadsheetViewerScreen extends ConsumerStatefulWidget {
  const SpreadsheetViewerScreen({super.key, required this.spreadsheetId});
  final String spreadsheetId;

  @override
  ConsumerState<SpreadsheetViewerScreen> createState() =>
      _SpreadsheetViewerScreenState();
}

class _SpreadsheetViewerScreenState
    extends ConsumerState<SpreadsheetViewerScreen> {
  String _activeRange = 'A1:Z50';

  @override
  Widget build(BuildContext context) {
    final metaAsync =
        ref.watch(spreadsheetByIdProvider(widget.spreadsheetId));
    return Scaffold(
      appBar: AppBar(
        title: metaAsync.maybeWhen(
          data: (res) => Text(res.fold(
            (_) => 'Spreadsheet',
            (s) => s.title,
          )),
          orElse: () => const Text('Spreadsheet'),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(sheetRangeProvider(
              SheetRangeKey(
                spreadsheetId: widget.spreadsheetId,
                range: _activeRange,
              ),
            )),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          metaAsync.maybeWhen(
            data: (res) => res.fold(
              (_) => const SizedBox.shrink(),
              (s) => s.sheets.isEmpty
                  ? const SizedBox.shrink()
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: s.sheets
                            .map((sheet) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 8,
                                  ),
                                  child: ChoiceChip(
                                    label: Text(sheet.title),
                                    selected:
                                        _activeRange.startsWith(sheet.title),
                                    onSelected: (_) {
                                      setState(() {
                                        _activeRange = '${sheet.title}!A1:Z200';
                                      });
                                    },
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          Expanded(child: _buildGrid()),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    final rangeAsync = ref.watch(sheetRangeProvider(
      SheetRangeKey(
        spreadsheetId: widget.spreadsheetId,
        range: _activeRange,
      ),
    ));
    return rangeAsync.when(
      data: (res) => res.fold(
        (err) => Center(child: Text(err.userMessage)),
        (range) {
          if (range.values.isEmpty) {
            return const Center(child: Text('Empty range'));
          }
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: List<DataColumn>.generate(
                  range.columnCount,
                  (i) => DataColumn(label: Text(_columnLetter(i))),
                ),
                rows: range.values
                    .map((row) => DataRow(
                          cells: List<DataCell>.generate(
                            range.columnCount,
                            (i) => DataCell(
                              Text(
                                i < row.length
                                    ? (row[i]?.toString() ?? '')
                                    : '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
    );
  }

  String _columnLetter(int idx) {
    String r = '';
    int n = idx;
    do {
      r = String.fromCharCode(65 + n % 26) + r;
      n = n ~/ 26 - 1;
    } while (n >= 0);
    return r;
  }
}
