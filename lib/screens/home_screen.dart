import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tubes_ppbl/utils/app_colors.dart';
import 'package:tubes_ppbl/models/mata_kuliah.dart';
import 'package:tubes_ppbl/sqlite/koneksi.dart';
import 'package:tubes_ppbl/screens/mk_form_screen.dart';
import 'package:tubes_ppbl/screens/mk_dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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


  final Map<String, Color> _warnaTextMap = {
    'mkBlue': Color(0xFF1E40AF),
    'mkGreen': Color(0xFF14532D),
    'mkYellow': Color(0xFF713F12),
    'mkPurple': Color(0xFF581C87),
    'mkRose': Color(0xFF881337),
  };

  bool _isGridView = false;
  String _semesterAktif = 'Semua Semester';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _refreshList();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isGridView = prefs.getBool('is_grid_view') ?? false;
        _semesterAktif = prefs.getString('semester_aktif') ?? 'Semua Semester';
      });
    }
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
        title: Text('Hapus Mata Kuliah?'),
        content: Text(
            'Semua data terkait (jadwal, eksperimen, tim, referensi) akan ikut terhapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Color(0xFFEF4444)),
            child: Text('Hapus'),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      await _dbHelper.deleteMataKuliah(id);
      _loadPreferences();
      _refreshList();
    }
  }

  Color _getCardColor(String warnaKey) {
    return _warnaMap[warnaKey] ?? AppColors.mkBlue;
  }

  Color _getTextColor(String warnaKey) {
    return _warnaTextMap[warnaKey] ?? Color(0xFF1E40AF);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('LabLog',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.slate900,
      ),
      body: FutureBuilder<List<MataKuliah>>(
        future: _mataKuliahFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: AppColors.sage));
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: Color(0xFFEF4444)),
                  SizedBox(height: 12),
                  Text('Error: ${snapshot.error}',
                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                      textAlign: TextAlign.center),
                ],
              ),
            );
          }

          final list = snapshot.data ?? [];
          final filteredList = _semesterAktif == 'Semua Semester'
              ? list
              : list.where((mk) => mk.semester == _semesterAktif).toList();

          if (filteredList.isEmpty) {
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
                    child: Icon(Icons.science_outlined,
                        size: 48, color: AppColors.sage),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Belum ada mata kuliah',
                    style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tekan tombol + untuk menambahkan',
                    style:
                        TextStyle(fontSize: 14, color: AppColors.textPlaceholder),
                  ),
                ],
              ),
            );
          }

          Widget buildItem(BuildContext context, int index) {
            final mk = filteredList[index];
            final cardColor = _getCardColor(mk.warnaLabel);
            final textColor = _getTextColor(mk.warnaLabel);

            Widget cardContent = Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 6,
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
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              mk.namaMk,
                              style: TextStyle(
                                fontSize: _isGridView ? 14 : 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.person_outline,
                                    size: 14,
                                    color: AppColors.textMuted),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    mk.dosen,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).textTheme.bodyMedium?.color,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                mk.semester,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: textColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!_isGridView)
                      Padding(
                        padding: EdgeInsets.only(right: 12.0),
                        child: Icon(Icons.chevron_right,
                            color: AppColors.textPlaceholder),
                      ),
                  ],
                ),
              ),
            );

            Widget item = Slidable(
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
                      if (result == true) {
                        _loadPreferences();
                        _refreshList();
                      }
                    },
                    backgroundColor: Color(0xFF3B82F6),
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
                    backgroundColor: Color(0xFFEF4444),
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
                  _loadPreferences();
                  _refreshList();
                },
                borderRadius: BorderRadius.circular(12),
                child: cardContent,
              ),
            );

            return _isGridView
                ? item
                : Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: item,
                  );
          }

          if (_isGridView) {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.2,
              ),
              itemCount: filteredList.length,
              padding: const EdgeInsets.all(16.0),
              itemBuilder: buildItem,
            );
          } else {
            return ListView.builder(
              itemCount: filteredList.length,
              padding: const EdgeInsets.all(16.0),
              itemBuilder: buildItem,
            );
          }
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
            MaterialPageRoute(builder: (_) => const MkFormScreen()),
          );
          if (result == true) {
            _loadPreferences();
            _refreshList();
          }
        },
      ),
    );
  }
}
