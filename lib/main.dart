import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tubes_ppbl/utils/app_colors.dart';
import 'package:tubes_ppbl/sqlite/koneksi.dart';
import 'package:tubes_ppbl/screens/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global error boundary — displays the error on screen instead of blank white
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.bgPage,
        appBar: AppBar(
          title: const Text('LabLog — Error', style: TextStyle(color: Colors.white)),
          backgroundColor: AppColors.slate900,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Color(0xFFEF4444)),
                const SizedBox(height: 16),
                const Text(
                  'Terjadi Kesalahan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                Text(
                  details.exceptionAsString(),
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  };

  // Initialize SQLite database early
  try {
    await DatabaseHelper().database;
  } catch (e) {
    debugPrint('Database init error: $e');
  }

  // Read dark mode preference
  bool isDarkMode = false;
  try {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode = prefs.getBool('is_dark_mode') ?? false;
  } catch (e) {
    debugPrint('SharedPreferences error: $e');
  }

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
      home: const MainNavigation(),
    );
  }
}
