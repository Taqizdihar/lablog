import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tubes_ppbl/utils/app_colors.dart';
import 'package:tubes_ppbl/models/tim_kelompok.dart';
import 'package:tubes_ppbl/sqlite/koneksi.dart';
import 'package:tubes_ppbl/screens/tim_form_screen.dart';

class TimListScreen extends StatefulWidget {
  final int mkId;
  const TimListScreen({super.key, required this.mkId});

  @override
  State<TimListScreen> createState() => _TimListScreenState();
}

class _TimListScreenState extends State<TimListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Future<List<TimKelompok>> _timFuture;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() {
    setState(() {
      _timFuture = _dbHelper.getTimKelompokList(widget.mkId);
    });
  }

  Future<void> _deleteItem(int id) async {
    await _dbHelper.deleteTimKelompok(id);
    _refreshList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: const Text('Tim Kelompok',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.slate900,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<TimKelompok>>(
        future: _timFuture,
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
                    child: const Icon(Icons.group_outlined,
                        size: 48, color: AppColors.sage),
                  ),
                  const SizedBox(height: 20),
                  const Text('Belum ada anggota tim',
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
              final tim = list[index];
              final isKetua = tim.peran == 'Ketua';
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Slidable(
                  key: ValueKey(tim.id),
                  endActionPane: ActionPane(
                    motion: const BehindMotion(),
                    extentRatio: 0.4,
                    children: [
                      SlidableAction(
                        onPressed: (_) async {
                          final r = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => TimFormScreen(
                                      mkId: widget.mkId,
                                      timKelompok: tim)));
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
                        onPressed: (_) => _deleteItem(tim.id!),
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
                        // Avatar
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isKetua
                                ? AppColors.mkPurple
                                : AppColors.baruBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                              isKetua
                                  ? Icons.star_rounded
                                  : Icons.person_outline,
                              color: isKetua
                                  ? const Color(0xFF8B5CF6)
                                  : const Color(0xFF3B82F6),
                              size: 22),
                        ),
                        const SizedBox(width: 14),
                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tim.namaAnggota,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary)),
                              const SizedBox(height: 4),
                              Row(children: [
                                const Icon(Icons.badge_outlined,
                                    size: 13, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Text(tim.nim,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary)),
                                if (tim.noHp.isNotEmpty) ...[
                                  const SizedBox(width: 12),
                                  const Icon(Icons.phone_outlined,
                                      size: 13,
                                      color: AppColors.textMuted),
                                  const SizedBox(width: 4),
                                  Text(tim.noHp,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color:
                                              AppColors.textSecondary)),
                                ],
                              ]),
                            ],
                          ),
                        ),
                        // Role badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isKetua
                                ? AppColors.mkPurple
                                : AppColors.baruBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(tim.peran,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isKetua
                                      ? const Color(0xFF581C87)
                                      : const Color(0xFF1E40AF))),
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
          final result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => TimFormScreen(mkId: widget.mkId)));
          if (result == true) _refreshList();
        },
      ),
    );
  }
}
