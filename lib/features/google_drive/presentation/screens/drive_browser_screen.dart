import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_apis_flutter/features/google_drive/domain/entities/drive_file.dart';
import 'package:google_apis_flutter/features/google_drive/presentation/providers/drive_providers.dart';
import 'package:google_apis_flutter/features/google_drive/presentation/widgets/drive_file_tile.dart';
import 'package:google_apis_flutter/features/google_drive/presentation/widgets/storage_indicator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class DriveBrowserScreen extends ConsumerStatefulWidget {
  const DriveBrowserScreen({super.key, this.folderId, this.folderName});

  final String? folderId;
  final String? folderName;

  @override
  ConsumerState<DriveBrowserScreen> createState() => _DriveBrowserScreenState();
}

class _DriveBrowserScreenState extends ConsumerState<DriveBrowserScreen> {
  double? _uploadProgress;

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(driveListProvider(widget.folderId));
    final quotaAsync = ref.watch(driveQuotaProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folderName ?? 'Drive'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.create_new_folder_outlined),
            onPressed: _createFolder,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(driveListProvider(widget.folderId)),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          quotaAsync.maybeWhen(
            data: (res) => res.fold(
              (_) => const SizedBox.shrink(),
              StorageIndicator.new,
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          if (_uploadProgress != null)
            LinearProgressIndicator(value: _uploadProgress),
          Expanded(
            child: listAsync.when(
              data: (res) => res.fold(
                (err) => Center(child: Text(err.userMessage)),
                (list) => list.files.isEmpty
                    ? const Center(child: Text('Empty folder'))
                    : RefreshIndicator(
                        onRefresh: () async => ref
                            .invalidate(driveListProvider(widget.folderId)),
                        child: ListView.separated(
                          itemCount: list.files.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final f = list.files[i];
                            return DriveFileTile(
                              file: f,
                              onTap: () => _onTap(f),
                              onShare: () => _share(f),
                              onDelete: () => _confirmDelete(f),
                              onRename: () => _rename(f),
                            );
                          },
                        ),
                      ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploadFile,
        icon: const Icon(Icons.upload),
        label: const Text('Upload'),
      ),
    );
  }

  void _onTap(DriveFile f) {
    if (f.isFolder) {
      context.push(
        '/drive/folder/${f.id}',
        extra: <String, String?>{'name': f.name},
      );
    } else {
      _downloadAndShare(f);
    }
  }

  Future<void> _downloadAndShare(DriveFile f) async {
    final dir = await getTemporaryDirectory();
    final dest = File('${dir.path}/${f.name}');
    setState(() => _uploadProgress = 0);
    final repo = ref.read(driveRepositoryProvider);
    final res = await repo.downloadFile(
      fileId: f.id,
      destination: dest,
      onProgress: (p) {
        if (mounted) {
          setState(() {
            _uploadProgress = p.totalBytes == 0
                ? null
                : p.bytesUploaded / p.totalBytes;
          });
        }
      },
    );
    if (!mounted) return;
    setState(() => _uploadProgress = null);
    res.fold(
      (err) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err.userMessage)),
      ),
      (file) async {
        await Share.shareXFiles(<XFile>[XFile(file.path)]);
      },
    );
  }

  Future<void> _uploadFile() async {
    final pick = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (pick == null || pick.files.isEmpty) return;
    final path = pick.files.single.path;
    if (path == null) return;
    final file = File(path);
    if (!mounted) return;
    setState(() => _uploadProgress = 0);
    final repo = ref.read(driveRepositoryProvider);
    final res = await repo.uploadFile(
      file: file,
      name: pick.files.single.name,
      parentFolderId: widget.folderId,
      onProgress: (p) {
        if (mounted) {
          setState(() {
            _uploadProgress = p.totalBytes == 0
                ? null
                : p.bytesUploaded / p.totalBytes;
          });
        }
      },
    );
    if (!mounted) return;
    setState(() => _uploadProgress = null);
    res.fold(
      (err) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err.userMessage)),
      ),
      (_) {
        ref.invalidate(driveListProvider(widget.folderId));
      },
    );
  }

  Future<void> _createFolder() async {
    final name = await _promptText(context, 'New folder name');
    if (name == null || name.isEmpty) return;
    if (!mounted) return;
    final res = await ref
        .read(driveRepositoryProvider)
        .createFolder(name: name, parentFolderId: widget.folderId);
    if (!mounted) return;
    res.fold(
      (err) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err.userMessage)),
      ),
      (_) => ref.invalidate(driveListProvider(widget.folderId)),
    );
  }

  Future<void> _share(DriveFile f) async {
    final email = await _promptText(context, 'Share with email');
    if (email == null || email.isEmpty) return;
    if (!mounted) return;
    final res = await ref.read(driveRepositoryProvider).shareFile(
          fileId: f.id,
          role: PermissionRole.reader,
          type: PermissionType.user,
          emailAddress: email,
        );
    if (!mounted) return;
    res.fold(
      (err) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err.userMessage)),
      ),
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Shared with $email')),
      ),
    );
  }

  Future<void> _confirmDelete(DriveFile f) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete "${f.name}"?'),
        content: const Text('This cannot be undone.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final res = await ref.read(driveRepositoryProvider).deleteFile(f.id);
    if (!mounted) return;
    res.fold(
      (err) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err.userMessage)),
      ),
      (_) => ref.invalidate(driveListProvider(widget.folderId)),
    );
  }

  Future<void> _rename(DriveFile f) async {
    final newName = await _promptText(context, 'Rename', initial: f.name);
    if (newName == null || newName.isEmpty || newName == f.name) return;
    if (!mounted) return;
    final res = await ref
        .read(driveRepositoryProvider)
        .renameFile(fileId: f.id, newName: newName);
    if (!mounted) return;
    res.fold(
      (err) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err.userMessage)),
      ),
      (_) => ref.invalidate(driveListProvider(widget.folderId)),
    );
  }
}

Future<String?> _promptText(BuildContext ctx, String label,
    {String? initial}) {
  final ctrl = TextEditingController(text: initial);
  return showDialog<String>(
    context: ctx,
    builder: (_) => AlertDialog(
      title: Text(label),
      content: TextField(controller: ctrl, autofocus: true),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
