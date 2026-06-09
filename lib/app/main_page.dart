import 'package:flutter/material.dart';
import '../kakulator/view/kakulator_view.dart';
import '../core/widgets/app_drawer.dart';
import '../home/view/home_page.dart';
import '../tanggal/view/tanggal_page.dart';
import '../catatan/view/catatan_page.dart';
import '../tabungan/view/tabungan_page.dart';
import '../profile/view/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;

  final List<String> titles = [
    'Home',
    'Tanggal',
    'Catatan',
    'Tabungan',
    'Kalkulator',
    'Profile',
  ];

  final List<Widget> pages = [
    const HomePage(),
    const TanggalPage(),
    const CatatanPage(),
    const TabunganPage(),
    const KalkulatorPage(),
    const ProfilePage(),
  ];

  void changePage(int index) {
    setState(() {
      selectedIndex = index;
    });

    Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FBF6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4FBF6),
        elevation: 0,
        title: Text(
          titles[selectedIndex],
          style: const TextStyle(
            color: Color(0xFF235347),
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(
                Icons.menu_rounded,
                color: Color(0xFF235347),
                size: 30,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: AppDrawer(
        selectedIndex: selectedIndex,
        onMenuTap: changePage,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: pages[selectedIndex],
      ),
    );
  }
}