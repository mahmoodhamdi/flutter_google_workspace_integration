import 'package:google_apis_flutter/core/errors/result.dart';
import 'package:google_apis_flutter/features/google_gmail/domain/entities/gmail_message.dart';

abstract class GmailRepository {
  /// Send an email via `gmail.send`. The recipient's mailbox receives a
  /// real message; the sender's "Sent" folder records it.
  ///
  /// **Scope used**: `https://www.googleapis.com/auth/gmail.send` (sensitive).
  Future<Result<SentMessageReceipt>> sendMessage(GmailDraft draft);

  /// Returns an app-local log of messages this app has sent. The Gmail
  /// `gmail.send` scope does NOT grant read access; we maintain the log
  /// ourselves in Hive.
  Future<Result<List<SentMessageReceipt>>> listSentLocal({int limit = 100});

  Future<Result<void>> clearSentLocal();
}
