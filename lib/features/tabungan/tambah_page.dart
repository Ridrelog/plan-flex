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
    const bgColor = Color(0xFF140D08);
    const cardColor = Color(0xFF5B4B3E);
    const orange = Color(0xFFFFB36B);
    const textColor = Color(0xFFEBDDD1);

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
                      foregroundColor: Colors.black87,
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
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: gambarPath == null
                      ? const Icon(
                          Icons.add_photo_alternate_outlined,
                          color: orange,
                          size: 52,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(14),
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
                ),
              ),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 62,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF9B8678),
                  ),
                  borderRadius: BorderRadius.circular(5),
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
                color: Color(0xFF3A2A20),
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
                height: 44,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF9B8678),
                  ),
                  borderRadius: BorderRadius.circular(24),
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
                      decoration: const InputDecoration(
                        hintText: 'Nominal Pengisian',
                        hintStyle: TextStyle(
                          color: Color(0xFFD6C4B8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF9B8678),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: orange,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFF6B4E35),
                    child: Icon(
                      Icons.event_available,
                      color: textColor,
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
    const textColor = Color(0xFFEBDDD1);
    const orange = Color(0xFFFFB36B);

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
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFFD6C4B8),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFF9B8678),
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: orange,
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
            color: selected ? const Color(0xFF6B4E35) : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFFEBDDD1),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}