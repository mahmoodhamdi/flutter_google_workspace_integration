import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_apis_flutter/core/auth/biometric_gate.dart';
import 'package:google_apis_flutter/core/config/app_config.dart';
import 'package:google_apis_flutter/core/routing/app_router.dart';
import 'package:google_apis_flutter/core/theme/workspace_theme.dart';

class WorkspaceApp extends ConsumerWidget {
  const WorkspaceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = AppConfig.fromEnvironment();
    final router = ref.watch(appRouterProvider);
    final theme = WorkspaceTheme.fromConfig(config);
    return BiometricGate(
      // Off by default; the UX is opt-in from settings. (We keep the gate
      // available so a buyer can enable it with one line of code.)
      enabled: false,
      child: MaterialApp.router(
        title: config.appName,
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: theme.light,
        darkTheme: theme.dark,
        routerConfig: router,
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const <Locale>[
          Locale('en'),
          Locale('ar'),
        ],
      ),
    );
  }
}

/// Backwards-compatible alias for code that imported the original symbol.
class MyApp extends WorkspaceApp {
  const MyApp({super.key});
}
