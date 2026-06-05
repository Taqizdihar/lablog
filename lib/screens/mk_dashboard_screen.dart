import 'package:flutter/material.dart';
import 'package:tubes_ppbl/utils/app_colors.dart';
import 'package:tubes_ppbl/models/mata_kuliah.dart';
import 'package:tubes_ppbl/sqlite/koneksi.dart';
import 'package:tubes_ppbl/screens/eksperimen_list_screen.dart';
import 'package:tubes_ppbl/screens/tim_list_screen.dart';
import 'package:tubes_ppbl/screens/referensi_list_screen.dart';

class MkDashboardScreen extends StatefulWidget {
  final int mkId;
  const MkDashboardScreen({super.key, required this.mkId});

  @override
  State<MkDashboardScreen> createState() => _MkDashboardScreenState();
}

class _MkDashboardScreenState extends State<MkDashboardScreen> {
  late Future<List<MataKuliah>> _mkListFuture;
  int _totalJurnal = 0;
  int _totalAnggota = 0;
  int _totalReferensi = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    _mkListFuture = DatabaseHelper().getMataKuliahList();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoadingStats = true);
    final dbHelper = DatabaseHelper();
    
    final eksperimenList = await dbHelper.getEksperimenList(widget.mkId);
    final timList = await dbHelper.getTimKelompokList(widget.mkId);
    final refList = await dbHelper.getReferensiList(widget.mkId);

    if (mounted) {
      setState(() {
        _totalJurnal = eksperimenList.length;
        _totalAnggota = timList.length;
        _totalReferensi = refList.length;
        _isLoadingStats = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MataKuliah>>(
      future: _mkListFuture,
      builder: (context, snapshot) {
        String title = 'Dashboard';
        String subtitle = 'Pilih menu di bawah';
        if (snapshot.hasData) {
          final match = snapshot.data!.where((mk) => mk.id == widget.mkId);
          if (match.isNotEmpty) {
            title = match.first.namaMk;
            subtitle = match.first.dosen;
          }
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(title,
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: AppColors.slate900,
            iconTheme: IconThemeData(color: Colors.white),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              _refreshData();
            },
            color: AppColors.sage,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
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
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.sageBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.dashboard_rounded,
                            size: 32, color: AppColors.sage),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).textTheme.bodyLarge?.color)),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.person_outline, size: 14, color: AppColors.textMuted),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(subtitle,
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textMuted),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                  
                  SizedBox(height: 24),
                  
                  if (!_isLoadingStats) ...[
                    Row(
                      children: [
                        Expanded(child: _buildStatItem('Jurnal', _totalJurnal, Icons.science_outlined, AppColors.mkBlue)),
                        SizedBox(width: 12),
                        Expanded(child: _buildStatItem('Anggota', _totalAnggota, Icons.group_outlined, AppColors.mkPurple)),
                        SizedBox(width: 12),
                        Expanded(child: _buildStatItem('Referensi', _totalReferensi, Icons.menu_book_outlined, AppColors.mkYellow)),
                      ],
                    ),
                    SizedBox(height: 24),
                  ],

                  GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _buildMenuCard(
                        context,
                        icon: Icons.science_outlined,
                        label: 'Jurnal\nEksperimen',
                        color: Color(0xFF3B82F6),
                        bg: AppColors.mkBlue,
                        onTap: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => EksperimenListScreen(mkId: widget.mkId)));
                          _refreshData();
                        },
                      ),
                      _buildMenuCard(
                        context,
                        icon: Icons.group_outlined,
                        label: 'Anggota\nKelompok',
                        color: Color(0xFF8B5CF6),
                        bg: AppColors.mkPurple,
                        onTap: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => TimListScreen(mkId: widget.mkId)));
                          _refreshData();
                        },
                      ),
                      _buildMenuCard(
                        context,
                        icon: Icons.menu_book_outlined,
                        label: 'Referensi',
                        color: Color(0xFFF59E0B),
                        bg: AppColors.mkYellow,
                        onTap: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => ReferensiListScreen(mkId: widget.mkId)));
                          _refreshData();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, int count, IconData icon, Color baseColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? baseColor.withOpacity(0.15) : baseColor.withOpacity(0.3);
    final iconColor = isDark ? baseColor : baseColor.withOpacity(0.8);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 20),
          SizedBox(height: 8),
          Text(count.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black54, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? bg.withOpacity(0.15) : bg.withOpacity(0.3);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            SizedBox(height: 12),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    height: 1.3)),
          ],
        ),
      ),
    );
  }
}
