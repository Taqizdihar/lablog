import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tubes_ppbl/utils/app_colors.dart';
import 'package:tubes_ppbl/models/mata_kuliah.dart';
import 'package:tubes_ppbl/sqlite/koneksi.dart';
import 'package:tubes_ppbl/screens/mk_form_screen.dart';
import 'package:tubes_ppbl/screens/mk_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Future<List<MataKuliah>> _mataKuliahFuture;

  final Map<String, Color> _warnaMap = {
    'mkBlue': AppColors.mkBlue,
    'mkGreen': AppColors.mkGreen,
    'mkYellow': AppColors.mkYellow,
    'mkPurple': AppColors.mkPurple,
    'mkRose': AppColors.mkRose,
  };

  // Darker tints for text on label backgrounds
  final Map<String, Color> _warnaTextMap = {
    'mkBlue': const Color(0xFF1E40AF),
    'mkGreen': const Color(0xFF14532D),
    'mkYellow': const Color(0xFF713F12),
    'mkPurple': const Color(0xFF581C87),
    'mkRose': const Color(0xFF881337),
  };

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() {
    setState(() {
      _mataKuliahFuture = _dbHelper.getMataKuliahList();
    });
  }

  Future<void> _deleteMataKuliah(int id) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Mata Kuliah?'),
        content: const Text(
            'Semua data terkait (jadwal, eksperimen, tim, referensi) akan ikut terhapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      await _dbHelper.deleteMataKuliah(id);
      _refreshList();
    }
  }

  Color _getCardColor(String warnaKey) {
    return _warnaMap[warnaKey] ?? AppColors.mkBlue;
  }

  Color _getTextColor(String warnaKey) {
    return _warnaTextMap[warnaKey] ?? const Color(0xFF1E40AF);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: const Text('LabLog',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.slate900,
      ),
      body: FutureBuilder<List<MataKuliah>>(
        future: _mataKuliahFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.sage));
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: Color(0xFFEF4444)),
                  const SizedBox(height: 12),
                  Text('Error: ${snapshot.error}',
                      style: const TextStyle(color: AppColors.textSecondary),
                      textAlign: TextAlign.center),
                ],
              ),
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
                      color: AppColors.sageBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.science_outlined,
                        size: 48, color: AppColors.sage),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Belum ada mata kuliah',
                    style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tekan tombol + untuk menambahkan',
                    style:
                        TextStyle(fontSize: 14, color: AppColors.textPlaceholder),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: list.length,
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, index) {
              final mk = list[index];
              final cardColor = _getCardColor(mk.warnaLabel);
              final textColor = _getTextColor(mk.warnaLabel);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Slidable(
                  key: ValueKey(mk.id),
                  endActionPane: ActionPane(
                    motion: const BehindMotion(),
                    extentRatio: 0.4,
                    children: [
                      SlidableAction(
                        onPressed: (_) async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    MkFormScreen(mataKuliah: mk)),
                          );
                          if (result == true) _refreshList();
                        },
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        icon: Icons.edit_outlined,
                        label: 'Edit',
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      SlidableAction(
                        onPressed: (_) => _deleteMataKuliah(mk.id!),
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        icon: Icons.delete_outline,
                        label: 'Hapus',
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              MkDashboardScreen(mkId: mk.id!),
                        ),
                      );
                      _refreshList();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Color accent strip
                          Container(
                            width: 6,
                            height: 88,
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mk.namaMk,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.person_outline,
                                          size: 14,
                                          color: AppColors.textMuted),
                                      const SizedBox(width: 4),
                                      Text(
                                        mk.dosen,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      mk.semester,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: textColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(right: 12.0),
                            child: Icon(Icons.chevron_right,
                                color: AppColors.textPlaceholder),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        backgroundColor: AppColors.sage,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MkFormScreen()),
          );
          if (result == true) {
            _refreshList();
          }
        },
      ),
    );
  }
}
