import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class NoteDatabaseService {
  static final NoteDatabaseService instance = NoteDatabaseService._init();

  static Database? _database;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  NoteDatabaseService._init();

  CollectionReference<Map<String, dynamic>> get _notesCollection =>
      _firestore.collection('notes');

  CollectionReference<Map<String, dynamic>> get _tabunganCollection =>
      _firestore.collection('tabungan');

  CollectionReference<Map<String, dynamic>> get _riwayatTabunganCollection =>
      _firestore.collection('riwayat_tabungan');

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase('plan_flex.db');
    return _database!;
  }

  Future<Database> _initDatabase(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
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

  Future<Map<String, String>> getAllNotes() async {
    final db = await database;
    final result = await db.query('notes');

    return {
      for (final item in result)
        item['date'].toString(): item['note']?.toString() ?? '',
    };
  }

  Future<void> saveNote(String date, String note) async {
    final db = await database;

    // 1. Simpan ke memory/storage HP dulu.
    await db.insert(
      'notes',
      {
        'date': date,
        'note': note,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // 2. Setelah lokal aman, coba kirim ke Firebase.
    try {
      await _notesCollection.doc(date).set({
        'date': date,
        'note': note,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Kalau internet mati, data tetap aman di HP.
      // Nanti bisa ditambah fitur sync ulang otomatis kalau dibutuhkan.
      print('Gagal sync note ke Firebase: $e');
    }
  }

  Future<void> deleteNote(String date) async {
    final db = await database;

    // 1. Hapus dari lokal HP dulu.
    await db.delete(
      'notes',
      where: 'date = ?',
      whereArgs: [date],
    );

    // 2. Coba hapus dari Firebase.
    try {
      await _notesCollection.doc(date).delete();
    } catch (e) {
      print('Gagal sync delete note ke Firebase: $e');
    }
  }

  Future<int> insertTabungan(Map<String, dynamic> data) async {
    final db = await database;

    final localData = Map<String, dynamic>.from(data);
    localData.remove('id');

    // 1. Simpan ke database lokal HP dulu.
    final localId = await db.insert('tabungan', localData);

    // 2. Setelah lokal aman, coba kirim ke Firebase.
    try {
      final firebaseData = Map<String, dynamic>.from(data);
      firebaseData['id'] = localId;
      firebaseData['createdAt'] = FieldValue.serverTimestamp();
      firebaseData['updatedAt'] = FieldValue.serverTimestamp();

      await _tabunganCollection.doc(localId.toString()).set(firebaseData);
    } catch (e) {
      print('Gagal sync tabungan ke Firebase: $e');
    }

    return localId;
  }

  Future<List<Map<String, dynamic>>> getAllTabungan() async {
    final db = await database;

    return db.query(
      'tabungan',
      orderBy: 'id DESC',
    );
  }

  Future<void> updateTabungan(int id, Map<String, dynamic> data) async {
    final db = await database;

    final localData = Map<String, dynamic>.from(data);
    localData.remove('id');

    // 1. Update lokal HP dulu.
    await db.update(
      'tabungan',
      localData,
      where: 'id = ?',
      whereArgs: [id],
    );

    // 2. Coba update Firebase.
    try {
      final firebaseData = Map<String, dynamic>.from(data);
      firebaseData['id'] = id;
      firebaseData['updatedAt'] = FieldValue.serverTimestamp();

      await _tabunganCollection.doc(id.toString()).set(
            firebaseData,
            SetOptions(merge: true),
          );
    } catch (e) {
      print('Gagal sync update tabungan ke Firebase: $e');
    }
  }

  Future<int> updateTerkumpul(int id, double terkumpul) async {
    final db = await database;

    // 1. Update lokal HP dulu.
    final result = await db.update(
      'tabungan',
      {'terkumpul': terkumpul},
      where: 'id = ?',
      whereArgs: [id],
    );

    // 2. Coba update Firebase.
    try {
      await _tabunganCollection.doc(id.toString()).set(
        {
          'id': id,
          'terkumpul': terkumpul,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      print('Gagal sync update terkumpul ke Firebase: $e');
    }

    return result;
  }

  Future<void> insertRiwayatTabungan(Map<String, dynamic> data) async {
    final db = await database;

    final localData = Map<String, dynamic>.from(data);
    localData.remove('id');

    // 1. Simpan riwayat ke lokal HP dulu.
    final localId = await db.insert('riwayat_tabungan', localData);

    // 2. Coba kirim riwayat ke Firebase.
    try {
      final firebaseData = Map<String, dynamic>.from(data);
      firebaseData['id'] = localId;
      firebaseData['createdAt'] = FieldValue.serverTimestamp();

      await _riwayatTabunganCollection.doc(localId.toString()).set(firebaseData);
    } catch (e) {
      print('Gagal sync riwayat tabungan ke Firebase: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getRiwayatTabungan(int tabunganId) async {
    final db = await database;

    return db.query(
      'riwayat_tabungan',
      where: 'tabungan_id = ?',
      whereArgs: [tabunganId],
      orderBy: 'id DESC',
    );
  }

  Future<void> deleteTabungan(int id) async {
    final db = await database;

    // 1. Hapus data lokal HP dulu.
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

    // 2. Coba hapus data di Firebase.
    try {
      final batch = _firestore.batch();

      final riwayatSnapshot = await _riwayatTabunganCollection
          .where('tabungan_id', isEqualTo: id)
          .get();

      for (final doc in riwayatSnapshot.docs) {
        batch.delete(doc.reference);
      }

      batch.delete(_tabunganCollection.doc(id.toString()));

      await batch.commit();
    } catch (e) {
      print('Gagal sync delete tabungan ke Firebase: $e');
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
