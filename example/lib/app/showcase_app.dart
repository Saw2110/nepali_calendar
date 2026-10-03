import 'package:flutter/material.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

import 'showcase_shell.dart';

/// The example app: Material 3 light and dark themes, and the package theme
/// on top of them.
class ShowcaseApp extends StatefulWidget {
  const ShowcaseApp({super.key});

  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

class _ShowcaseAppState extends State<ShowcaseApp> {
  ThemeMode _themeMode = ThemeMode.light;

  static const _seed = Color(0xFF2F49B5);

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nepali Calendar Plus',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _seed),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode,
      // The calendar theme goes above the Navigator, so it reaches every
      // route and dialog. `fromContext` reads the ambient Material
      // ColorScheme, so flipping themeMode restyles every calendar with no
      // other change.
      builder: (context, child) {
        return NepaliCalendarTheme(
          data: NepaliCalendarThemeData.fromContext(context),
          child: child!,
        );
      },
      home: ShowcaseShell(
        isDark: _themeMode == ThemeMode.dark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}
