import 'package:freezed_annotation/freezed_annotation.dart';

part 'gmail_message.freezed.dart';
part 'gmail_message.g.dart';

/// A message to be composed/sent via the `gmail.send` scope.
///
/// We intentionally do not model received messages — reading mail requires
/// restricted scopes that trigger CASA assessment.
@freezed
class GmailDraft with _$GmailDraft {
  const factory GmailDraft({
    required List<String> to,
    @Default(<String>[]) List<String> cc,
    @Default(<String>[]) List<String> bcc,
    required String subject,
    required String bodyText,
    String? bodyHtml,
    @Default(<MailAttachment>[]) List<MailAttachment> attachments,
    String? replyToMessageId,
  }) = _GmailDraft;

  factory GmailDraft.fromJson(Map<String, dynamic> json) =>
      _$GmailDraftFromJson(json);
}

@freezed
class MailAttachment with _$MailAttachment {
  const factory MailAttachment({
    required String filename,
    required String mimeType,
    required List<int> bytes,
  }) = _MailAttachment;

  factory MailAttachment.fromJson(Map<String, dynamic> json) =>
      _$MailAttachmentFromJson(json);
}

@freezed
class SentMessageReceipt with _$SentMessageReceipt {
  const factory SentMessageReceipt({
    required String messageId,
    required DateTime sentAt,
    required List<String> recipients,
    required String subject,
  }) = _SentMessageReceipt;

  factory SentMessageReceipt.fromJson(Map<String, dynamic> json) =>
      _$SentMessageReceiptFromJson(json);
}
