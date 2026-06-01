import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tubes_ppbl/utils/app_colors.dart';
import 'package:tubes_ppbl/models/pengamatan.dart';
import 'package:tubes_ppbl/sqlite/koneksi.dart';

class PengamatanScreen extends StatefulWidget {
  final int eksperimenId;
  const PengamatanScreen({super.key, required this.eksperimenId});

  @override
  State<PengamatanScreen> createState() => _PengamatanScreenState();
}

class _PengamatanScreenState extends State<PengamatanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _varController = TextEditingController();
  final _nilaiController = TextEditingController();
  final _satuanController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  late Future<List<Pengamatan>> _dataFuture;
  bool _showChart = false;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  @override
  void dispose() {
    _varController.dispose();
    _nilaiController.dispose();
    _satuanController.dispose();
    super.dispose();
  }

  void _refreshData() {
    setState(() {
      _dataFuture = _dbHelper.getPengamatanList(widget.eksperimenId);
    });
  }

  Future<void> _addData() async {
    if (!_formKey.currentState!.validate()) return;

    final data = Pengamatan(
      eksperimenId: widget.eksperimenId,
      variabel: _varController.text,
      nilai: double.parse(_nilaiController.text),
      satuan: _satuanController.text,
    );
    await _dbHelper.insertPengamatan(data);

    _varController.clear();
    _nilaiController.clear();
    _satuanController.clear();
    _refreshData();
  }

  Future<void> _deleteItem(int id) async {
    await _dbHelper.deletePengamatan(id);
    _refreshData();
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.sage),
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: AppColors.bgCard,
      isDense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: const Text('Data Pengamatan', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.slate900,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Form
            Card(
              color: AppColors.bgCard,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Tambah Data',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.slate700)),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _varController,
                        decoration: _inputDeco('Variabel', Icons.science_outlined),
                        style: const TextStyle(color: AppColors.textPrimary),
                        validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _nilaiController,
                              decoration: _inputDeco('Nilai', Icons.numbers),
                              style: const TextStyle(color: AppColors.textPrimary),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Wajib diisi';
                                if (double.tryParse(v) == null) return 'Harus angka';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: _satuanController,
                              decoration: _inputDeco('Satuan', Icons.straighten),
                              style: const TextStyle(color: AppColors.textPrimary),
                              validator: (v) => v == null || v.isEmpty ? 'Wajib' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.sage,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _addData,
                        icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 18),
                        label: const Text('Tambah Data',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Toggle View
            Row(
              children: [
                const Text('Tampilan:', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Tabel'),
                  selected: !_showChart,
                  onSelected: (_) => setState(() => _showChart = false),
                  selectedColor: AppColors.sageBg,
                  labelStyle: TextStyle(
                    color: !_showChart ? AppColors.sageText : AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                  side: BorderSide(color: !_showChart ? AppColors.sageBorder : AppColors.border),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Grafik'),
                  selected: _showChart,
                  onSelected: (_) => setState(() => _showChart = true),
                  selectedColor: AppColors.sageBg,
                  labelStyle: TextStyle(
                    color: _showChart ? AppColors.sageText : AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                  side: BorderSide(color: _showChart ? AppColors.sageBorder : AppColors.border),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Data View
            FutureBuilder<List<Pengamatan>>(
              future: _dataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: AppColors.sage),
                  ));
                }

                final list = snapshot.data ?? [];
                if (list.isEmpty) {
                  return Card(
                    color: AppColors.bgCard,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text('Belum ada data pengamatan',
                          style: TextStyle(color: AppColors.textMuted)),
                      ),
                    ),
                  );
                }

                if (_showChart) return _buildChart(list);
                return _buildTable(list);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(List<Pengamatan> list) {
    return Card(
      color: AppColors.bgCard,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
        itemBuilder: (context, index) {
          final item = list[index];
          return ListTile(
            title: Text(item.variabel,
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
            subtitle: Text('${item.nilai} ${item.satuan}',
              style: const TextStyle(color: AppColors.textSecondary)),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
              onPressed: () => _deleteItem(item.id!),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChart(List<Pengamatan> list) {
    final spots = list.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.nilai);
    }).toList();

    return Card(
      color: AppColors.bgCard,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AspectRatio(
          aspectRatio: 1.6,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: AppColors.border,
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) => Text(
                      value.toStringAsFixed(1),
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i >= 0 && i < list.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(list[i].variabel,
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border: const Border(
                  left: BorderSide(color: AppColors.border),
                  bottom: BorderSide(color: AppColors.border),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: AppColors.sage,
                  barWidth: 3,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                      radius: 4,
                      color: AppColors.sage,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.sage.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
