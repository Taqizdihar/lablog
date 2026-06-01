import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
    String path = join(await getDatabasesPath(), 'lablog_database.db');
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
}
