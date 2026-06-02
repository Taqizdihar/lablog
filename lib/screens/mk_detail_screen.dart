import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tubes_ppbl/utils/app_colors.dart';
import 'package:tubes_ppbl/models/mata_kuliah.dart';
import 'package:tubes_ppbl/models/eksperimen.dart';
import 'package:tubes_ppbl/sqlite/koneksi.dart';
import 'package:tubes_ppbl/screens/eksperimen_form_screen.dart';

class MkDetailScreen extends StatefulWidget {
  final MataKuliah? mataKuliah;
  const MkDetailScreen({super.key, this.mataKuliah});

  @override
  State<MkDetailScreen> createState() => _MkDetailScreenState();
}

class _MkDetailScreenState extends State<MkDetailScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Future<List<Eksperimen>> _eksperimenFuture;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() {
    if (widget.mataKuliah?.id != null) {
      setState(() {
        _eksperimenFuture = _dbHelper.getEksperimenList(widget.mataKuliah!.id!);
      });
    } else {
      setState(() {
        _eksperimenFuture = Future.value([]);
      });
    }
  }

  Future<void> _deleteEksperimen(int id) async {
    await _dbHelper.deleteEksperimen(id);
    _refreshList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: Text(
          widget.mataKuliah?.namaMk ?? 'Detail Mata Kuliah',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.slate900,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Eksperimen>>(
        future: _eksperimenFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.sage));
          }

          final list = snapshot.data ?? [];

          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.science_outlined, size: 64, color: AppColors.textPlaceholder),
                  const SizedBox(height: 16),
                  const Text('Belum ada eksperimen',
                    style: TextStyle(fontSize: 18, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  const Text('Tekan tombol + untuk menambahkan',
                    style: TextStyle(fontSize: 14, color: AppColors.textPlaceholder)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: list.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final eks = list[index];
              final isSelesai = eks.statusJurnal == 'Selesai';
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Slidable(
                  key: ValueKey(eks.id),
                  endActionPane: ActionPane(
                    motion: const BehindMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) => _deleteEksperimen(eks.id!),
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        icon: Icons.delete_outline,
                        label: 'Hapus',
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ],
                  ),
                  child: Card(
                    color: AppColors.bgCard,
                    elevation: 2,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        final result = await Navigator.push(context,
                          MaterialPageRoute(builder: (_) => EksperimenFormScreen(
                            eksperimen: eks,
                            mkId: widget.mataKuliah!.id!,
                          )),
                        );
                        if (result == true) _refreshList();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(eks.judul,
                                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelesai ? AppColors.selesaiBg : AppColors.baruBg,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: isSelesai ? AppColors.sageBorder : Colors.transparent),
                                  ),
                                  child: Text(
                                    eks.statusJurnal,
                                    style: TextStyle(
                                      color: isSelesai ? AppColors.selesaiText : AppColors.baruText,
                                      fontSize: 12, fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(eks.tanggal, style: const TextStyle(color: AppColors.textSecondary)),

                          ],
                        ),
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
        backgroundColor: AppColors.sage,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(context,
            MaterialPageRoute(builder: (_) => EksperimenFormScreen(mkId: widget.mataKuliah!.id!)),
          );
          if (result == true) _refreshList();
        },
      ),
    );
  }
}
