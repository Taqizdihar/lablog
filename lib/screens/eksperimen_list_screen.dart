import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tubes_ppbl/utils/app_colors.dart';
import 'package:tubes_ppbl/models/eksperimen.dart';
import 'package:tubes_ppbl/sqlite/koneksi.dart';
import 'package:tubes_ppbl/screens/eksperimen_form_screen.dart';

class EksperimenListScreen extends StatefulWidget {
  final int mkId;
  const EksperimenListScreen({super.key, required this.mkId});

  @override
  State<EksperimenListScreen> createState() => _EksperimenListScreenState();
}

class _EksperimenListScreenState extends State<EksperimenListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Future<List<Eksperimen>> _eksFuture;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() {
    setState(() {
      _eksFuture = _dbHelper.getEksperimenList(widget.mkId);
    });
  }

  Future<void> _deleteItem(int id) async {
    await _dbHelper.deleteEksperimen(id);
    _refreshList();
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'Selesai':
        return AppColors.selesaiBg;
      case 'Revisi':
        return AppColors.revisiBg;
      default:
        return AppColors.draftBg;
    }
  }

  Color _statusTextColor(String status) {
    switch (status) {
      case 'Selesai':
        return AppColors.selesaiText;
      case 'Revisi':
        return AppColors.revisiText;
      default:
        return AppColors.draftText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Jurnal Eksperimen',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.slate900,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Eksperimen>>(
        future: _eksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: AppColors.sage));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style:
                      TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
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
                        shape: BoxShape.circle),
                    child: Icon(Icons.science_outlined,
                        size: 48, color: AppColors.sage),
                  ),
                  SizedBox(height: 20),
                  Text('Belum ada eksperimen',
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
              final eks = list[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Slidable(
                  key: ValueKey(eks.id),
                  endActionPane: ActionPane(
                    motion: const BehindMotion(),
                    extentRatio: 0.4,
                    children: [
                      SlidableAction(
                        onPressed: (_) async {
                          final r = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      EksperimenFormScreen(
                                          eksperimen: eks,
                                          mkId: widget.mkId)));
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
                        onPressed: (_) => _deleteItem(eks.id!),
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
                  child: InkWell(
                    onTap: () async {
                      final r = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => EksperimenFormScreen(
                                  eksperimen: eks,
                                  mkId: widget.mkId)));
                      if (r == true) _refreshList();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                              child: Text(eks.judul,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).textTheme.bodyLarge?.color)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color:
                                    _statusBg(eks.statusJurnal),
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              child: Text(eks.statusJurnal,
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _statusTextColor(
                                          eks.statusJurnal))),
                            ),
                          ]),
                          SizedBox(height: 8),
                          Row(children: [
                            Icon(
                                Icons.calendar_today_outlined,
                                size: 13,
                                color: AppColors.textMuted),
                            SizedBox(width: 4),
                            Text(eks.tanggal,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context).textTheme.bodyMedium?.color)),
                          ]),
                          if (eks.tujuan.isNotEmpty) ...[
                            SizedBox(height: 6),
                            Text(eks.tujuan,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textMuted)),
                          ],
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
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      EksperimenFormScreen(mkId: widget.mkId)));
          if (result == true) _refreshList();
        },
      ),
    );
  }
}
