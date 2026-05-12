import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TabunganPage extends StatefulWidget {
  const TabunganPage({super.key});

  @override
  State<TabunganPage> createState() => _TabunganPageState();
}

class _TabunganPageState extends State<TabunganPage> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController nominalController = TextEditingController();
  final TextEditingController hariController = TextEditingController();

  final ImagePicker picker = ImagePicker();

  File? gambarBarang;

  String namaBarang = '';
  String nominalBarang = '';
  String jumlahHari = '';

  double nominalValue = 0;
  double tabunganPerHari = 0;

  Future<void> pilihGambar() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        gambarBarang = File(image.path);
      });
    }
  }

  void hapusGambar() {
    setState(() {
      gambarBarang = null;
    });
  }

  void tambahNominal() {
    setState(() {
      nominalValue = double.tryParse(nominalController.text) ?? 0;
      nominalValue += 10000;
      nominalController.text = nominalValue.toStringAsFixed(0);
    });
  }

  void kurangNominal() {
    setState(() {
      nominalValue = double.tryParse(nominalController.text) ?? 0;
      nominalValue -= 10000;

      if (nominalValue < 0) {
        nominalValue = 0;
      }

      nominalController.text = nominalValue.toStringAsFixed(0);
    });
  }

  void simpanData() {
    setState(() {
      namaBarang = namaController.text;

      nominalValue = double.tryParse(nominalController.text) ?? 0;
      nominalBarang = nominalValue.toStringAsFixed(0);

      jumlahHari = hariController.text;

      int hari = int.tryParse(hariController.text) ?? 1;

      if (hari <= 0) {
        hari = 1;
      }

      tabunganPerHari = nominalValue / hari;
    });
  }

  void editData() {
    setState(() {
      namaController.text = namaBarang;
      nominalController.text = nominalBarang;
      hariController.text = jumlahHari;
    });
  }

  @override
  void dispose() {
    namaController.dispose();
    nominalController.dispose();
    hariController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: pilihGambar,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: gambarBarang == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, size: 50),
                            SizedBox(height: 8),
                            Text('Pilih gambar barang'),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            gambarBarang!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                ),
              ),

              if (gambarBarang != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.red,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: hapusGambar,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),

          TextField(
            controller: namaController,
            decoration: const InputDecoration(
              labelText: 'Nama barang',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: nominalController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Nominal barang',
              prefixText: 'Rp ',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: kurangNominal,
                  icon: const Icon(Icons.remove),
                  label: const Text('Kurang'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: tambahNominal,
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          TextField(
            controller: hariController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Target hari',
              suffixText: 'hari',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: simpanData,
                  child: const Text('Simpan'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: editData,
                  child: const Text('Edit'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          if (namaBarang.isNotEmpty ||
              nominalBarang.isNotEmpty ||
              jumlahHari.isNotEmpty ||
              gambarBarang != null)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (gambarBarang != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          gambarBarang!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                    const SizedBox(height: 12),

                    Text(
                      namaBarang,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Harga barang: Rp $nominalBarang',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Target: $jumlahHari hari',
                      style: const TextStyle(fontSize: 18),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Tabung per hari: Rp ${tabunganPerHari.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: pilihGambar,
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit Gambar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: hapusGambar,
                            icon: const Icon(Icons.delete),
                            label: const Text('Hapus'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}