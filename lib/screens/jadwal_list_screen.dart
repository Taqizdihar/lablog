import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tubes_ppbl/utils/app_colors.dart';
import 'package:tubes_ppbl/models/jadwal_praktikum.dart';
import 'package:tubes_ppbl/models/mata_kuliah.dart';
import 'package:tubes_ppbl/sqlite/koneksi.dart';
import 'package:tubes_ppbl/screens/jadwal_form_screen.dart';

class JadwalListScreen extends StatefulWidget {
  const JadwalListScreen({super.key});

  @override
  State<JadwalListScreen> createState() => _JadwalListScreenState();
}

class _JadwalListScreenState extends State<JadwalListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Future<List<JadwalPraktikum>> _jadwalFuture;
  Map<int, MataKuliah> _mkCache = {};

  final Map<String, Color> _warnaMap = {
    'mkBlue': AppColors.mkBlue,
    'mkGreen': AppColors.mkGreen,
    'mkYellow': AppColors.mkYellow,
    'mkPurple': AppColors.mkPurple,
    'mkRose': AppColors.mkRose,
  };

  final Map<String, Color> _warnaTextMap = {
    'mkBlue': const Color(0xFF1E40AF),
    'mkGreen': const Color(0xFF14532D),
    'mkYellow': const Color(0xFF713F12),
    'mkPurple': const Color(0xFF581C87),
    'mkRose': const Color(0xFF881337),
  };

  final Map<String, int> _dayOrder = {
    'Senin': 1, 'Selasa': 2, 'Rabu': 3, 'Kamis': 4,
    'Jumat': 5, 'Sabtu': 6, 'Minggu': 7,
  };

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() {
    setState(() {
      _jadwalFuture = _loadJadwalWithMk();
    });
  }

  Future<List<JadwalPraktikum>> _loadJadwalWithMk() async {
    final mkList = await _dbHelper.getMataKuliahList();
    _mkCache = {for (var mk in mkList) mk.id!: mk};
    final jadwalList = await _dbHelper.getAllJadwalList();
    jadwalList.sort((a, b) {
      final dayA = _dayOrder[a.hari] ?? 99;
      final dayB = _dayOrder[b.hari] ?? 99;
      if (dayA != dayB) return dayA.compareTo(dayB);
      return a.jamMulai.compareTo(b.jamMulai);
    });
    return jadwalList;
  }

  Future<void> _deleteJadwal(int id) async {
    await _dbHelper.deleteJadwal(id);
    _refreshList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: const Text('Jadwal Praktikum',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.slate900,
      ),
      body: FutureBuilder<List<JadwalPraktikum>>(
        future: _jadwalFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.sage));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: AppColors.textSecondary)),
            );
          }

          final list = snapshot.data ?? [];

          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: AppColors.sageBg, shape: BoxShape.circle),
                    child: const Icon(Icons.calendar_today_outlined,
                        size: 48, color: AppColors.sage),
                  ),
                  const SizedBox(height: 20),
                  const Text('Belum ada jadwal',
                      style: TextStyle(fontSize: 18,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text('Tekan tombol + untuk menambahkan',
                      style: TextStyle(fontSize: 14,
                          color: AppColors.textPlaceholder)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: list.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final jadwal = list[index];
              final mk = _mkCache[jadwal.mkId];
              final warnaKey = mk?.warnaLabel ?? 'mkBlue';
              final cardColor = _warnaMap[warnaKey] ?? AppColors.mkBlue;
              final textColor = _warnaTextMap[warnaKey] ?? const Color(0xFF1E40AF);

              final showDayHeader =
                  index == 0 || list[index - 1].hari != jadwal.hari;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showDayHeader) ...[
                    if (index > 0) const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, top: 4),
                      child: Row(children: [
                        const Icon(Icons.event, size: 18,
                            color: AppColors.sage),
                        const SizedBox(width: 8),
                        Text(jadwal.hari,
                            style: const TextStyle(fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.slate700)),
                      ]),
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Slidable(
                      key: ValueKey(jadwal.id),
                      endActionPane: ActionPane(
                        motion: const BehindMotion(),
                        extentRatio: 0.4,
                        children: [
                          SlidableAction(
                            onPressed: (_) async {
                              final r = await Navigator.push(context,
                                MaterialPageRoute(builder: (_) =>
                                    JadwalFormScreen(jadwal: jadwal)));
                              if (r == true) _refreshList();
                            },
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            icon: Icons.edit_outlined,
                            label: 'Edit',
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12)),
                          ),
                          SlidableAction(
                            onPressed: (_) => _deleteJadwal(jadwal.id!),
                            backgroundColor: const Color(0xFFEF4444),
                            foregroundColor: Colors.white,
                            icon: Icons.delete_outline,
                            label: 'Hapus',
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12)),
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(children: [
                          Container(
                            width: 5, height: 76,
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12)),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      borderRadius: BorderRadius.circular(8)),
                                    child: Text(
                                      mk?.namaMk ?? 'MK Tidak Ditemukan',
                                      style: TextStyle(fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: textColor)),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(children: [
                                    const Icon(Icons.access_time_outlined,
                                        size: 15, color: AppColors.textMuted),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${jadwal.jamMulai} – ${jadwal.jamSelesai}',
                                      style: const TextStyle(fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary)),
                                    const SizedBox(width: 16),
                                    const Icon(Icons.room_outlined,
                                        size: 15, color: AppColors.textMuted),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(jadwal.ruangan,
                                          style: const TextStyle(fontSize: 13,
                                              color: AppColors.textSecondary),
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ]),
                                ],
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.sage,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(context,
            MaterialPageRoute(builder: (_) => const JadwalFormScreen()));
          if (result == true) _refreshList();
        },
      ),
    );
  }
}
