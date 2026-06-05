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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Anggota Kelompok',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.slate900,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<TimKelompok>>(
        future: _timFuture,
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
                    child: Icon(Icons.group_outlined,
                        size: 48, color: AppColors.sage),
                  ),
                  SizedBox(height: 20),
                  Text('Belum ada anggota tim',
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
                        backgroundColor: Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        icon: Icons.edit_outlined,
                        label: 'Edit',
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12)),
                      ),
                      SlidableAction(
                        onPressed: (_) => _deleteItem(tim.id!),
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
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isKetua
                                ? (Theme.of(context).brightness == Brightness.dark ? AppColors.mkPurple.withOpacity(0.15) : AppColors.mkPurple.withOpacity(0.3))
                                : (Theme.of(context).brightness == Brightness.dark ? AppColors.baruBg.withOpacity(0.15) : AppColors.baruBg.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                              isKetua
                                  ? Icons.star_rounded
                                  : Icons.person_outline,
                              color: isKetua
                                  ? Color(0xFF8B5CF6)
                                  : Color(0xFF3B82F6),
                              size: 22),
                        ),
                        SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tim.namaAnggota,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).textTheme.bodyLarge?.color)),
                              SizedBox(height: 4),
                              Wrap(
                                spacing: 12,
                                runSpacing: 4,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.badge_outlined,
                                          size: 13, color: AppColors.textMuted),
                                      SizedBox(width: 4),
                                      Text(tim.nim,
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Theme.of(context).textTheme.bodyMedium?.color)),
                                    ],
                                  ),
                                  if (tim.noHp.isNotEmpty)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.phone_outlined,
                                            size: 13,
                                            color: AppColors.textMuted),
                                        SizedBox(width: 4),
                                        Text(tim.noHp,
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Theme.of(context).textTheme.bodyMedium?.color)),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isKetua
                                ? (Theme.of(context).brightness == Brightness.dark ? AppColors.mkPurple.withOpacity(0.15) : AppColors.mkPurple.withOpacity(0.5))
                                : (Theme.of(context).brightness == Brightness.dark ? AppColors.baruBg.withOpacity(0.15) : AppColors.baruBg.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(tim.peran,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isKetua
                                      ? (Theme.of(context).brightness == Brightness.dark ? Color(0xFFC4B5FD) : Color(0xFF581C87))
                                      : (Theme.of(context).brightness == Brightness.dark ? Color(0xFF93C5FD) : Color(0xFF1E40AF)))),
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
