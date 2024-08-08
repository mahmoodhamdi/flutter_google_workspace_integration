import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_apis_flutter/app.dart';
import 'package:google_apis_flutter/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
