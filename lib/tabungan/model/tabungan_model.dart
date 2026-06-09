class TabunganModel {
  final int? id;
  final String nama;
  final double target;
  final double terkumpul;
  final int hari;
  final String? gambar;

  const TabunganModel({
    this.id,
    required this.nama,
    required this.target,
    required this.terkumpul,
    required this.hari,
    this.gambar,
  });

  factory TabunganModel.fromMap(Map<String, dynamic> map) {
    return TabunganModel(
      id: map['id'] as int?,
      nama: map['nama']?.toString() ?? '',
      target: (map['target'] as num).toDouble(),
      terkumpul: (map['terkumpul'] as num).toDouble(),
      hari: map['hari'] as int,
      gambar: map['gambar']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nama': nama,
      'target': target,
      'terkumpul': terkumpul,
      'hari': hari,
      'gambar': gambar,
    };
  }
}
