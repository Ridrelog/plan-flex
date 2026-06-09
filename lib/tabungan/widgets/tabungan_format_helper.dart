class TabunganFormatHelper {
  static String formatRupiah(num value) {
    return value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
  }

  static num parseNominal(String value) {
    return num.tryParse(value.replaceAll('.', '').replaceAll(',', '')) ?? 0;
  }

  static String formatTanggal(String value) {
    final tanggal = DateTime.parse(value);

    const bulan = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    final jam = tanggal.hour.toString().padLeft(2, '0');
    final menit = tanggal.minute.toString().padLeft(2, '0');

    return '${tanggal.day} ${bulan[tanggal.month]} ${tanggal.year} • $jam:$menit';
  }
}
