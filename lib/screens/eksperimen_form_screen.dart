import 'package:flutter/material.dart';
import 'package:tubes_ppbl/utils/app_colors.dart';
import 'package:tubes_ppbl/models/eksperimen.dart';
import 'package:tubes_ppbl/sqlite/koneksi.dart';

class EksperimenFormScreen extends StatefulWidget {
  final Eksperimen? eksperimen;
  final int mkId;

  const EksperimenFormScreen({super.key, this.eksperimen, required this.mkId});

  @override
  State<EksperimenFormScreen> createState() => _EksperimenFormScreenState();
}

class _EksperimenFormScreenState extends State<EksperimenFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dbHelper = DatabaseHelper();

  final _judulCtrl = TextEditingController();
  final _tanggalCtrl = TextEditingController();
  final _tujuanCtrl = TextEditingController();
  final _prosedurCtrl = TextEditingController();
  final _kesimpulanCtrl = TextEditingController();

  bool get _isEditing => widget.eksperimen != null;
  String _statusJurnal = 'Draft';
  bool _isSaving = false;

  final List<String> _statusOptions = ['Draft', 'Selesai', 'Revisi'];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final e = widget.eksperimen!;
      _judulCtrl.text = e.judul;
      _tanggalCtrl.text = e.tanggal;
      _tujuanCtrl.text = e.tujuan;
      _prosedurCtrl.text = e.prosedur;
      _kesimpulanCtrl.text = e.kesimpulan;
      _statusJurnal = _statusOptions.contains(e.statusJurnal) ? e.statusJurnal : _statusOptions.first;
    }
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _tanggalCtrl.dispose();
    _tujuanCtrl.dispose();
    _prosedurCtrl.dispose();
    _kesimpulanCtrl.dispose();
    super.dispose();
  }

  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
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

  Future<void> _saveEksperimen() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final eks = Eksperimen(
        id: widget.eksperimen?.id,
        mkId: widget.mkId,
        judul: _judulCtrl.text,
        tanggal: _tanggalCtrl.text,
        tujuan: _tujuanCtrl.text,
        prosedur: _prosedurCtrl.text,
        kesimpulan: _kesimpulanCtrl.text,
        statusJurnal: _statusJurnal,
      );

      if (_isEditing) {
        await _dbHelper.updateEksperimen(eks);
      } else {
        await _dbHelper.insertEksperimen(eks);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEditing ? 'Eksperimen diperbarui' : 'Eksperimen ditambahkan'),
          backgroundColor: AppColors.sage,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.sage),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _tanggalCtrl.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Eksperimen' : 'Form Eksperimen',
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
                controller: _judulCtrl,
                decoration: _inputDeco('Judul Eksperimen'),
                style: const TextStyle(color: AppColors.textPrimary),
                validator: (v) => v == null || v.isEmpty ? 'Judul wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tanggalCtrl,
                decoration: _inputDeco('Tanggal (YYYY-MM-DD)').copyWith(
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today, color: AppColors.textMuted),
                    onPressed: _selectDate,
                  ),
                ),
                style: const TextStyle(color: AppColors.textPrimary),
                readOnly: true,
                onTap: _selectDate,
                validator: (v) => v == null || v.isEmpty ? 'Tanggal wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tujuanCtrl,
                decoration: _inputDeco('Tujuan Eksperimen'),
                style: const TextStyle(color: AppColors.textPrimary),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _prosedurCtrl,
                decoration: _inputDeco('Prosedur'),
                style: const TextStyle(color: AppColors.textPrimary),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _kesimpulanCtrl,
                decoration: _inputDeco('Kesimpulan'),
                style: const TextStyle(color: AppColors.textPrimary),
                maxLines: 2,
              ),

              const SizedBox(height: 24),
              const Text('Status Jurnal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.slate700)),
              const SizedBox(height: 12),


              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _statusJurnal,
                decoration: _inputDeco('Status Jurnal'),
                dropdownColor: AppColors.bgCard,
                style: const TextStyle(color: AppColors.textPrimary),
                items: _statusOptions.map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _statusJurnal = value ?? 'Draft';
                  });
                },
              ),

              const SizedBox(height: 32),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sage,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _isSaving ? null : _saveEksperimen,
                icon: Icon(_isEditing ? Icons.save_outlined : Icons.add_circle_outline,
                  color: Colors.white),
                label: Text(
                  _isEditing ? 'Perbarui Eksperimen' : 'Simpan Eksperimen',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
