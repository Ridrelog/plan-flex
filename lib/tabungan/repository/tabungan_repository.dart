import '../../core/services/note_database_service.dart';

class TabunganRepository {
  Future<List<Map<String, dynamic>>> getAllTabungan() {
    return NoteDatabaseService.instance.getAllTabungan();
  }

  Future<int> insertTabungan(Map<String, dynamic> data) {
    return NoteDatabaseService.instance.insertTabungan(data);
  }

  Future<void> updateTabungan(int id, Map<String, dynamic> data) {
    return NoteDatabaseService.instance.updateTabungan(id, data);
  }

  Future<void> deleteTabungan(int id) {
    return NoteDatabaseService.instance.deleteTabungan(id);
  }

  Future<int> updateTerkumpul(int id, double terkumpul) {
    return NoteDatabaseService.instance.updateTerkumpul(id, terkumpul);
  }

  Future<void> insertRiwayatTabungan(Map<String, dynamic> data) {
    return NoteDatabaseService.instance.insertRiwayatTabungan(data);
  }

  Future<List<Map<String, dynamic>>> getRiwayatTabungan(int tabunganId) {
    return NoteDatabaseService.instance.getRiwayatTabungan(tabunganId);
  }
}
