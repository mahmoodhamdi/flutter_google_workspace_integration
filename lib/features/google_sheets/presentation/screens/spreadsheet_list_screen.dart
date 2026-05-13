import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_apis_flutter/features/google_sheets/presentation/providers/sheets_providers.dart';
import 'package:intl/intl.dart';

class SpreadsheetListScreen extends ConsumerWidget {
  const SpreadsheetListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(spreadsheetsListProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spreadsheets'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(spreadsheetsListProvider),
          ),
        ],
      ),
      body: async.when(
        data: (res) => res.fold(
          (err) => Center(child: Text(err.userMessage)),
          (list) {
            if (list.isEmpty) {
              return const Center(child: Text('No spreadsheets'));
            }
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(spreadsheetsListProvider),
              child: ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final s = list[i];
                  return ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.table_chart),
                    ),
                    title: Text(s.title),
                    subtitle: Text(s.id),
                    onTap: () => context.push('/sheets/${s.id}'),
                  );
                },
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createNew(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New'),
      ),
    );
  }

  Future<void> _createNew(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(
      text: 'New Sheet — ${DateFormat.yMd().format(DateTime.now())}',
    );
    final title = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Create spreadsheet'),
        content: TextField(controller: controller, autofocus: true),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (title == null || title.isEmpty) return;
    if (!context.mounted) return;
    final res = await ref
        .read(sheetsRepositoryProvider)
        .createSpreadsheet(title: title);
    if (!context.mounted) return;
    res.fold(
      (err) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err.userMessage)),
      ),
      (s) {
        ref.invalidate(spreadsheetsListProvider);
        context.push('/sheets/${s.id}');
      },
    );
  }
}
