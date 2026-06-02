import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tubes_ppbl/utils/app_colors.dart';
import 'package:tubes_ppbl/models/peminjaman_alat.dart';
import 'package:tubes_ppbl/sqlite/koneksi.dart';
import 'package:tubes_ppbl/screens/peminjaman_form_screen.dart';

class PeminjamanListScreen extends StatefulWidget {
  const PeminjamanListScreen({super.key});

  @override
  State<PeminjamanListScreen> createState() => _PeminjamanListScreenState();
}

class _PeminjamanListScreenState extends State<PeminjamanListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Future<List<PeminjamanAlat>> _peminjamanFuture;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() {
    setState(() {
      _peminjamanFuture = _dbHelper.getPeminjamanAlatList();
    });
  }

  Future<void> _deleteItem(int id) async {
    await _dbHelper.deletePeminjamanAlat(id);
    _refreshList();
  }

  Color _statusBg(String status) {
    return status == 'Dikembalikan' ? AppColors.selesaiBg : AppColors.draftBg;
  }

  Color _statusText(String status) {
    return status == 'Dikembalikan'
        ? AppColors.selesaiText
        : AppColors.draftText;
  }

  IconData _statusIcon(String status) {
    return status == 'Dikembalikan'
        ? Icons.check_circle_outline
        : Icons.hourglass_bottom_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: const Text('Peminjaman Alat',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.slate900,
      ),
      body: FutureBuilder<List<PeminjamanAlat>>(
        future: _peminjamanFuture,
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
                    child: const Icon(Icons.inventory_2_outlined,
                        size: 48, color: AppColors.sage),
                  ),
                  const SizedBox(height: 20),
                  const Text('Belum ada peminjaman',
                      style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text('Tekan tombol + untuk menambahkan',
                      style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textPlaceholder)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: list.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final item = list[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Slidable(
                  key: ValueKey(item.id),
                  endActionPane: ActionPane(
                    motion: const BehindMotion(),
                    extentRatio: 0.4,
                    children: [
                      SlidableAction(
                        onPressed: (_) async {
                          final r = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => PeminjamanFormScreen(
                                      peminjaman: item)));
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
                        onPressed: (_) => _deleteItem(item.id!),
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
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _statusBg(item.status),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(_statusIcon(item.status),
                              size: 24,
                              color: _statusText(item.status)),
                        ),
                        const SizedBox(width: 14),
                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(item.namaAlat,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary)),
                              const SizedBox(height: 4),
                              Row(children: [
                                const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 13,
                                    color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Text(
                                    '${item.tanggalPinjam}  →  ${item.tenggatKembali}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color:
                                            AppColors.textSecondary)),
                              ]),
                            ],
                          ),
                        ),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _statusBg(item.status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(item.status,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _statusText(item.status))),
                        ),
                      ],
                    ),
                  ),
                ),
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
              MaterialPageRoute(
                  builder: (_) => const PeminjamanFormScreen()));
          if (result == true) _refreshList();
        },
      ),
    );
  }
}
