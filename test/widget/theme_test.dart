import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_apis_flutter/core/config/app_config.dart';
import 'package:google_apis_flutter/core/theme/workspace_theme.dart';

void main() {
  group('WorkspaceTheme', () {
    test('builds light + dark themes for each flavor', () {
      for (final flavor in AppFlavor.values) {
        final cfg = AppConfig.fromFlavor(flavor);
        final theme = WorkspaceTheme.fromConfig(cfg);
        expect(theme.light.useMaterial3, true);
        expect(theme.dark.useMaterial3, true);
        expect(theme.dark.brightness, Brightness.dark);
      }
    });

    test('primary color derived from flavor hex', () {
      final base = AppConfig.fromFlavor(AppFlavor.base);
      final bizcalendar = AppConfig.fromFlavor(AppFlavor.bizcalendar);
      final t1 = WorkspaceTheme.fromConfig(base);
      final t2 = WorkspaceTheme.fromConfig(bizcalendar);
      // Different seed colors produce different schemes.
      expect(t1.light.colorScheme.primary !=
          t2.light.colorScheme.primary, true);
    });
  });
}
