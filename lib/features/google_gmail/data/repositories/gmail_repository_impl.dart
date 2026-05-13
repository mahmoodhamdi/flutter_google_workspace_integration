import 'dart:convert';

import 'package:google_apis_flutter/core/errors/guard.dart';
import 'package:google_apis_flutter/core/errors/result.dart';
import 'package:google_apis_flutter/core/storage/hive_init.dart';
import 'package:google_apis_flutter/features/google_gmail/data/datasources/gmail_remote_datasource.dart';
import 'package:google_apis_flutter/features/google_gmail/domain/entities/gmail_message.dart';
import 'package:google_apis_flutter/features/google_gmail/domain/repositories/gmail_repository.dart';

class GmailRepositoryImpl implements GmailRepository {
  GmailRepositoryImpl(this._remote);

  final GmailRemoteDataSource _remote;
  static const String _sentBoxKey = 'sent_log';

  @override
  Future<Result<SentMessageReceipt>> sendMessage(GmailDraft draft) =>
      guard<SentMessageReceipt>(() async {
        final raw = await _remote.sendMime(draft);
        final receipt = SentMessageReceipt(
          messageId: raw.id ?? '',
          sentAt: DateTime.now().toUtc(),
          recipients: <String>[
            ...draft.to,
            ...draft.cc,
            ...draft.bcc,
          ],
          subject: draft.subject,
        );
        await _appendToLog(receipt);
        return receipt;
      }, operation: 'gmail.send');

  @override
  Future<Result<List<SentMessageReceipt>>> listSentLocal({
    int limit = 100,
  }) =>
      guard<List<SentMessageReceipt>>(() async {
        final box = cacheBox('drive'); // reuse a box
        final raw = box.get('$_sentBoxKey');
        if (raw == null) return const <SentMessageReceipt>[];
        final list = (jsonDecode(raw) as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(SentMessageReceipt.fromJson)
            .toList();
        list.sort((a, b) => b.sentAt.compareTo(a.sentAt));
        return list.take(limit).toList();
      }, operation: 'gmail.listSentLocal');

  @override
  Future<Result<void>> clearSentLocal() => guard<void>(() async {
        final box = cacheBox('drive');
        await box.delete(_sentBoxKey);
      }, operation: 'gmail.clearSentLocal');

  Future<void> _appendToLog(SentMessageReceipt receipt) async {
    try {
      final box = cacheBox('drive');
      final raw = box.get(_sentBoxKey);
      final list = raw == null
          ? <Map<String, dynamic>>[]
          : (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>();
      list.insert(0, receipt.toJson());
      await box.put(_sentBoxKey, jsonEncode(list.take(500).toList()));
    } catch (_) {
      // best-effort
    }
  }
}
