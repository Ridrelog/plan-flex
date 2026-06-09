import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CatatanRepository {
  static const String catatanDocId = 'catatan_utama';
  static const String _localKey = 'catatan_harian_utama';

  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('catatan_harian');

  Future<String> ambilCatatan() async {
    final prefs = await SharedPreferences.getInstance();
    final localValue = prefs.getString(_localKey);

    // Ambil dari memory HP dulu.
    if (localValue != null) return localValue;

    // Kalau belum ada di HP, coba ambil dari Firebase lalu simpan ke HP.
    try {
      final doc = await _collection.doc(catatanDocId).get();
      if (!doc.exists) return '';

      final data = doc.data();
      final firebaseValue = data?['isi']?.toString() ?? '';

      await prefs.setString(_localKey, firebaseValue);
      return firebaseValue;
    } catch (e) {
      print('Gagal ambil catatan dari Firebase: $e');
      return '';
    }
  }

  Future<void> simpanCatatan(String value) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Simpan ke memory/storage HP dulu.
    await prefs.setString(_localKey, value);

    // 2. Setelah lokal aman, coba kirim ke Firebase.
    try {
      await _collection.doc(catatanDocId).set({
        'isi': value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Gagal sync catatan ke Firebase: $e');
    }
  }

  Future<void> hapusCatatan() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Hapus dari memory HP dulu.
    await prefs.remove(_localKey);

    // 2. Coba hapus dari Firebase.
    try {
      await _collection.doc(catatanDocId).delete();
    } catch (e) {
      print('Gagal sync hapus catatan ke Firebase: $e');
    }
  }
}
