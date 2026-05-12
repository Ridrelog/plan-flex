import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/services/note_database_service.dart';
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

  Future<void> editTabungan(Map<String, dynamic> item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TambahPage(item: item),
      ),
    );

    if (result == true) {
      loadTabungan();
    }
  }

  Future<void> tambahSaldo(Map<String, dynamic> item) async {
    await showSaldoDialog(item, true);
  }

  Future<void> kurangSaldo(Map<String, dynamic> item) async {
    await showSaldoDialog(item, false);
  }

  Future<void> showSaldoDialog(Map<String, dynamic> item, bool tambah) async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(tambah ? 'Tambah Tabungan' : 'Kurangi Tabungan'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Nominal',
              prefixText: 'Rp ',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final nominal = double.tryParse(controller.text) ?? 0;
                double saldo = (item['terkumpul'] as num).toDouble();

                if (tambah) {
                  saldo += nominal;
                } else {
                  saldo -= nominal;

                  if (saldo < 0) {
                    saldo = 0;
                  }
                }

                await NoteDatabaseService.instance.updateTabungan(
                  item['id'],
                  {
                    'nama': item['nama'],
                    'target': item['target'],
                    'terkumpul': saldo,
                    'hari': item['hari'],
                    'gambar': item['gambar'],
                  },
                );

                if (!mounted) return;

                Navigator.pop(context);
                loadTabungan();
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    controller.dispose();
  }

  Future<void> hapusTabungan(int id) async {
    await NoteDatabaseService.instance.deleteTabungan(id);
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
      body: daftarTabungan.isEmpty
          ? const Center(
              child: Text(
                'Belum ada celengan',
                style: TextStyle(fontSize: 18),
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

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
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
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),

                        const SizedBox(height: 12),

                        Text(
                          item['nama'],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Rp ${formatRupiah(terkumpul)} / Rp ${formatRupiah(target)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 10),

                        LinearProgressIndicator(
                          value: progress.clamp(0, 1),
                          minHeight: 12,
                          borderRadius: BorderRadius.circular(20),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          '${persen.toStringAsFixed(0)}% terkumpul',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          sisa <= 0
                              ? 'Target sudah tercapai!'
                              : 'Sisa: Rp ${formatRupiah(sisa)}',
                        ),

                        Text(
                          'Estimasi tabung per hari: Rp ${formatRupiah(perHari)}',
                        ),

                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => tambahSaldo(item),
                                icon: const Icon(Icons.add),
                                label: const Text('Tambah'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => kurangSaldo(item),
                                icon: const Icon(Icons.remove),
                                label: const Text('Kurang'),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => editTabungan(item),
                                icon: const Icon(Icons.edit),
                                label: const Text('Edit'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => hapusTabungan(item['id']),
                                icon: const Icon(Icons.delete),
                                label: const Text('Hapus'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: tambahTabungan,
        icon: const Icon(Icons.add),
        label: const Text('Celengan'),
      ),
    );
  }
}