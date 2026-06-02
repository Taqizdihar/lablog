import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tubes_ppbl/utils/app_colors.dart';
import 'package:tubes_ppbl/models/referensi.dart';
import 'package:tubes_ppbl/sqlite/koneksi.dart';
import 'package:tubes_ppbl/screens/referensi_form_screen.dart';

class ReferensiListScreen extends StatefulWidget {
  final int mkId;
  const ReferensiListScreen({super.key, required this.mkId});

  @override
  State<ReferensiListScreen> createState() => _ReferensiListScreenState();
}

class _ReferensiListScreenState extends State<ReferensiListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Future<List<Referensi>> _refFuture;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() {
    setState(() {
      _refFuture = _dbHelper.getReferensiList(widget.mkId);
    });
  }

  Future<void> _deleteItem(int id) async {
    await _dbHelper.deleteReferensi(id);
    _refreshList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: const Text('Referensi',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.slate900,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Referensi>>(
        future: _refFuture,
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
                    child: const Icon(Icons.menu_book_outlined,
                        size: 48, color: AppColors.sage),
                  ),
                  const SizedBox(height: 20),
                  const Text('Belum ada referensi',
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
              final ref = list[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Slidable(
                  key: ValueKey(ref.id),
                  endActionPane: ActionPane(
                    motion: const BehindMotion(),
                    extentRatio: 0.4,
                    children: [
                      SlidableAction(
                        onPressed: (_) async {
                          final r = await Navigator.push(context,
                              MaterialPageRoute(builder: (_) =>
                                  ReferensiFormScreen(
                                      mkId: widget.mkId,
                                      referensi: ref)));
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
                        onPressed: (_) => _deleteItem(ref.id!),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.mkYellow,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                              Icons.auto_stories_outlined,
                              size: 22,
                              color: Color(0xFFF59E0B)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ref.judulBuku,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary)),
                              const SizedBox(height: 4),
                              Row(children: [
                                const Icon(Icons.person_outline,
                                    size: 13,
                                    color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(ref.penulis,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary),
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ]),
                              const SizedBox(height: 4),
                              Row(children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.mkYellow,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(ref.tahunTerbit,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF713F12))),
                                ),
                                if (ref.tautanSumber.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  const Icon(Icons.link,
                                      size: 13,
                                      color: AppColors.textMuted),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(ref.tautanSumber,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textMuted),
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ]),
                            ],
                          ),
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
        heroTag: null,
        backgroundColor: AppColors.sage,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(context,
              MaterialPageRoute(builder: (_) =>
                  ReferensiFormScreen(mkId: widget.mkId)));
          if (result == true) _refreshList();
        },
      ),
    );
  }
}
