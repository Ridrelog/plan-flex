import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/services/note_database_service.dart';
import 'detail_page.dart';
import 'tambah_page.dart';

class TabunganPage extends StatefulWidget {
  const TabunganPage({super.key});

  @override
  State<TabunganPage> createState() => _TabunganPageState();
}

class _TabunganPageState extends State<TabunganPage> {
  List<Map<String, dynamic>> daftarTabungan = [];

  @override
  void initState() {
    super.initState();
    loadTabungan();
  }

  Future<void> loadTabungan() async {
    final data = await NoteDatabaseService.instance.getAllTabungan();

    if (!mounted) return;

    setState(() {
      daftarTabungan = data;
    });
  }

  Future<void> tambahTabungan() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TambahPage(),
      ),
    );

    if (result == true) {
      loadTabungan();
    }
  }

  Future<void> bukaDetail(Map<String, dynamic> item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailPage(item: item),
      ),
    );

    loadTabungan();
  }

  String formatRupiah(num value) {
    return value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6B18B),
      body: daftarTabungan.isEmpty
          ? const Center(
              child: Text(
                'Belum ada celengan',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF5A4034),
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: daftarTabungan.length,
              itemBuilder: (context, index) {
                final item = daftarTabungan[index];

                final target = (item['target'] as num).toDouble();
                final terkumpul = (item['terkumpul'] as num).toDouble();
                final hari = item['hari'] as int;

                final progress = target == 0 ? 0.0 : terkumpul / target;
                final persen = (progress * 100).clamp(0, 100);
                final sisa = target - terkumpul;
                final perHari = sisa <= 0 ? 0 : sisa / hari;

                return GestureDetector(
                  onTap: () => bukaDetail(item),
                  child: Card(
                    color: const Color(0xFFF3E4D8),
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item['gambar'] != null &&
                              item['gambar'].toString().isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                File(item['gambar']),
                                width: double.infinity,
                                fit: BoxFit.fitWidth,
                              ),
                            ),

                          const SizedBox(height: 12),

                          Text(
                            item['nama'],
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF211810),
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Rp ${formatRupiah(terkumpul)} / Rp ${formatRupiah(target)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF211810),
                            ),
                          ),

                          const SizedBox(height: 10),

                          LinearProgressIndicator(
                            value: progress.clamp(0, 1),
                            minHeight: 12,
                            backgroundColor: const Color(0xFFE7D3B5),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF8A5200),
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            '${persen.toStringAsFixed(0)}% terkumpul',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF211810),
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            sisa <= 0
                                ? 'Target sudah tercapai!'
                                : 'Sisa: Rp ${formatRupiah(sisa)}',
                            style: const TextStyle(
                              color: Color(0xFF211810),
                            ),
                          ),

                          Text(
                            'Estimasi tabung per hari: Rp ${formatRupiah(perHari)}',
                            style: const TextStyle(
                              color: Color(0xFF211810),
                            ),
                          ),

                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF6B4B3E),
        foregroundColor: Colors.white,
        onPressed: tambahTabungan,
        icon: const Icon(Icons.add),
        label: const Text('Celengan'),
      ),
    );
  }
}