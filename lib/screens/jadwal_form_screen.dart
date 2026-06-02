import 'package:flutter/material.dart';
import 'package:tubes_ppbl/utils/app_colors.dart';
import 'package:tubes_ppbl/models/jadwal_praktikum.dart';
import 'package:tubes_ppbl/models/mata_kuliah.dart';
import 'package:tubes_ppbl/sqlite/koneksi.dart';

class JadwalFormScreen extends StatefulWidget {
  final JadwalPraktikum? jadwal;
  const JadwalFormScreen({super.key, this.jadwal});

  @override
  State<JadwalFormScreen> createState() => _JadwalFormScreenState();
}

class _JadwalFormScreenState extends State<JadwalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dbHelper = DatabaseHelper();
  final _ruanganCtrl = TextEditingController();

  bool get _isEditing => widget.jadwal != null;
  int? _selectedMkId;
  String _selectedHari = 'Senin';
  String _jamMulai = '08:00';
  String _jamSelesai = '10:00';
  bool _isSaving = false;

  late Future<List<MataKuliah>> _mkListFuture;

  final List<String> _hariOptions = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu',
  ];

  @override
  void initState() {
    super.initState();
    _mkListFuture = _dbHelper.getMataKuliahList();
    if (_isEditing) {
      final j = widget.jadwal!;
      _selectedMkId = j.mkId;
      _selectedHari = j.hari;
      _jamMulai = j.jamMulai;
      _jamSelesai = j.jamSelesai;
      _ruanganCtrl.text = j.ruangan;
    }
  }

  @override
  void dispose() {
    _ruanganCtrl.dispose();
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

  Future<void> _pickTime(bool isStart) async {
    final current = isStart ? _jamMulai : _jamSelesai;
    final parts = current.split(':');
    final init = TimeOfDay(
        hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    final picked = await showTimePicker(
      context: context, initialTime: init,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.sage)),
        child: child!),
    );
    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (isStart) {
          _jamMulai = formatted;
        } else {
          _jamSelesai = formatted;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMkId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pilih mata kuliah terlebih dahulu'),
        backgroundColor: Color(0xFFEF4444)));
      return;
    }
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final jadwal = JadwalPraktikum(
        id: widget.jadwal?.id,
        mkId: _selectedMkId!,
        hari: _selectedHari,
        jamMulai: _jamMulai,
        jamSelesai: _jamSelesai,
        ruangan: _ruanganCtrl.text,
      );

      if (_isEditing) {
        await _dbHelper.updateJadwal(jadwal);
      } else {
        await _dbHelper.insertJadwal(jadwal);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEditing
              ? 'Jadwal berhasil diperbarui'
              : 'Jadwal berhasil ditambahkan'),
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
        title: Text(_isEditing ? 'Edit Jadwal' : 'Tambah Jadwal',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.slate900,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<MataKuliah>>(
        future: _mkListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.sage));
          }

          final mkList = snapshot.data ?? [];

          if (mkList.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.warning_amber_outlined,
                        size: 48, color: Color(0xFFF59E0B)),
                    const SizedBox(height: 16),
                    const Text('Belum ada Mata Kuliah',
                        style: TextStyle(fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    const Text(
                        'Tambahkan mata kuliah terlebih dahulu di tab Beranda.',
                        style: TextStyle(color: AppColors.textMuted),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.sage)),
                      child: const Text('Kembali',
                          style: TextStyle(color: AppColors.sage)),
                    ),
                  ],
                ),
              ),
            );
          }

          // Ensure selectedMkId is valid
          if (_selectedMkId != null &&
              !mkList.any((mk) => mk.id == _selectedMkId)) {
            _selectedMkId = null;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Mata Kuliah dropdown ──
                  const Text('Mata Kuliah',
                      style: TextStyle(fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate700)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: _selectedMkId,
                    decoration: _deco('Pilih Mata Kuliah',
                        Icons.book_outlined),
                    dropdownColor: AppColors.bgCard,
                    style: const TextStyle(color: AppColors.textPrimary),
                    items: mkList.map((mk) {
                      return DropdownMenuItem<int>(
                        value: mk.id,
                        child: Text(mk.namaMk));
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedMkId = v),
                    validator: (v) =>
                        v == null ? 'Mata kuliah wajib dipilih' : null,
                  ),

                  const SizedBox(height: 20),

                  // ── Hari dropdown ──
                  const Text('Hari',
                      style: TextStyle(fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate700)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedHari,
                    decoration: _deco('Pilih Hari',
                        Icons.calendar_today_outlined),
                    dropdownColor: AppColors.bgCard,
                    style: const TextStyle(color: AppColors.textPrimary),
                    items: _hariOptions.map((h) {
                      return DropdownMenuItem<String>(
                        value: h, child: Text(h));
                    }).toList(),
                    onChanged: (v) =>
                        setState(() => _selectedHari = v ?? 'Senin'),
                  ),

                  const SizedBox(height: 20),

                  // ── Jam Mulai & Jam Selesai ──
                  const Text('Waktu',
                      style: TextStyle(fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate700)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickTime(true),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(8)),
                          child: Row(children: [
                            const Icon(Icons.access_time,
                                size: 18, color: AppColors.textMuted),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Mulai',
                                    style: TextStyle(fontSize: 11,
                                        color: AppColors.textMuted)),
                                Text(_jamMulai,
                                    style: const TextStyle(fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary)),
                              ],
                            ),
                          ]),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.arrow_forward,
                          color: AppColors.textPlaceholder, size: 20)),
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickTime(false),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(8)),
                          child: Row(children: [
                            const Icon(Icons.access_time,
                                size: 18, color: AppColors.textMuted),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Selesai',
                                    style: TextStyle(fontSize: 11,
                                        color: AppColors.textMuted)),
                                Text(_jamSelesai,
                                    style: const TextStyle(fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary)),
                              ],
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // ── Ruangan ──
                  const Text('Ruangan',
                      style: TextStyle(fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate700)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _ruanganCtrl,
                    decoration: _deco('Nama Ruangan', Icons.room_outlined),
                    style: const TextStyle(color: AppColors.textPrimary),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Ruangan wajib diisi' : null,
                  ),

                  const SizedBox(height: 32),

                  // ── Save button ──
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sage,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2),
                    onPressed: _isSaving ? null : _save,
                    icon: Icon(
                        _isEditing ? Icons.save_outlined
                            : Icons.add_circle_outline,
                        color: Colors.white),
                    label: Text(
                      _isEditing ? 'Perbarui Jadwal' : 'Simpan Jadwal',
                      style: const TextStyle(color: Colors.white,
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
