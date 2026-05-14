import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/services/note_database_service.dart';
import 'tambah_page.dart';

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> item;

  const DetailPage({
    super.key,
    required this.item,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Map<String, dynamic> item;

  bool isTambah = true;
  List<Map<String, dynamic>> riwayat = [];

  final TextEditingController nominalController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();

  static const bgColor = Color(0xFFE1BA92);
  static const cardColor = Color(0xFFF1DCBA);
  static const softCardColor = Color(0xFFE7C49F);
  static const selectedColor = Color(0xFFF5E4C8);
  static const brownColor = Color(0xFF6B4B3E);
  static const textColor = Color(0xFF5A4034);
  static const borderColor = Color(0xFFB58A6B);
  static const buttonColor = Color(0xFFFFB86F);
  static const greenColor = Color(0xFF2F8F46);
  static const redColor = Color(0xFFC35A5A);

  @override
  void initState() {
    super.initState();
    item = Map<String, dynamic>.from(widget.item);
    loadRiwayat();
  }

  @override
  void dispose() {
    nominalController.dispose();
    keteranganController.dispose();
    super.dispose();
  }

  Future<void> loadRiwayat() async {
    final data = await NoteDatabaseService.instance.getRiwayatTabungan(
      item['id'],
    );

    if (!mounted) return;

    setState(() {
      riwayat = data;
    });
  }

  String formatRupiah(num value) {
    return value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
  }

  num parseNominal(String value) {
    return num.tryParse(value.replaceAll('.', '').replaceAll(',', '')) ?? 0;
  }

  String formatTanggal(String value) {
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

  Future<void> editData(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TambahPage(item: item),
      ),
    );

    if (result == true && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> hapusData(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: const Text(
            'Hapus Tabungan',
            style: TextStyle(color: textColor),
          ),
          content: const Text(
            'Yakin ingin menghapus tabungan ini?',
            style: TextStyle(color: textColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Batal',
                style: TextStyle(color: brownColor),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: brownColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await NoteDatabaseService.instance.deleteTabungan(item['id']);

      if (!context.mounted) return;
      Navigator.pop(context, true);
    }
  }

  Future<void> simpanCatatanTabungan() async {
    final nominal = parseNominal(nominalController.text);

    if (nominal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal tidak boleh kosong')),
      );
      return;
    }

    final terkumpulLama = (item['terkumpul'] as num).toDouble();
    final target = (item['target'] as num).toDouble();

    double terkumpulBaru;

    if (isTambah) {
      terkumpulBaru = terkumpulLama + nominal;
    } else {
      terkumpulBaru = terkumpulLama - nominal;
    }

    if (terkumpulBaru < 0) terkumpulBaru = 0;
    if (terkumpulBaru > target) terkumpulBaru = target;

    await NoteDatabaseService.instance.updateTerkumpul(
      item['id'],
      terkumpulBaru,
    );

    await NoteDatabaseService.instance.insertRiwayatTabungan({
      'tabungan_id': item['id'],
      'nominal': nominal,
      'tipe': isTambah ? 'tambah' : 'kurang',
      'keterangan': keteranganController.text.trim(),
      'tanggal': DateTime.now().toIso8601String(),
    });

    setState(() {
      item['terkumpul'] = terkumpulBaru;
    });

    await loadRiwayat();

    if (!mounted) return;
    Navigator.pop(context);

    nominalController.clear();
    keteranganController.clear();
  }

  void tampilDialogCatatanTabungan() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 24,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(26, 24, 26, 20),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Catat Tabungan',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Container(
                        height: 46,
                        decoration: BoxDecoration(
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setDialogState(() {
                                    isTambah = true;
                                  });
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isTambah
                                        ? selectedColor
                                        : Colors.transparent,
                                    borderRadius: const BorderRadius.horizontal(
                                      left: Radius.circular(30),
                                    ),
                                  ),
                                  child: const Text(
                                    '+ Tambah',
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 1,
                              color: borderColor,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setDialogState(() {
                                    isTambah = false;
                                  });
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: !isTambah
                                        ? selectedColor
                                        : Colors.transparent,
                                    borderRadius: const BorderRadius.horizontal(
                                      right: Radius.circular(30),
                                    ),
                                  ),
                                  child: const Text(
                                    '− Kurangi',
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      TextField(
                        controller: nominalController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: textColor),
                        cursorColor: brownColor,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: cardColor,
                          prefixIcon: const Icon(
                            Icons.money,
                            color: brownColor,
                          ),
                          hintText: 'Nominal',
                          hintStyle: const TextStyle(color: brownColor),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: brownColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _chipNominal('10.000'),
                            _chipNominal('1.000.000'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: keteranganController,
                        style: const TextStyle(color: textColor),
                        cursorColor: brownColor,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: cardColor,
                          prefixIcon: const Icon(
                            Icons.notes,
                            color: brownColor,
                          ),
                          hintText: 'Keterangan',
                          hintStyle: const TextStyle(color: brownColor),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: brownColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                nominalController.clear();
                                keteranganController.clear();
                              },
                              child: const Text(
                                'Batal',
                                style: TextStyle(
                                  color: brownColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: simpanCatatanTabungan,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedColor,
                                foregroundColor: textColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text(
                                'Simpan',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        riwayat.isEmpty
                            ? 'Tidak Ada Riwayat Tabungan'
                            : '${riwayat.length} Riwayat Tabungan',
                        style: const TextStyle(
                          color: brownColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _chipNominal(String value) {
    return GestureDetector(
      onTap: () {
        nominalController.text = value;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: cardColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          value,
          style: const TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nama = item['nama'] ?? '';
    final target = (item['target'] as num).toDouble();
    final terkumpul = (item['terkumpul'] as num).toDouble();
    final hari = item['hari'] as int;
    final gambar = item['gambar'];

    final progress = target == 0 ? 0.0 : terkumpul / target;
    final persen = (progress * 100).clamp(0, 100);
    final sisa = target - terkumpul;
    final perHari = sisa <= 0 ? 0 : sisa / hari;

    return Scaffold(
      backgroundColor: bgColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: brownColor,
        onPressed: tampilDialogCatatanTabungan,
        child: const Icon(
          Icons.edit_note,
          color: selectedColor,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: textColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => editData(context),
                    icon: const Icon(
                      Icons.edit,
                      color: brownColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () => hapusData(context),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: brownColor,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        nama,
                        style: const TextStyle(
                          color: textColor,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (gambar != null && gambar.toString().isNotEmpty)
                            Image.file(
                              File(gambar),
                              width: double.infinity,
                              fit: BoxFit.fitWidth,
                            ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Rp${formatRupiah(target)}',
                                        style: const TextStyle(
                                          color: textColor,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 58,
                                      width: 58,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: brownColor,
                                          width: 4,
                                        ),
                                      ),
                                      child: Text(
                                        '${persen.toStringAsFixed(0)}%',
                                        style: const TextStyle(
                                          color: textColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rp${formatRupiah(perHari)} Perhari',
                                  style: const TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Divider(color: borderColor),
                                const SizedBox(height: 12),
                                _infoRow('Tanggal Dibuat', '12 Mei'),
                                const SizedBox(height: 12),
                                _infoRow('Estimasi', '$hari Hari'),
                                const SizedBox(height: 12),
                                _infoRow(
                                  'Terkumpul',
                                  'Rp${formatRupiah(terkumpul)}',
                                ),
                                const SizedBox(height: 12),
                                _infoRow(
                                  'Sisa',
                                  'Rp${formatRupiah(sisa)}',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _riwayatCard(
                      target: target,
                      terkumpul: terkumpul,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _riwayatCard({
    required double target,
    required double terkumpul,
  }) {
    final kekurangan = target - terkumpul;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Terkumpul',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rp${formatRupiah(terkumpul)}',
                      style: const TextStyle(
                        color: greenColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 52,
                color: borderColor,
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Kekurangan',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rp${formatRupiah(kekurangan < 0 ? 0 : kekurangan)}',
                      style: const TextStyle(
                        color: redColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: borderColor),
          if (riwayat.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 16, bottom: 6),
              child: Text(
                'Tidak Ada Riwayat Tabungan',
                style: TextStyle(
                  color: brownColor,
                  fontSize: 14,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: riwayat.length,
              separatorBuilder: (_, __) => const Divider(color: borderColor),
              itemBuilder: (context, index) {
                final data = riwayat[index];

                final nominal = data['nominal'] as num;
                final tipe = data['tipe'] ?? 'tambah';
                final keterangan = data['keterangan'] ?? '';
                final tanggal =
                    data['tanggal'] ?? DateTime.now().toIso8601String();

                final isTambahData = tipe == 'tambah';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formatTanggal(tanggal),
                              style: const TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (keterangan.toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  keterangan.toString(),
                                  style: const TextStyle(
                                    color: brownColor,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        '${isTambahData ? '+' : '-'} ${formatRupiah(nominal)}',
                        style: TextStyle(
                          color: isTambahData ? greenColor : redColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}