import 'package:flutter_test/flutter_test.dart';
import 'package:google_apis_flutter/features/google_gmail/domain/entities/gmail_message.dart';

void main() {
  group('GmailDraft', () {
    test('to is required', () {
      const draft = GmailDraft(
        to: <String>['a@example.com'],
        subject: 's',
        bodyText: 'b',
      );
      expect(draft.to, hasLength(1));
    });

    test('JSON roundtrip with attachments and html body', () {
      const draft = GmailDraft(
        to: <String>['x@example.com'],
        cc: <String>['cc@example.com'],
        subject: 'Hello',
        bodyText: 'Plain body',
        bodyHtml: '<p>HTML body</p>',
        attachments: <MailAttachment>[
          MailAttachment(
            filename: 'doc.pdf',
            mimeType: 'application/pdf',
            bytes: <int>[1, 2, 3, 4],
          ),
        ],
      );
      final j = draft.toJson();
      final back = GmailDraft.fromJson(j);
      expect(back.to, draft.to);
      expect(back.cc, draft.cc);
      expect(back.bodyHtml, draft.bodyHtml);
      expect(back.attachments.length, 1);
      expect(back.attachments.first.bytes, <int>[1, 2, 3, 4]);
    });
  });

  group('SentMessageReceipt', () {
    test('captures recipients and subject', () {
      final r = SentMessageReceipt(
        messageId: 'm1',
        sentAt: DateTime.utc(2026, 5, 13),
        recipients: const <String>['a@b.com', 'c@d.com'],
        subject: 'Hi',
      );
      expect(r.recipients, hasLength(2));
      expect(r.subject, 'Hi');
    });
  });
}
