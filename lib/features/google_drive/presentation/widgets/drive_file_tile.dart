import 'package:flutter/material.dart';
import 'package:google_apis_flutter/features/google_drive/domain/entities/drive_file.dart';
import 'package:intl/intl.dart';

class DriveFileTile extends StatelessWidget {
  const DriveFileTile({
    super.key,
    required this.file,
    required this.onTap,
    required this.onShare,
    required this.onDelete,
    required this.onRename,
  });

  final DriveFile file;
  final VoidCallback onTap;
  final VoidCallback onShare;
  final VoidCallback onDelete;
  final VoidCallback onRename;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final modified = file.modifiedTime;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Icon(_iconFor(file.mimeType),
            color: theme.colorScheme.onPrimaryContainer),
      ),
      title: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        <String>[
          if (file.sizeBytes != null) file.formattedSize,
          if (modified != null) DateFormat.yMMMd().format(modified.toLocal()),
        ].join(' · '),
      ),
      trailing: PopupMenuButton<String>(
        itemBuilder: (_) => const <PopupMenuEntry<String>>[
          PopupMenuItem<String>(value: 'rename', child: Text('Rename')),
          PopupMenuItem<String>(value: 'share', child: Text('Share')),
          PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
        ],
        onSelected: (v) {
          switch (v) {
            case 'rename':
              onRename();
            case 'share':
              onShare();
            case 'delete':
              onDelete();
          }
        },
      ),
      onTap: onTap,
    );
  }

  IconData _iconFor(String mime) {
    if (mime.contains('folder')) return Icons.folder;
    if (mime.contains('image')) return Icons.image;
    if (mime.contains('pdf')) return Icons.picture_as_pdf;
    if (mime.contains('video')) return Icons.video_file;
    if (mime.contains('audio')) return Icons.audio_file;
    if (mime.contains('spreadsheet')) return Icons.table_chart;
    if (mime.contains('document')) return Icons.description;
    if (mime.contains('presentation')) return Icons.slideshow;
    return Icons.insert_drive_file;
  }
}
