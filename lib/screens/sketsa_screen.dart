import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:tubes_ppbl/utils/app_colors.dart';
import 'package:tubes_ppbl/models/lampiran_media.dart';
import 'package:tubes_ppbl/sqlite/koneksi.dart';

class DrawingPoint {
  final Offset offset;
  final Paint paint;
  DrawingPoint({required this.offset, required this.paint});
}

class SketchPainter extends CustomPainter {
  final List<DrawingPoint?> points;
  SketchPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!.offset, points[i + 1]!.offset, points[i]!.paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SketchPainter oldDelegate) => true;
}

class SketsaScreen extends StatefulWidget {
  final int eksperimenId;
  const SketsaScreen({super.key, required this.eksperimenId});

  @override
  State<SketsaScreen> createState() => _SketsaScreenState();
}

class _SketsaScreenState extends State<SketsaScreen> {
  final GlobalKey _repaintKey = GlobalKey();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final List<DrawingPoint?> _points = [];
  Color _selectedColor = Colors.black;
  double _strokeWidth = 3.0;
  bool _isSaving = false;

  final List<Color> _colorOptions = [
    Colors.black,
    const Color(0xFFEF4444),
    const Color(0xFF3B82F6),
    const Color(0xFF16A34A),
    const Color(0xFFF59E0B),
    const Color(0xFF8B5CF6),
    const Color(0xFFEC4899),
    const Color(0xFF64748B),
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final hex = prefs.getString('sketsa_color');
    final sw = prefs.getDouble('sketsa_stroke_width');
    setState(() {
      if (hex != null) _selectedColor = Color(int.parse(hex, radix: 16));
      if (sw != null) _strokeWidth = sw;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sketsa_color', _selectedColor.value.toRadixString(16));
    await prefs.setDouble('sketsa_stroke_width', _strokeWidth);
  }

  Paint _createPaint() {
    return Paint()
      ..color = _selectedColor
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
  }

  Future<void> _saveSketch() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final boundary = _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final sketsaDir = Directory('${directory.path}/sketsa');
      if (!await sketsaDir.exists()) await sketsaDir.create(recursive: true);

      final ts = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${sketsaDir.path}/sketsa_$ts.png';
      await File(filePath).writeAsBytes(pngBytes);

      await _dbHelper.insertLampiran(LampiranMedia(
        eksperimenId: widget.eksperimenId,
        filePath: filePath,
        jenisMedia: 'SKETSA',
        waktuDiambil: DateTime.now().toIso8601String(),
      ));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Sketsa berhasil disimpan'),
          backgroundColor: AppColors.sage,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal menyimpan: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: const Text('Papan Sketsa', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.slate900,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: RepaintBoundary(
                    key: _repaintKey,
                    child: GestureDetector(
                      onPanStart: (d) => setState(() => _points.add(DrawingPoint(offset: d.localPosition, paint: _createPaint()))),
                      onPanUpdate: (d) => setState(() => _points.add(DrawingPoint(offset: d.localPosition, paint: _createPaint()))),
                      onPanEnd: (_) => setState(() => _points.add(null)),
                      child: CustomPaint(painter: SketchPainter(points: _points), size: Size.infinite),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Toolbar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.bgCard,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Color picker
                Row(
                  children: [
                    const Text('Warna', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _colorOptions.map((c) {
                            final sel = _selectedColor == c;
                            return GestureDetector(
                              onTap: () { setState(() => _selectedColor = c); _savePreferences(); },
                              child: Container(
                                width: 32, height: 32,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: c, shape: BoxShape.circle,
                                  border: Border.all(color: sel ? AppColors.sage : AppColors.border, width: sel ? 3 : 1),
                                ),
                                child: sel ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Stroke width
                Row(
                  children: [
                    const Text('Tebal', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                    Expanded(
                      child: Slider(
                        value: _strokeWidth, min: 1, max: 20,
                        activeColor: AppColors.sage, inactiveColor: AppColors.border,
                        onChanged: (v) => setState(() => _strokeWidth = v),
                        onChangeEnd: (_) => _savePreferences(),
                      ),
                    ),
                    Text(_strokeWidth.toStringAsFixed(1), style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: const BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => setState(() => _points.clear()),
                        icon: const Icon(Icons.clear, size: 18),
                        label: const Text('Hapus Semua'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.sage,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _points.isNotEmpty && !_isSaving ? _saveSketch : null,
                        icon: const Icon(Icons.save_outlined, size: 18, color: Colors.white),
                        label: const Text('Simpan Sketsa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
