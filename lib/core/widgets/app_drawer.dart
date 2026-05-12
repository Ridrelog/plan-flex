import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onMenuTap;

  const AppDrawer({
    super.key,
    required this.selectedIndex,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFDDB892),

      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,

          children: [
            // ===== HEADER ===== //

            Container(
              width: double.infinity,

              padding: const EdgeInsets.only(
                top: 30,
                left: 20,
                bottom: 24,
              ),

              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,

                  colors: [
                    Color(0xFFF5E6CC),
                    Color(0xFFDDB892),
                  ],
                ),
              ),

              child: const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // ICON APP

                  CircleAvatar(
                    radius: 32,

                    backgroundColor:
                        Colors.white,

                    child: Icon(
                      Icons.all_inbox,

                      color:
                          Color(0xFF6D4C41),

                      size: 34,
                    ),
                  ),

                  SizedBox(height: 14),

                  // TITLE

                  Text(
                    'Plan Flex',

                    style: TextStyle(
                      color:
                          Color(0xFF5D4037),

                      fontSize: 26,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 4),

                  // SUBTITLE

                  Text(
                    'Internet Monitoring',

                    style: TextStyle(
                      color:
                          Color(0xFF8D6E63),

                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ===== MENU ===== //

            drawerItem(
              icon: Icons.home,
              title: 'Home',
              selected: selectedIndex == 0,
              onTap: () => onMenuTap(0),
            ),

            drawerItem(
              icon: Icons.calendar_month,
              title: 'Tanggal',
              selected: selectedIndex == 1,
              onTap: () => onMenuTap(1),
            ),

            drawerItem(
              icon: Icons.note,
              title: 'Catatan',
              selected: selectedIndex == 2,
              onTap: () => onMenuTap(2),
            ),

            drawerItem(
              icon: Icons.savings,
              title: 'Tabungan',
              selected: selectedIndex == 3,
              onTap: () => onMenuTap(3),
            ),


            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ===== ITEM MENU ===== //

  Widget drawerItem({
    required IconData icon,
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),

      child: Material(
        color: selected
            ? const Color(0xFFF5E6CC)
                .withOpacity(0.8)
            : Colors.transparent,

        borderRadius:
            BorderRadius.circular(14),

        child: ListTile(
          leading: Icon(
            icon,

            color: selected
                ? const Color(0xFF5D4037)
                : const Color(0xFF6D4C41),
          ),

          title: Text(
            title,

            style: TextStyle(
              color: selected
                  ? const Color(0xFF5D4037)
                  : const Color(0xFF6D4C41),

              fontWeight: selected
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),

          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),

          onTap: onTap,
        ),
      ),
    );
  }
}