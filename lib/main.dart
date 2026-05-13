import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_apis_flutter/app.dart';
import 'package:google_apis_flutter/core/storage/hive_init.dart';
import 'package:google_apis_flutter/core/utils/logger/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  try {
    await Firebase.initializeApp();
  } catch (e, st) {
    appLog.w(
      'Firebase init skipped: ${e.toString().split('\n').first}',
      stackTrace: st,
    );
  }

  await HiveBootstrap.init();

  runApp(const ProviderScope(child: WorkspaceApp()));
}
