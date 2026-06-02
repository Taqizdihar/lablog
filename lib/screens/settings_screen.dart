import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tubes_ppbl/utils/app_colors.dart';
import 'package:tubes_ppbl/main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nimController = TextEditingController();
  final _programStudiController = TextEditingController();
  final _targetIpkController = TextEditingController();

  String _selectedSemester = 'Semester 1';
  bool _isDarkMode = false;

  bool _isLoading = true;

  final List<String> _semesterOptions = [
    'Semester 1',
    'Semester 2',
    'Semester 3',
    'Semester 4',
    'Semester 5',
    'Semester 6',
    'Semester 7',
    'Semester 8',
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nimController.dispose();
    _programStudiController.dispose();
    _targetIpkController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _namaController.text = prefs.getString('nama_praktikan') ?? '';
      _nimController.text = prefs.getString('nim_praktikan') ?? '';
      _programStudiController.text = prefs.getString('program_studi') ?? '';
      _targetIpkController.text = prefs.getString('target_ipk') ?? '';
      _selectedSemester = prefs.getString('semester_aktif') ?? 'Semester 1';
      _isDarkMode = prefs.getBool('is_dark_mode') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nama_praktikan', _namaController.text);
    await prefs.setString('nim_praktikan', _nimController.text);
    await prefs.setString('program_studi', _programStudiController.text);
    await prefs.setString('target_ipk', _targetIpkController.text);
    await prefs.setString('semester_aktif', _selectedSemester);
    await prefs.setBool('is_dark_mode', _isDarkMode);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pengaturan berhasil disimpan'),
          backgroundColor: AppColors.sage,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
      prefixIcon: Icon(icon, color: AppColors.textMuted),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.sage),
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: AppColors.bgCard,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text('Pengaturan',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.slate900,
        ),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.sage),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Pengaturan',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.slate900,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              _buildSectionHeader(Icons.person_outline, 'Profil Praktikan'),
              SizedBox(height: 12),

              Card(
                color: Theme.of(context).cardColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _namaController,
                        decoration: _inputDecoration(
                            'Nama Lengkap', Icons.person_outline),
                        style:
                            TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _nimController,
                        decoration:
                            _inputDecoration('NIM', Icons.badge_outlined),
                        style:
                            TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _programStudiController,
                        decoration: _inputDecoration(
                            'Program Studi', Icons.school_outlined),
                        style:
                            TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _targetIpkController,
                        decoration: _inputDecoration(
                            'Target IPK', Icons.analytics_outlined),
                        style:
                            TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedSemester,
                        decoration: _inputDecoration(
                            'Semester Aktif', Icons.calendar_today_outlined),
                        dropdownColor: Theme.of(context).cardColor,
                        style:
                            TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                        items: _semesterOptions.map((semester) {
                          return DropdownMenuItem<String>(
                            value: semester,
                            child: Text(semester),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSemester = value ?? 'Semester 1';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),


              _buildSectionHeader(Icons.palette_outlined, 'Preferensi Tampilan'),
              SizedBox(height: 12),

              Card(
                color: Theme.of(context).cardColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text('Dark Mode',
                          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                      subtitle: Text(
                        'Aktifkan tema gelap untuk tampilan lebih nyaman',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12),
                      ),
                      value: _isDarkMode,
                      onChanged: (bool value) async {
                        setState(() => _isDarkMode = value);
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('is_dark_mode', value);
                        themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
                      },
                      activeThumbColor: AppColors.sage,
                      secondary: Icon(
                        _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        color: AppColors.textMuted,
                      ),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),

              SizedBox(height: 32),


              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sage,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                onPressed: _savePreferences,
                icon: Icon(Icons.save_outlined, color: Colors.white),
                label: Text(
                  'Simpan Pengaturan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: 24),


              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.sageBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'LabLog v1.0.0',
                        style: TextStyle(
                          color: AppColors.sageText,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Aplikasi Catatan Laboratorium',
                      style: TextStyle(
                          color: AppColors.textPlaceholder, fontSize: 12),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.sageBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.sage, size: 20),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
      ],
    );
  }
}
