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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Referensi',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.slate900,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Referensi>>(
        future: _refFuture,
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
                    child: Icon(Icons.menu_book_outlined,
                        size: 48, color: AppColors.sage),
                  ),
                  SizedBox(height: 20),
                  Text('Belum ada referensi',
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
                        backgroundColor: Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        icon: Icons.edit_outlined,
                        label: 'Edit',
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16)),
                      ),
                      SlidableAction(
                        onPressed: (_) => _deleteItem(ref.id!),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark ? AppColors.mkYellow.withOpacity(0.15) : AppColors.mkYellow.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                              Icons.auto_stories_outlined,
                              size: 22,
                              color: Theme.of(context).brightness == Brightness.dark ? Color(0xFFFCD34D) : Color(0xFFD97706)),
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ref.judulBuku,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).textTheme.bodyLarge?.color)),
                              SizedBox(height: 4),
                              Row(children: [
                                Icon(Icons.person_outline,
                                    size: 13,
                                    color: AppColors.textMuted),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(ref.penulis,
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Theme.of(context).textTheme.bodyMedium?.color),
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ]),
                              SizedBox(height: 4),
                              Row(children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness == Brightness.dark ? AppColors.mkYellow.withOpacity(0.2) : AppColors.mkYellow,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(ref.tahunTerbit,
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context).brightness == Brightness.dark ? Color(0xFFFCD34D) : Color(0xFF713F12))),
                                ),
                                if (ref.tautanSumber.isNotEmpty) ...[
                                  SizedBox(width: 8),
                                  Icon(Icons.link,
                                      size: 13,
                                      color: AppColors.textMuted),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(ref.tautanSumber,
                                        style: TextStyle(
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
        child: Icon(Icons.add, color: Colors.white),
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
