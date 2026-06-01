import 'package:flutter/material.dart';
import 'package:tubes_ppbl/utils/app_colors.dart';
import 'package:tubes_ppbl/models/mata_kuliah.dart';
import 'package:tubes_ppbl/models/eksperimen.dart';
import 'package:tubes_ppbl/screens/eksperimen_form_screen.dart';

class MkDetailScreen extends StatefulWidget {
  final MataKuliah? mataKuliah;
  
  const MkDetailScreen({super.key, this.mataKuliah});

  @override
  State<MkDetailScreen> createState() => _MkDetailScreenState();
}

class _MkDetailScreenState extends State<MkDetailScreen> {
  // Static placeholder data for now
  final List<Eksperimen> _eksperimenList = [
    Eksperimen(
      id: 1,
      mkId: 1,
      judul: 'Eksperimen 1: Hukum Newton',
      tanggal: '2026-06-01',
      tujuan: 'Membuktikan hukum newton',
      alat: 'Beban, Tali',
      prosedur: 'Gantung beban pada tali',
      kesimpulan: 'Gaya berbanding lurus dengan percepatan'
    ),
    Eksperimen(
      id: 2,
      mkId: 1,
      judul: 'Eksperimen 2: Gerak Parabola',
      tanggal: '2026-06-08',
      tujuan: 'Mengetahui lintasan benda jatuh',
      alat: 'Bola, Mistar',
      prosedur: 'Lemparkan bola',
      kesimpulan: 'Lintasan berbentuk parabola'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: const Text('Detail Mata Kuliah', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.slate900,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: _eksperimenList.length,
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, index) {
          final eksperimen = _eksperimenList[index];
          return Card(
            color: AppColors.bgCard,
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                eksperimen.judul, 
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(eksperimen.tanggal, style: const TextStyle(color: AppColors.textSecondary)),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: index == 0 ? AppColors.selesaiBg : AppColors.baruBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: index == 0 ? AppColors.sageBorder : Colors.transparent),
                ),
                child: Text(
                  index == 0 ? 'Selesai' : 'Baru', 
                  style: TextStyle(
                    color: index == 0 ? AppColors.selesaiText : AppColors.baruText, 
                    fontSize: 12,
                    fontWeight: FontWeight.bold
                  )
                ),
              ),
              onTap: () {
                // Navigate to detail
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.sage,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EksperimenFormScreen()),
          );
        },
      ),
    );
  }
}
