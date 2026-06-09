class RiwayatTabunganModel {
  final int? id;
  final int tabunganId;
  final num nominal;
  final String tipe;
  final String keterangan;
  final String tanggal;

  const RiwayatTabunganModel({
    this.id,
    required this.tabunganId,
    required this.nominal,
    required this.tipe,
    required this.keterangan,
    required this.tanggal,
  });

  factory RiwayatTabunganModel.fromMap(Map<String, dynamic> map) {
    return RiwayatTabunganModel(
      id: map['id'] as int?,
      tabunganId: map['tabungan_id'] as int,
      nominal: map['nominal'] as num,
      tipe: map['tipe'].toString(),
      keterangan: map['keterangan']?.toString() ?? '',
      tanggal: map['tanggal'].toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'tabungan_id': tabunganId,
      'nominal': nominal,
      'tipe': tipe,
      'keterangan': keterangan,
      'tanggal': tanggal,
    };
  }
}
