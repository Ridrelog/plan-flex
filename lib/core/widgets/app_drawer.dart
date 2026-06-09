import 'dart:io';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../auth/repository/auth_repository.dart';

class AppDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onMenuTap;

  const AppDrawer({
    super.key,
    required this.selectedIndex,
    required this.onMenuTap,
  });

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Text('Apakah kamu yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await AuthRepository().logout();

    if (context.mounted) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final width = math.min(MediaQuery.of(context).size.width * 0.84, 330.0);

    return Drawer(
      width: width,
      backgroundColor: const Color(0xFFF4FBF6),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
          children: [
            _DrawerHeader(
              user: user,
              onTap: () => onMenuTap(5),
            ),
            const SizedBox(height: 18),
            drawerItem(
              icon: Icons.home_rounded,
              title: 'Home',
              selected: selectedIndex == 0,
              onTap: () => onMenuTap(0),
            ),
            drawerItem(
              icon: Icons.calendar_month_rounded,
              title: 'Tanggal',
              selected: selectedIndex == 1,
              onTap: () => onMenuTap(1),
            ),
            drawerItem(
              icon: Icons.sticky_note_2_rounded,
              title: 'Catatan',
              selected: selectedIndex == 2,
              onTap: () => onMenuTap(2),
            ),
            drawerItem(
              icon: Icons.savings_rounded,
              title: 'Tabungan',
              selected: selectedIndex == 3,
              onTap: () => onMenuTap(3),
            ),
            drawerItem(
              icon: Icons.calculate_rounded,
              title: 'Kalkulator',
              selected: selectedIndex == 4,
              onTap: () => onMenuTap(4),
            ),
            drawerItem(
              icon: Icons.person_rounded,
              title: 'Profile',
              selected: selectedIndex == 5,
              onTap: () => onMenuTap(5),
            ),
            const SizedBox(height: 14),
            const Divider(color: Color(0xFFD7E8DC)),
            const SizedBox(height: 8),
            drawerItem(
              icon: Icons.logout_rounded,
              title: 'Logout',
              selected: false,
              isDanger: true,
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget drawerItem({
    required IconData icon,
    required String title,
    required bool selected,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    final activeColor = isDanger ? Colors.red.shade600 : const Color(0xFF235347);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE5F2E9) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? const Color(0xFF8EB69B) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF235347) : Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: selected ? Colors.white : activeColor,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDanger ? Colors.red.shade600 : const Color(0xFF051F20),
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  final User? user;
  final VoidCallback onTap;

  const _DrawerHeader({
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return _HeaderContent(
        displayName: 'Plan Flex User',
        email: 'Belum login',
        firstLetter: 'P',
        photoPath: null,
        onTap: onTap,
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final firestoreName = data?['name']?.toString().trim();
        final firebaseName = user!.displayName?.trim();
        final displayName = (firebaseName != null && firebaseName.isNotEmpty)
            ? firebaseName
            : (firestoreName != null && firestoreName.isNotEmpty)
                ? firestoreName
                : 'Plan Flex User';
        final email = user!.email ?? data?['email']?.toString() ?? 'Tidak ada email';
        final photoPath = data?['photoPath']?.toString();
        final firstLetter = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'P';
        final hasLocalPhoto = photoPath != null && photoPath.trim().isNotEmpty && File(photoPath).existsSync();

        return _HeaderContent(
          displayName: displayName,
          email: email,
          firstLetter: firstLetter,
          photoPath: hasLocalPhoto ? photoPath : null,
          onTap: onTap,
        );
      },
    );
  }
}

class _HeaderContent extends StatelessWidget {
  final String displayName;
  final String email;
  final String firstLetter;
  final String? photoPath;
  final VoidCallback onTap;

  const _HeaderContent({
    required this.displayName,
    required this.email,
    required this.firstLetter,
    required this.photoPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF235347), Color(0xFF8EB69B)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF235347).withOpacity(0.22),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                backgroundImage: photoPath != null ? FileImage(File(photoPath!)) : null,
                child: photoPath == null
                    ? Text(
                        firstLetter,
                        style: const TextStyle(
                          color: Color(0xFF235347),
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFE9F6EE),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Lihat Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
