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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Peminjaman Alat',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.slate900,
      ),
      body: FutureBuilder<List<PeminjamanAlat>>(
        future: _peminjamanFuture,
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
                    child: Icon(Icons.inventory_2_outlined,
                        size: 48, color: AppColors.sage),
                  ),
                  SizedBox(height: 20),
                  Text('Belum ada peminjaman',
                      style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Text('Tekan tombol + untuk menambahkan',
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
                        backgroundColor: Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        icon: Icons.edit_outlined,
                        label: 'Edit',
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16)),
                      ),
                      SlidableAction(
                        onPressed: (_) => _deleteItem(item.id!),
                        backgroundColor: Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        icon: Icons.delete_outline,
                        label: 'Hapus',
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(16),
                            bottomRight: Radius.circular(16)),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [

                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark ? _statusBg(item.status).withOpacity(0.15) : _statusBg(item.status).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(_statusIcon(item.status),
                              size: 22,
                              color: Theme.of(context).brightness == Brightness.dark ? (item.status == 'Dikembalikan' ? Colors.greenAccent : Colors.orangeAccent) : _statusText(item.status)),
                        ),
                        SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(item.namaAlat,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).textTheme.bodyLarge?.color)),
                              SizedBox(height: 4),
                              Row(children: [
                                Icon(
                                    Icons.calendar_today_outlined,
                                    size: 13,
                                    color: AppColors.textMuted),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                      '${item.tanggalPinjam}  →  ${item.tenggatKembali}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).textTheme.bodyMedium?.color),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                  ),
                                ),
                              ]),
                            ],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark ? _statusBg(item.status).withOpacity(0.2) : _statusBg(item.status),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(item.status,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).brightness == Brightness.dark ? (item.status == 'Dikembalikan' ? Colors.greenAccent : Colors.orangeAccent) : _statusText(item.status))),
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
        child: Icon(Icons.add, color: Colors.white),
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
