import 'package:flutter/material.dart';
import 'package:google_apis_flutter/features/google_drive/domain/entities/drive_file.dart';

class StorageIndicator extends StatelessWidget {
  const StorageIndicator(this.quota, {super.key});
  final DriveStorageQuota quota;

  @override
  Widget build(BuildContext context) {
    if (quota.limitBytes == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final pct = quota.usagePercent.clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '${_fmt(quota.usageBytes)} of ${_fmt(quota.limitBytes!)} used',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: pct,
            backgroundColor:
                theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              pct > 0.9
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(int bytes) {
    const units = <String>['B', 'KB', 'MB', 'GB', 'TB'];
    double s = bytes.toDouble();
    int u = 0;
    while (s >= 1024 && u < units.length - 1) {
      s /= 1024;
      u++;
    }
    return '${s.toStringAsFixed(s < 10 ? 1 : 0)} ${units[u]}';
  }
}
