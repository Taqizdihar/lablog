import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:tubes_ppbl/models/mata_kuliah.dart';
import 'package:tubes_ppbl/models/peminjaman_alat.dart';
import 'package:tubes_ppbl/models/jadwal_praktikum.dart';
import 'package:tubes_ppbl/models/eksperimen.dart';
import 'package:tubes_ppbl/models/tim_kelompok.dart';
import 'package:tubes_ppbl/models/referensi.dart';

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
    if (kIsWeb) {
      var factory = databaseFactoryFfiWebNoWebWorker;
      return await factory.openDatabase(
        'lablog_database.db',
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _onCreate,
          onConfigure: _onConfigure,
        ),
      );
    }

    final dbPath = join(await getDatabasesPath(), 'lablog_database.db');
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON;');
  }

  Future _onCreate(Database db, int version) async {

    await db.execute('''
      CREATE TABLE mata_kuliah(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_mk TEXT NOT NULL,
        dosen TEXT NOT NULL,
        semester TEXT NOT NULL,
        warna_label TEXT NOT NULL
      )
    ''');


    await db.execute('''
      CREATE TABLE peminjaman_alat(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_alat TEXT NOT NULL,
        tanggal_pinjam TEXT NOT NULL,
        tenggat_kembali TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');


    await db.execute('''
      CREATE TABLE jadwal_praktikum(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mk_id INTEGER NOT NULL,
        hari TEXT NOT NULL,
        jam_mulai TEXT NOT NULL,
        jam_selesai TEXT NOT NULL,
        ruangan TEXT NOT NULL,
        FOREIGN KEY (mk_id) REFERENCES mata_kuliah(id) ON DELETE CASCADE
      )
    ''');


    await db.execute('''
      CREATE TABLE eksperimen(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mk_id INTEGER NOT NULL,
        judul TEXT NOT NULL,
        tanggal TEXT NOT NULL,
        tujuan TEXT NOT NULL,
        prosedur TEXT NOT NULL,
        kesimpulan TEXT NOT NULL,
        status_jurnal TEXT NOT NULL,
        FOREIGN KEY (mk_id) REFERENCES mata_kuliah(id) ON DELETE CASCADE
      )
    ''');


    await db.execute('''
      CREATE TABLE tim_kelompok(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mk_id INTEGER NOT NULL,
        nama_anggota TEXT NOT NULL,
        nim TEXT NOT NULL,
        peran TEXT NOT NULL,
        no_hp TEXT NOT NULL,
        FOREIGN KEY (mk_id) REFERENCES mata_kuliah(id) ON DELETE CASCADE
      )
    ''');


    await db.execute('''
      CREATE TABLE referensi(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mk_id INTEGER NOT NULL,
        judul_buku TEXT NOT NULL,
        penulis TEXT NOT NULL,
        tahun_terbit TEXT NOT NULL,
        tautan_sumber TEXT NOT NULL,
        FOREIGN KEY (mk_id) REFERENCES mata_kuliah(id) ON DELETE CASCADE
      )
    ''');
  }



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



  Future<int> insertPeminjamanAlat(PeminjamanAlat alat) async {
    final db = await database;
    return await db.insert('peminjaman_alat', alat.toMap());
  }

  Future<List<PeminjamanAlat>> getPeminjamanAlatList() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('peminjaman_alat');
    return List.generate(
        maps.length, (i) => PeminjamanAlat.fromMap(maps[i]));
  }

  Future<int> updatePeminjamanAlat(PeminjamanAlat alat) async {
    final db = await database;
    return await db.update(
      'peminjaman_alat',
      alat.toMap(),
      where: 'id = ?',
      whereArgs: [alat.id],
    );
  }

  Future<int> deletePeminjamanAlat(int id) async {
    final db = await database;
    return await db.delete(
      'peminjaman_alat',
      where: 'id = ?',
      whereArgs: [id],
    );
  }



  Future<int> insertJadwal(JadwalPraktikum jadwal) async {
    final db = await database;
    return await db.insert('jadwal_praktikum', jadwal.toMap());
  }

  Future<List<JadwalPraktikum>> getJadwalList(int mkId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'jadwal_praktikum',
      where: 'mk_id = ?',
      whereArgs: [mkId],
    );
    return List.generate(
        maps.length, (i) => JadwalPraktikum.fromMap(maps[i]));
  }

  Future<int> updateJadwal(JadwalPraktikum jadwal) async {
    final db = await database;
    return await db.update(
      'jadwal_praktikum',
      jadwal.toMap(),
      where: 'id = ?',
      whereArgs: [jadwal.id],
    );
  }

  Future<int> deleteJadwal(int id) async {
    final db = await database;
    return await db.delete(
      'jadwal_praktikum',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<JadwalPraktikum>> getAllJadwalList() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('jadwal_praktikum');
    return List.generate(
        maps.length, (i) => JadwalPraktikum.fromMap(maps[i]));
  }



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



  Future<int> insertTimKelompok(TimKelompok tim) async {
    final db = await database;
    return await db.insert('tim_kelompok', tim.toMap());
  }

  Future<List<TimKelompok>> getTimKelompokList(int mkId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tim_kelompok',
      where: 'mk_id = ?',
      whereArgs: [mkId],
    );
    return List.generate(
        maps.length, (i) => TimKelompok.fromMap(maps[i]));
  }

  Future<int> updateTimKelompok(TimKelompok tim) async {
    final db = await database;
    return await db.update(
      'tim_kelompok',
      tim.toMap(),
      where: 'id = ?',
      whereArgs: [tim.id],
    );
  }

  Future<int> deleteTimKelompok(int id) async {
    final db = await database;
    return await db.delete(
      'tim_kelompok',
      where: 'id = ?',
      whereArgs: [id],
    );
  }



  Future<int> insertReferensi(Referensi ref) async {
    final db = await database;
    return await db.insert('referensi', ref.toMap());
  }

  Future<List<Referensi>> getReferensiList(int mkId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'referensi',
      where: 'mk_id = ?',
      whereArgs: [mkId],
    );
    return List.generate(maps.length, (i) => Referensi.fromMap(maps[i]));
  }

  Future<int> updateReferensi(Referensi ref) async {
    final db = await database;
    return await db.update(
      'referensi',
      ref.toMap(),
      where: 'id = ?',
      whereArgs: [ref.id],
    );
  }

  Future<int> deleteReferensi(int id) async {
    final db = await database;
    return await db.delete(
      'referensi',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
