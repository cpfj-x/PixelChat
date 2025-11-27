import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'groups_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const Color primary = Color(0xFF7A5AF8); // PixelChat Purple

  final List<Widget> _screens = const [
    HomeScreen(),
    GroupsScreen(),
    SettingsScreen(),
  ];

  void _onTap(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _screens[_selectedIndex],
      ),

      bottomNavigationBar: _bottomNavBar(),
    );
  }

  // ---------------- BOTTOM NAV STYLE WHATSAPP ----------------
  Widget _bottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onTap,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primary,
      unselectedItemColor: Colors.grey.shade600,
      backgroundColor: Colors.white,

      items: [
        BottomNavigationBarItem(
          icon: Icon(
            _selectedIndex == 0
                ? Icons.chat_bubble
                : Icons.chat_bubble_outline,
          ),
          label: "Chats",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            _selectedIndex == 1
                ? Icons.group
                : Icons.group_outlined,
          ),
          label: "Grupos",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            _selectedIndex == 2
                ? Icons.settings
                : Icons.settings_outlined,
          ),
          label: "Config",
        ),
      ],
    );
  }
}
