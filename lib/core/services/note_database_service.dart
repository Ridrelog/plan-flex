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
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        date TEXT PRIMARY KEY,
        note TEXT NOT NULL
      )
    ''');
  }

  Future<Map<String, String>> getAllNotes() async {
    final db = await database;
    final result = await db.query('notes');

    return {
      for (final item in result)
        item['date'] as String: item['note'] as String,
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
}