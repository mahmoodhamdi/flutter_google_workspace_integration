import 'dart:convert';
import 'dart:typed_data';

import 'package:google_apis_flutter/core/auth/data/google_sign_in_service.dart';
import 'package:google_apis_flutter/core/errors/app_error.dart';
import 'package:google_apis_flutter/core/utils/constants/api_constants.dart';
import 'package:google_apis_flutter/features/google_gmail/domain/entities/gmail_message.dart';
import 'package:googleapis/gmail/v1.dart' as ggmail;

class GmailRemoteDataSource {
  GmailRemoteDataSource(this._signIn);
  final GoogleSignInService _signIn;

  Future<ggmail.GmailApi> _api() async {
    final client =
        await _signIn.authClient(scopes: ApiConstants.gmailSendScopes);
    if (client == null) {
      throw const AppError.unauthorized(message: 'Not signed in');
    }
    return ggmail.GmailApi(client);
  }

  Future<ggmail.Message> sendMime(GmailDraft draft) async {
    final api = await _api();
    final mime = _buildMimeMessage(draft);
    final encoded = base64Url.encode(utf8.encode(mime)).replaceAll('=', '');
    final msg = ggmail.Message(raw: encoded);
    return api.users.messages.send(msg, 'me');
  }

  String _buildMimeMessage(GmailDraft draft) {
    final hasAttachments = draft.attachments.isNotEmpty;
    final mixedBoundary = '----=_GWS_${DateTime.now().millisecondsSinceEpoch}';
    final altBoundary = '----=_GWS_ALT_${DateTime.now().millisecondsSinceEpoch}';

    final headers = <String>[
      'MIME-Version: 1.0',
      'To: ${draft.to.join(', ')}',
      if (draft.cc.isNotEmpty) 'Cc: ${draft.cc.join(', ')}',
      if (draft.bcc.isNotEmpty) 'Bcc: ${draft.bcc.join(', ')}',
      'Subject: =?utf-8?B?${base64.encode(utf8.encode(draft.subject))}?=',
      if (draft.replyToMessageId != null)
        'In-Reply-To: <${draft.replyToMessageId}>',
    ];

    final altPart = StringBuffer()
      ..writeln('Content-Type: multipart/alternative; boundary="$altBoundary"')
      ..writeln()
      ..writeln('--$altBoundary')
      ..writeln('Content-Type: text/plain; charset=UTF-8')
      ..writeln('Content-Transfer-Encoding: base64')
      ..writeln()
      ..writeln(_chunk(base64.encode(utf8.encode(draft.bodyText))));
    if (draft.bodyHtml != null) {
      altPart
        ..writeln('--$altBoundary')
        ..writeln('Content-Type: text/html; charset=UTF-8')
        ..writeln('Content-Transfer-Encoding: base64')
        ..writeln()
        ..writeln(_chunk(base64.encode(utf8.encode(draft.bodyHtml!))));
    }
    altPart.writeln('--$altBoundary--');

    if (!hasAttachments) {
      return <String>[
        ...headers,
        'Content-Type: multipart/alternative; boundary="$altBoundary"',
        '',
        altPart.toString().replaceFirst(
              'Content-Type: multipart/alternative; boundary="$altBoundary"\n\n',
              '',
            ),
      ].join('\r\n');
    }

    final body = StringBuffer()
      ..writeln('--$mixedBoundary')
      ..writeln(altPart.toString())
      ..writeln();
    for (final att in draft.attachments) {
      body
        ..writeln('--$mixedBoundary')
        ..writeln('Content-Type: ${att.mimeType}; name="${att.filename}"')
        ..writeln('Content-Transfer-Encoding: base64')
        ..writeln(
            'Content-Disposition: attachment; filename="${att.filename}"')
        ..writeln()
        ..writeln(_chunk(base64.encode(Uint8List.fromList(att.bytes))));
    }
    body.writeln('--$mixedBoundary--');

    return <String>[
      ...headers,
      'Content-Type: multipart/mixed; boundary="$mixedBoundary"',
      '',
      body.toString(),
    ].join('\r\n');
  }

  String _chunk(String b, [int width = 76]) {
    final out = StringBuffer();
    for (var i = 0; i < b.length; i += width) {
      out.writeln(b.substring(i, i + width > b.length ? b.length : i + width));
    }
    return out.toString().trimRight();
  }
}
