import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tubes_ppbl/utils/app_colors.dart';
import 'package:tubes_ppbl/sqlite/koneksi.dart';
import 'package:tubes_ppbl/screens/home_screen.dart';
import 'package:tubes_ppbl/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Initialize sqflite for Web without worker (easier setup)
    databaseFactory = databaseFactoryFfiWebNoWebWorker;
  } else if (defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.linux) {
    // Initialize sqflite for Windows/Linux desktop
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize SQLite database early
  await DatabaseHelper().database;

  // Read dark mode preference
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('is_dark_mode') ?? false;

  runApp(LabLogApp(isDarkMode: isDarkMode));
}

class LabLogApp extends StatefulWidget {
  final bool isDarkMode;
  const LabLogApp({super.key, required this.isDarkMode});

  @override
  State<LabLogApp> createState() => _LabLogAppState();
}

class _LabLogAppState extends State<LabLogApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }

  // Light theme using AppColors
  ThemeData get _lightTheme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.bgPage,
    primaryColor: AppColors.slate900,
    colorScheme: ColorScheme.light(
      primary: AppColors.sage,
      secondary: AppColors.sage,
      surface: AppColors.bgCard,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.slate900,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.sage,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.sage,
        foregroundColor: Colors.white,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: AppColors.bgCard,
    ),
    cardTheme: CardThemeData(
      color: AppColors.bgCard,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerColor: AppColors.border,
  );

  // Dark theme using AppColors as base
  ThemeData get _darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    primaryColor: AppColors.slate900,
    colorScheme: ColorScheme.dark(
      primary: AppColors.sage,
      secondary: AppColors.sage,
      surface: const Color(0xFF1E293B),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0F172A),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.sage,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.sage,
        foregroundColor: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E293B),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerColor: const Color(0xFF334155),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LabLog',
      debugShowCheckedModeBanner: false,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const HomeScreen(),
      routes: {
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
