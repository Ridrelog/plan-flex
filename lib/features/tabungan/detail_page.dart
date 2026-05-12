import 'dart:io';

import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> item;

  const DetailPage({
    super.key,
    required this.item,
  });

  String formatRupiah(num value) {
    return value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFD6B18B);
    const cardColor = Color(0xFFE7D3B5);
    const orange = Color(0xFF6B4B3E);
    const textColor = Color(0xFF5A4034);

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
        backgroundColor: orange,
        onPressed: () {},
        child: const Icon(
          Icons.edit_note,
          color: Colors.white,
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
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: textColor,
                    ),
                  ),

                  const Spacer(),

                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.edit,
                      color: orange,
                    ),
                  ),

                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.delete_outline,
                      color: orange,
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

                    if (gambar != null && gambar.toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.file(
                            File(gambar),
                            height: 360,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(22),
                      ),
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
                                    color: const Color(0xFF8A6A58),
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

                          const Divider(
                            color: Color(0xFFB38B6D),
                          ),

                          const SizedBox(height: 12),

                          _infoRow(
                            'Tanggal Dibuat',
                            '12 Mei',
                          ),

                          const SizedBox(height: 12),

                          _infoRow(
                            'Estimasi',
                            '$hari Hari',
                          ),

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

  Widget _infoRow(String title, String value) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF5A4034),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const Spacer(),

        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF5A4034),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}