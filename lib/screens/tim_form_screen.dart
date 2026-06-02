import 'package:flutter/material.dart';
import 'package:tubes_ppbl/utils/app_colors.dart';
import 'package:tubes_ppbl/models/tim_kelompok.dart';
import 'package:tubes_ppbl/sqlite/koneksi.dart';

class TimFormScreen extends StatefulWidget {
  final int mkId;
  final TimKelompok? timKelompok;
  const TimFormScreen({super.key, required this.mkId, this.timKelompok});

  @override
  State<TimFormScreen> createState() => _TimFormScreenState();
}

class _TimFormScreenState extends State<TimFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dbHelper = DatabaseHelper();
  final _namaCtrl = TextEditingController();
  final _nimCtrl = TextEditingController();
  final _noHpCtrl = TextEditingController();

  bool get _isEditing => widget.timKelompok != null;
  String _peran = 'Anggota';
  bool _isSaving = false;

  final List<String> _peranOptions = ['Ketua', 'Anggota'];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final t = widget.timKelompok!;
      _namaCtrl.text = t.namaAnggota;
      _nimCtrl.text = t.nim;
      _noHpCtrl.text = t.noHp;
      _peran = t.peran;
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _nimCtrl.dispose();
    _noHpCtrl.dispose();
    super.dispose();
  }

  InputDecoration _deco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      prefixIcon: Icon(icon, color: AppColors.textMuted),
      border: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.sage),
          borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: AppColors.bgCard,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final tim = TimKelompok(
        id: widget.timKelompok?.id,
        mkId: widget.mkId,
        namaAnggota: _namaCtrl.text,
        nim: _nimCtrl.text,
        peran: _peran,
        noHp: _noHpCtrl.text,
      );

      if (_isEditing) {
        await _dbHelper.updateTimKelompok(tim);
      } else {
        await _dbHelper.insertTimKelompok(tim);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              _isEditing ? 'Anggota diperbarui' : 'Anggota ditambahkan'),
          backgroundColor: AppColors.sage,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8))));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: const Color(0xFFEF4444)));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: Text(
            _isEditing ? 'Edit Anggota' : 'Tambah Anggota',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.slate900,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _namaCtrl,
                decoration: _deco('Nama Anggota', Icons.person_outline),
                style: const TextStyle(color: AppColors.textPrimary),
                validator: (v) => v == null || v.isEmpty
                    ? 'Nama wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nimCtrl,
                decoration: _deco('NIM', Icons.badge_outlined),
                style: const TextStyle(color: AppColors.textPrimary),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty
                    ? 'NIM wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _noHpCtrl,
                decoration: _deco('No HP', Icons.phone_outlined),
                style: const TextStyle(color: AppColors.textPrimary),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _peran,
                decoration: _deco('Peran', Icons.assignment_ind_outlined),
                dropdownColor: AppColors.bgCard,
                style: const TextStyle(color: AppColors.textPrimary),
                items: _peranOptions.map((p) {
                  return DropdownMenuItem<String>(
                      value: p, child: Text(p));
                }).toList(),
                onChanged: (v) =>
                    setState(() => _peran = v ?? 'Anggota'),
              ),

              const SizedBox(height: 32),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sage,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                onPressed: _isSaving ? null : _save,
                icon: Icon(
                    _isEditing
                        ? Icons.save_outlined
                        : Icons.add_circle_outline,
                    color: Colors.white),
                label: Text(
                  _isEditing ? 'Perbarui Anggota' : 'Simpan Anggota',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
