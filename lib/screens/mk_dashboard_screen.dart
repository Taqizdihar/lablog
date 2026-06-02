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

  @override
  void initState() {
    super.initState();
    _mkListFuture = DatabaseHelper().getMataKuliahList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MataKuliah>>(
      future: _mkListFuture,
      builder: (context, snapshot) {
        String title = 'Dashboard';
        if (snapshot.hasData) {
          final match = snapshot.data!.where((mk) => mk.id == widget.mkId);
          if (match.isNotEmpty) title = match.first.namaMk;
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
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.sageBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.dashboard_rounded,
                          size: 28, color: AppColors.sage),
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
                          SizedBox(height: 4),
                          Text('Pilih menu di bawah',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  ]),
                ),

                SizedBox(height: 24),


                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.0,
                    children: [
                      _buildMenuCard(
                        context,
                        icon: Icons.science_outlined,
                        label: 'Jurnal\nEksperimen',
                        color: Color(0xFF3B82F6),
                        bg: AppColors.baruBg,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => EksperimenListScreen(
                                    mkId: widget.mkId))),
                      ),
                      _buildMenuCard(
                        context,
                        icon: Icons.group_outlined,
                        label: 'Tim\nKelompok',
                        color: Color(0xFF8B5CF6),
                        bg: AppColors.mkPurple,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => TimListScreen(
                                    mkId: widget.mkId))),
                      ),
                      _buildMenuCard(
                        context,
                        icon: Icons.menu_book_outlined,
                        label: 'Referensi',
                        color: Color(0xFFF59E0B),
                        bg: AppColors.mkYellow,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ReferensiListScreen(
                                    mkId: widget.mkId))),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
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
