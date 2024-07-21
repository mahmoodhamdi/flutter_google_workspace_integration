import 'package:flutter/material.dart';
import 'package:google_apis_flutter/presentation/pages/home_page.dart';
import 'package:google_apis_flutter/utils/themes/theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      title: 'Google APIs Flutter Integrator',
      home: const HomePage(),
    );
  }
}
