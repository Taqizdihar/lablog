import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tubes_ppbl/utils/app_colors.dart';
import 'package:tubes_ppbl/models/mata_kuliah.dart';
import 'package:tubes_ppbl/sqlite/koneksi.dart';
import 'package:tubes_ppbl/screens/mk_form_screen.dart';
import 'package:tubes_ppbl/screens/mk_dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
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
  String _namaPraktikan = 'Praktikan';

  int _totalMataKuliah = 0;
  int _totalJadwalHariIni = 0;
  int _totalPeminjamanAktif = 0;
  List<int> _mataKuliahPerSemester = List.filled(8, 0);
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadStats();
    _refreshList();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isGridView = prefs.getBool('is_grid_view') ?? false;
        _semesterAktif = prefs.getString('semester_aktif') ?? 'Semua Semester';
        _namaPraktikan = prefs.getString('nama_praktikan') ?? 'Praktikan';
        if (_namaPraktikan.isEmpty) _namaPraktikan = 'Praktikan';
      });
    }
  }

  String _getTodayDayName() {
    final weekday = DateTime.now().weekday;
    switch (weekday) {
      case 1: return 'Senin';
      case 2: return 'Selasa';
      case 3: return 'Rabu';
      case 4: return 'Kamis';
      case 5: return 'Jumat';
      case 6: return 'Sabtu';
      case 7: return 'Minggu';
      default: return '';
    }
  }

  Future<void> _loadStats() async {
    setState(() => _isLoadingStats = true);
    
    final mkList = await _dbHelper.getMataKuliahList();
    
    // Filter MK by semester for stats
    final filteredMk = _semesterAktif == 'Semua Semester'
        ? mkList
        : mkList.where((mk) => mk.semester == _semesterAktif).toList();
    _totalMataKuliah = filteredMk.length;
    
    // Collect filtered MK IDs for jadwal filtering
    final filteredMkIds = filteredMk.map((mk) => mk.id).toSet();
    
    _mataKuliahPerSemester = List.filled(8, 0);
    for (var mk in mkList) {
      final semesterString = mk.semester.replaceAll('Semester ', '');
      final semNum = int.tryParse(semesterString);
      if (semNum != null && semNum >= 1 && semNum <= 8) {
        _mataKuliahPerSemester[semNum - 1]++;
      }
    }
    
    final jadwalList = await _dbHelper.getAllJadwalList();
    final todayStr = _getTodayDayName();
    final filteredJadwal = _semesterAktif == 'Semua Semester'
        ? jadwalList
        : jadwalList.where((j) => filteredMkIds.contains(j.mkId)).toList();
    _totalJadwalHariIni = filteredJadwal.where((j) => j.hari == todayStr).length;
    
    final peminjamanList = await _dbHelper.getPeminjamanAlatList();
    _totalPeminjamanAktif = peminjamanList.where((p) => p.status == 'Dipinjam').length;
    
    if (mounted) {
      setState(() => _isLoadingStats = false);
    }
  }

  void reloadPreferences() {
    _loadPreferences();
    _loadStats();
    _refreshList();
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
        content: Text('Semua data terkait (jadwal, eksperimen, tim, referensi) akan ikut terhapus.'),
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
      _loadStats();
      _refreshList();
    }
  }

  Color _getCardColor(String warnaKey) {
    return _warnaMap[warnaKey] ?? AppColors.mkBlue;
  }

  Color _getTextColor(String warnaKey) {
    return _warnaTextMap[warnaKey] ?? Color(0xFF1E40AF);
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'MK';
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length == 1) {
      return words[0].substring(0, words[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  Widget _buildDashboardHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Halo, $_namaPraktikan 👋',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Selamat datang di LabLog',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatCard('Mata Kuliah', _totalMataKuliah.toString(), Icons.book_outlined, AppColors.mkBlue, Color(0xFF1E40AF)),
          SizedBox(width: 12),
          _buildStatCard('Jadwal Hari Ini', _totalJadwalHariIni.toString(), Icons.event, AppColors.mkYellow, Color(0xFF713F12)),
          SizedBox(width: 12),
          _buildStatCard('Alat Dipinjam', _totalPeminjamanAktif.toString(), Icons.handyman_outlined, AppColors.mkRose, Color(0xFF881337)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color bgColor, Color iconColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? bgColor.withOpacity(0.15) : bgColor.withOpacity(0.3);
    final finalIconColor = isDark ? bgColor : iconColor;
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.5), 
              shape: BoxShape.circle
            ),
            child: Icon(icon, color: finalIconColor, size: 20),
          ),
          SizedBox(height: 12),
          Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: finalIconColor)),
          SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : finalIconColor.withOpacity(0.8))),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribusi Mata Kuliah',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (_mataKuliahPerSemester.isEmpty ? 0 : _mataKuliahPerSemester.reduce((a, b) => a > b ? a : b)) + 2.0,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final style = TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        );
                        return SideTitleWidget(
                          meta: meta,
                          child: Text('S${value.toInt() + 1}', style: style),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        if (value % 1 != 0) return const SizedBox.shrink();
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Theme.of(context).dividerColor.withOpacity(0.5),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(8, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: _mataKuliahPerSemester[i].toDouble(),
                        color: AppColors.sage,
                        width: 16,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('LabLog', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.slate900,
      ),
      body: FutureBuilder<List<MataKuliah>>(
        future: _mataKuliahFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _isLoadingStats) {
            return Center(child: CircularProgressIndicator(color: AppColors.sage));
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
                  SizedBox(height: 12),
                  Text('Error: ${snapshot.error}', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color), textAlign: TextAlign.center),
                ],
              ),
            );
          }

          final list = snapshot.data ?? [];
          final filteredList = _semesterAktif == 'Semua Semester'
              ? list
              : list.where((mk) => mk.semester == _semesterAktif).toList();

          Widget buildItem(BuildContext context, int index) {
            final mk = filteredList[index];
            final cardColor = _getCardColor(mk.warnaLabel);
            final textColor = _getTextColor(mk.warnaLabel);
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final avatarBg = isDark ? cardColor.withOpacity(0.3) : cardColor.withOpacity(0.5);
            final avatarText = isDark ? cardColor : textColor;

            Widget cardContent = Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isGridView 
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: avatarBg, shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          _getInitials(mk.namaMk),
                          style: TextStyle(color: avatarText, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(mk.namaMk, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color), maxLines: 2, overflow: TextOverflow.ellipsis),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.person_outline, size: 12, color: AppColors.textMuted),
                              SizedBox(width: 4),
                              Expanded(child: Text(mk.dosen, style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodyMedium?.color), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ]
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: isDark ? cardColor.withOpacity(0.2) : cardColor, borderRadius: BorderRadius.circular(12)),
                      child: Text(mk.semester, style: TextStyle(fontSize: 11, color: isDark ? cardColor : textColor, fontWeight: FontWeight.w600)),
                    ),
                  ],
                )
                : Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(color: avatarBg, shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          _getInitials(mk.namaMk),
                          style: TextStyle(color: avatarText, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(mk.namaMk, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color), maxLines: 1, overflow: TextOverflow.ellipsis),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.person_outline, size: 14, color: AppColors.textMuted),
                              SizedBox(width: 4),
                              Expanded(child: Text(mk.dosen, style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: isDark ? cardColor.withOpacity(0.2) : cardColor, borderRadius: BorderRadius.circular(12)),
                            child: Text(mk.semester, style: TextStyle(fontSize: 11, color: isDark ? cardColor : textColor, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.textPlaceholder),
                  ],
                ),
              ),
            );

            return Slidable(
              key: ValueKey(mk.id),
              endActionPane: ActionPane(
                motion: const BehindMotion(),
                extentRatio: 0.4,
                children: [
                  SlidableAction(
                    onPressed: (_) async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MkFormScreen(mataKuliah: mk)),
                      );
                      if (result == true) reloadPreferences();
                    },
                    backgroundColor: Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    icon: Icons.edit_outlined,
                    label: 'Edit',
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                  ),
                  SlidableAction(
                    onPressed: (_) => _deleteMataKuliah(mk.id!),
                    backgroundColor: Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    icon: Icons.delete_outline,
                    label: 'Hapus',
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(16), bottomRight: Radius.circular(16)),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MkDashboardScreen(mkId: mk.id!)),
                  );
                  reloadPreferences();
                },
                borderRadius: BorderRadius.circular(16),
                child: cardContent,
              ),
            );
          }

          final bool isFiltered = _semesterAktif != 'Semua Semester';
          final bool hasAnyMk = list.isNotEmpty;

          Widget emptyState = Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: AppColors.sageBg, shape: BoxShape.circle),
                    child: Icon(
                      isFiltered && hasAnyMk ? Icons.filter_list_off : Icons.science_outlined,
                      size: 48, color: AppColors.sage,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    isFiltered && hasAnyMk
                        ? 'Tidak ada Mata Kuliah di $_semesterAktif'
                        : 'Belum ada mata kuliah',
                    style: TextStyle(fontSize: 18, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    isFiltered && hasAnyMk
                        ? 'Ubah filter semester di Pengaturan'
                        : 'Tekan tombol + untuk menambahkan',
                    style: TextStyle(fontSize: 14, color: AppColors.textPlaceholder),
                  ),
                ],
              ),
            ),
          );

          return RefreshIndicator(
            onRefresh: () async {
              reloadPreferences();
            },
            color: AppColors.sage,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildDashboardHeader(),
                ),
                SliverToBoxAdapter(
                  child: _buildQuickStats(),
                ),
                if (!_isLoadingStats)
                  SliverToBoxAdapter(
                    child: _buildBarChart(),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mata Kuliah Anda', 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color)
                        ),
                        if (_semesterAktif != 'Semua Semester')
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.sage.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _semesterAktif,
                              style: TextStyle(fontSize: 12, color: AppColors.sage, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (filteredList.isEmpty)
                  SliverToBoxAdapter(child: emptyState)
                else if (_isGridView)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => buildItem(context, index),
                        childCount: filteredList.length,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: buildItem(context, index),
                        ),
                        childCount: filteredList.length,
                      ),
                    ),
                  ),
                SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
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
            MaterialPageRoute(builder: (_) => const MkFormScreen()),
          );
          if (result == true) {
            reloadPreferences();
          }
        },
      ),
    );
  }
}
