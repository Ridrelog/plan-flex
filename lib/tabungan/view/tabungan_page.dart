import 'package:flutter/material.dart';

import '../repository/tabungan_repository.dart';
import '../widgets/tabungan_card.dart';
import 'detail_page.dart';
import 'tambah_page.dart';

class TabunganPage extends StatefulWidget {
  const TabunganPage({super.key});

  @override
  State<TabunganPage> createState() => _TabunganPageState();
}

class _TabunganPageState extends State<TabunganPage> {
  final TabunganRepository repository = TabunganRepository();

  List<Map<String, dynamic>> daftarTabungan = [];

  @override
  void initState() {
    super.initState();
    loadTabungan();
  }

  Future<void> loadTabungan() async {
    final data = await repository.getAllTabungan();

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

  num get totalTerkumpul {
    return daftarTabungan.fold<num>(0, (total, item) {
      return total + ((item['terkumpul'] as num?) ?? 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FBF6),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF4FBF6), Color(0xFFEAF6EE)],
          ),
        ),
        child: daftarTabungan.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFFD7E8DC)),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: Color(0xFFE5F2E9),
                          child: Icon(Icons.savings_rounded, color: Color(0xFF235347), size: 34),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Belum ada celengan',
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(0xFF051F20),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Tekan tombol + Celengan untuk membuat target tabungan baru.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF56746B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: loadTabungan,
                color: const Color(0xFF235347),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: daftarTabungan.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF235347), Color(0xFF8EB69B)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF235347).withOpacity(0.20),
                              blurRadius: 22,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF235347), size: 30),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total Terkumpul',
                                    style: TextStyle(color: Color(0xFFE9F6EE), fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rp ${formatRupiah(totalTerkumpul)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 23,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    '${daftarTabungan.length} celengan aktif',
                                    style: const TextStyle(color: Color(0xFFE9F6EE), fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final item = daftarTabungan[index - 1];

                    return TabunganCard(
                      item: item,
                      onTap: () => bukaDetail(item),
                      formatRupiah: formatRupiah,
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: tambahTabungan,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Celengan',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
