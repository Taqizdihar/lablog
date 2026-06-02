import 'package:flutter/material.dart';
import 'package:tubes_ppbl/utils/app_colors.dart';
import 'package:tubes_ppbl/models/referensi.dart';
import 'package:tubes_ppbl/sqlite/koneksi.dart';

class ReferensiFormScreen extends StatefulWidget {
  final int mkId;
  final Referensi? referensi;
  const ReferensiFormScreen({super.key, required this.mkId, this.referensi});

  @override
  State<ReferensiFormScreen> createState() => _ReferensiFormScreenState();
}

class _ReferensiFormScreenState extends State<ReferensiFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dbHelper = DatabaseHelper();
  final _judulCtrl = TextEditingController();
  final _penulisCtrl = TextEditingController();
  final _tahunCtrl = TextEditingController();
  final _tautanCtrl = TextEditingController();

  bool get _isEditing => widget.referensi != null;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final r = widget.referensi!;
      _judulCtrl.text = r.judulBuku;
      _penulisCtrl.text = r.penulis;
      _tahunCtrl.text = r.tahunTerbit;
      _tautanCtrl.text = r.tautanSumber;
    }
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _penulisCtrl.dispose();
    _tahunCtrl.dispose();
    _tautanCtrl.dispose();
    super.dispose();
  }

  InputDecoration _deco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
      prefixIcon: Icon(icon, color: AppColors.textMuted),
      border: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.sage),
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
      final ref = Referensi(
        id: widget.referensi?.id,
        mkId: widget.mkId,
        judulBuku: _judulCtrl.text,
        penulis: _penulisCtrl.text,
        tahunTerbit: _tahunCtrl.text,
        tautanSumber: _tautanCtrl.text,
      );

      if (_isEditing) {
        await _dbHelper.updateReferensi(ref);
      } else {
        await _dbHelper.insertReferensi(ref);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              _isEditing ? 'Referensi diperbarui' : 'Referensi ditambahkan'),
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
            backgroundColor: Color(0xFFEF4444)));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
            _isEditing ? 'Edit Referensi' : 'Tambah Referensi',
            style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.slate900,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _judulCtrl,
                decoration:
                    _deco('Judul Buku / Jurnal', Icons.menu_book_outlined),
                style: const TextStyle(color: AppColors.slate900),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Judul wajib diisi' : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _penulisCtrl,
                decoration: _deco('Penulis', Icons.person_outline),
                style: const TextStyle(color: AppColors.slate900),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Penulis wajib diisi' : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _tahunCtrl,
                decoration:
                    _deco('Tahun Terbit', Icons.calendar_today_outlined),
                style: const TextStyle(color: AppColors.slate900),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Tahun wajib diisi' : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _tautanCtrl,
                decoration: _deco('Tautan Sumber (opsional)', Icons.link),
                style: const TextStyle(color: AppColors.slate900),
                keyboardType: TextInputType.url,
              ),

              SizedBox(height: 32),

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
                  _isEditing ? 'Perbarui Referensi' : 'Simpan Referensi',
                  style: TextStyle(
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
