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
    'mkBlue': Color(0xFF1E40AF),
    'mkGreen': Color(0xFF14532D),
    'mkYellow': Color(0xFF713F12),
    'mkPurple': Color(0xFF581C87),
    'mkRose': Color(0xFF881337),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Jadwal Praktikum',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.slate900,
      ),
      body: FutureBuilder<List<JadwalPraktikum>>(
        future: _jadwalFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: AppColors.sage));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
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
                    decoration: BoxDecoration(
                      color: AppColors.sageBg, shape: BoxShape.circle),
                    child: Icon(Icons.calendar_today_outlined,
                        size: 48, color: AppColors.sage),
                  ),
                  SizedBox(height: 20),
                  Text('Belum ada jadwal',
                      style: TextStyle(fontSize: 18,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Text('Tekan tombol + untuk menambahkan',
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
              final textColor = _warnaTextMap[warnaKey] ?? Color(0xFF1E40AF);

              final showDayHeader =
                  index == 0 || list[index - 1].hari != jadwal.hari;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showDayHeader) ...[
                    if (index > 0) SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, top: 4),
                      child: Row(children: [
                        Icon(Icons.event, size: 18,
                            color: AppColors.sage),
                        SizedBox(width: 8),
                        Text(jadwal.hari,
                            style: TextStyle(fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.titleLarge?.color)),
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
                            backgroundColor: Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            icon: Icons.edit_outlined,
                            label: 'Edit',
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12)),
                          ),
                          SlidableAction(
                            onPressed: (_) => _deleteJadwal(jadwal.id!),
                            backgroundColor: Color(0xFFEF4444),
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
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Theme.of(context).dividerColor),
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
                                  SizedBox(height: 8),
                                  Row(children: [
                                    Icon(Icons.access_time_outlined,
                                        size: 15, color: AppColors.textMuted),
                                    SizedBox(width: 4),
                                    Text(
                                      '${jadwal.jamMulai} – ${jadwal.jamSelesai}',
                                      style: TextStyle(fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context).textTheme.bodyLarge?.color)),
                                    SizedBox(width: 16),
                                    Icon(Icons.room_outlined,
                                        size: 15, color: AppColors.textMuted),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: Text(jadwal.ruangan,
                                          style: TextStyle(fontSize: 13,
                                              color: Theme.of(context).textTheme.bodyMedium?.color),
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
        heroTag: null,
        backgroundColor: AppColors.sage,
        elevation: 4,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(context,
            MaterialPageRoute(builder: (_) => const JadwalFormScreen()));
          if (result == true) _refreshList();
        },
      ),
    );
  }
}
