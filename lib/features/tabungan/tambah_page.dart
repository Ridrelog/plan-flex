import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/services/note_database_service.dart';

class TambahPage extends StatefulWidget {
  final Map<String, dynamic>? item;

  const TambahPage({super.key, this.item});

  @override
  State<TambahPage> createState() => _TambahPageState();
}

class _TambahPageState extends State<TambahPage> {
  final namaController = TextEditingController();
  final targetController = TextEditingController();
  final nominalController = TextEditingController();

  final ImagePicker picker = ImagePicker();

  String? gambarPath;
  String rencana = 'Harian';

  @override
  void initState() {
    super.initState();

    if (widget.item != null) {
      namaController.text = widget.item!['nama'];

      targetController.text =
          (widget.item!['target'] as num).toStringAsFixed(0);

      nominalController.text =
          (widget.item!['terkumpul'] as num).toStringAsFixed(0);

      gambarPath = widget.item!['gambar'];
    }
  }

  Future<void> pilihGambar() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        gambarPath = image.path;
      });
    }
  }

  Future<void> simpanTabungan() async {
    final nama = namaController.text.trim();
    final target = double.tryParse(targetController.text) ?? 0;
    final nominal = double.tryParse(nominalController.text) ?? 0;

    if (nama.isEmpty || target <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data belum lengkap'),
        ),
      );
      return;
    }

    final data = {
      'nama': nama,
      'target': target,
      'terkumpul': nominal,
      'hari': 1,
      'gambar': gambarPath,
    };

    if (widget.item == null) {
      await NoteDatabaseService.instance.insertTabungan(data);
    } else {
      await NoteDatabaseService.instance.updateTabungan(
        widget.item!['id'],
        data,
      );
    }

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    namaController.dispose();
    targetController.dispose();
    nominalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFD6B18B);
    const cardColor = Color(0xFFE7D3B5);
    const orange = Color(0xFF6B4B3E);
    const textColor = Color(0xFF5A4034);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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

                  ElevatedButton(
                    onPressed: simpanTabungan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                    ),
                    child: Text(
                      widget.item == null ? 'Simpan' : 'Update',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              GestureDetector(
                onTap: pilihGambar,
                child: Container(
                  height: 190,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: gambarPath == null
                      ? const Icon(
                          Icons.add_photo_alternate_outlined,
                          color: orange,
                          size: 52,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.file(
                            File(gambarPath!),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 32),

              _inputField(
                icon: Icons.short_text,
                hint: 'Nama Tabungan',
                controller: namaController,
              ),

              const SizedBox(height: 22),

              _inputField(
                icon: Icons.account_balance_wallet_outlined,
                hint: 'Target Tabungan',
                controller: targetController,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 22),

              const Text(
                'Mata Uang',
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 62,
                decoration: BoxDecoration(
                  color: cardColor,
                  border: Border.all(
                    color: Color(0xFF8A6A58),
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Text(
                      '🇮🇩',
                      style: TextStyle(fontSize: 24),
                    ),

                    SizedBox(width: 14),

                    Expanded(
                      child: Text(
                        'Indonesia Rupiah ( Rp )',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    Icon(
                      Icons.keyboard_arrow_down,
                      color: textColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              const Divider(
                color: Color(0xFFB38B6D),
              ),

              const SizedBox(height: 18),

              const Text(
                'Rencana Pengisian',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 18),

              Container(
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF8A6A58),
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  children: [
                    _tabButton('Harian'),
                    _tabButton('Mingguan'),
                    _tabButton('Bulanan'),
                  ],
                ),
              ),

              const SizedBox(height: 38),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: nominalController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        color: textColor,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: cardColor,
                        hintText: 'Nominal Pengisian',
                        hintStyle: const TextStyle(
                          color: Color(0xFF8A6A58),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF8A6A58),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: orange,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFF8A6A58),
                    child: Icon(
                      Icons.event_available,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    const textColor = Color(0xFF5A4034);
    const orange = Color(0xFF6B4B3E);
    const cardColor = Color(0xFFE7D3B5);

    return Row(
      children: [
        Icon(
          icon,
          color: textColor,
        ),

        const SizedBox(width: 22),

        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: textColor,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: cardColor,
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF8A6A58),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF8A6A58),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: orange,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tabButton(String value) {
    final selected = rencana == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            rencana = value;
          });
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF8A6A58)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF5A4034),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}