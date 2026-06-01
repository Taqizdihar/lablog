import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import 'package:tubes_ppbl/models/mata_kuliah.dart';
import 'package:tubes_ppbl/models/jadwal_praktikum.dart';
import 'package:tubes_ppbl/models/eksperimen.dart';
import 'package:tubes_ppbl/models/alat_bahan.dart';
import 'package:tubes_ppbl/models/pengamatan.dart';
import 'package:tubes_ppbl/models/lampiran_media.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Configure database factory for web platform
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWebNoWebWorker;
    }

    String path = 'lablog_database.db';
    if (!kIsWeb) {
      path = join(await getDatabasesPath(), 'lablog_database.db');
    }
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future _onConfigure(Database db) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _onCreate(Database db, int version) async {
    // Table 1: mata_kuliah
    await db.execute('''
      CREATE TABLE mata_kuliah(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT,
        dosen TEXT,
        semester TEXT,
        warna TEXT
      )
    ''');

    // Table 2: jadwal_praktikum
    await db.execute('''
      CREATE TABLE jadwal_praktikum(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mk_id INTEGER,
        hari TEXT,
        jam_mulai TEXT,
        ruangan TEXT,
        FOREIGN KEY (mk_id) REFERENCES mata_kuliah (id) ON DELETE CASCADE
      )
    ''');

    // Table 3: eksperimen
    await db.execute('''
      CREATE TABLE eksperimen(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mk_id INTEGER,
        judul TEXT,
        tanggal TEXT,
        tujuan TEXT,
        alat TEXT,
        prosedur TEXT,
        kesimpulan TEXT,
        FOREIGN KEY (mk_id) REFERENCES mata_kuliah (id) ON DELETE CASCADE
      )
    ''');

    // Table 4: alat_bahan
    await db.execute('''
      CREATE TABLE alat_bahan(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        eksperimen_id INTEGER,
        nama_item TEXT,
        jumlah INTEGER,
        is_ready INTEGER,
        FOREIGN KEY (eksperimen_id) REFERENCES eksperimen (id) ON DELETE CASCADE
      )
    ''');

    // Table 5: pengamatan
    await db.execute('''
      CREATE TABLE pengamatan(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        eksperimen_id INTEGER,
        variabel TEXT,
        nilai REAL,
        satuan TEXT,
        FOREIGN KEY (eksperimen_id) REFERENCES eksperimen (id) ON DELETE CASCADE
      )
    ''');

    // Table 6: lampiran_media
    await db.execute('''
      CREATE TABLE lampiran_media(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        eksperimen_id INTEGER,
        file_path TEXT,
        jenis_media TEXT,
        waktu_diambil TEXT,
        FOREIGN KEY (eksperimen_id) REFERENCES eksperimen (id) ON DELETE CASCADE
      )
    ''');
  }

  // ============ CRUD: Mata Kuliah ============

  Future<int> insertMataKuliah(MataKuliah mk) async {
    final db = await database;
    return await db.insert('mata_kuliah', mk.toMap());
  }

  Future<List<MataKuliah>> getMataKuliahList() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('mata_kuliah');
    return List.generate(maps.length, (i) => MataKuliah.fromMap(maps[i]));
  }

  Future<int> updateMataKuliah(MataKuliah mk) async {
    final db = await database;
    return await db.update(
      'mata_kuliah',
      mk.toMap(),
      where: 'id = ?',
      whereArgs: [mk.id],
    );
  }

  Future<int> deleteMataKuliah(int id) async {
    final db = await database;
    return await db.delete(
      'mata_kuliah',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============ CRUD: Jadwal Praktikum ============

  Future<int> insertJadwal(JadwalPraktikum jadwal) async {
    final db = await database;
    return await db.insert('jadwal_praktikum', jadwal.toMap());
  }

  Future<List<JadwalPraktikum>> getJadwalList() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('jadwal_praktikum');
    return List.generate(maps.length, (i) => JadwalPraktikum.fromMap(maps[i]));
  }

  // ============ CRUD: Pengamatan ============

  Future<int> insertPengamatan(Pengamatan data) async {
    final db = await database;
    return await db.insert('pengamatan', data.toMap());
  }

  Future<List<Pengamatan>> getPengamatanList(int eksperimenId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pengamatan',
      where: 'eksperimen_id = ?',
      whereArgs: [eksperimenId],
    );
    return List.generate(maps.length, (i) => Pengamatan.fromMap(maps[i]));
  }

  Future<int> deletePengamatan(int id) async {
    final db = await database;
    return await db.delete(
      'pengamatan',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============ CRUD: Lampiran Media ============

  Future<int> insertLampiran(LampiranMedia media) async {
    final db = await database;
    return await db.insert('lampiran_media', media.toMap());
  }

  Future<List<LampiranMedia>> getLampiranList(int eksperimenId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'lampiran_media',
      where: 'eksperimen_id = ?',
      whereArgs: [eksperimenId],
    );
    return List.generate(maps.length, (i) => LampiranMedia.fromMap(maps[i]));
  }

  Future<int> deleteLampiran(int id) async {
    final db = await database;
    return await db.delete(
      'lampiran_media',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============ CRUD: Eksperimen ============

  Future<int> insertEksperimen(Eksperimen eks) async {
    final db = await database;
    return await db.insert('eksperimen', eks.toMap());
  }

  Future<List<Eksperimen>> getEksperimenList(int mkId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'eksperimen',
      where: 'mk_id = ?',
      whereArgs: [mkId],
    );
    return List.generate(maps.length, (i) => Eksperimen.fromMap(maps[i]));
  }

  Future<int> updateEksperimen(Eksperimen eks) async {
    final db = await database;
    return await db.update(
      'eksperimen',
      eks.toMap(),
      where: 'id = ?',
      whereArgs: [eks.id],
    );
  }

  Future<int> deleteEksperimen(int id) async {
    final db = await database;
    return await db.delete(
      'eksperimen',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============ CRUD: Alat Bahan ============

  Future<int> insertAlatBahan(AlatBahan alat) async {
    final db = await database;
    return await db.insert('alat_bahan', alat.toMap());
  }

  Future<List<AlatBahan>> getAlatBahanList(int eksperimenId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'alat_bahan',
      where: 'eksperimen_id = ?',
      whereArgs: [eksperimenId],
    );
    return List.generate(maps.length, (i) => AlatBahan.fromMap(maps[i]));
  }

  Future<int> updateAlatBahan(AlatBahan alat) async {
    final db = await database;
    return await db.update(
      'alat_bahan',
      alat.toMap(),
      where: 'id = ?',
      whereArgs: [alat.id],
    );
  }
}
