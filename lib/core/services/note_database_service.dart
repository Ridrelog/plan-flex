import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class NoteDatabaseService {
  static final NoteDatabaseService instance = NoteDatabaseService._init();

  static Database? _database;

  NoteDatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('calendar_notes.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        date TEXT PRIMARY KEY,
        note TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tabungan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        target REAL NOT NULL,
        terkumpul REAL NOT NULL,
        hari INTEGER NOT NULL,
        gambar TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE riwayat_tabungan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tabungan_id INTEGER NOT NULL,
        nominal REAL NOT NULL,
        tipe TEXT NOT NULL,
        keterangan TEXT,
        tanggal TEXT NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE tabungan (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nama TEXT NOT NULL,
          target REAL NOT NULL,
          terkumpul REAL NOT NULL,
          hari INTEGER NOT NULL,
          gambar TEXT
        )
      ''');
    }

    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE riwayat_tabungan (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          tabungan_id INTEGER NOT NULL,
          nominal REAL NOT NULL,
          tipe TEXT NOT NULL,
          keterangan TEXT,
          tanggal TEXT NOT NULL
        )
      ''');
    }
  }

  Future<Map<String, String>> getAllNotes() async {
    final db = await database;
    final result = await db.query('notes');

    return {
      for (final item in result) item['date'] as String: item['note'] as String,
    };
  }

  Future<void> saveNote(String date, String note) async {
    final db = await database;

    await db.insert(
      'notes',
      {
        'date': date,
        'note': note,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteNote(String date) async {
    final db = await database;

    await db.delete(
      'notes',
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  Future<int> insertTabungan(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('tabungan', data);
  }

  Future<List<Map<String, dynamic>>> getAllTabungan() async {
    final db = await database;
    return await db.query('tabungan', orderBy: 'id DESC');
  }

  Future<void> updateTabungan(int id, Map<String, dynamic> data) async {
    final db = await database;

    await db.update(
      'tabungan',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateTerkumpul(int id, double terkumpul) async {
    final db = await database;

    return await db.update(
      'tabungan',
      {
        'terkumpul': terkumpul,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertRiwayatTabungan(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('riwayat_tabungan', data);
  }

  Future<List<Map<String, dynamic>>> getRiwayatTabungan(int tabunganId) async {
    final db = await database;

    return await db.query(
      'riwayat_tabungan',
      where: 'tabungan_id = ?',
      whereArgs: [tabunganId],
      orderBy: 'id DESC',
    );
  }

  Future<void> deleteTabungan(int id) async {
    final db = await database;

    await db.delete(
      'riwayat_tabungan',
      where: 'tabungan_id = ?',
      whereArgs: [id],
    );

    await db.delete(
      'tabungan',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}