import 'package:flutter/material.dart';
import 'package:tubes_ppbl/utils/app_colors.dart';
import 'package:tubes_ppbl/models/peminjaman_alat.dart';
import 'package:tubes_ppbl/sqlite/koneksi.dart';

class PeminjamanFormScreen extends StatefulWidget {
  final PeminjamanAlat? peminjaman;
  const PeminjamanFormScreen({super.key, this.peminjaman});

  @override
  State<PeminjamanFormScreen> createState() => _PeminjamanFormScreenState();
}

class _PeminjamanFormScreenState extends State<PeminjamanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dbHelper = DatabaseHelper();
  final _namaAlatCtrl = TextEditingController();
  final _tanggalPinjamCtrl = TextEditingController();
  final _tenggatCtrl = TextEditingController();

  bool get _isEditing => widget.peminjaman != null;
  String _status = 'Dipinjam';
  bool _isSaving = false;

  final List<String> _statusOptions = ['Dipinjam', 'Dikembalikan'];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final p = widget.peminjaman!;
      _namaAlatCtrl.text = p.namaAlat;
      _tanggalPinjamCtrl.text = p.tanggalPinjam;
      _tenggatCtrl.text = p.tenggatKembali;
      _status = _statusOptions.contains(p.status) ? p.status : _statusOptions.first;
    }
  }

  @override
  void dispose() {
    _namaAlatCtrl.dispose();
    _tanggalPinjamCtrl.dispose();
    _tenggatCtrl.dispose();
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

  Future<void> _pickDate(TextEditingController ctrl) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
          data: Theme.of(ctx).copyWith(
              colorScheme:
                  const ColorScheme.light(primary: AppColors.sage)),
          child: child!),
    );
    if (picked != null) {
      ctrl.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final alat = PeminjamanAlat(
        id: widget.peminjaman?.id,
        namaAlat: _namaAlatCtrl.text,
        tanggalPinjam: _tanggalPinjamCtrl.text,
        tenggatKembali: _tenggatCtrl.text,
        status: _status,
      );

      if (_isEditing) {
        await _dbHelper.updatePeminjamanAlat(alat);
      } else {
        await _dbHelper.insertPeminjamanAlat(alat);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEditing
              ? 'Peminjaman diperbarui'
              : 'Peminjaman ditambahkan'),
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
            _isEditing ? 'Edit Peminjaman' : 'Tambah Peminjaman',
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
                controller: _namaAlatCtrl,
                decoration: _deco('Nama Alat', Icons.build_outlined),
                style: const TextStyle(color: AppColors.textPrimary),
                validator: (v) => v == null || v.isEmpty
                    ? 'Nama alat wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),


              TextFormField(
                controller: _tanggalPinjamCtrl,
                decoration:
                    _deco('Tanggal Pinjam', Icons.calendar_today_outlined)
                        .copyWith(
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.event,
                        color: AppColors.textMuted),
                    onPressed: () => _pickDate(_tanggalPinjamCtrl),
                  ),
                ),
                style: const TextStyle(color: AppColors.textPrimary),
                readOnly: true,
                onTap: () => _pickDate(_tanggalPinjamCtrl),
                validator: (v) => v == null || v.isEmpty
                    ? 'Tanggal pinjam wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),


              TextFormField(
                controller: _tenggatCtrl,
                decoration:
                    _deco('Tenggat Kembali', Icons.event_outlined)
                        .copyWith(
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.event,
                        color: AppColors.textMuted),
                    onPressed: () => _pickDate(_tenggatCtrl),
                  ),
                ),
                style: const TextStyle(color: AppColors.textPrimary),
                readOnly: true,
                onTap: () => _pickDate(_tenggatCtrl),
                validator: (v) => v == null || v.isEmpty
                    ? 'Tenggat kembali wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),


              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _status,
                decoration:
                    _deco('Status', Icons.flag_outlined),
                dropdownColor: AppColors.bgCard,
                style: const TextStyle(color: AppColors.textPrimary),
                items: _statusOptions.map((s) {
                  return DropdownMenuItem<String>(
                      value: s, child: Text(s));
                }).toList(),
                onChanged: (v) =>
                    setState(() => _status = v ?? 'Dipinjam'),
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
                  _isEditing
                      ? 'Perbarui Peminjaman'
                      : 'Simpan Peminjaman',
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
