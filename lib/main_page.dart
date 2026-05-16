import 'package:flutter/material.dart';
import 'package:plan_flex/features/kakulator/kakulator_view.dart';
import 'core/widgets/app_drawer.dart';
import 'features/home/home_page.dart';
import 'features/tanggal/tanggal_page.dart';
import 'features/catatan/catatan_page.dart';
import 'features/tabungan/tabungan_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;

  final List<String> titles = ['Home', 'Tanggal', 'Catatan', 'Tabungan', 'Kalkulator'];

  final List<Widget> pages = [
    const HomePage(),
    const TanggalPage(),
    const CatatanPage(),
    const TabunganPage(),
    const KalkulatorPage(),
  ];

  void changePage(int index) {
    setState(() {
      selectedIndex = index;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titles[selectedIndex])),
      drawer: AppDrawer(selectedIndex: selectedIndex, onMenuTap: changePage),
      body: pages[selectedIndex],
    );
  }
}
