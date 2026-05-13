import 'package:flutter/material.dart';
import 'package:google_apis_flutter/core/config/app_config.dart';

class WorkspaceTheme {
  const WorkspaceTheme._({required this.light, required this.dark});

  factory WorkspaceTheme.fromConfig(AppConfig config) {
    final primary = _parseHex(config.primaryColorHex);
    final lightScheme = ColorScheme.fromSeed(
      seedColor: primary,
    );
    final darkScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    );
    return WorkspaceTheme._(
      light: _build(lightScheme, false),
      dark: _build(darkScheme, true),
    );
  }

  final ThemeData light;
  final ThemeData dark;

  static Color _parseHex(String hex) {
    var s = hex.replaceFirst('#', '');
    if (s.length == 6) s = 'FF$s';
    return Color(int.parse(s, radix: 16));
  }

  static ThemeData _build(ColorScheme scheme, bool dark) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: scheme.outlineVariant.withOpacity(0.3),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
