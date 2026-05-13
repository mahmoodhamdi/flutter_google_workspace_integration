/// Entry point for the SheetsOps vertical.
///
/// Build with: `flutter build apk -t lib/main_sheetsops.dart --dart-define=FLAVOR=sheetsops`
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_apis_flutter/app.dart';
import 'package:google_apis_flutter/core/storage/hive_init.dart';
import 'package:google_apis_flutter/core/utils/logger/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    appLog.w('Firebase init skipped: $e');
  }
  await HiveBootstrap.init();
  runApp(const ProviderScope(child: WorkspaceApp()));
}
