import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tubes_ppbl/utils/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nimController = TextEditingController();

  String _selectedSemester = 'Semester 1';
  String _ukuranFont = 'Sedang';
  bool _isDarkMode = false;
  bool _notifikasiAktif = true;

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

  final List<String> _fontOptions = ['Kecil', 'Sedang', 'Besar'];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nimController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _namaController.text = prefs.getString('nama_praktikan') ?? '';
      _nimController.text = prefs.getString('nim_praktikan') ?? '';
      _selectedSemester = prefs.getString('semester_aktif') ?? 'Semester 1';
      _ukuranFont = prefs.getString('ukuran_font') ?? 'Sedang';
      _isDarkMode = prefs.getBool('is_dark_mode') ?? false;
      _notifikasiAktif = prefs.getBool('notifikasi_aktif') ?? true;
      _isLoading = false;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nama_praktikan', _namaController.text);
    await prefs.setString('nim_praktikan', _nimController.text);
    await prefs.setString('semester_aktif', _selectedSemester);
    await prefs.setString('ukuran_font', _ukuranFont);
    await prefs.setBool('is_dark_mode', _isDarkMode);
    await prefs.setBool('notifikasi_aktif', _notifikasiAktif);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pengaturan berhasil disimpan'),
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
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      prefixIcon: Icon(icon, color: AppColors.textMuted),
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.sage),
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
        backgroundColor: AppColors.bgPage,
        appBar: AppBar(
          title: const Text('Pengaturan',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.slate900,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.sage),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: const Text('Pengaturan',
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
              // ── Section: Profil Praktikan ──────────────────────────
              _buildSectionHeader(Icons.person_outline, 'Profil Praktikan'),
              const SizedBox(height: 12),

              Card(
                color: AppColors.bgCard,
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
                            const TextStyle(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nimController,
                        decoration:
                            _inputDecoration('NIM', Icons.badge_outlined),
                        style:
                            const TextStyle(color: AppColors.textPrimary),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _selectedSemester,
                        decoration: _inputDecoration(
                            'Semester Aktif', Icons.school_outlined),
                        dropdownColor: AppColors.bgCard,
                        style:
                            const TextStyle(color: AppColors.textPrimary),
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

              const SizedBox(height: 24),

              // ── Section: Preferensi Tampilan ──────────────────────
              _buildSectionHeader(Icons.palette_outlined, 'Preferensi Tampilan'),
              const SizedBox(height: 12),

              Card(
                color: AppColors.bgCard,
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    // Ukuran Font dropdown
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _ukuranFont,
                        decoration: _inputDecoration(
                            'Ukuran Font', Icons.format_size_outlined),
                        dropdownColor: AppColors.bgCard,
                        style:
                            const TextStyle(color: AppColors.textPrimary),
                        items: _fontOptions.map((size) {
                          return DropdownMenuItem<String>(
                            value: size,
                            child: Text(size),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _ukuranFont = value ?? 'Sedang';
                          });
                        },
                      ),
                    ),

                    const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: AppColors.border),

                    // Dark Mode switch
                    SwitchListTile(
                      title: const Text('Dark Mode',
                          style: TextStyle(color: AppColors.textPrimary)),
                      subtitle: const Text(
                        'Aktifkan tema gelap untuk tampilan lebih nyaman',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12),
                      ),
                      value: _isDarkMode,
                      onChanged: (bool value) {
                        setState(() => _isDarkMode = value);
                      },
                      activeColor: AppColors.sage,
                      secondary: Icon(
                        _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        color: AppColors.textMuted,
                      ),
                    ),

                    const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: AppColors.border),

                    // Notifikasi switch
                    SwitchListTile(
                      title: const Text('Notifikasi',
                          style: TextStyle(color: AppColors.textPrimary)),
                      subtitle: const Text(
                        'Terima pengingat jadwal dan tenggat peminjaman',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12),
                      ),
                      value: _notifikasiAktif,
                      onChanged: (bool value) {
                        setState(() => _notifikasiAktif = value);
                      },
                      activeColor: AppColors.sage,
                      secondary: Icon(
                        _notifikasiAktif
                            ? Icons.notifications_active_outlined
                            : Icons.notifications_off_outlined,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Simpan Button ─────────────────────────────────────
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
                icon: const Icon(Icons.save_outlined, color: Colors.white),
                label: const Text(
                  'Simpan Pengaturan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── App Info ──────────────────────────────────────────
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
                      child: const Text(
                        'LabLog v1.0.0',
                        style: TextStyle(
                          color: AppColors.sageText,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Aplikasi Catatan Laboratorium',
                      style: TextStyle(
                          color: AppColors.textPlaceholder, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.slate700,
          ),
        ),
      ],
    );
  }
}
