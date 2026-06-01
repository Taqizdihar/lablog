import 'package:flutter/material.dart';
import 'package:tubes_ppbl/utils/app_colors.dart';
import 'package:tubes_ppbl/models/eksperimen.dart';
import 'package:tubes_ppbl/models/alat_bahan.dart';
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
  final _alatNamaCtrl = TextEditingController();

  bool get _isEditing => widget.eksperimen != null;
  List<AlatBahan> _alatList = [];
  bool _isSaving = false;

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
      _loadAlatBahan();
    }
  }

  Future<void> _loadAlatBahan() async {
    if (widget.eksperimen?.id != null) {
      final list = await _dbHelper.getAlatBahanList(widget.eksperimen!.id!);
      setState(() => _alatList = list);
    }
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _tanggalCtrl.dispose();
    _tujuanCtrl.dispose();
    _prosedurCtrl.dispose();
    _kesimpulanCtrl.dispose();
    _alatNamaCtrl.dispose();
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

  void _addAlatBahanLocal() {
    final name = _alatNamaCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _alatList.add(AlatBahan(
        eksperimenId: widget.eksperimen?.id ?? 0,
        namaItem: name,
        jumlah: 1,
        isReady: 0,
      ));
    });
    _alatNamaCtrl.clear();
  }

  void _toggleReady(int index) {
    setState(() {
      final item = _alatList[index];
      item.isReady = item.isReady == 1 ? 0 : 1;
    });
  }

  void _removeAlat(int index) {
    setState(() => _alatList.removeAt(index));
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
        alat: _alatList.map((a) => a.namaItem).join(', '),
        prosedur: _prosedurCtrl.text,
        kesimpulan: _kesimpulanCtrl.text,
      );

      int eksId;
      if (_isEditing) {
        await _dbHelper.updateEksperimen(eks);
        eksId = eks.id!;
      } else {
        eksId = await _dbHelper.insertEksperimen(eks);
      }

      // Save alat bahan items
      for (final alat in _alatList) {
        alat.eksperimenId = eksId;
        if (alat.id != null) {
          await _dbHelper.updateAlatBahan(alat);
        } else {
          await _dbHelper.insertAlatBahan(alat);
        }
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
              const Text('Alat & Bahan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.slate700)),
              const SizedBox(height: 12),

              // Add alat input
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _alatNamaCtrl,
                      decoration: _inputDeco('Nama alat/bahan'),
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addAlatBahanLocal,
                    icon: const Icon(Icons.add_circle, color: AppColors.sage, size: 36),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Alat bahan checklist
              Container(
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: _alatList.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: Text('Belum ada alat/bahan',
                          style: TextStyle(color: AppColors.textMuted))),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _alatList.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
                        itemBuilder: (context, index) {
                          final alat = _alatList[index];
                          return CheckboxListTile(
                            title: Text(alat.namaItem,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                decoration: alat.isReady == 1 ? TextDecoration.lineThrough : null,
                              )),
                            value: alat.isReady == 1,
                            onChanged: (_) => _toggleReady(index),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            activeColor: AppColors.sage,
                            checkColor: Colors.white,
                            secondary: IconButton(
                              icon: const Icon(Icons.close, color: Color(0xFFEF4444), size: 18),
                              onPressed: () => _removeAlat(index),
                            ),
                          );
                        },
                      ),
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
