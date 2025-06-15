// lib/features/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/widgets/app_header.dart';
import '../medication/add_medication_screen.dart';
import '../medication/medication_screen.dart';
import '../schedule/schedule_screen.dart';
import '../supplies/supplies_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  // List of screens
  final List<Widget> _screens = [
    const Center(child: Text('Home Dashboard')), // Placeholder for Home content
    const MedicationScreen(),
    const ScheduleScreen(),
    const SuppliesScreen(),
    const SettingsScreen(),
  ];

  // List of AppBar titles
  final List<String> _appBarTitles = [
    AppConstants.homeScreenTitle,
    AppConstants.medicationScreenTitle,
    AppConstants.schedulesScreenTitle,
    AppConstants.suppliesScreenTitle,
    AppConstants.settingsScreenTitle,
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: _appBarTitles[_selectedIndex],
        actions: _selectedIndex == 1 // Add action for MedicationScreen
            ? [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AddMedicationScreen()),
            ),
          ),
        ]
            : null,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.medication), label: 'Medications'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Schedules'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Supplies'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}