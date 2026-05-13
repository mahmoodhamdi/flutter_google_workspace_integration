import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_apis_flutter/core/errors/app_error.dart';
import 'package:google_apis_flutter/features/google_gmail/domain/entities/gmail_message.dart';
import 'package:google_apis_flutter/features/google_gmail/presentation/providers/gmail_providers.dart';

class ComposeScreen extends ConsumerStatefulWidget {
  const ComposeScreen({
    super.key,
    this.replyTo,
    this.prefillTo,
    this.prefillSubject,
  });

  final String? replyTo;
  final String? prefillTo;
  final String? prefillSubject;

  @override
  ConsumerState<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends ConsumerState<ComposeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _to;
  late TextEditingController _cc;
  late TextEditingController _bcc;
  late TextEditingController _subject;
  late TextEditingController _body;
  bool _showCcBcc = false;
  bool _busy = false;
  AppError? _error;
  final List<MailAttachment> _attachments = <MailAttachment>[];

  @override
  void initState() {
    super.initState();
    _to = TextEditingController(text: widget.prefillTo);
    _cc = TextEditingController();
    _bcc = TextEditingController();
    _subject = TextEditingController(text: widget.prefillSubject);
    _body = TextEditingController();
  }

  @override
  void dispose() {
    _to.dispose();
    _cc.dispose();
    _bcc.dispose();
    _subject.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _pickAttachments() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return;
    for (final f in result.files) {
      if (f.path == null) continue;
      final bytes = await File(f.path!).readAsBytes();
      _attachments.add(MailAttachment(
        filename: f.name,
        mimeType: 'application/octet-stream',
        bytes: bytes,
      ));
    }
    if (mounted) setState(() {});
  }

  List<String> _split(TextEditingController c) =>
      c.text.split(RegExp(r'[,;\s]+')).where((s) => s.contains('@')).toList();

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    final to = _split(_to);
    if (to.isEmpty) {
      setState(() => _error = const AppError.validation(
            message: 'At least one recipient is required',
          ));
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final draft = GmailDraft(
      to: to,
      cc: _split(_cc),
      bcc: _split(_bcc),
      subject: _subject.text.trim(),
      bodyText: _body.text,
      attachments: _attachments,
      replyToMessageId: widget.replyTo,
    );
    final res = await ref.read(gmailRepositoryProvider).sendMessage(draft);
    if (!mounted) return;
    res.fold(
      (err) => setState(() {
        _busy = false;
        _error = err;
      }),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message sent')),
        );
        Navigator.of(context).pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compose'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: _pickAttachments,
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _busy ? null : _send,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _error!.userMessage,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                TextFormField(
                  controller: _to,
                  decoration: const InputDecoration(labelText: 'To'),
                  validator: (v) => v == null || !v.contains('@')
                      ? 'Enter a valid recipient'
                      : null,
                ),
                if (_showCcBcc) ...<Widget>[
                  TextFormField(
                    controller: _cc,
                    decoration: const InputDecoration(labelText: 'Cc'),
                  ),
                  TextFormField(
                    controller: _bcc,
                    decoration: const InputDecoration(labelText: 'Bcc'),
                  ),
                ] else
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: () => setState(() => _showCcBcc = true),
                      child: const Text('Cc / Bcc'),
                    ),
                  ),
                TextFormField(
                  controller: _subject,
                  decoration: const InputDecoration(labelText: 'Subject'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _body,
                  maxLines: 12,
                  minLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (_attachments.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Wrap(
                      spacing: 8,
                      children: _attachments
                          .map((a) => Chip(
                                label: Text(a.filename),
                                onDeleted: () {
                                  setState(() {
                                    _attachments.remove(a);
                                  });
                                },
                              ))
                          .toList(),
                    ),
                  ),
                if (_busy)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: LinearProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
