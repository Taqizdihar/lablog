import 'package:flutter/material.dart';
import 'package:tubes_ppbl/utils/app_colors.dart';
import 'package:tubes_ppbl/models/mata_kuliah.dart';
import 'package:tubes_ppbl/sqlite/koneksi.dart';

class MkFormScreen extends StatefulWidget {
  final MataKuliah? mataKuliah;

  const MkFormScreen({super.key, this.mataKuliah});

  @override
  State<MkFormScreen> createState() => _MkFormScreenState();
}

class _MkFormScreenState extends State<MkFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _dosenController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  String _selectedSemester = 'Semester 1';
  String _selectedWarna = 'mkBlue';

  bool get _isEditing => widget.mataKuliah != null;

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

  final Map<String, Color> _warnaOptions = {
    'mkBlue': AppColors.mkBlue,
    'mkGreen': AppColors.mkGreen,
    'mkYellow': AppColors.mkYellow,
    'mkPurple': AppColors.mkPurple,
    'mkRose': AppColors.mkRose,
  };

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _namaController.text = widget.mataKuliah!.namaMk;
      _dosenController.text = widget.mataKuliah!.dosen;
      final sem = widget.mataKuliah!.semester;
      _selectedSemester = _semesterOptions.contains(sem) ? sem : _semesterOptions.first;
      final warna = widget.mataKuliah!.warnaLabel;
      _selectedWarna = _warnaOptions.containsKey(warna) ? warna : _warnaOptions.keys.first;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _dosenController.dispose();
    super.dispose();
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

  Future<void> _saveMataKuliah() async {
    if (!_formKey.currentState!.validate()) return;

    final mk = MataKuliah(
      id: widget.mataKuliah?.id,
      namaMk: _namaController.text,
      dosen: _dosenController.text,
      semester: _selectedSemester,
      warnaLabel: _selectedWarna,
    );

    if (_isEditing) {
      await _dbHelper.updateMataKuliah(mk);
    } else {
      await _dbHelper.insertMataKuliah(mk);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Mata Kuliah berhasil diperbarui'
              : 'Mata Kuliah berhasil ditambahkan'),
          backgroundColor: AppColors.sage,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Mata Kuliah' : 'Tambah Mata Kuliah',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.slate900,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _namaController,
                decoration: _inputDecoration('Nama Mata Kuliah', Icons.book_outlined),
                style: const TextStyle(color: AppColors.slate900),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama mata kuliah wajib diisi';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _dosenController,
                decoration: _inputDecoration('Dosen Pengampu', Icons.person_outline),
                style: const TextStyle(color: AppColors.slate900),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Dosen pengampu wajib diisi';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _selectedSemester,
                decoration: _inputDecoration('Semester', Icons.calendar_today_outlined),
                dropdownColor: Theme.of(context).cardColor,
                style: const TextStyle(color: AppColors.slate900),
                items: _semesterOptions.map((semester) {
                  return DropdownMenuItem<String>(
                    value: semester,
                    child: Text(semester, style: const TextStyle(color: AppColors.slate900)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSemester = value ?? 'Semester 1';
                  });
                },
              ),

              SizedBox(height: 24),
              Text(
                'Warna Label',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              SizedBox(height: 12),


              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _warnaOptions.entries.map((entry) {
                  final isSelected = _selectedWarna == entry.key;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedWarna = entry.key;
                      });
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: entry.value,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.sage : AppColors.border,
                          width: isSelected ? 3 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.sage.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                )
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? Icon(Icons.check, color: AppColors.sage, size: 24)
                          : null,
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: 32),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sage,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _saveMataKuliah,
                icon: Icon(
                  _isEditing ? Icons.save_outlined : Icons.add_circle_outline,
                  color: Colors.white,
                ),
                label: Text(
                  _isEditing ? 'Perbarui Mata Kuliah' : 'Simpan Mata Kuliah',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
