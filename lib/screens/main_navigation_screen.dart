import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'tabs/gear_tab.dart';
import 'tabs/kits_tab.dart';
import 'tabs/pack_tab.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onSelectTab(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const GearTab(),
      KitsTab(onNavigateTab: _onSelectTab),
      PackTab(onSwitchToKits: () => _onSelectTab(1)),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: tabs,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.darkNavy,
          border: Border(
            top: BorderSide(color: AppTheme.border, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onSelectTab,
          backgroundColor: AppTheme.darkNavy,
          selectedItemColor: AppTheme.orangeAccent,
          unselectedItemColor: const Color(0xFF8A99A8),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2_rounded),
              label: 'My Gear',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.cases_outlined),
              activeIcon: Icon(Icons.cases_rounded),
              label: 'Activity Kits',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.checklist_rounded),
              activeIcon: Icon(Icons.checklist_rtl_rounded),
              label: 'Checklist',
            ),
          ],
        ),
      ),
    );
  }
}
